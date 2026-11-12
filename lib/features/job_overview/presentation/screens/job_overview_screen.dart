import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../main.dart' show userID;
import '../../../customer_details/data/models/customer_details_model.dart';
import '../../data/models/job_overview_model.dart';
import '../providers/job_overview_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';

// ─── Job request timer helpers ──────────────────────────────────────────────
import '../../../../core/services/job_closed.dart';
export '../../../../core/services/job_closed.dart' show kJobRequestWindowSeconds;

int? parseSentTimeMs(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

Duration jobTimeRemaining(int? sentTimeMs) {
  const window = Duration(seconds: kJobRequestWindowSeconds);
  if (sentTimeMs == null) return window;
  var elapsedMs = DateTime.now().millisecondsSinceEpoch - sentTimeMs;
  if (elapsedMs < 0) elapsedMs = 0;
  return window - Duration(milliseconds: elapsedMs);
}

int jobSecondsLeft(int? sentTimeMs) =>
    (jobTimeRemaining(sentTimeMs).inMilliseconds / 1000).ceil();

String formatCountdown(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final m = (s ~/ 60).toString().padLeft(2, '0');
  final r = (s % 60).toString().padLeft(2, '0');
  return '$m:$r';
}

void showJobExpiredToast() {
  AppSnackBar.error(L10n.current.jobExpired, title: L10n.current.warningTitle);
}

// ─── JobOverviewScreen ────────────────────────────────────────────────────────

class JobOverviewScreen extends StatefulWidget {
  final JobOverviewData job;
  const JobOverviewScreen({super.key, required this.job});

  @override
  State<JobOverviewScreen> createState() => _JobOverviewScreenState();
}

class _JobOverviewScreenState extends State<JobOverviewScreen> {
  static const Color _green = AppColors.success;
  static const Color _orange = AppColors.warning;
  static const Color _reject = AppColors.accent;
  static const Color _blue = AppColors.primaryPressed;

  late final JobOverviewController _controller;
  late JobOverviewData _job;

  Timer? _timer;
  int? _secondsLeft;
  bool _expiredHandled = false;
  BuildContext? _sheetCtx;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createJobOverviewController();
    _job = widget.job;
    _startCountdown();
    // A new job offer closes here too when another partner accepts it.
    if (_job.sentTimeMs != null) {
      _closedSub = JobClosed.stream.listen((id) {
        if (_ids.contains(id)) _handleExpired(takenByOther: true);
      });
      if (_ids.any(JobClosed.isClosed)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _handleExpired(takenByOther: true));
      }
    }
  }

  StreamSubscription<String>? _closedSub;

  Set<String> get _ids {
    final raw = _job.rawApiData;
    return {
      _job.id,
      ...[raw['RequestID'], raw['RequestId'], raw['_id']].whereType<Object>().map((e) => e.toString()),
    }..remove('');
  }

  @override
  void dispose() {
    _closedSub?.cancel();
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startCountdown() {
    final sent = _job.sentTimeMs;
    if (sent == null) return;

    _secondsLeft = jobSecondsLeft(sent);
    if (_secondsLeft! <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleExpired());
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final left = jobSecondsLeft(_job.sentTimeMs);
    if (left <= 0) {
      _timer?.cancel();
      _handleExpired();
      return;
    }
    if (left != _secondsLeft) setState(() => _secondsLeft = left);
  }

  bool get _isExpired =>
      _job.sentTimeMs != null && jobSecondsLeft(_job.sentTimeMs) <= 0;

  void _handleExpired({bool takenByOther = false}) {
    if (_expiredHandled || !mounted) return;
    if (_controller.isAccepting || _controller.isRejecting) return;
    _expiredHandled = true;
    _timer?.cancel();
    setState(() => _secondsLeft = 0);

    final sheet = _sheetCtx;
    if (sheet != null && sheet.mounted) Navigator.of(sheet).pop();

    takenByOther
        ? AppSnackBar.error(L10n.current.jobTakenByOther, title: L10n.current.warningTitle)
        : showJobExpiredToast();
    Navigator.of(context).maybePop();
  }

  Future<void> _onAccept() async {
    if (_job.id.isEmpty) return;
    if (_isExpired) {
      _handleExpired();
      return;
    }

    final success = await _controller.acceptJob(
      partnerId: userID,
      jobId: _job.id,
      serviceId: _job.serviceId,
    );

    if (!mounted) return;

    if (success) {
      AppSnackBar.success(context.l10n.jobAcceptedSuccess);
      final customerDetails = CustomerDetails.fromJobOverview(
        _job,
        _job.rawApiData,
        nextStep: _job.nextStep,
      );
      context.push(AppRoutes.customerDetails, extra: customerDetails);
    } else {
      AppSnackBar.error(_controller.errorMessage ?? context.l10n.jobAcceptFailed);
    }
  }

  void _onReject() {
    if (_isExpired) {
      _handleExpired();
      return;
    }
    _showRejectSheet();
  }

  void _showRejectSheet() {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          _sheetCtx = ctx;
          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.jobRejectReasonTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: reasonController,
                      maxLines: 4,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.text),
                      decoration: InputDecoration(
                        hintText:
                            context.l10n.jobRejectReasonHint,
                        hintStyle:
                            const TextStyle(fontSize: 13, color: AppColors.textDisabled),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _controller.isRejecting
                          ? null
                          : () async {
                              final reason = reasonController.text.trim();
                              if (reason.isEmpty) {
                                AppSnackBar.error(context.l10n.enterReason);
                                return;
                              }

                              final success = await _controller.rejectJob(
                                partnerId: userID,
                                jobId: _job.id,
                                reason: reason,
                              );

                              if (!mounted || !ctx.mounted) return;

                              if (success) {
                                Navigator.pop(ctx);
                                AppSnackBar.success(L10n.current.jobRejected);
                                Navigator.maybePop(context);
                              } else {
                                AppSnackBar.error(_controller.errorMessage ??
                                    context.l10n.jobRejectFailed);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        disabledBackgroundColor: _blue.withOpacity(0.6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: _controller.isRejecting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              context.l10n.commonSubmit,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() => _sheetCtx = null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
 top: false,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroImage(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleRow(),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDateRow(),
                                  if (_secondsLeft != null) ...[
                                    const SizedBox(height: 10),
                                    _buildTimerRow(),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInstantBadge(),
                              const SizedBox(height: 20),
                              _buildDivider(),
                              if (_job.aboutPoints.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                _buildAboutService(),
                                const SizedBox(height: 20),
                                _buildDivider(),
                              ],
                              const SizedBox(height: 20),
                              _buildServiceBookedBy(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AppTopBar(title: context.l10n.overviewTitle);
  }

  Widget _buildHeroImage() {
    return SizedBox(
      width: double.infinity,
      height: 220,
      child: AppNetworkImage(
        url: _job.imageUrl,
        width: double.infinity,
        height: 220,
        fallback: _imageFallback(),
      ),
    );
  }

  Widget _imageFallback() {
    return Image.asset('assets/images/job_banner.webp');
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            _job.title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '₹${_job.amount.toInt()}',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text),
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    return Text(
      _job.dateTime,
      style: const TextStyle(fontSize: 13, color: AppColors.textDisabled),
    );
  }

  Widget _buildTimerRow() {
    final left = _secondsLeft ?? 0;
    final color = left <= 10 ? Colors.red : AppColors.success;
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          formatCountdown(left),
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }

  Widget _buildInstantBadge() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: _orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _orange.withOpacity(0.3))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 5),
              Text(context.l10n.instantLabel,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _orange)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _job.etaLabel,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAboutService() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.aboutService,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text),
        ),
        const SizedBox(height: 12),
        ..._job.aboutPoints.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceBookedBy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.serviceBookedBy,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(context.l10n.labelName, _job.customerName),
        if (_job.customerPhone.isNotEmpty)
          _buildInfoRow(context.l10n.labelPhone, _job.customerPhone),
        if (_job.customerEmail.isNotEmpty)
          _buildInfoRow(context.l10n.labelEmail, _job.customerEmail),
        _buildLocationRow(),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textDisabled)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 90,
              child: Text(context.l10n.labelLocation,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.textDisabled)),
            ),
            const Spacer(),
            _buildDistanceBadge(_job.distance),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _job.address,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceBadge(String distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.success],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.location_on, size: 11, color: Colors.white),
          ),
          const SizedBox(width: 5),
          Text(
            context.l10n.jobDistanceKm(distance),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(height: 1, color: AppColors.background);

  Widget _buildBottomButtons() {
    final isBusy = _controller.isAccepting || _controller.isRejecting;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.background)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isBusy ? null : _onAccept,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: _controller.isAccepting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        context.l10n.jobAccept,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: isBusy ? null : _onReject,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _reject, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  context.l10n.jobReject,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _reject),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

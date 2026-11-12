import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../job_overview/data/models/job_overview_model.dart';
import '../../../job_overview/presentation/screens/job_overview_screen.dart';
import '../../domain/entities/notification_popup_config.dart';
import '../providers/notification_popup_controller.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/design/app_tokens.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class NotificationPopup extends StatelessWidget {
  final NotificationPopupController controller;
  final VoidCallback onAcceptConfirmed;
  final VoidCallback onRejectReasonSubmitted;

  const NotificationPopup({
    super.key,
    required this.controller,
    required this.onAcceptConfirmed,
    required this.onRejectReasonSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.visible || controller.config == null) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            GestureDetector(
              onTap: controller.close,
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: _buildStep(context),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (controller.step) {
      case PopupStep.jobDetail:
        return _JobDetailPopup(
          key: const ValueKey('detail'),
          config: controller.config!,
          timeLeft: controller.timeLeft,
          onAccept: () => controller.goTo(PopupStep.confirmAccept),
          onReject: () => controller.goTo(PopupStep.confirmReject),
          onClose: controller.close,
          onDetails: () {
            final config = controller.config;
            final mappedJobData = JobOverviewData.fromApi(config?.apiData, config?.apiData ?? {});
            context.push(AppRoutes.jobOverview, extra: mappedJobData);
          },
        );

      case PopupStep.confirmAccept:
        return _ConfirmPopup(
          key: const ValueKey('accept'),
          title: context.l10n.jobAcceptTitle,
          message: context.l10n.jobAcceptMessage,
          confirmColor: AppColors.success,
          confirmTextColor: Colors.white,
          confirmBorderColor: AppColors.success,
          isSubmitting: controller.isSubmitting,
          onYes: onAcceptConfirmed,
          onNo: () => controller.goTo(PopupStep.jobDetail),
        );

      case PopupStep.confirmReject:
        return _ConfirmPopup(
          key: const ValueKey('reject'),
          title: context.l10n.jobRejectTitle,
          message: context.l10n.jobRejectMessage,
          confirmColor: AppColors.accent,
          confirmTextColor: Colors.white,
          confirmBorderColor: AppColors.accent,
          isSubmitting: controller.isSubmitting,
          onYes: () => controller.goTo(PopupStep.rejectReason),
          onNo: () => controller.goTo(PopupStep.jobDetail),
        );

      case PopupStep.rejectReason:
        return _RejectReasonPopup(
          key: const ValueKey('reason'),
          controller: controller.rejectReasonController,
          isSubmitting: controller.isSubmitting,
          onBack: () => controller.goTo(PopupStep.confirmReject),
          onSubmit: onRejectReasonSubmitted,
        );
    }
  }
}

class _JobDetailPopup extends StatelessWidget {
  final PopupConfig config;
  final int timeLeft;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onClose;
  final VoidCallback onDetails;

  const _JobDetailPopup({
    super.key,
    required this.config,
    required this.timeLeft,
    required this.onAccept,
    required this.onReject,
    required this.onClose,
    required this.onDetails,
  });


  Widget _buildPlaceholder() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Image.asset('assets/images/job_banner.webp', fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final services = config.services;
    final pricing = config.pricing;

    final totalAmount = pricing['totalAmount']?.toString() ?? '';
    final finalAmount = pricing['finalAmount']?.toString() ?? '';

    final firstService = services.isNotEmpty
        ? services.first['Name'] ?? l10n.jobServiceRequest
        : l10n.jobServiceRequest;

    final totalPrice = finalAmount.isNotEmpty
        ? finalAmount
        : totalAmount.isNotEmpty
        ? totalAmount
        : '0';

    final String imageUrl = config.apiData?['ServiceImage']?.toString() ??
        config.apiData?['Image']?.toString() ?? '';
    final String avatarUrl = config.apiData?['CustomerProfileImage']?.toString() ?? '';
    final bool urgent = timeLeft <= 10;
    final customerName = config.customerName.isNotEmpty ? config.customerName : l10n.jobCustomer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.sheet),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(18, 10, 6, 10),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_outlined, size: 22, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.jobNotificationTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                Semantics(
                  label: l10n.jobTimeLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: urgent ? AppColors.accent : Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 15, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          formatCountdown(timeLeft),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonClose,
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // ── Service image ───────────────────────────────────────────────
          AppNetworkImage(
            url: imageUrl,
            height: 160,
            width: double.infinity,
            fallback: Container(
              height: 160,
              color: AppColors.primaryTint,
              child: _buildPlaceholder(),
            ),
          ),

          // ── Details ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        firstService,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '₹$totalPrice',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${config.formattedDate} | ${config.timeSlot}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: AppNetworkImage(
                          url: avatarUrl,
                          width: 40,
                          height: 40,
                          fallback: Container(
                            width: 40,
                            height: 40,
                            color: AppColors.primary,
                            alignment: Alignment.center,
                            child: Text(
                              config.customerName.isNotEmpty ? config.customerName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                        ),
                      ),
                      const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        l10n.jobDistanceKm('${config.apiData?['Distance'] ?? 'N/A'}'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: l10n.jobAccept,
                        color: AppColors.success,
                        textColor: Colors.white,
                        borderColor: AppColors.success,
                        onTap: onAccept,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionBtn(
                        label: l10n.jobReject,
                        color: AppColors.accentTint,
                        textColor: AppColors.accentPressed,
                        borderColor: AppColors.accentTint,
                        onTap: onReject,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionBtn(
                        label: l10n.jobDetails,
                        color: Colors.white,
                        textColor: AppColors.primary,
                        borderColor: AppColors.primary,
                        onTap: onDetails,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: AppRadii.buttonAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.buttonAll,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: AppRadii.buttonAll,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmPopup extends StatelessWidget {
  final String title;
  final String message;
  final Color confirmColor;
  final Color confirmTextColor;
  final Color confirmBorderColor;
  final bool isSubmitting;
  final VoidCallback onYes;
  final VoidCallback onNo;

  const _ConfirmPopup({
    super.key,
    required this.title,
    required this.message,
    required this.confirmColor,
    required this.confirmTextColor,
    required this.confirmBorderColor,
    required this.isSubmitting,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.sheet),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: isSubmitting ? context.l10n.jobWait : context.l10n.commonYes,
                  color: confirmColor,
                  textColor: confirmTextColor,
                  borderColor: confirmBorderColor,
                  onTap: isSubmitting ? () {} : onYes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionBtn(
                  label: context.l10n.commonNo,
                  color: Colors.white,
                  textColor: AppColors.textMuted,
                  borderColor: AppColors.borderStrong,
                  onTap: isSubmitting ? () {} : onNo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RejectReasonPopup extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const _RejectReasonPopup({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.sheet),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: isSubmitting ? null : onBack,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.arrow_back_rounded, color: AppColors.ink, size: 24),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.jobRejectionReason,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(fontSize: 15, color: AppColors.text),
              decoration: InputDecoration(
                filled: false,
                hintText: context.l10n.jobRejectionHint,
                hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: isSubmitting ? context.l10n.jobSubmitting : context.l10n.commonSubmit,
                  color: AppColors.primary,
                  textColor: Colors.white,
                  borderColor: AppColors.primary,
                  onTap: isSubmitting ? () {} : onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

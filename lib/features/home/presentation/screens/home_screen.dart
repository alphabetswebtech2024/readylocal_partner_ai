// lib/screens/home/HomeScreen.dart

import 'package:gotask_partner/features/home/data/repositories/home_repository_impl.dart' show kHomeNetworkFailure;
import 'dart:developer';
import 'package:gotask_partner/core/design/job_alerts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_on_it/focus_on_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/User.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../../../main.dart'
    show
        getRequestDetailsMethod,
        getDynamicDistance,
        userID,
        analytics,
        user,
        userFirstName,
        userLastName,
        userEmail,
        userPhone,
        isGuestUser;
import '../../../../core/utils/AppConstants.dart' show deviceId;
import '../../../customer_details/data/models/customer_details_model.dart';
import '../../../job_overview/data/models/job_overview_model.dart';
import '../../domain/entities/earnings_data_entity.dart';
import '../../domain/entities/home_stats_entity.dart';
import '../../domain/entities/job_item_entity.dart';
import '../providers/home_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/design/app_tokens.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

// ─── Aliases for Backwards Compatibility ────────────────────────────────────
typedef HomeStats = HomeStatsEntity;
typedef EarningsData = EarningsDataEntity;
typedef JobItem = JobItemEntity;

// ─── HomeScreen ─────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? args;
  const HomeScreen({super.key, this.args});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final HomeController _controller;
  late final TabController _tabController;

  String _selectedJobTab = 'Ongoing';
  String _selectedEarningPeriod = 'Daily';
  bool _isDetailsLoading = false;

  static const Color _green = AppColors.success;
  static const Color _orange = AppColors.accent;
  static const Color _blue = AppColors.primary;
  static const Color _surfaceBg = AppColors.background;

  @override
  void initState() {
    super.initState();

    _controller = ServiceLocator.createHomeController();

    final onlineArg = widget.args?["_isOnline"];
    if (onlineArg != null) {
      _controller.setInitialOnlineStatus(onlineArg as bool);
    }

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedJobTab = _tabController.index == 0 ? 'Ongoing' : 'Completed';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final success = await _controller.loadDashboard(deviceToken: deviceId);

    if (_controller.user != null) {
      final u = _controller.user!;
      user = u;
      userID = u.id.toString();
      userFirstName = u.FirstName;
      userLastName = u.LastName;
      userEmail = u.email;
      userPhone = u.phone;
      isGuestUser = "false";
      analytics.setUserId(id: u.id.toString());
      analytics.setUserProperty(name: "email", value: u.email);
      analytics.setUserProperty(name: "phone", value: u.phone);
    }

    // A weak or lost connection keeps the partner signed in (they would
    // otherwise need a new OTP and could miss jobs); only a server refusal logs out.
    if (!success && _controller.errorMessage == kHomeNetworkFailure) {
      if (mounted) AppSnackBar.error(context.l10n.netNoInternet);
      return;
    }

    if (!success && _controller.errorMessage != null) {
      if (mounted) {
        AppSnackBar.error(
          context.l10n.homeSessionErrorMessage,
          title: context.l10n.homeSessionErrorTitle,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) {
          context.go(AppRoutes.intro);
        }
      }
    }
  }

  Future<void> _handleToggleOnline() async {
    final updated = await _controller.toggleOnlineStatus();
    if (updated) {
      AppSnackBar.success(
        _controller.isOnline ? L10n.current.homeYouAreOnline : L10n.current.homeYouAreOffline,
      );
    } else if (_controller.errorMessage != null) {
      AppSnackBar.error(_controller.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return FocusOnIt(
          onFocus: () {
            log('HomeScreen gained focus via FocusOnIt - Reloading data');
            _loadDashboardData();
          },
          child: CommonLoadingOverlay(
            isLoading: (_controller.isLoading && !_controller.hasDashboard) || _isDetailsLoading,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: Scaffold(
                backgroundColor: _surfaceBg,
                body: RefreshIndicator(
                  color: _blue,
                  onRefresh: _loadDashboardData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildHeader(_controller.user),
                            Positioned(
                              left: AppSpacing.md,
                              right: AppSpacing.md,
                              bottom: -44,
                              child: _buildStatsRow(_controller.stats),
                            ),
                          ],
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 44)),
                      const SliverToBoxAdapter(child: JobAlertsNotice()),
                      SliverToBoxAdapter(child: _buildEarningsCard(_controller.earnings)),
                      SliverToBoxAdapter(
                        child: _buildJobsSection(
                          _controller.ongoingJobs,
                          _controller.completedJobs,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(User? currentUser) {
    final l10n = context.l10n;
    final userName = currentUser != null
        ? '${currentUser.FirstName} ${currentUser.LastName}'.trim()
        : '';
    final location = currentUser != null
        ? '${currentUser.City}, ${currentUser.State}'
        : l10n.homeLocationFallback;
    final avatarUrl = currentUser?.Avatar ?? '';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Container(
      decoration: AppDecorations.brandHeader,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.paddingOf(context).top + AppSpacing.md,
        AppSpacing.lg,
        64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: l10n.homeOpenProfile,
                child: GestureDetector(
                  onTap: () {
                    context.push(AppRoutes.profile);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                    ),
                    child: ClipOval(
                      child: AppNetworkImage(
                        url: avatarUrl,
                        width: 44,
                        height: 44,
                        fallback: Container(
                          color: AppColors.primaryTint,
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: _blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeWelcomeBack,
                      style: const TextStyle(fontSize: 13, color: AppColors.onPrimaryMuted),
                    ),
                    Text(
                      currentUser?.FirstName.isNotEmpty == true
                          ? (userName.isNotEmpty ? userName : currentUser!.FirstName)
                          : l10n.homeWelcomeName(''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _buildOnlineToggle(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.onPrimaryMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.onPrimaryMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineToggle() {
    final isOnline = _controller.isOnline;
    final isToggling = _controller.isTogglingStatus;
    final l10n = context.l10n;
    final trackColor = isOnline ? _green : AppColors.textDisabled;

    return Semantics(
      button: true,
      toggled: isOnline,
      label: l10n.homeOnlineToggleHint,
      child: GestureDetector(
        onTap: isToggling ? null : _handleToggleOnline,
        child: Container(
          height: 40,
          padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isOnline ? l10n.statusOnline : l10n.statusOffline,
                style: TextStyle(
                  color: isOnline ? _green : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              AnimatedContainer(
                duration: AppSizes.normal,
                width: 44,
                height: 28,
                padding: const EdgeInsets.all(3),
                alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: isToggling
                      ? Padding(
                          padding: const EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(trackColor),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(HomeStatsEntity stats) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xxs),
      decoration: AppDecorations.card(shadow: true),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatCard(l10n.homeTotalRequest, stats.totalAssigned, _blue),
            const VerticalDivider(width: 1, color: AppColors.border),
            _buildStatCard(l10n.statusOngoing, stats.accepted, _orange),
            const VerticalDivider(width: 1, color: AppColors.border),
            _buildStatCard(l10n.statusCompleted, stats.completed, _green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(EarningsDataEntity earnings) {
    final l10n = context.l10n;
    double displayAmount = 0;
    int displayJobs = 0;
    String displayTitle;
    String jobsLabel;

    if (_selectedEarningPeriod == 'Weekly') {
      displayAmount = earnings.weeklyEarnings;
      displayJobs = earnings.weeklyJobs;
      displayTitle = l10n.homeWeeklyEarning;
      jobsLabel = l10n.homeJobsThisWeek(displayJobs);
    } else if (_selectedEarningPeriod == 'Monthly') {
      displayAmount = earnings.monthlyEarnings;
      displayJobs = earnings.monthlyJobs;
      displayTitle = l10n.homeMonthlyEarning;
      jobsLabel = l10n.homeJobsThisMonth(displayJobs);
    } else {
      displayAmount = earnings.todayEarnings;
      displayJobs = earnings.todayJobs;
      displayTitle = l10n.homeTodaysEarning;
      jobsLabel = l10n.homeJobsToday(displayJobs);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
        decoration: AppDecorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: l10n.homeEarnings,
              actionLabel: l10n.commonViewAll,
              onAction: () {
                context.push(AppRoutes.earnings);
              },
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${displayAmount % 1 == 0 ? displayAmount.toInt() : displayAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        jobsLabel,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildPeriodDropdown(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(String period) {
    final l10n = context.l10n;
    switch (period) {
      case 'Weekly':
        return l10n.periodWeekly;
      case 'Monthly':
        return l10n.periodMonthly;
      default:
        return l10n.periodDaily;
    }
  }

  Widget _buildPeriodDropdown() {
    // Values stay in English (they drive the logic above); only labels translate.
    const periods = ['Daily', 'Weekly', 'Monthly'];
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEarningPeriod,
          isDense: true,
          borderRadius: BorderRadius.circular(AppRadii.input),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
          style: const TextStyle(
            fontFamily: AppFonts.sans,
            fontFamilyFallback: AppFonts.fallback,
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: periods
              .map((p) => DropdownMenuItem(value: p, child: Text(_periodLabel(p))))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedEarningPeriod = val);
          },
        ),
      ),
    );
  }

  Widget _buildJobsSection(
    List<JobItemEntity> ongoingJobs,
    List<JobItemEntity> completedJobs,
  ) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: l10n.homeJobs,
            actionLabel: l10n.commonViewAll,
            onAction: () {
              context.push(AppRoutes.jobsList);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildJobTabBar(),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: AppSizes.normal,
            child: _selectedJobTab == 'Ongoing'
                ? _buildOngoingJobsList(ongoingJobs)
                : _buildCompletedJobsList(completedJobs),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTabBar() {
    final l10n = context.l10n;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          _buildTabButton('Ongoing', l10n.statusOngoing, 0),
          _buildTabButton('Completed', l10n.statusCompleted, 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String value, String label, int index) {
    final isSelected = _selectedJobTab == value;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: () {
            setState(() => _selectedJobTab = value);
            _tabController.animateTo(index);
          },
          child: AnimatedContainer(
            duration: AppSizes.fast,
            decoration: BoxDecoration(
              color: isSelected ? _blue : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              boxShadow: isSelected
                  ? const [BoxShadow(color: Color(0x140F172A), blurRadius: 3, offset: Offset(0, 1))]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOngoingJobsList(List<JobItemEntity> jobs) {
    if (jobs.isEmpty) {
      return AppEmptyState(
        key: const ValueKey('ongoing-empty'),
        title: context.l10n.homeNoOngoingJobs,
        message: context.l10n.homeNoOngoingJobsHint,
        icon: Icons.work_outline_rounded,
      );
    }
    return Column(
      key: const ValueKey('ongoing'),
      children: jobs.map(_buildJobCard).toList(),
    );
  }

  Widget _buildCompletedJobsList(List<JobItemEntity> jobs) {
    if (jobs.isEmpty) {
      return AppEmptyState(
        key: const ValueKey('completed-empty'),
        title: context.l10n.homeNoCompletedJobs,
        icon: Icons.task_alt_rounded,
      );
    }
    return Column(
      key: const ValueKey('completed'),
      children: jobs.map(_buildJobCard).toList(),
    );
  }

  Future<void> _openJobDetails(JobItemEntity job) async {
    setState(() => _isDetailsLoading = true);

    final apiData = await getRequestDetailsMethod(job.requestId, job.serviceId);

    if (apiData != null) {
      apiData['Distance'] = await getDynamicDistance(apiData, 'N/A');

      final mockFcm = {
        'RequestID': job.requestId,
        'ServiceID': job.serviceId,
      };

      final mappedJobData = JobOverviewData.fromApi(apiData, mockFcm, nextStep: job.nextStep);
      final customerDetails = CustomerDetails.fromJobOverview(mappedJobData, apiData, nextStep: job.nextStep);

      if (!mounted) return;
      setState(() => _isDetailsLoading = false);

      if (job.status.toLowerCase() == "completed") {
        context.push(AppRoutes.completedJobOverview, extra: mappedJobData);
      } else {
        context.push(AppRoutes.customerDetails, extra: customerDetails);
      }
    } else {
      if (!mounted) return;
      setState(() => _isDetailsLoading = false);
      AppSnackBar.error(context.l10n.homeJobDetailsFailed);
    }
  }

  Widget _buildJobCard(JobItemEntity job) {
    final l10n = context.l10n;
    final isCompleted = job.status.toLowerCase() == 'completed';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.white,
        borderRadius: AppRadii.cardAll,
        child: InkWell(
          borderRadius: AppRadii.cardAll,
          onTap: () => _openJobDetails(job),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: AppDecorations.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadii.button),
                      ),
                      child: const Icon(Icons.handyman_outlined, color: _blue, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.dateTime,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (job.amount > 0) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '₹${job.amount.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    isCompleted
                        ? AppStatusChip.success(label: l10n.statusCompleted)
                        : AppStatusChip.warning(label: l10n.statusInProgress),
                    const Spacer(),
                    Text(
                      l10n.commonMoreDetails,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _blue,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: _blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

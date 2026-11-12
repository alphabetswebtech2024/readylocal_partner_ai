import 'dart:developer';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import 'package:flutter/material.dart';
import 'package:focus_on_it/focus_on_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../../../main.dart' show getRequestDetailsMethod, getDynamicDistance;
import '../../../customer_details/data/models/customer_details_model.dart';
import '../../../job_overview/data/models/job_overview_model.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../domain/entities/job_item_entity.dart';
import '../providers/jobs_list_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen>
    with TickerProviderStateMixin {
  late final HomeController _controller;
  late final TabController _tabController;

  String _selectedJobTab = 'Ongoing';
  bool _isDetailsLoading = false;

  static const Color _blue = AppColors.primary;
  static const Color _green = AppColors.success;
  static const Color _surfaceBg = AppColors.surfaceMuted;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createHomeController();
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

  Future<void> _fetchJobs() async {
    await _controller.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return FocusOnIt(
          onFocus: () {
            log('JobsListScreen gained focus - Reloading jobs');
            _fetchJobs();
          },
          child: CommonLoadingOverlay(
            isLoading: _controller.isLoading || _isDetailsLoading,
            child: Scaffold(
              backgroundColor: _surfaceBg,
              appBar: AppTopBar(title: context.l10n.jobsAllJobs),
              body: SafeArea(
                child: RefreshIndicator(
                  color: _blue,
                  onRefresh: _fetchJobs,
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: _buildJobTabBar(),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _selectedJobTab == 'Ongoing'
                              ? _buildJobsList(
                                  _controller.ongoingJobs, context.l10n.homeNoOngoingJobs)
                              : _buildJobsList(_controller.completedJobs,
                                  context.l10n.homeNoCompletedJobs),
                        ),
                      ),
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

  Widget _buildJobTabBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton('Ongoing', 0),
          _buildTabButton('Completed', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedJobTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedJobTab = label);
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _blue.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label == 'Ongoing' ? context.l10n.statusOngoing : context.l10n.statusCompleted,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobsList(List<JobItemEntity> jobs, String emptyMessage) {
    if (jobs.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          child: AppEmptyState(title: emptyMessage, icon: Icons.work_outline_rounded),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return _buildJobCard(jobs[index]);
      },
    );
  }

  Widget _buildJobCard(JobItemEntity job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Transform.scale(
                    scale: 0.72,
                    child: Image.asset(
                      'assets/images/logo_mark.png',
                      width: 48,
                      height: 48,
                      cacheHeight: 144,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Container(
                        color: _blue.withOpacity(0.08),
                        child: const Icon(Icons.handyman_rounded, color: _blue),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (job.amount > 0)
                          Text(
                            '₹${job.amount.toInt()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _green,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.dateTime,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() => _isDetailsLoading = true);

                  final apiData = await getRequestDetailsMethod(
                      job.requestId, job.serviceId);

                  if (apiData != null) {
                    apiData['Distance'] =
                        await getDynamicDistance(apiData, 'N/A');

                    final mockFcm = {
                      'RequestID': job.requestId,
                      'ServiceID': job.serviceId,
                    };

                    final mappedJobData = JobOverviewData.fromApi(
                        apiData, mockFcm,
                        nextStep: job.nextStep);
                    final customerDetails = CustomerDetails.fromJobOverview(
                        mappedJobData, apiData,
                        nextStep: job.nextStep);

                    if (!mounted) return;
                    setState(() => _isDetailsLoading = false);

                    if (job.status.toLowerCase() == "completed") {
                      if (mounted) {
                        context.push(AppRoutes.completedJobOverview,
                            extra: mappedJobData);
                      }
                    } else {
                      if (mounted) {
                        context.push(AppRoutes.customerDetails,
                            extra: customerDetails);
                      }
                    }
                  } else {
                    if (!mounted) return;
                    setState(() => _isDetailsLoading = false);
                    AppSnackBar.error(L10n.current.homeJobDetailsFailed);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.commonMoreDetails,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: AppColors.text),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import '../../../job_overview/data/models/job_overview_model.dart';
import '../../../job_overview/presentation/screens/job_overview_screen.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';

class CompletedJobOverviewScreen extends StatelessWidget {
  final JobOverviewData job;
  const CompletedJobOverviewScreen({super.key, required this.job});

  static const Color _green = AppColors.success;
  static const Color _blue = AppColors.primaryPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
 top: false,
        child: Column(
          children: [
            _buildAppBar(context),
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
                          _buildTitleAndStatus(),
                          const SizedBox(height: 20),
                          _buildBookingSummaryCard(),
                          const SizedBox(height: 24),
                          _buildCustomerDetailsCard(),
                          const SizedBox(height: 24),
                          _buildPaymentSummaryCard(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppTopBar(title: context.l10n.jobSummary);
  }

  Widget _buildHeroImage() {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: AppNetworkImage(
        url: job.imageUrl,
        width: double.infinity,
        height: 200,
        fallback: _imageFallback(),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.background,
      child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.textDisabled)
      ),
    );
  }

  Widget _buildTitleAndStatus() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Text(
                job.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.2)
            )
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _green.withValues(alpha: 0.5))
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: _green, size: 14),
              const SizedBox(width: 4),
              Text(L10n.current.statusCompleted, style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummaryCard() {
    // Extract OrderID from raw API data if available, fallback to JobId
    final orderId = job.rawApiData['OrderID'] ?? job.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(L10n.current.labelOrderId, orderId.toString()),
          const SizedBox(height: 12),
          _buildSummaryRow(L10n.current.labelScheduledOn, job.dateTime),
          const SizedBox(height: 12),
          _buildSummaryRow(L10n.current.labelDistanceTraveled, L10n.current.jobDistanceKm(job.distance)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        Expanded(
            child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.w700)
            )
        ),
      ],
    );
  }

  Widget _buildCustomerDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10n.current.customerDetailsTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              _buildIconRow(Icons.person_outline, L10n.current.labelName, job.customerName),
              if (job.customerPhone.isNotEmpty) ...[
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.background)),
                _buildIconRow(Icons.phone_outlined, L10n.current.labelPhone, job.customerPhone),
              ],
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.background)),
              _buildIconRow(Icons.location_on_outlined, L10n.current.labelLocation, job.address),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _blue.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: _blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDisabled, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.w600, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10n.current.paymentSummary, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(L10n.current.paymentServiceTotal, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  Text('₹${job.amount.toInt()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(L10n.current.paymentAmountCollected, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                    Text('₹${job.amount.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _green)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
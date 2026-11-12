import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_tokens.dart';
import '../../../../core/design/app_top_bar.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/services/alert_setup.dart';
import '../../../../core/services/push_notification_service.dart';

/// Step-by-step guide that opens each phone setting job alerts depend on.
/// The phone's own state is re-read whenever the partner comes back.
class AlertSetupScreen extends StatefulWidget {
  const AlertSetupScreen({super.key});

  @override
  State<AlertSetupScreen> createState() => _AlertSetupScreenState();
}

class _AlertSetupScreenState extends State<AlertSetupScreen> with WidgetsBindingObserver {
  AlertSetupStatus? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final status = await AlertSetup.status();
    if (mounted) setState(() => _status = status);
  }

  Future<void> _open(AlertStep step) async {
    await AlertSetup.open(step);
  }

  Future<void> _confirm(AlertStep step, bool done) async {
    await AlertSetup.setConfirmed(step, done);
    await _refresh();
  }

  ({IconData icon, String title, String body}) _text(AlertStep step) {
    final l10n = context.l10n;
    return switch (step) {
      AlertStep.notifications => (
          icon: Icons.notifications_active_outlined,
          title: l10n.alertStepNotificationsTitle,
          body: l10n.alertStepNotificationsBody,
        ),
      AlertStep.jobChannel => (
          icon: Icons.volume_up_rounded,
          title: l10n.alertStepChannelTitle,
          body: l10n.alertStepChannelBody,
        ),
      AlertStep.battery => (
          icon: Icons.battery_charging_full_rounded,
          title: l10n.alertStepBatteryTitle,
          body: l10n.alertStepBatteryBody,
        ),
      AlertStep.autostart => (
          icon: Icons.rocket_launch_outlined,
          title: l10n.alertStepAutostartTitle,
          body: l10n.alertStepAutostartBody,
        ),
      AlertStep.popup => (
          icon: Icons.screen_lock_portrait_outlined,
          title: l10n.alertStepPopupTitle,
          body: l10n.alertStepPopupBody,
        ),
    };
  }

  /// Autostart and pop-up can't be read from the phone; the partner confirms them.
  bool _needsConfirm(AlertStep step) => step == AlertStep.autostart || step == AlertStep.popup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = _status;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: l10n.alertSetupTitle),
            Expanded(
              child: status == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
                      children: [
                        Text(l10n.alertSetupIntro, style: const TextStyle(fontSize: 14.5, color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          status.allDone
                              ? l10n.alertSetupAllDone
                              : l10n.alertSetupProgress(status.doneCount, status.steps.length),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: status.allDone ? AppColors.success : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (final (i, step) in status.steps.indexed) _stepCard(i + 1, step, status.isDone(step)),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: () => PushNotificationService.showTestAlert(
                            title: l10n.alertSetupTestTitle,
                            body: l10n.alertSetupTestBody,
                          ),
                          icon: const Icon(Icons.campaign_outlined),
                          label: Text(l10n.alertSetupTest),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ElevatedButton(
                          onPressed: () => Navigator.maybePop(context),
                          child: Text(status.allDone ? l10n.alertSetupDone : l10n.alertSetupLater),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepCard(int number, AlertStep step, bool done) {
    final l10n = context.l10n;
    final t = _text(step);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.cardAll,
        border: Border.all(color: done ? AppColors.success.withValues(alpha: 0.4) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: done ? AppColors.successTint : AppColors.primaryTint,
                child: done
                    ? const Icon(Icons.check_rounded, size: 18, color: AppColors.success)
                    : Text('$number', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(t.icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(t.title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(t.body, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.35)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              if (!done || _needsConfirm(step))
                ElevatedButton(
                  onPressed: () => _open(step),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                  child: Text(l10n.alertSetupOpen),
                ),
              if (_needsConfirm(step))
                FilterChip(
                  selected: done,
                  onSelected: (v) => _confirm(step, v),
                  label: Text(l10n.alertSetupIDidThis),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

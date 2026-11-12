// lib/screens/profile/ProfileScreen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/design/job_alerts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';

// ─── ProfileScreen ────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _blue = AppColors.primaryPressed;
  static const Color _surfaceBg = AppColors.surfaceMuted;

  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createProfileController();
    _controller.loadUserProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _surfaceBg,
          body: SafeArea(
 top: false,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryPressed,
                          ),
                        )
                      : _buildBody(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return AppTopBar(title: context.l10n.profileTitle);
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 28),
          _buildProfileHeader(),
          const SizedBox(height: 32),
          _buildMenuSection(),
          const SizedBox(height: 24),
          _buildDeleteAccountTile(),
          const SizedBox(height: 24),
          _buildLogoutTile(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Profile Header ───────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Column(
      children: [
        _buildAvatarWithProgress(),
        const SizedBox(height: 14),
        Text(
          _controller.displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _controller.displayRole,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        _buildEditProfileButton(),
      ],
    );
  }

  Widget _buildAvatarWithProgress() {
    final avatarUrl = _controller.user?.Avatar ?? '';

    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _blue.withOpacity(0.1),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: AppNetworkImage(
                url: avatarUrl,
                width: 78,
                height: 78,
                fallback: _avatarFallback(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    final initials = _controller.displayName.isNotEmpty
        ? _controller.displayName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : 'P';
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return ElevatedButton(
      onPressed: () {
        context.push(AppRoutes.viewProfile);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(
            horizontal: 28, vertical: 12),
      ),
      child: Text(
        context.l10n.profileViewProfile,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ─── Menu Section ─────────────────────────────────────────────────────────

  Widget _buildMenuSection() {
    final l10n = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();
    final items = [
      _MenuItem(
        label: l10n.alertSetupTitle,
        icon: Icons.notifications_active_outlined,
        onTap: () => context.push(AppRoutes.alertSetup),
      ),
      _MenuItem(
        label: l10n.profileLanguage,
        icon: Icons.translate_rounded,
        trailing: localeProvider.isTelugu ? l10n.languageTelugu : l10n.languageEnglish,
        onTap: _showLanguagePicker,
      ),
      _MenuItem(
        label: l10n.profileAbout,
        icon: Icons.info_outline_rounded,
        onTap: () {
          context.push(AppRoutes.webView, extra: {
            'title': l10n.webAboutTitle,
            'url': 'https://www.readylocal.in/about',
          });
        },
      ),
      _MenuItem(
        label: l10n.profileTerms,
        icon: Icons.article_outlined,
        onTap: () {
          context.push(AppRoutes.webView, extra: {
            'title': l10n.webTermsTitle,
            'url': 'https://www.readylocal.in/terms-and-conditions',
          });
        },
      ),
      _MenuItem(
        label: l10n.profilePrivacy,
        icon: Icons.privacy_tip_outlined,
        onTap: () {
          context.push(AppRoutes.webView, extra: {
            'title': l10n.webPrivacyTitle,
            'url': 'https://www.readylocal.in/privacy-policy',
          });
        },
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          return _buildMenuTile(item, isLast: isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuTile(_MenuItem item, {bool isLast = false}) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                if (item.trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      item.trailing!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ),
                const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.textDisabled),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
            color: AppColors.background,
          ),
      ],
    );
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Widget _buildLogoutTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: _onLogout,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 18),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, size: 20, color: AppColors.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.l10n.profileLogout,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: _deleteAccount,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 18),
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.l10n.profileDeleteAccount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final localeProvider = context.read<LocaleProvider>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        Widget option(Locale locale, String label) {
          final selected = localeProvider.locale.languageCode == locale.languageCode;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            trailing: Icon(
              selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.textDisabled,
            ),
            onTap: () {
              localeProvider.setLocale(locale);
              Navigator.pop(sheetContext);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(l10n.profileChooseLanguage, style: Theme.of(sheetContext).textTheme.titleMedium),
              ),
              option(const Locale('en'), 'English'),
              option(const Locale('te'), 'తెలుగు'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Opens inside the app, like About, Terms and Privacy (tester request 2026-11-08).
  Future<void> _deleteAccount() async {
    context.push(AppRoutes.webView, extra: {
      'title': context.l10n.profileDeleteAccount,
      'url': 'https://www.readylocal.in/delete-account',
    });
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.profileLogout),
        content: Text(context.l10n.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel,
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _controller.logout();
              if (mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(88, 44),
            ),
            child: Text(context.l10n.profileLogout),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Item Model ──────────────────────────────────────────────────────────

class _MenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? trailing;

  const _MenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.trailing,
  });
}

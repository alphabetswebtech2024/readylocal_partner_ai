import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../../../main.dart' show userEmail;
import '../providers/view_profile_provider.dart';
import '../widgets/view_profile_item_card.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/localization/server_labels.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late final ViewProfileProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ServiceLocator.createViewProfileProvider();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadProfile();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Widget _buildAppBar() {
    return AppTopBar(title: context.l10n.profileTitle);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        final profile = _provider.profileData;
        final user = _provider.user;

        final fullName = profile != null
            ? '${profile.firstName} ${profile.lastName}'.trim()
            : (user != null ? '${user.FirstName} ${user.LastName}'.trim() : '');
        final email = (profile?.email.isNotEmpty ?? false)
            ? profile!.email
            : userEmail;
        final gender = profile?.gender ?? '';
        final address = profile?.address ?? '';
        final city = profile?.city ?? '';
        final state = profile?.state ?? '';
        final pinCode = profile?.pinCode ?? '';

        return CommonLoadingOverlay(
          isLoading: _provider.isLoading,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
 top: false,
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      children: [
                        Center(child: _buildAvatar()),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.background),
                          ),
                          child: Column(
                            children: [
                              ViewProfileDetailRowWidget(label: context.l10n.fullNameLabel, value: fullName),
                              ViewProfileDetailRowWidget(label: context.l10n.emailLabel, value: email),
                              ViewProfileDetailRowWidget(label: context.l10n.genderLabel, value: context.serverLabel(gender)),
                              ViewProfileDetailRowWidget(label: context.l10n.addressLabel, value: address),
                              ViewProfileDetailRowWidget(label: context.l10n.cityLabel, value: city),
                              ViewProfileDetailRowWidget(label: context.l10n.stateLabel, value: state),
                              ViewProfileDetailRowWidget(label: context.l10n.pinLabel, value: pinCode, isLast: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = _provider.user?.Avatar ?? '';
    final initials = _provider.user != null &&
            _provider.user!.FirstName.isNotEmpty
        ? _provider.user!.FirstName[0].toUpperCase()
        : 'P';

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipOval(
        child: AppNetworkImage(
          url: avatarUrl,
          width: 100,
          height: 100,
          fallback: _avatarFallback(initials),
        ),
      ),
    );
  }

  Widget _avatarFallback(String initials) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

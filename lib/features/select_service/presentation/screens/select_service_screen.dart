import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../providers/select_service_provider.dart';
import '../widgets/service_module_card.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen({super.key});

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  late final SelectServiceProvider _provider;
  String? _selectedModuleId;

  @override
  void initState() {
    super.initState();
    _provider = ServiceLocator.createSelectServiceProvider();
    _provider.loadModules(AppSession.userId);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_selectedModuleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.selectServiceRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }


    final selected = _provider.modules.firstWhere((m) => m.id == _selectedModuleId);
    final code = selected.moduleCode.toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('registrationFee', _provider.feeFor(code));

    if (!mounted) return;

    if (code == 'PERSONAL_DRIVER') {
      context.push(
        AppRoutes.driverSetup,
        extra: {
          'moduleId': selected.id,
          'moduleCode': selected.moduleCode,
          'ModuleName': selected.title,
        },
      );
    } else if (code == 'PUROHIT') {
      context.push(
        AppRoutes.panditSetup,
        extra: {
          'moduleId': selected.id,
          'moduleCode': selected.moduleCode,
          'ModuleName': selected.title,
        },
      );
    } else if (code == 'PHYSIOTHERAPY' || code == 'NURSING' || code == 'CAREGIVER') {
      context.push(
        AppRoutes.medicalSetup,
        extra: {
          'moduleId': selected.id,
          'moduleCode': selected.moduleCode,
          'ModuleName': selected.title,
        },
      );
    } else {
      context.push(
        AppRoutes.selectCategories,
        extra: {
          'moduleId': selected.id,
          'moduleCode': selected.moduleCode,
          'hasCategory': selected.hasCategory,
          'ModuleName': selected.title,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return CommonLoadingOverlay(
          isLoading: _provider.isLoading,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppTopBar(title: context.l10n.selectServiceTitle),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: (_provider.modules.isEmpty && !_provider.isLoading)
                        ? Center(
                            child: AppErrorState(
                              title: _provider.errorMessage ?? context.l10n.commonSomethingWentWrong,
                              retryLabel: context.l10n.commonRetry,
                              onRetry: () => _provider.loadModules(AppSession.userId),
                            ),
                          )
                        : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: _provider.modules.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final module = _provider.modules[index];
                        final isSelected = module.id == _selectedModuleId;
                        return ServiceModuleCard(
                          module: module,
                          isSelected: isSelected,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedModuleId = module.id);
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _selectedModuleId != null ? _onNext : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(context.l10n.commonNext, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
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
}

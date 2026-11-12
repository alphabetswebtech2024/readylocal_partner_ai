import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../main.dart';
import '../providers/bank_details_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class AddBankDetailsScreen extends StatefulWidget {
  const AddBankDetailsScreen({super.key});

  @override
  State<AddBankDetailsScreen> createState() => _AddBankDetailsScreenState();
}

class _AddBankDetailsScreenState extends State<AddBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _ifsCodeController = TextEditingController();

  late final BankDetailsProvider _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createBankDetailsProvider();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _ifsCodeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.addAccount(
      partnerId: userID,
      accountName: _accountHolderNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      ifsc: _ifsCodeController.text.trim(),
      bankName: _bankNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.pop();
      AppSnackBar.success(context.l10n.bankAddedSuccess);
    } else {
      AppSnackBar.error(_controller.errorMessage ?? context.l10n.bankAddFailed);
    }
  }

  // Field style comes from the app theme.
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint);

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppTopBar(title: context.l10n.bankAddTitle),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Bank Name ─────────────────────────────────────────────
                  _fieldLabel(context.l10n.bankName),
                  TextFormField(
                    controller: _bankNameController,
                    decoration: _inputDecoration(context.l10n.bankNameHint),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return context.l10n.bankNameRequired;
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 20),

                  // ── Account Number ────────────────────────────────────────
                  _fieldLabel(context.l10n.bankAccountNumber),
                  TextFormField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration(context.l10n.bankAccountNumberHint),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return context.l10n.bankAccountNumberRequired;
                      }
                      if (v.trim().length < 9 || v.trim().length > 18) {
                        return context.l10n.bankAccountNumberInvalid;
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 20),

                  // ── Account Holder Name ───────────────────────────────────
                  _fieldLabel(context.l10n.bankHolderName),
                  TextFormField(
                    controller: _accountHolderNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(context.l10n.bankHolderNameHint),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return context.l10n.bankHolderNameRequired;
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 20),

                  // ── IFS Code ──────────────────────────────────────────────
                  _fieldLabel(context.l10n.bankIfsc),
                  TextFormField(
                    controller: _ifsCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _inputDecoration(context.l10n.bankIfscHint),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return context.l10n.bankIfscRequired;
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 32),

                  // ── Save Button ───────────────────────────────────────────
                  ElevatedButton(
                    onPressed: _controller.isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor: colorScheme.primary.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _controller.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            context.l10n.commonSave,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

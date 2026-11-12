// lib/screens/earnings/WithdrawScreen.dart

import 'package:gotask_partner/core/localization/server_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_on_it/focus_on_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../domain/entities/bank_detail_entity.dart';
import '../providers/withdraw_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

// ─── Aliases for Backward Compatibility ─────────────────────────────────────
typedef BankDetail = BankDetailEntity;

// ─── TicketClipper ────────────────────────────────────────────────────────────

class TicketClipper extends CustomClipper<Path> {
  final double cutPosition; // Y position of cut
  final double radius;

  TicketClipper({
    required this.cutPosition,
    this.radius = 10,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // Right side cut
    path.lineTo(size.width, cutPosition - radius);
    path.arcToPoint(
      Offset(size.width, cutPosition + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    // Left side cut
    path.lineTo(0, cutPosition + radius);
    path.arcToPoint(
      Offset(0, cutPosition - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TicketClipper oldClipper) {
    return oldClipper.cutPosition != cutPosition;
  }
}

// ─── WithdrawScreen ───────────────────────────────────────────────────────────

class WithdrawScreen extends StatefulWidget {
  final double availableBalance;

  const WithdrawScreen({
    super.key,
    this.availableBalance = 0.0,
  });

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  static const Color _blue = AppColors.primaryPressed;
  static const Color _surfaceBg = AppColors.surfaceMuted;

  late final WithdrawController _controller;
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createWithdrawController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBankDetails() async {
    final user = await UserProvider.getCurrentUser();
    if (user != null) {
      await _controller.loadBankDetails(user.id);
    }
  }

  Future<void> _sendWithdrawRequest() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      AppSnackBar.error(context.l10n.withdrawInvalidAmount);
      return;
    }
    if (amount > widget.availableBalance) {
      AppSnackBar.error(context.l10n.withdrawExceedsBalance);
      return;
    }
    if (_controller.bankDetails.isEmpty) {
      AppSnackBar.error(context.l10n.withdrawNoBank);
      return;
    }

    final user = await UserProvider.getCurrentUser();
    if (user == null) return;

    final success = await _controller.submitWithdrawal(
      partnerId: user.id,
      amount: amount,
    );

    if (mounted) {
      if (success) {
        AppSnackBar.success(context.l10n.withdrawSuccess);
        context.pop();
      } else if (_controller.errorMessage != null) {
        AppSnackBar.error(_controller.errorMessage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return FocusOnIt(
          onFocus: _loadBankDetails,
          child: CommonLoadingOverlay(
            isLoading: _controller.isLoading,
            child: Scaffold(
              backgroundColor: _surfaceBg,
              body: SafeArea(
 top: false,
                child: Column(
                  children: [
                    _buildAppBar(context.l10n.withdrawTitle),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBalanceRow(),
                              const SizedBox(height: 20),
                              if (!_controller.isLoading) ...[
                                ..._controller.bankDetails.asMap().entries.map(
                                      (e) => _buildBankCard(e.value, e.key),
                                    ),
                                const SizedBox(height: 16),
                                _buildAddBankRow(),
                              ],
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildSendButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(String title) {
    return AppTopBar(title: title);
  }

  Widget _buildBalanceRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${_formatAmount(widget.availableBalance)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.earningsAvailableBalance,
                  style: const TextStyle(fontSize: 12, color: AppColors.textDisabled),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _amountController,
                  focusNode: _amountFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.text,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.borderStrong,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.borderStrong,
                    ),
                    prefixText: '₹',
                    prefixStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.withdrawEnterAmount,
                  style: const TextStyle(fontSize: 12, color: AppColors.textDisabled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(BankDetailEntity bank, int index) {
    final isSelected = _controller.selectedBankIndex == index;

    return GestureDetector(
      onTap: () => _controller.selectBank(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipPath(
          clipper: TicketClipper(
            cutPosition: 68,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(14),
              border: isSelected
                  ? Border.all(color: Colors.white30, width: 1.5)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.bankName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (bank.branch.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          context.serverLabel(bank.branch),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.12),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    children: [
                      _buildDetailRow(context.l10n.labelName, bank.accountHolderName),
                      const SizedBox(height: 10),
                      _buildDetailRow(context.l10n.bankAccountNumber, bank.accountNumber),
                      const SizedBox(height: 10),
                      _buildDetailRow(context.l10n.bankIfscLabel, bank.ifscCode),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddBankRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // the whole row, not only the words
      onTap: () {
        context.push(AppRoutes.addBankDetails);
      },
      child: Row(
        children: [
          Text(
            context.l10n.withdrawAddAnotherBank,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderStrong, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 16, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    final isSending = _controller.isSending;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSending ? null : _sendWithdrawRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            disabledBackgroundColor: _blue.withOpacity(0.6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0,
          ),
          child: isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  context.l10n.withdrawSendRequest,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      final formatted = amount.toInt().toString();
      if (formatted.length > 3) {
        return '${formatted.substring(0, formatted.length - 3)},${formatted.substring(formatted.length - 3)}';
      }
      return formatted;
    }
    return amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
  }
}

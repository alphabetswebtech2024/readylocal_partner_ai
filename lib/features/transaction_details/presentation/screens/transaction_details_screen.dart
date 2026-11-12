// lib/screens/earnings/TransactionDetailsScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/localization/server_labels.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../domain/entities/transaction_detail_entity.dart';
import '../providers/transaction_details_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

// ─── Aliases for Backward Compatibility ─────────────────────────────────────
typedef TransactionDetail = TransactionDetailEntity;

// ─── TicketClipper ────────────────────────────────────────────────────────────

class TicketClipper extends CustomClipper<Path> {
  final double cutPosition;
  final double radius;

  const TicketClipper({
    required this.cutPosition,
    this.radius = 10,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    path.lineTo(size.width, cutPosition - radius);
    path.arcToPoint(
      Offset(size.width, cutPosition + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

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
  bool shouldReclip(covariant TicketClipper oldClipper) =>
      oldClipper.cutPosition != cutPosition;
}

// ─── TransactionDetailsScreen ─────────────────────────────────────────────────

class TransactionDetailsScreen extends StatefulWidget {
  final String transactionId;
  final TransactionDetailEntity? transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
    this.transaction,
  });

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  static const Color _blue = AppColors.primaryPressed;
  static const Color _green = AppColors.success;
  static const Color _orange = AppColors.warning;
  static const Color _surfaceBg = AppColors.surfaceMuted;

  late final TransactionDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createTransactionDetailsController();
    if (widget.transaction != null) {
      _controller.setInitialTransaction(widget.transaction);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.transactionId.isNotEmpty) {
        _controller.loadTransactionDetails(widget.transactionId);
      }
    });
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
        final tx = _controller.transaction;

        return CommonLoadingOverlay(
          isLoading: _controller.isLoading,
          child: Scaffold(
            backgroundColor: _surfaceBg,
            body: SafeArea(
 top: false,
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: tx == null && !_controller.isLoading
                        ? _buildEmptyState()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (tx != null) ...[
                                  _buildTransactionTicketCard(tx),
                                  const SizedBox(height: 16),
                                  if (tx.bankName != null ||
                                      tx.accountNumber != null)
                                    _buildBankTicketCard(tx),
                                  const SizedBox(height: 32),
                                ],
                              ],
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

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return AppTopBar(title: context.l10n.txnDetailsTitle);
  }

  // ─── Transaction Ticket Card ──────────────────────────────────────────────

  Widget _buildTransactionTicketCard(TransactionDetailEntity tx) {
    const double cutPos = 68;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipPath(
        clipper: const TicketClipper(cutPosition: cutPos),
        child: Container(
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.serverLabel(tx.jobTitle),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tx.dateTime,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (tx.status == 'Completed')
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '₹${_formatAmount(tx.amount)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildDashedDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Column(
                  children: [
                    _buildTxRow(
                      context.l10n.txnId,
                      tx.transactionId,
                      trailing: GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: tx.transactionId));
                          _showSnackBar(context.l10n.txnIdCopied);
                        },
                        child: const Icon(Icons.copy_rounded,
                            size: 14, color: Colors.white54),
                      ),
                    ),
                    _buildTxRow(context.l10n.txnPaidThrough, context.serverLabel(tx.paidThrough)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 1,
                color: Colors.white.withOpacity(0.10),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    _buildTxRow(context.l10n.txnAmount, '₹${_formatAmount(tx.baseAmount)}'),
                    _buildTxRow('CGST', '₹${_formatAmount(tx.cgst)}'),
                    _buildTxRow('SGST', '₹${_formatAmount(tx.sgst)}'),
                    if (tx.tax > 0)
                      _buildTxRow(context.l10n.txnTax, '₹${_formatAmount(tx.tax)}'),
                    const SizedBox(height: 4),
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.10),
                    ),
                    const SizedBox(height: 10),
                    _buildTxRow(
                      context.l10n.txnTotalAmount,
                      '₹${_formatAmount(tx.totalAmount)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(
          40,
          (i) => Expanded(
            child: Container(
              height: 1,
              color: i.isEven ? Colors.white24 : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTxRow(
    String label,
    String value, {
    Widget? trailing,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing,
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankTicketCard(TransactionDetailEntity tx) {
    const double cutPos = 68;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipPath(
        clipper: const TicketClipper(cutPosition: cutPos),
        child: Container(
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.bankName ?? context.l10n.txnBankAccount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (tx.bankBranch != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              tx.bankBranch!,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildStatusBadge(tx.status),
                  ],
                ),
              ),
              _buildDashedDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  children: [
                    if (tx.accountHolderName != null)
                      _buildTxRow(context.l10n.labelName, tx.accountHolderName!),
                    if (tx.accountNumber != null)
                      _buildTxRow(context.l10n.bankAccountNumber, tx.accountNumber!),
                    if (tx.ifscCode != null)
                      _buildTxRow(context.l10n.bankIfscLabel, tx.ifscCode!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isComplete = status == 'Completed';
    final color = isComplete ? _green : _orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isComplete ? context.l10n.statusCompleted : context.l10n.statusPending,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            context.l10n.txnLoadFailed,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      final s = amount.toInt().toString();
      return s.length > 3
          ? '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}'
          : s;
    }
    return amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
  }
}

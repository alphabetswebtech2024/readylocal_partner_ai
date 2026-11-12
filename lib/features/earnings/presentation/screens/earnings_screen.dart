// lib/screens/earnings/EarningsScreen.dart

import 'package:flutter/material.dart';
import 'package:focus_on_it/focus_on_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../domain/entities/earnings_summary_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/earnings_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/design/app_tokens.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

// ─── Aliases for Backward Compatibility ─────────────────────────────────────
typedef EarningsSummary = EarningsSummaryEntity;
typedef Transaction = TransactionEntity;

// ─── EarningsScreen ───────────────────────────────────────────────────────────

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  static const Color _blue = AppColors.primaryPressed;
  static const Color _surfaceBg = AppColors.background;

  late final EarningsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createEarningsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadEarnings() async {
    final user = await UserProvider.getCurrentUser();
    if (user != null) {
      await _controller.loadEarnings(user.id);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return FocusOnIt(
          onFocus: _loadEarnings,
          child: CommonLoadingOverlay(
            isLoading: _controller.isLoading,
            child: Scaffold(
              backgroundColor: _surfaceBg,
              appBar: AppTopBar(title: context.l10n.earningsTitle),
              body: RefreshIndicator(
                color: _blue,
                onRefresh: _loadEarnings,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildPeriodSelector()),
                    SliverToBoxAdapter(child: _buildSummaryCard(_controller.summary)),
                    SliverToBoxAdapter(child: _buildBankTransactionSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  // ─── Period selector ──────────────────────────────────────────────────────
  // Values stay in English (they drive the provider); only labels translate.

  Widget _buildPeriodSelector() {
    const periods = ['Daily', 'Weekly', 'Monthly'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: _segmented(
        values: periods,
        selected: _controller.selectedPeriod,
        label: _periodLabel,
        onSelect: _controller.setPeriod,
      ),
    );
  }

  Widget _segmented({
    required List<String> values,
    required String selected,
    required String Function(String) label,
    required void Function(String) onSelect,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: values.map((value) {
          final isSelected = selected == value;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              child: GestureDetector(
                onTap: () => onSelect(value),
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
                    label(value),
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
        }).toList(),
      ),
    );
  }

  // ─── Summary card ─────────────────────────────────────────────────────────

  Widget _buildSummaryCard(EarningsSummaryEntity summary) {
    final l10n = context.l10n;
    double displayAmount = 0;
    String displayTitle;

    if (_controller.selectedPeriod == 'Weekly') {
      displayAmount = summary.weeklyEarnings;
      displayTitle = l10n.homeWeeklyEarning;
    } else if (_controller.selectedPeriod == 'Monthly') {
      displayAmount = summary.monthlyEarnings;
      displayTitle = l10n.homeMonthlyEarning;
    } else {
      displayAmount = summary.todayEarnings;
      displayTitle = l10n.homeTodaysEarning;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayTitle, style: const TextStyle(color: AppColors.onPrimaryMuted, fontSize: 13)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '₹${_formatAmount(displayAmount)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.earningsAvailableBalance,
                        style: const TextStyle(color: AppColors.onPrimaryMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${_formatAmount(summary.availableBalance)}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => _onWithdrawTapped(summary.availableBalance),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _blue,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      textStyle: const TextStyle(
                        fontFamily: AppFonts.sans,
                        fontFamilyFallback: AppFonts.fallback,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(l10n.earningsSendWithdraw, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onWithdrawTapped(double availableBalance) {
    context.push(
      AppRoutes.withdraw,
      extra: availableBalance,
    );
  }

  // ─── Bank Transaction Section ─────────────────────────────────────────────

  Widget _buildBankTransactionSection() {
    final l10n = context.l10n;
    final transactions = _controller.selectedTab == 'Completed'
        ? _controller.completedTransactions
        : _controller.pendingTransactions;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.earningsBankTransaction, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _segmented(
            values: const ['Pending', 'Completed'],
            selected: _controller.selectedTab,
            label: (tab) => tab == 'Completed' ? l10n.statusCompleted : l10n.statusPending,
            onSelect: _controller.setTab,
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: AppSizes.normal,
            child: transactions.isEmpty
                ? AppEmptyState(
                    key: const ValueKey('empty'),
                    title: l10n.earningsNoTransactions,
                    icon: Icons.account_balance_wallet_outlined,
                  )
                : Container(
                    key: ValueKey(_controller.selectedTab),
                    decoration: AppDecorations.card(),
                    child: Column(
                      children: [
                        for (var i = 0; i < transactions.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildTransactionRow(transactions[i]),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(TransactionEntity transaction) {
    final l10n = context.l10n;
    final isPending = transaction.status == 'Pending';
    final title = transaction.title == 'Bank Transaction' ? l10n.earningsBankTransactionItem : transaction.title;

    return InkWell(
      borderRadius: AppRadii.cardAll,
      onTap: () {
        context.push(
          AppRoutes.transactionDetails,
          extra: transaction.id,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPending ? AppColors.warningTint : AppColors.successTint,
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: Icon(
                Icons.account_balance_outlined,
                size: 20,
                color: isPending ? AppColors.warning : AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.dateTime,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${_formatAmount(transaction.amount)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                isPending
                    ? AppStatusChip.warning(label: l10n.statusPending)
                    : AppStatusChip.success(label: l10n.statusCompleted),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textDisabled),
          ],
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

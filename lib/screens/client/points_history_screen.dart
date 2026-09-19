import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/points_provider.dart';
import '../../models/point_transaction_model.dart';
import '../../widgets/animated_stat_counter.dart';
import '../../widgets/fade_slide_in.dart';

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key});

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PointsProvider>().fetchTransactions(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PointsProvider>().fetchTransactions();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PointsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Puntos'),
      ),
      body: Column(
        children: [
          // Total points banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8C38), Color(0xFFD4500A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Puntos acumulados',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    AnimatedStatCounter(
                      value: provider.totalPoints,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: provider.isLoading && provider.transactions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.transactions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => provider.refresh(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppTheme.spacing16),
                          itemCount: provider.transactions.length +
                              (provider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.transactions.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return FadeSlideIn(
                              delay: Duration(milliseconds: (index % 6) * 60),
                              child: _buildTransactionCard(provider.transactions[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PointTransactionModel tx) {
    final color = tx.isEarned ? AppTheme.successColor : AppTheme.errorColor;
    final icon = _iconForType(tx.type);
    String formattedDate = '';
    try {
      final dt = DateTime.parse(tx.createdAt);
      formattedDate = DateFormat('dd MMM yyyy, HH:mm', 'es').format(dt);
    } catch (_) {
      formattedDate = tx.createdAt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(formattedDate, style: context.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            tx.isEarned ? '+${tx.points}' : '${tx.points}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'referral':
        return Icons.people_rounded;
      case 'redeemed':
        return Icons.shopping_bag_rounded;
      case 'purchase':
        return Icons.shopping_cart_rounded;
      case 'bonus':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars_outlined, size: 72, color: context.textTertCol),
          const SizedBox(height: 16),
          Text('Sin transacciones', style: context.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tu historial de puntos aparecerá aquí',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

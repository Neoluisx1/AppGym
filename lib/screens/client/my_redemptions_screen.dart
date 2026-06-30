// 📦 My Redemptions Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/store_provider.dart';
import '../../models/product_model.dart';

class MyRedemptionsScreen extends StatefulWidget {
  const MyRedemptionsScreen({Key? key}) : super(key: key);

  @override
  State<MyRedemptionsScreen> createState() => _MyRedemptionsScreenState();
}

class _MyRedemptionsScreenState extends State<MyRedemptionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchRedemptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Canjes'),
      ),
      body: storeProvider.isLoading && storeProvider.redemptions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => storeProvider.fetchRedemptions(),
              child: storeProvider.redemptions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(AppTheme.spacing16),
                      itemCount: storeProvider.redemptions.length,
                      itemBuilder: (context, index) {
                        final redemption = storeProvider.redemptions[index];
                        return _buildRedemptionCard(redemption);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.redeem,
            size: 80,
            color: context.textTertCol,
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'No tienes canjes',
            style: context.textTheme.bodyLarge,
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            'Los productos que canjees aparecerán aquí',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondCol,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionCard(RedemptionModel redemption) {
    final statusColor = _getStatusColor(context, redemption.status);
    final statusText = _getStatusText(redemption.status);
    
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    _getStatusIcon(redemption.status),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        redemption.productName,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Row(
                        children: [
                          Icon(Icons.stars, color: AppTheme.warningColor, size: 14),
                          SizedBox(width: AppTheme.spacing4),
                          Text(
                            '${redemption.pointsUsed} puntos',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.textSecondCol,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    statusText,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppTheme.spacing12),
            
            Divider(color: context.borderCol),
            
            SizedBox(height: AppTheme.spacing8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de canje',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondCol,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      _formatDate(redemption.redeemedAt),
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (redemption.claimedAt != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Recogido',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.textSecondCol,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        _formatDate(redemption.claimedAt!),
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
              ],
            ),
            
            if (redemption.isPending) ...[
              SizedBox(height: AppTheme.spacing12),
              Container(
                padding: EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryOrange,
                      size: 20,
                    ),
                    SizedBox(width: AppTheme.spacing8),
                    Expanded(
                      child: Text(
                        'Recoge tu producto en recepción',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningColor;
      case 'claimed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return context.textSecondCol;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'claimed':
        return 'Recogido';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'claimed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.redeem;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

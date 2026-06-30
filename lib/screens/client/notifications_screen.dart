// 🔔 Notifications Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import 'membership_plans_screen.dart';
import 'group_classes_screen.dart';
import 'surveys_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (notificationProvider.hasUnread)
            TextButton.icon(
              onPressed: () => _markAllAsRead(notificationProvider),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Marcar todas'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryOrange,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationProvider.isLoading && notificationProvider.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => notificationProvider.refresh(),
              child: notificationProvider.notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(AppTheme.spacing16),
                      itemCount: notificationProvider.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notificationProvider.notifications[index];
                        return _buildNotificationCard(notification, notificationProvider);
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
            Icons.notifications_none,
            size: 80,
            color: context.textTertCol,
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'No tienes notificaciones',
            style: context.textTheme.bodyLarge,
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            'Aquí aparecerán tus notificaciones importantes',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondCol,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationProvider provider) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);
    
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificación eliminada')),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.spacing12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: notification.isRead ? context.borderCol : color.withValues(alpha: 0.3),
            width: notification.isRead ? 1 : 2,
          ),
          boxShadow: notification.isRead ? null : [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            onTap: () => _handleNotificationTap(notification, provider),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spacing8),
                        Text(
                          notification.message,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.textSecondCol,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppTheme.spacing8),
                        Text(
                          _formatDate(notification.createdAt),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.textTertCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'membership_expiring':
        return AppTheme.warningColor;
      case 'membership_expired':
        return AppTheme.errorColor;
      case 'group_class':
        return AppTheme.primaryOrange;
      case 'routine':
        return AppTheme.successColor;
      case 'goal':
        return Colors.purple;
      case 'announcement':
        return Colors.blue;
      case 'survey':
        return Colors.purple;
      default:
        return context.textSecondCol;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'membership_expiring':
      case 'membership_expired':
        return Icons.card_membership;
      case 'group_class':
        return Icons.fitness_center;
      case 'routine':
        return Icons.assignment;
      case 'goal':
        return Icons.flag;
      case 'announcement':
        return Icons.campaign;
      case 'survey':
        return Icons.assignment_outlined;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Ahora';
      } else if (difference.inHours < 1) {
        return 'Hace ${difference.inMinutes} min';
      } else if (difference.inDays < 1) {
        return 'Hace ${difference.inHours} h';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification, NotificationProvider provider) async {
    if (!notification.isRead) {
      await provider.markAsRead(notification.id);
    }

    if (!mounted) return;

    switch (notification.type) {
      case 'membership_expiring':
      case 'membership_expired':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MembershipPlansScreen()),
        );
        break;
      case 'group_class':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GroupClassesScreen()),
        );
        break;
      case 'survey':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SurveysScreen()),
        );
        break;
      default:
        break;
    }
  }

  Future<void> _markAllAsRead(NotificationProvider provider) async {
    final success = await provider.markAllAsRead();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas las notificaciones marcadas como leídas'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

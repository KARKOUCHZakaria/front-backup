import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = _getMockNotifications();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All notifications marked as read'))),
            child: Text('Mark all read', style: TextStyle(color: AppColors.primaryCyan, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildNotificationCard(context, notifications[index]),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.notifications_none, size: 64, color: AppColors.primaryCyan),
          ),
          const SizedBox(height: 24),
          Text('No notifications yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('We\'ll notify you when something important happens', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> notif) {
    return Container(
      decoration: BoxDecoration(
        color: notif['isRead'] ? AppColors.darkTeal : AppColors.darkTeal.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: notif['isRead'] ? Colors.white.withOpacity(0.05) : AppColors.primaryCyan.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () { if (notif['route'] != null) context.push(notif['route']); },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _getIconColor(notif['type']).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_getIcon(notif['type']), color: _getIconColor(notif['type']), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(notif['title'], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: notif['isRead'] ? FontWeight.w500 : FontWeight.bold))),
                          if (!notif['isRead']) Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primaryCyan, shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(notif['message'], style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(notif['time'], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
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

  IconData _getIcon(String type) {
    switch (type) {
      case 'application': return Icons.description;
      case 'score': return Icons.analytics;
      case 'update': return Icons.system_update;
      case 'alert': return Icons.warning;
      default: return Icons.info;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'application': return AppColors.primaryCyan;
      case 'score': return Colors.green;
      case 'update': return Colors.blue;
      case 'alert': return Colors.orange;
      default: return Colors.purple;
    }
  }

  List<Map<String, dynamic>> _getMockNotifications() {
    return [
      {'title': 'Application Approved', 'message': 'Your credit application has been approved!', 'time': '2 hours ago', 'type': 'application', 'isRead': false, 'route': '/user/home'},
      {'title': 'Credit Score Updated', 'message': 'Your credit score has increased to 785', 'time': '1 day ago', 'type': 'score', 'isRead': false, 'route': '/user/score-gauge'},
      {'title': 'System Maintenance', 'message': 'Scheduled maintenance on Dec 15, 2025', 'time': '2 days ago', 'type': 'update', 'isRead': true, 'route': null},
      {'title': 'Payment Reminder', 'message': 'Your payment is due in 3 days', 'time': '3 days ago', 'type': 'alert', 'isRead': true, 'route': null},
      {'title': 'New Feature Available', 'message': 'Check out our new AI-powered insights', 'time': '1 week ago', 'type': 'info', 'isRead': true, 'route': null},
    ];
  }
}

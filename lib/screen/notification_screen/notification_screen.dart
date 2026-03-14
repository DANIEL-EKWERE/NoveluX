import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/notification_screen/controller/notifcation_controller.dart';

class NotificationScreen extends GetWidget<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(color: Colors.white, onPressed: () => Get.back(),
            icon: const Icon(Icons.chevron_left_rounded)),
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          Obx(() => controller.notifications.isNotEmpty
              ? TextButton(onPressed: controller.markAllRead,
                  child: Text('Mark all read', style: TextStyle(color: depperBlue, fontSize: 12)))
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }
        if (controller.notifications.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.notifications_none, color: Colors.grey[700], size: 60),
            const SizedBox(height: 16),
            const Text('No notifications yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ]));
        }
        return ListView.separated(
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => const Divider(color: Color(0xFF2a2a2a), height: 1),
          itemBuilder: (_, i) {
            final n = controller.notifications[i];
            final isRead = n['is_read'] ?? false;
            return ListTile(
              tileColor: isRead ? null : depperBlue.withOpacity(0.05),
              leading: Container(width: 42, height: 42,
                decoration: BoxDecoration(color: _color(n['notification_type']).withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(_icon(n['notification_type']), color: _color(n['notification_type']), size: 20)),
              title: Text(n['title'] ?? '', style: TextStyle(color: Colors.white, fontSize: 13,
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
              subtitle: Text(n['message'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: !isRead ? Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: depperBlue, shape: BoxShape.circle)) : null,
              onTap: () => controller.markRead(n['id']),
            );
          },
        );
      }),
    );
  }

  IconData _icon(String? type) {
    switch (type) {
      case 'new_chapter':   return Icons.menu_book;
      case 'tip_received':  return Icons.monetization_on;
      case 'new_follower':  return Icons.person_add;
      case 'comment_reply': return Icons.reply;
      case 'comment_like':  return Icons.thumb_up;
      case 'bonus_earned':  return Icons.card_giftcard;
      default:              return Icons.notifications;
    }
  }

  Color _color(String? type) {
    switch (type) {
      case 'new_chapter':   return Colors.blue;
      case 'tip_received':  return Colors.orange;
      case 'new_follower':  return Colors.green;
      case 'comment_reply': return Colors.purple;
      default:              return Colors.grey;
    }
  }
}

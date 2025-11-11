import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:novelux/screen/notification_screen/controller/notifcation_controller.dart';

class NotificationScreen extends GetWidget<NotificationController> {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.chevron_left_rounded),
        ),
        backgroundColor: Color(0xFF1A1A1A),
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

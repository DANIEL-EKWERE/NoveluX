import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/about/about_screen.dart';
import 'package:novelux/screen/auth/auth_controller.dart';
import 'package:novelux/screen/auth/auth_screens.dart';
import 'package:novelux/screen/author/author_dashboard_screen.dart';
import 'package:novelux/screen/coins/coin_store_screen.dart';
import 'package:novelux/screen/download_screen/download_screen.dart';
import 'package:novelux/screen/library/library_screen.dart';
import 'package:novelux/screen/me/controller/me_controller.dart';
import 'package:novelux/screen/notification_screen/controller/notifcation_controller.dart';
import 'package:novelux/screen/notification_screen/notification_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final ctrl = Get.put(MeController());

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final isLoggedIn = auth.isLoggedIn.value;
          final avatar = auth.avatar;
          return Column(
            children: [
              // ── Profile Header ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: depperBlue,
                          backgroundImage:
                              (avatar != null && avatar.isNotEmpty)
                                  ? NetworkImage(
                                        avatar.startsWith('http')
                                            ? avatar
                                            : 'http://10.0.2.2:8000$avatar',
                                      )
                                      as ImageProvider
                                  : null,
                          child:
                              (avatar == null || avatar.isEmpty)
                                  ? Text(
                                    isLoggedIn && auth.username.isNotEmpty
                                        ? auth.username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : null,
                        ),
                        if (auth.isVip)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.diamond,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoggedIn ? auth.username : 'Guest',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isLoggedIn) ...[
                            Text(
                              auth.email,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Colors.orange,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${auth.coins} coins',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: depperBlue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Lv.${auth.readingLevel}',
                                    style: TextStyle(
                                      color: depperBlue,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isLoggedIn)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: depperBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => Get.to(() => const LoginScreen()),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Coins banner ──────────────────────────────────────────────
              if (isLoggedIn)
                GestureDetector(
                  onTap: () => Get.to(() => const CoinStoreScreen()),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          depperBlue.withOpacity(0.9),
                          const Color(0xFF003d80),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${auth.coins} coins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Buy More',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Menu List ─────────────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _section([
                      _item(
                        Icons.timelapse_rounded,
                        'History',
                        Colors.lightBlueAccent,
                        () => Get.to(
                          () => const LibraryScreen(),
                          arguments: {'value': 1, 'isProfile': true},
                        ),
                      ),
                      if (isLoggedIn)
                        _item(
                          Icons.monetization_on,
                          'Coin Store',
                          Colors.orange,
                          () => Get.to(() => const CoinStoreScreen()),
                        ),
                      _item(
                        Icons.download,
                        'Downloads',
                        Colors.blue,
                        () => Get.to(() => DownloadScreen()),
                      ),
                      _item(
                        Icons.dark_mode,
                        'Display Mode',
                        Colors.purple,
                        () => _showThemeSheet(context),
                      ),
                      _item(
                        Icons.favorite_outline,
                        'Reading Preferences',
                        Colors.pink,
                        () {},
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _section([
                      Obx(
                        () => _item(
                          Icons.notifications_outlined,
                          'Notifications',
                          Colors.orange,
                          () {
                            Get.put(NotificationController());
                            Get.to(() => const NotificationScreen());
                          },
                          badge:
                              ctrl.unreadCount.value > 0
                                  ? '${ctrl.unreadCount.value}'
                                  : null,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _section([
                      if (isLoggedIn && auth.isAuthor)
                        _item(
                          Icons.dashboard_outlined,
                          'Author Dashboard',
                          Colors.teal,
                          () => Get.to(() => const AuthorDashboardScreen()),
                        )
                      else if (isLoggedIn)
                        _item(
                          Icons.edit_outlined,
                          'Become an Author',
                          Colors.lightBlue,
                          () => _becomeAuthorDialog(ctrl),
                        )
                      else
                        _item(
                          Icons.login,
                          'Sign In to Write',
                          Colors.lightBlue,
                          () => Get.to(() => const LoginScreen()),
                        ),
                      _item(
                        Icons.info_outline,
                        'About NoveluX',
                        Colors.amber,
                        () => Get.to(() => AboutScreen()),
                      ),
                      _item(
                        Icons.help_outline,
                        'Help & Feedback',
                        Colors.orange,
                        () {},
                      ),
                      if (isLoggedIn)
                        _item(
                          Icons.logout,
                          'Sign Out',
                          Colors.red,
                          () => _signOutDialog(auth),
                        ),
                      if (!isLoggedIn)
                        _item(
                          Icons.person_add_outlined,
                          'Create Account',
                          Colors.green,
                          () => Get.to(() => const RegisterScreen()),
                        ),
                    ]),
                  ],
                ),
              ),
              SizedBox(height: 70),
            ],
          );
        }),
      ),
    );
  }

  Widget _section(List<Widget> items) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    padding: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(children: items),
  );

  Widget _item(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap, {
    String? badge,
  }) => ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
    title: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 13),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        const SizedBox(width: 4),
        Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 12),
      ],
    ),
    onTap: onTap,
  );

  void _showThemeSheet(BuildContext ctx) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: ctx,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1a1a1a),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Display Mode',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const Divider(color: Colors.black26),
                  ...['System Default', 'Dark', 'Light'].map(
                    (mode) => ListTile(
                      leading: Radio<String>(
                        value: mode,
                        groupValue: 'Dark',
                        onChanged: (_) {},
                        activeColor: depperBlue,
                      ),
                      title: Text(
                        mode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _becomeAuthorDialog(MeController ctrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Become an Author',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Start publishing stories and earn coins on NoveluX!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: depperBlue),
            onPressed: () {
              Get.back();
              ctrl.becomeAuthor();
            },
            child: const Text(
              'Become Author',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _signOutDialog(AuthController auth) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              auth.logout();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

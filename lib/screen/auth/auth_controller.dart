import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';
import 'package:novelux/config/local_storage.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final DataBase _db = Get.find<DataBase>();

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);

  // Form controllers
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final password2Ctrl= TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _db.getToken();
    if (token.isNotEmpty) {
      isLoggedIn.value = true;
      await fetchMe();
    }
  }

  Future<void> login() async {
    if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    final res = await ApiService.login(
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text,
    );
    isLoading.value = false;
    if (res['success']) {
      final data = res['data'];
      await _db.saveToken(data['access'] ?? '');
      // Save refresh token separately
      await _saveRefreshToken(data['refresh'] ?? '');
      isLoggedIn.value = true;
      await fetchMe();
      Get.offAllNamed('/main_screen');
    } else {
      errorMessage.value = res['error'] ?? 'Login failed';
    }
  }

  Future<void> register({String role = 'reader'}) async {
    if (usernameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty ||
        password2Ctrl.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }
    if (passwordCtrl.text != password2Ctrl.text) {
      errorMessage.value = 'Passwords do not match';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    final res = await ApiService.register(
      username: usernameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      password1: passwordCtrl.text,
      password2: password2Ctrl.text,
      role: role,
    );
    isLoading.value = false;
    if (res['success']) {
      final data = res['data'];
      if (data['access'] != null) {
        await _db.saveToken(data['access']);
        await _saveRefreshToken(data['refresh'] ?? '');
        isLoggedIn.value = true;
        await fetchMe();
        Get.offAllNamed('/main_screen');
      } else {
        // Registration succeeded but no token — redirect to login
        Get.offNamed('/login_screen');
        Get.snackbar('Success', 'Account created! Please log in.',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } else {
      errorMessage.value = res['error'] ?? 'Registration failed';
    }
  }

  Future<void> fetchMe() async {
    final res = await ApiService.getMe();
    if (res['success']) {
      currentUser.value = res['data'];
      // Save key user info
      final data = res['data'];
      await _db.saveUserName(data['username'] ?? '');
      await _db.saveEmail(data['email'] ?? '');
      await _db.saveRole(data['role'] ?? 'reader');
    }
  }

  Future<void> logout() async {
    await _db.logOut();
    isLoggedIn.value = false;
    currentUser.value = null;
    Get.offAllNamed('/onboarding_screen');
  }

  Future<void> _saveRefreshToken(String refresh) async {
    // Reuse profileId field as temp refresh token storage
    await _db.saveProfileId(refresh);
  }

  Future<String> _getRefreshToken() async {
    return await _db.getProfileId();
  }

  // Getters for current user data
  String get username => currentUser.value?['username'] ?? '';
  String get email    => currentUser.value?['email'] ?? '';
  String get role     => currentUser.value?['role'] ?? 'reader';
  int    get coins    => currentUser.value?['coin_balance'] ?? 0;
  bool   get isVip    => currentUser.value?['is_vip'] ?? false;
  bool   get isAuthor => role == 'author';
  String? get avatar  => currentUser.value?['avatar'];
  int    get readingLevel => currentUser.value?['reading_level'] ?? 1;
}

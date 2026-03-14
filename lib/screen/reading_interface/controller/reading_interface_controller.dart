import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';

class ReadingInterfaceController extends GetxController {
  final RxBool _showTopBar      = false.obs;
  final RxBool _showBottomBar   = false.obs;
  final RxBool _showSettings    = false.obs;
  final RxBool _showContents    = false.obs;
  final RxBool _showListenButton= false.obs;
  final RxInt  _tapCount        = 0.obs;

  final RxDouble _brightness       = 0.5.obs;
  final RxDouble _fontSize         = 18.0.obs;
  final RxString _selectedFont     = 'Lora'.obs;
  final RxInt    _selectedLineSpacing = 3.obs;
  final RxInt    _selectedBackground  = 0.obs;
  final RxString _pageFlipEffect   = 'Flip'.obs;
  final RxBool   _volumeKeyTurning = true.obs;

  final RxString _bookTitle      = ''.obs;
  final RxString _currentChapter = 'Chapter 1'.obs;
  final RxInt    _coins          = 0.obs;
  final RxDouble _readingProgress= 0.0.obs;

  // API-loaded content
  final RxString chapterContent   = ''.obs;
  final RxBool   isLoadingChapter = false.obs;

  late ScrollController scrollController;

  bool get showTopBar       => _showTopBar.value;
  bool get showBottomBar    => _showBottomBar.value;
  bool get showSettings     => _showSettings.value;
  bool get showContents     => _showContents.value;
  bool get showListenButton => _showListenButton.value;
  double get brightness     => _brightness.value;
  double get fontSize       => _fontSize.value;
  String get selectedFont   => _selectedFont.value;
  int get selectedLineSpacing => _selectedLineSpacing.value;
  int get selectedBackground  => _selectedBackground.value;
  String get pageFlipEffect => _pageFlipEffect.value;
  bool get volumeKeyTurning => _volumeKeyTurning.value;
  String get bookTitle      => _bookTitle.value;
  String get currentChapter => _currentChapter.value;
  int get coins             => _coins.value;
  double get readingProgress=> _readingProgress.value;

  final List<String> fonts = ['System', 'Modern', 'Assistant', 'Lora'];
  final List<Color> backgroundColors = [
    const Color(0xFFFFF2D4),
    const Color(0xFFFFFFFF),
    const Color(0xFFE8F5E8),
    const Color(0xFFE3F2FD),
    const Color(0xFF1a1a1a),
  ];
  final List<String> pageFlipEffects = ['Scroll ↔', 'Scroll ↕', 'Flip', 'Animate'];

  final List<Chapter> chapters = [];

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    // Default to dark background (index 4)
    _selectedBackground.value = 4;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final cur = scrollController.offset;
      _readingProgress.value = maxScroll > 0 ? cur / maxScroll : 0.0;
    }
  }

  Future<void> loadChapter(String storySlug, int chapterNum, String? title) async {
    _currentChapter.value = title ?? 'Chapter $chapterNum';
    isLoadingChapter.value = true;
    chapterContent.value = '';
    final res = await ApiService.getChapter(storySlug, chapterNum);
    isLoadingChapter.value = false;
    if (res['success']) {
      final data = res['data'];
      chapterContent.value = data['content'] ?? '';
      _currentChapter.value = data['title'] ?? title ?? 'Chapter $chapterNum';
    } else {
      chapterContent.value = res['error'] ?? 'Failed to load chapter.';
    }
  }

  void onScreenTap() {
    _tapCount.value++;
    if (_tapCount.value == 1) {
      _showTopBar.value    = true;
      _showBottomBar.value = true;
      _showListenButton.value = true;
      Future.delayed(const Duration(seconds: 3), () {
        if (_tapCount.value == 1) hideAllControls();
      });
    }
  }

  void hideAllControls() {
    _showTopBar.value       = false;
    _showBottomBar.value    = false;
    _showSettings.value     = false;
    _showContents.value     = false;
    _showListenButton.value = false;
    _tapCount.value         = 0;
  }

  void toggleSettings() {
    _showSettings.value = !_showSettings.value;
    if (_showSettings.value) _showContents.value = false;
  }

  void toggleContents() {
    _showContents.value = !_showContents.value;
    if (_showContents.value) _showSettings.value = false;
  }

  void setBrightness(double v)  => _brightness.value = v;
  void setFontSize(double v)    => _fontSize.value = v;
  void setFont(String f)        => _selectedFont.value = f;
  void setLineSpacing(int s)    => _selectedLineSpacing.value = s;
  void setBackground(int i)     => _selectedBackground.value = i;
  void setPageFlipEffect(String e) => _pageFlipEffect.value = e;
  void toggleVolumeKeyTurning() => _volumeKeyTurning.value = !_volumeKeyTurning.value;

  Color get currentBackgroundColor => backgroundColors[selectedBackground];
  Color get currentTextColor {
    if (selectedBackground == 4) {
      return Colors.white;
    }
    if (selectedBackground == 0) {
      return const Color(0xFF8B4513);
    }
    return Colors.black87;
  }

  double get currentLineHeight {
    switch (selectedLineSpacing) {
      case 0: return 1.2;
      case 1: return 1.4;
      case 2: return 1.6;
      case 3: return 1.8;
      default: return 1.5;
    }
  }
}

class Chapter {
  final String title;
  final bool isRead;
  Chapter(this.title, {this.isRead = false});
}

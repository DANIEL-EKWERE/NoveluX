import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';

class ReadingInterfaceController extends GetxController {
  final RxBool _showTopBar = false.obs;
  final RxBool _showBottomBar = false.obs;
  final RxBool _showSettings = false.obs;
  final RxBool _showContents = false.obs;
  final RxBool _showListenButton = false.obs;

  final RxDouble _brightness = 0.5.obs;
  final RxDouble _fontSize = 18.0.obs;
  final RxString _selectedFont = 'Lora'.obs;
  final RxInt _selectedLineSpacing = 3.obs;
  final RxInt _selectedBackground = 0.obs;
  final RxString _pageFlipEffect = 'Flip'.obs;
  final RxBool _volumeKeyTurning = true.obs;

  final RxString _bookTitle = ''.obs;
  final RxString _currentChapter = 'Chapter 1'.obs;
  final RxInt _coins = 0.obs;
  final RxDouble _readingProgress = 0.0.obs;

  // API-loaded content
  final RxString chapterContent = ''.obs;
  final RxBool isLoadingChapter = false.obs;

  late ScrollController scrollController;

  bool get showTopBar => _showTopBar.value;
  bool get showBottomBar => _showBottomBar.value;
  bool get showSettings => _showSettings.value;
  bool get showContents => _showContents.value;
  bool get showListenButton => _showListenButton.value;
  double get brightness => _brightness.value;
  double get fontSize => _fontSize.value;
  String get selectedFont => _selectedFont.value;
  int get selectedLineSpacing => _selectedLineSpacing.value;
  int get selectedBackground => _selectedBackground.value;
  String get pageFlipEffect => _pageFlipEffect.value;
  bool get volumeKeyTurning => _volumeKeyTurning.value;
  String get bookTitle => _bookTitle.value;
  String get currentChapter => _currentChapter.value;
  int get coins => _coins.value;
  double get readingProgress => _readingProgress.value;

  final List<String> fonts = ['System', 'Modern', 'Assistant', 'Lora'];
  final List<Color> backgroundColors = [
    const Color(0xFFFFF2D4),
    const Color(0xFFFFFFFF),
    const Color(0xFFE8F5E8),
    const Color(0xFFE3F2FD),
    const Color(0xFF1a1a1a),
    const Color(0xFF000000),
  ];
  final List<String> pageFlipEffects = [
    'Scroll ↔',
    'Scroll ↕',
    'Flip',
    'Animate',
  ];

  final List<Chapter> chapters = [];

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    // Default to dark background (index 4)
    _selectedBackground.value = 5;
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

      // Hide overlay when user scrolls
      if (_showTopBar.value || _showBottomBar.value) {
        hideAllControls();
      }
    }
  }

  // Future<void> loadChapter(
  //   String storySlug,
  //   int chapterNum,
  //   String? title,
  // ) async {
  //   _currentChapter.value = title ?? 'Chapter $chapterNum';
  //   isLoadingChapter.value = true;
  //   chapterContent.value = '';
  //   final res = await ApiService.getChapter(storySlug, chapterNum);
  //   isLoadingChapter.value = false;
  //   if (res['success']) {
  //     final data = res['data'];
  //     chapterContent.value = data['content'] ?? '';
  //     _currentChapter.value = data['title'] ?? title ?? 'Chapter $chapterNum';
  //   } else {
  //     chapterContent.value = res['error'] ?? 'Failed to load chapter.';
  //   }
  // }

  final RxInt currentChapterNumber = 1.obs;
  final RxInt totalChapters = 0.obs;
  final RxList chapterList = [].obs; // full list from API
  String? currentStorySlug;

  // Navigation helpers
  bool get hasPrevChapter => currentChapterNumber.value > 1;
  bool get hasNextChapter {
    if (totalChapters.value > 0) {
      return currentChapterNumber.value < totalChapters.value;
    }
    // fallback: allow next if chapter list has more
    return chapterList.isNotEmpty &&
        currentChapterNumber.value < chapterList.length;
  }

  // Current chapter title from list (or fallback)
  String get nextChapterTitle {
    final nextNum = currentChapterNumber.value + 1;
    try {
      final match = chapterList.firstWhere(
        (c) => c['chapter_number'] == nextNum,
      );
      return match['title'] ?? 'Chapter $nextNum';
    } catch (_) {
      return 'Chapter $nextNum';
    }
  }

  String get prevChapterTitle {
    final prevNum = currentChapterNumber.value - 1;
    try {
      final match = chapterList.firstWhere(
        (c) => c['chapter_number'] == prevNum,
      );
      return match['title'] ?? 'Chapter $prevNum';
    } catch (_) {
      return 'Chapter $prevNum';
    }
  }

  Future<void> loadChapterList(String storySlug) async {
    final res = await ApiService.getChapters(storySlug);
    if (res['success']) {
      final data = res['data'];
      final list = data is List ? data : (data['results'] ?? []);
      chapterList.value = List.from(list);
      totalChapters.value = chapterList.length;

      // Rebuild chapters for the contents panel
      chapters.clear();
      for (final c in chapterList) {
        chapters.add(
          Chapter(
            c['title'] ?? 'Chapter ${c['chapter_number']}',
            isRead: false,
          ),
        );
      }
    }
  }

  // ── Load a specific chapter ───────────────────────────────────────────────
  Future<void> loadChapter(
    String storySlug,
    int chapterNum,
    String? title,
  ) async {
    currentStorySlug = storySlug;
    currentChapterNumber.value = chapterNum;
    _currentChapter.value = title ?? 'Chapter $chapterNum';
    isLoadingChapter.value = true;
    chapterContent.value = '';

    // Fetch chapter list if we don't have it yet
    if (chapterList.isEmpty) {
      await loadChapterList(storySlug);
    }

    final res = await ApiService.getChapter(storySlug, chapterNum);
    isLoadingChapter.value = false;

    if (res['success']) {
      final data = res['data'];
      chapterContent.value = data['content'] ?? '';
      _currentChapter.value = data['title'] ?? title ?? 'Chapter $chapterNum';

      // Try to get story title from response
      if (data['story'] is Map) {
        _bookTitle.value = data['story']['title'] ?? _bookTitle.value;
      }

      // Scroll back to top for new chapter
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
      _readingProgress.value = 0.0;
    } else {
      chapterContent.value = res['error'] ?? 'Failed to load chapter.';
    }
  }

  // ── Chapter navigation ────────────────────────────────────────────────────
  Future<void> goNextChapter() async {
    if (!hasNextChapter || currentStorySlug == null) {
      return;
    }
    final nextNum = currentChapterNumber.value + 1;
    await loadChapter(currentStorySlug!, nextNum, nextChapterTitle);
  }

  Future<void> goPrevChapter() async {
    if (!hasPrevChapter || currentStorySlug == null) {
      return;
    }
    final prevNum = currentChapterNumber.value - 1;
    await loadChapter(currentStorySlug!, prevNum, prevChapterTitle);
  }

  void onScreenTap() {
    // If controls are already visible, hide them
    if (_showTopBar.value || _showBottomBar.value) {
      hideAllControls();
      return;
    }

    // Otherwise, show controls
    _showTopBar.value = true;
    _showBottomBar.value = true;
    _showListenButton.value = true;
  }

  void hideAllControls() {
    _showTopBar.value = false;
    _showBottomBar.value = false;
    _showSettings.value = false;
    _showContents.value = false;
    _showListenButton.value = false;
  }

  void toggleSettings() {
    _showSettings.value = !_showSettings.value;
    if (_showSettings.value) _showContents.value = false;
  }

  void toggleContents() {
    _showContents.value = !_showContents.value;
    if (_showContents.value) _showSettings.value = false;
  }

  void setBrightness(double v) => _brightness.value = v;
  void setFontSize(double v) => _fontSize.value = v;
  void setFont(String f) => _selectedFont.value = f;
  void setLineSpacing(int s) => _selectedLineSpacing.value = s;
  void setBackground(int i) => _selectedBackground.value = i;
  void setPageFlipEffect(String e) => _pageFlipEffect.value = e;
  void toggleVolumeKeyTurning() =>
      _volumeKeyTurning.value = !_volumeKeyTurning.value;

  Color get currentBackgroundColor => backgroundColors[selectedBackground];
  Color get currentTextColor {
    if (selectedBackground == 5) {
      return Colors.white;
    }
    if (selectedBackground == 0) {
      return const Color(0xFF8B4513);
    }
    return Colors.black87;
  }

  double get currentLineHeight {
    switch (selectedLineSpacing) {
      case 0:
        return 1.2;
      case 1:
        return 1.4;
      case 2:
        return 1.6;
      case 3:
        return 1.8;
      default:
        return 1.5;
    }
  }
}

class Chapter {
  final String title;
  final bool isRead;
  Chapter(this.title, {this.isRead = false});
}

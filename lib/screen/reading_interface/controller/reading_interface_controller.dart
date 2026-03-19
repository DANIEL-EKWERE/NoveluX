import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';

class ReadingInterfaceController extends GetxController {
  Rx<List> comments = Rx([]);

  // ── UI visibility ─────────────────────────────────────────────────────────
  final RxBool _showTopBar = false.obs;
  final RxBool _showBottomBar = false.obs;
  final RxBool _showSettings = false.obs;
  final RxBool _showContents = false.obs;
  final RxBool _showListenButton = false.obs;

  // ── Reading settings ──────────────────────────────────────────────────────
  final RxDouble _brightness = 0.5.obs;
  final RxDouble _fontSize = 18.0.obs;
  final RxString _selectedFont = 'Lora'.obs;
  final RxInt _selectedLineSpacing = 2.obs;
  final RxInt _selectedBackground = 4.obs; // default dark
  final RxString _pageFlipEffect = 'Flip'.obs;
  final RxBool _volumeKeyTurning = true.obs;

  // ── Content ───────────────────────────────────────────────────────────────
  final RxString _bookTitle = ''.obs;
  final RxString _currentChapter = 'Chapter 1'.obs;
  final RxInt _coins = 0.obs;
  final RxDouble _readingProgress = 0.0.obs;
  final RxString chapterContent = ''.obs;
  final RxBool isLoadingChapter = false.obs;

  // ── Navigation ────────────────────────────────────────────────────────────
  final RxInt currentChapterNumber = 1.obs;
  final RxInt totalChapters = 0.obs;
  final RxList chapterList = [].obs;
  String? currentStorySlug;

  late ScrollController scrollController;

  // ── Getters ───────────────────────────────────────────────────────────────
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

  // ── Navigation helpers ────────────────────────────────────────────────────
  bool get hasPrevChapter => currentChapterNumber.value > 1;
  bool get hasNextChapter {
    if (totalChapters.value > 0) {
      return currentChapterNumber.value < totalChapters.value;
    }
    return chapterList.isNotEmpty &&
        currentChapterNumber.value < chapterList.length;
  }

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

  // ── Static options ────────────────────────────────────────────────────────
  final List<String> fonts = ['System', 'Modern', 'Assistant', 'Lora'];
  final List<String> pageFlipEffects = [
    'Scroll ↔',
    'Scroll ↕',
    'Flip',
    'Animate',
  ];

  final List<Color> backgroundColors = [
    const Color(0xFFFFF2D4), // 0 Sepia
    const Color(0xFFFFFFFF), // 1 White
    const Color(0xFFE8F5E8), // 2 Green
    const Color(0xFFE3F2FD), // 3 Blue
    const Color(0xFF1a1a1a), // 4 Dark (default)
    const Color(0xFFFFE4EC), // 5 Pink
  ];

  final List<Chapter> chapters = [];

  // void showComments() {
  //   if (_storySlug == null || widget.chapterNumber == null) {
  //     return;
  //   }

  //   final commentCtrl = TextEditingController();
  //   final comments = <Map>[].obs;
  //   final loading = true.obs;
  //   final isSending = false.obs;
  //   final replyingTo = Rx<Map?>(null);
  //   final authCtrl = Get.find<AuthController>();

  //   ApiService.getComments(widget.storySlug!, widget.chapterNumber!).then((
  //     res,
  //   ) {
  //     loading.value = false;
  //     if (res['success']) {
  //       final d = res['data'];
  //       comments.value = List<Map>.from(d is List ? d : (d['results'] ?? []));
  //       comments.refresh();
  //     }
  //   });

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) {
      return;
    }
    final max = scrollController.position.maxScrollExtent;
    final cur = scrollController.offset;
    _readingProgress.value = max > 0 ? cur / max : 0.0;
  }

  // ── Volume key page turn ──────────────────────────────────────────────────
  void handleVolumeKey(RawKeyEvent event) {
    if (!_volumeKeyTurning.value) {
      return;
    }
    if (event is! RawKeyDownEvent) {
      return;
    }
    if (!scrollController.hasClients) {
      return;
    }
    final viewport = scrollController.position.viewportDimension;
    final max = scrollController.position.maxScrollExtent;
    final cur = scrollController.offset;
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
      scrollController.animateTo(
        (cur + viewport * 0.85).clamp(0.0, max),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
      scrollController.animateTo(
        (cur - viewport * 0.85).clamp(0.0, max),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Load chapter list ─────────────────────────────────────────────────────
  Future<void> loadChapterList(String storySlug) async {
    final res = await ApiService.getChapters(storySlug);
    if (res['success']) {
      final data = res['data'];
      final list = data is List ? data : (data['results'] ?? []);
      chapterList.value = List.from(list);
      totalChapters.value = chapterList.length;
      chapters.clear();
      for (final c in chapterList) {
        chapters.add(Chapter(c['title'] ?? 'Chapter ${c['chapter_number']}'));
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

    if (chapterList.isEmpty) {
      await loadChapterList(storySlug);
    }

    final res = await ApiService.getChapter(storySlug, chapterNum);
    isLoadingChapter.value = false;

    if (res['success']) {
      final data = res['data'];
      chapterContent.value = data['content'] ?? '';
      _currentChapter.value = data['title'] ?? title ?? 'Chapter $chapterNum';
      if (data['story'] is Map) {
        _bookTitle.value = data['story']['title'] ?? _bookTitle.value;
      }
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
      _readingProgress.value = 0.0;
    } else {
      chapterContent.value = res['error'] ?? 'Failed to load chapter.';
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  Future<void> goNextChapter() async {
    if (!hasNextChapter || currentStorySlug == null) {
      return;
    }
    await loadChapter(
      currentStorySlug!,
      currentChapterNumber.value + 1,
      nextChapterTitle,
    );
  }

  Future<void> goPrevChapter() async {
    if (!hasPrevChapter || currentStorySlug == null) {
      return;
    }
    await loadChapter(
      currentStorySlug!,
      currentChapterNumber.value - 1,
      prevChapterTitle,
    );
  }

  // ── UI controls ───────────────────────────────────────────────────────────
  void onScreenTap() {
    if (_showTopBar.value || _showBottomBar.value) {
      hideAllControls();
      return;
    }
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
    if (_showSettings.value) {
      _showContents.value = false;
    }
  }

  void toggleContents() {
    _showContents.value = !_showContents.value;
    if (_showContents.value) {
      _showSettings.value = false;
    }
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  void setBrightness(double v) => _brightness.value = v;
  void setFontSize(double v) => _fontSize.value = v;
  void setFont(String f) => _selectedFont.value = f;
  void setLineSpacing(int s) => _selectedLineSpacing.value = s;
  void setBackground(int i) => _selectedBackground.value = i;
  void setPageFlipEffect(String e) => _pageFlipEffect.value = e;
  void toggleVolumeKeyTurning() =>
      _volumeKeyTurning.value = !_volumeKeyTurning.value;

  // ── Theme ─────────────────────────────────────────────────────────────────
  Color get currentBackgroundColor => backgroundColors[selectedBackground];

  Color get currentTextColor {
    switch (selectedBackground) {
      case 0:
        return const Color(0xFF5C3317); // sepia brown
      case 4:
        return const Color(0xFFE8E8E8); // dark mode
      default:
        return const Color(0xFF1a1a1a); // light bgs
    }
  }

  double get currentLineHeight {
    switch (selectedLineSpacing) {
      case 0:
        return 1.2;
      case 1:
        return 1.5;
      case 2:
        return 1.8;
      case 3:
        return 2.2;
      default:
        return 1.8;
    }
  }

  String get progressPercent =>
      '${(_readingProgress.value * 100).toStringAsFixed(0)}%';
}

class Chapter {
  final String title;
  final bool isRead;
  Chapter(this.title, {this.isRead = false});
}

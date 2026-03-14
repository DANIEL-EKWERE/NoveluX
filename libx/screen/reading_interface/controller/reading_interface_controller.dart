import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadingInterfaceController extends GetxController {
  // UI State
  final RxBool _showTopBar = false.obs;
  final RxBool _showBottomBar = false.obs;
  final RxBool _showSettings = false.obs;
  final RxBool _showContents = false.obs;
  final RxBool _showListenButton = false.obs;
  final RxInt _tapCount = 0.obs;

  // Reading Settings
  final RxDouble _brightness = 0.5.obs;
  final RxDouble _fontSize = 18.0.obs;
  final RxString _selectedFont = 'Lora'.obs;
  final RxInt _selectedLineSpacing = 3.obs;
  final RxInt _selectedBackground = 0.obs;
  final RxString _pageFlipEffect = 'Flip'.obs;
  final RxBool _volumeKeyTurning = true.obs;

  // Page Management
  final RxInt _currentPageIndex = 0.obs;
  final RxList<String> _pages = <String>[].obs;
  final RxBool _isFlipping = false.obs;

  // Book Data
  final RxString _bookTitle = 'Expelled, But I Hatched a Dragon'.obs;
  final RxString _currentChapter = 'Chapter 1'.obs;
  final RxInt _coins = 5.obs;
  final RxDouble _readingProgress = 0.0.obs;
  final RxString _readingTime = '14:56'.obs;

  late ScrollController scrollController;

  // Getters
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
  String get readingTime => _readingTime.value;
  int get currentPageIndex => _currentPageIndex.value;
  List<String> get pages => _pages;
  bool get isFlipping => _isFlipping.value;

  final List<String> fonts = ['System', 'Modern', 'Assistant', 'Lora'];
  final List<Color> backgroundColors = [
    Color(0xFFFFF2D4), // Sepia
    Color(0xFFFFFFFF), // White
    Color(0xFFE8F5E8), // Light Green
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFFCE4EC), // Light Pink
  ];

  final List<String> pageFlipEffects = [
    'Scroll ↔',
    'Scroll ↕',
    'Flip',
    'Animate',
  ];

  final List<Chapter> chapters = [
    Chapter('Chapter 1 Su Yang', isRead: true),
    Chapter('Chapter 2 The fickleness of human relationships.', isRead: false),
    Chapter('Chapter 3 This pear should only exist in heaven.', isRead: false),
    Chapter('Chapter 4 Do you know who my cousin is?', isRead: false),
    Chapter('Chapter 5 Little Dragon', isRead: false),
    Chapter('Chapter 6 Beating up the village chief', isRead: false),
    Chapter('Chapter 7 No matter how long, I will wait.', isRead: false),
    Chapter('Chapter 8 Country Inn', isRead: false),
    Chapter('Chapter 9 Heartless Beauty', isRead: false),
    Chapter('Chapter 10 He is my boyfriend.', isRead: false),
  ];

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    _initializePages();
  }

  void _initializePages() {
    // Split content into pages for flip effect
    String fullContent = _getSampleContent();
    List<String> pageList = [];

    // Simple page splitting based on character count
    int charsPerPage = 1000;
    for (int i = 0; i < fullContent.length; i += charsPerPage) {
      int end =
          (i + charsPerPage < fullContent.length)
              ? i + charsPerPage
              : fullContent.length;
      pageList.add(fullContent.substring(i, end));
    }

    _pages.assignAll(pageList);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;
      _readingProgress.value = maxScroll > 0 ? currentScroll / maxScroll : 0.0;
    }
  }

  void onScreenTap() {
    _tapCount.value++;

    if (_tapCount.value == 1) {
      // First tap - show top and bottom bars
      _showTopBar.value = true;
      _showBottomBar.value = true;
      _showListenButton.value = true;

      // Hide after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (_tapCount.value == 1) {
          hideAllControls();
        }
      });
    }
  }

  void hideAllControls() {
    _showTopBar.value = false;
    _showBottomBar.value = false;
    _showSettings.value = false;
    _showContents.value = false;
    _showListenButton.value = false;
    _tapCount.value = 0;
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

  // Settings Methods
  void setBrightness(double value) => _brightness.value = value;
  void setFontSize(double value) => _fontSize.value = value;
  void setFont(String font) => _selectedFont.value = font;
  void setLineSpacing(int spacing) => _selectedLineSpacing.value = spacing;
  void setBackground(int index) => _selectedBackground.value = index;
  void setPageFlipEffect(String effect) {
    _pageFlipEffect.value = effect;
    if (effect == 'Flip' || effect == 'Animate') {
      _initializePages();
    }
  }

  void toggleVolumeKeyTurning() =>
      _volumeKeyTurning.value = !_volumeKeyTurning.value;

  // Page Navigation Methods
  void nextPage() {
    if (_isFlipping.value) return;

    switch (_pageFlipEffect.value) {
      case 'Flip':
      case 'Animate':
        _flipToNextPage();
        break;
      case 'Scroll ↕':
        _scrollVertical(true);
        break;
      case 'Scroll ↔':
      default:
        _scrollHorizontal(true);
        break;
    }
  }

  void previousPage() {
    if (_isFlipping.value) return;

    switch (_pageFlipEffect.value) {
      case 'Flip':
      case 'Animate':
        _flipToPreviousPage();
        break;
      case 'Scroll ↕':
        _scrollVertical(false);
        break;
      case 'Scroll ↔':
      default:
        _scrollHorizontal(false);
        break;
    }
  }

  void _flipToNextPage() {
    if (_currentPageIndex.value < _pages.length - 1) {
      _isFlipping.value = true;
      _currentPageIndex.value++;

      // Simulate flip animation duration
      Future.delayed(Duration(milliseconds: 600), () {
        _isFlipping.value = false;
      });
    }
  }

  void _flipToPreviousPage() {
    if (_currentPageIndex.value > 0) {
      _isFlipping.value = true;
      _currentPageIndex.value--;

      // Simulate flip animation duration
      Future.delayed(Duration(milliseconds: 600), () {
        _isFlipping.value = false;
      });
    }
  }

  void _scrollVertical(bool forward) {
    if (!scrollController.hasClients) return;

    final viewportHeight = scrollController.position.viewportDimension;
    final currentOffset = scrollController.offset;
    final maxScroll = scrollController.position.maxScrollExtent;

    double newOffset;
    if (forward) {
      newOffset = currentOffset + viewportHeight * 0.8;
      if (newOffset > maxScroll) newOffset = maxScroll;
    } else {
      newOffset = currentOffset - viewportHeight * 0.8;
      if (newOffset < 0) newOffset = 0;
    }

    scrollController.animateTo(
      newOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollHorizontal(bool forward) {
    // For horizontal scroll, we'll use page-based navigation
    _scrollVertical(forward);
  }

  Color get currentBackgroundColor => backgroundColors[selectedBackground];
  Color get currentTextColor =>
      selectedBackground == 0 ? Color(0xFF8B4513) : Colors.black87;

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

// NovelUP Controller
class NovelUpController extends GetxController {}

class Chapter {
  final String title;
  final bool isRead;

  Chapter(this.title, {this.isRead = false});
}

// Main Reading Interface
String _getSampleContent() {
  return """once he got better," the group perked up with interest. "Who told you that?"

"Yesterday, Sanpang came back and was talking to Su by the fish pond. I happened to overhear a bit," Aunt Wang said mysteriously. "He seemed like such a good kid, sigh."

Though their voices were low, Su Yang heard every word, a bitter taste rising in his heart. For two years, he'd endured countless cold remarks and sneers.

He looked down at his stomach, then gazed into the distance, his thoughts drifting far away.

Three years ago, at eighteen, Su Yang had been the top scorer in the college entrance exams in Cloud Sea City, bringing honor to the entire village. Everyone had praised him as a genius, destined for great things.

But fate had other plans. During his first year at university, he was involved in a terrible accident that left him in a coma for six months. When he finally woke up, he discovered that his spiritual core had been completely shattered.

In this world where cultivation determined one's status and future, losing one's spiritual core was equivalent to becoming a cripple. All his dreams and aspirations crumbled in an instant.

The village that had once celebrated him now whispered behind his back. Former friends avoided him, and even his own relatives treated him with pity mixed with disdain.

Su Yang clenched his fists, feeling the familiar ache in his chest. But today felt different somehow. As he sat by the pond, watching the ripples spread across the water's surface, he felt a strange warmth building within him.

Little did he know that this moment would mark the beginning of an extraordinary journey that would change not only his fate but the destiny of the entire realm.""";
}

// Additional required dependency for GetX:
// pubspec.yaml:
// dependencies:
//   get: ^4.6.6

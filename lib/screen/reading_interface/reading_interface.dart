import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:novelux/config/api_service.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/auth/auth_controller.dart';
import 'package:novelux/screen/book_preview/book_preview.dart';
import 'package:novelux/screen/reading_interface/controller/reading_interface_controller.dart';

class NovelUpReadingInterface extends StatefulWidget {
  final String? storySlug;
  final int? chapterNumber;
  final String? chapterTitle;

  const NovelUpReadingInterface({
    super.key,
    this.storySlug,
    this.chapterNumber,
    this.chapterTitle,
  });

  @override
  State<NovelUpReadingInterface> createState() =>
      _NovelUpReadingInterfaceState();
}

class _NovelUpReadingInterfaceState extends State<NovelUpReadingInterface>
    with TickerProviderStateMixin {
  late final ReadingInterfaceController ctrl;

  // Flip animation
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  String _prevContent = '';
  String _nextContent = '';
  bool _isAnimating = false;
  bool _flipForward = true;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(ReadingInterfaceController());

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut);

    if (widget.storySlug != null && widget.chapterNumber != null) {
      ctrl.loadChapter(
        widget.storySlug!,
        widget.chapterNumber!,
        widget.chapterTitle,
      );
    }
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  // ── Trigger flip then load chapter ───────────────────────────────────────
  Future<void> _navigateWithFlip(bool forward) async {
    if (_isAnimating) {
      return;
    }
    final useFlip =
        ctrl.pageFlipEffect == 'Flip' || ctrl.pageFlipEffect == 'Animate';

    if (useFlip) {
      setState(() {
        _isAnimating = true;
        _flipForward = forward;
        _prevContent = ctrl.chapterContent.value;
      });
      // Phase 1: fold out current page
      await _flipCtrl.forward();
      // Load the new chapter while page is "flipped away"
      if (forward) {
        await ctrl.goNextChapter();
      } else {
        await ctrl.goPrevChapter();
      }
      setState(() => _nextContent = ctrl.chapterContent.value);
      // Phase 2: unfold new page
      await _flipCtrl.reverse();
      setState(() => _isAnimating = false);
    } else {
      if (forward) {
        await ctrl.goNextChapter();
      } else {
        await ctrl.goPrevChapter();
      }
      ctrl.scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: ctrl.handleVolumeKey,
      child: Scaffold(
        body: Obx(
          () => Container(
            color: ctrl.currentBackgroundColor,
            child: Stack(
              children: [
                _buildContent(),
                if (ctrl.showTopBar) _buildTopBar(context),
                if (ctrl.showBottomBar) _buildBottomBar(),
                if (ctrl.showListenButton &&
                    !ctrl.showSettings &&
                    !ctrl.showContents)
                  _buildListenFab(),
                if (ctrl.showSettings)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildSettingsPanel(),
                  ),
                if (ctrl.showContents) _buildContentsPanel(),
                if (ctrl.isLoadingChapter.value)
                  Container(
                    color: Colors.black38,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Page content with flip animation ─────────────────────────────────────
  Widget _buildContent() {
    return GestureDetector(
      onTap: ctrl.onScreenTap,
      child: AnimatedBuilder(
        animation: _flipAnim,
        builder: (_, __) {
          final useFlip =
              (ctrl.pageFlipEffect == 'Flip' ||
                  ctrl.pageFlipEffect == 'Animate') &&
              _isAnimating;

          if (!useFlip) {
            return Obx(() => _scrollPage(ctrl.chapterContent.value));
          }

          // 3-D page flip using Matrix4
          final angle = _flipAnim.value * math.pi;
          final isBack = angle > math.pi / 2;
          final displayContent = isBack ? _nextContent : _prevContent;

          return Transform(
            alignment:
                _flipForward ? Alignment.centerRight : Alignment.centerLeft,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipForward ? -angle : angle),
            child: _scrollPage(displayContent),
          );
        },
      ),
    );
  }

  Widget _scrollPage(String content) => SingleChildScrollView(
    controller: ctrl.scrollController,
    padding: const EdgeInsets.fromLTRB(24, 80, 24, 160),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chapter title
        Text(
          ctrl.currentChapter,
          style: TextStyle(
            fontSize: ctrl.fontSize + 4,
            fontWeight: FontWeight.bold,
            color: ctrl.currentTextColor,
            fontFamily:
                ctrl.selectedFont == 'System' ? null : ctrl.selectedFont,
          ),
        ),
        const SizedBox(height: 20),
        // Body
        Text(
          content.isNotEmpty ? content : 'Loading...',
          style: TextStyle(
            fontSize: ctrl.fontSize,
            color: ctrl.currentTextColor,
            height: ctrl.currentLineHeight,
            fontFamily:
                ctrl.selectedFont == 'System' ? null : ctrl.selectedFont,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 40),
        // End of chapter actions
        if (!ctrl.isLoadingChapter.value && content.isNotEmpty)
          Builder(
            builder:
                (ctx) => _EndOfChapterSection(
                  storySlug: widget.storySlug,
                  chapterNumber: widget.chapterNumber,
                  controller: ctrl,
                  onCommentTap: () => _showComments(ctx),
                  onNext:
                      ctrl.hasNextChapter
                          ? () => _navigateWithFlip(true)
                          : null,
                  onPrev:
                      ctrl.hasPrevChapter
                          ? () => _navigateWithFlip(false)
                          : null,
                ),
          ),
        const SizedBox(height: 80),
      ],
    ),
  );

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      color: ctrl.currentBackgroundColor.withOpacity(0.97),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: ctrl.currentTextColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(
                  () => Text(
                    ctrl.currentChapter,
                    style: TextStyle(
                      color: ctrl.currentTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.white,
                      size: 14,
                    ),
                    Obx(
                      () => Text(
                        ' +${ctrl.coins}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: ctrl.currentTextColor,
                  size: 20,
                ),
                color: const Color(0xFF2a2a2a),
                onSelected: (v) {
                  if (v == 'vip') {
                    Get.snackbar(
                      'VIP',
                      'VIP Ad-Free coming soon!',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  }
                },
                itemBuilder:
                    (_) => [
                      const PopupMenuItem(
                        value: 'vip',
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            SizedBox(width: 10),
                            Text(
                              'VIP Ad-Free',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ── Bottom bar with progress ──────────────────────────────────────────────
  Widget _buildBottomBar() => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Container(
        color: ctrl.currentBackgroundColor.withOpacity(0.97),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress slider + prev/next chapter chevrons
            Obx(
              () => Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color:
                            ctrl.hasPrevChapter
                                ? ctrl.currentTextColor
                                : Colors.grey,
                        size: 26,
                      ),
                      onPressed:
                          ctrl.hasPrevChapter
                              ? () => _navigateWithFlip(false)
                              : null,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          activeTrackColor: Colors.orange,
                          inactiveTrackColor: Colors.grey[700],
                          thumbColor: Colors.orange,
                        ),
                        child: Slider(
                          value: ctrl.readingProgress.clamp(0.0, 1.0),
                          min: 0,
                          max: 1,
                          onChanged: (v) {
                            if (ctrl.scrollController.hasClients) {
                              final max =
                                  ctrl
                                      .scrollController
                                      .position
                                      .maxScrollExtent;
                              ctrl.scrollController.jumpTo(v * max);
                            }
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color:
                            ctrl.hasNextChapter
                                ? ctrl.currentTextColor
                                : Colors.grey,
                        size: 26,
                      ),
                      onPressed:
                          ctrl.hasNextChapter
                              ? () => _navigateWithFlip(true)
                              : null,
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons row
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navBtn(
                    LucideIcons.libraryBig300,
                    'Contents',
                    ctrl.toggleContents,
                  ),
                  _navBtn(
                    LucideIcons.moon300,
                    'Dark mode',
                    () => ctrl.setBackground(
                      ctrl.selectedBackground == 4 ? 1 : 4,
                    ),
                  ),
                  _navBtn(
                    LucideIcons.settings200,
                    'Settings',
                    ctrl.toggleSettings,
                  ),
                  _navBtn(
                    LucideIcons.bookDown300,
                    'Download',
                    () => Get.snackbar(
                      'Download',
                      'Coming soon!',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _navBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ctrl.currentTextColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: ctrl.currentTextColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  // ── Listen FAB ────────────────────────────────────────────────────────────
  Widget _buildListenFab() => Positioned(
    bottom: 140,
    right: 20,
    child: GestureDetector(
      onTap:
          () => Get.snackbar(
            'Audio',
            'Coming soon!',
            backgroundColor: depperBlue,
            colorText: Colors.white,
          ),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black87,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.headphones300, color: Colors.white, size: 20),
            SizedBox(height: 2),
            Text('Listen', style: TextStyle(color: Colors.white, fontSize: 8)),
          ],
        ),
      ),
    ),
  );

  // ── Settings panel — pixel-perfect match to screenshot ───────────────────
  Widget _buildSettingsPanel() {
    final bg = ctrl.currentBackgroundColor;
    final labelColor = Colors.grey[500]!;

    return Container(
      constraints: const BoxConstraints(maxHeight: 560),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Brightness ────────────────────────────────────────────────
            Text(
              'Brightness',
              style: TextStyle(fontSize: 11, color: labelColor),
            ),
            Row(
              children: [
                Icon(Icons.brightness_low, color: Colors.grey[500], size: 20),
                Expanded(
                  child: Obx(
                    () => Slider(
                      value: ctrl.brightness,
                      onChanged: ctrl.setBrightness,
                      activeColor: Colors.orange,
                      inactiveColor: Colors.grey[700],
                    ),
                  ),
                ),
                Icon(Icons.brightness_high, color: Colors.grey[500], size: 20),
              ],
            ),

            // ── Font size ─────────────────────────────────────────────────
            Text(
              'Font size',
              style: TextStyle(fontSize: 11, color: labelColor),
            ),
            Row(
              children: [
                Text(
                  'A-',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                Expanded(
                  child: Obx(
                    () => Slider(
                      value: ctrl.fontSize,
                      min: 12,
                      max: 28,
                      onChanged: ctrl.setFontSize,
                      activeColor: Colors.orange,
                      inactiveColor: Colors.grey[700],
                    ),
                  ),
                ),
                Text(
                  'A+',
                  style: TextStyle(fontSize: 17, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ── Fonts ─────────────────────────────────────────────────────
            Text('Fonts', style: TextStyle(fontSize: 11, color: labelColor)),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children:
                    ctrl.fonts.map((f) {
                      final sel = ctrl.selectedFont == f;
                      return GestureDetector(
                        onTap: () => ctrl.setFont(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: sel ? Colors.orange : Colors.grey[600]!,
                              width: sel ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: f == 'System' ? null : f,
                              color: sel ? Colors.orange : Colors.grey[500],
                              fontWeight:
                                  sel ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Line spacing — horizontal line icons like screenshot ──────
            Text(
              'Line spacing',
              style: TextStyle(fontSize: 11, color: labelColor),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: List.generate(4, (i) {
                  final sel = ctrl.selectedLineSpacing == i;
                  // Draw i+2 horizontal lines to represent spacing visually
                  return GestureDetector(
                    onTap: () => ctrl.setLineSpacing(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: sel ? Colors.orange : Colors.grey[600]!,
                          width: sel ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          i + 2,
                          (j) => Container(
                            width: 22,
                            height: 2.5,
                            margin: EdgeInsets.only(
                              bottom: j < i + 1 ? (2.5 + i * 1.0) : 0,
                            ),
                            color: sel ? Colors.orange : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),

            // ── Background color — pill shapes like screenshot ────────────
            Text(
              'Background color',
              style: TextStyle(fontSize: 11, color: labelColor),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Row(
                spacing: 1.0,
                children: List.generate(ctrl.backgroundColors.length, (i) {
                  final sel = ctrl.selectedBackground == i;
                  return GestureDetector(
                    onTap: () => ctrl.setBackground(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 4),
                      width: 43,
                      height: 25,
                      decoration: BoxDecoration(
                        color: ctrl.backgroundColors[i],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: sel ? Colors.orange : Colors.grey[600]!,
                          width: sel ? 2.5 : 1,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // ── Page flip effect ──────────────────────────────────────────
            Text(
              'Page flip effect',
              style: TextStyle(fontSize: 11, color: labelColor),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children:
                    ctrl.pageFlipEffects.map((e) {
                      final sel = ctrl.pageFlipEffect == e;
                      return GestureDetector(
                        onTap: () => ctrl.setPageFlipEffect(e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: sel ? Colors.orange : Colors.grey[600]!,
                              width: sel ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 10,
                              color: sel ? Colors.orange : Colors.grey[500],
                              fontWeight:
                                  sel ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            //  const SizedBox(height: 10),

            // ── Volume key toggle ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page turning by volume keys',
                  style: TextStyle(fontSize: 11, color: labelColor),
                ),
                Obx(
                  () => Switch(
                    value: ctrl.volumeKeyTurning,
                    onChanged: (_) => ctrl.toggleVolumeKeyTurning(),
                    activeColor: Colors.orange,
                    inactiveThumbColor: Colors.grey,
                    trackOutlineColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Contents panel ────────────────────────────────────────────────────────
  Widget _buildContentsPanel() => Positioned.fill(
    child: Container(
      color: const Color(0xFF1a1a1a),
      child: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: ctrl.hideAllControls,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            Obx(
              () => Text(
                ctrl.bookTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(color: Color(0xFF2a2a2a)),
            Expanded(
              child: Obx(
                () =>
                    ctrl.chapters.isEmpty
                        ? const Center(
                          child: Text(
                            'No chapters loaded',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: ctrl.chapters.length,
                          itemBuilder: (_, i) {
                            final ch = ctrl.chapters[i];
                            final isCurrent = ctrl.currentChapter == ch.title;
                            return ListTile(
                              leading: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color:
                                      isCurrent
                                          ? Colors.orange
                                          : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              title: Text(
                                ch.title,
                                style: TextStyle(
                                  color:
                                      isCurrent ? Colors.orange : Colors.white,
                                  fontSize: 14,
                                  fontWeight:
                                      isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                              trailing:
                                  ch.isRead
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      )
                                      : null,
                              onTap: () {
                                ctrl.hideAllControls();
                                if (widget.storySlug != null) {
                                  ctrl.loadChapter(
                                    widget.storySlug!,
                                    i + 1,
                                    ch.title,
                                  );
                                }
                              },
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // ── Comment sheet ─────────────────────────────────────────────────────────
  void _showComments(BuildContext ctx) {
    if (widget.storySlug == null || widget.chapterNumber == null) {
      return;
    }

    final commentCtrl = TextEditingController();
    final comments = <Map>[].obs;
    final loading = true.obs;
    final isSending = false.obs;
    final replyingTo = Rx<Map?>(null);
    final authCtrl = Get.find<AuthController>();

    ApiService.getComments(widget.storySlug!, widget.chapterNumber!).then((
      res,
    ) {
      loading.value = false;
      if (res['success']) {
        final d = res['data'];
        comments.value = List<Map>.from(d is List ? d : (d['results'] ?? []));
        comments.refresh();
      }
    });

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            builder:
                (__, sc) => Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Text(
                        'Comments${comments.isNotEmpty ? "  (${comments.length})" : ""}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFF2a2a2a)),
                    Expanded(
                      child: Obx(() {
                        if (loading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          );
                        }
                        if (comments.isEmpty) {
                          return const Center(
                            child: Text(
                              'Be the first to comment!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: sc,
                          itemCount: comments.length,
                          itemBuilder: (_, i) {
                            final c = comments[i];
                            final user =
                                c['user'] is Map
                                    ? c['user'] as Map
                                    : <String, dynamic>{};
                            final username =
                                user['username']?.toString().isNotEmpty == true
                                    ? user['username'].toString()
                                    : authCtrl.username;
                            final avatar = user['avatar']?.toString() ?? '';
                            final initial =
                                username.isNotEmpty
                                    ? username[0].toUpperCase()
                                    : '?';
                            final replies = (c['replies'] as List? ?? []);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: depperBlue,
                                        radius: 18,
                                        backgroundImage:
                                            avatar.isNotEmpty
                                                ? NetworkImage(
                                                  avatar.startsWith('http')
                                                      ? avatar
                                                      : 'http://10.0.2.2:8000$avatar',
                                                )
                                                : null,
                                        child:
                                            avatar.isEmpty
                                                ? Text(
                                                  initial,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                                : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              username,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              c['content']?.toString() ?? '',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                _LikeButton(
                                                  comment: c,
                                                  onLikeChanged: (
                                                    liked,
                                                    count,
                                                  ) {
                                                    final u = Map<
                                                      String,
                                                      dynamic
                                                    >.from(c);
                                                    u['likes_count'] = count;
                                                    u['is_liked'] = liked;
                                                    comments[i] = u;
                                                    comments.refresh();
                                                  },
                                                ),
                                                const SizedBox(width: 16),
                                                GestureDetector(
                                                  onTap: () {
                                                    replyingTo.value = c;
                                                    commentCtrl.clear();
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.reply,
                                                        size: 15,
                                                        color: Colors.grey[500],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Reply',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[500],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (replies.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 46),
                                    child: Column(
                                      children:
                                          replies.map((r) {
                                            final ru =
                                                r['user'] is Map
                                                    ? r['user'] as Map
                                                    : <String, dynamic>{};
                                            final rn =
                                                ru['username']
                                                            ?.toString()
                                                            .isNotEmpty ==
                                                        true
                                                    ? ru['username'].toString()
                                                    : '?';
                                            final ra =
                                                ru['avatar']?.toString() ?? '';
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    12,
                                                    6,
                                                    12,
                                                    0,
                                                  ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 2,
                                                    height: 40,
                                                    color: Colors.grey[800],
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 8,
                                                        ),
                                                  ),
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    radius: 14,
                                                    backgroundImage:
                                                        ra.isNotEmpty
                                                            ? NetworkImage(
                                                              ra.startsWith(
                                                                    'http',
                                                                  )
                                                                  ? ra
                                                                  : 'http://10.0.2.2:8000$ra',
                                                            )
                                                            : null,
                                                    child:
                                                        ra.isEmpty
                                                            ? Text(
                                                              rn.isNotEmpty
                                                                  ? rn[0]
                                                                      .toUpperCase()
                                                                  : '?',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 10,
                                                              ),
                                                            )
                                                            : null,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          rn,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          r['content']
                                                                  ?.toString() ??
                                                              '',
                                                          style: const TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                const Divider(
                                  color: Color(0xFF2a2a2a),
                                  height: 16,
                                  indent: 12,
                                  endIndent: 12,
                                ),
                              ],
                            );
                          },
                        );
                      }),
                    ),

                    // Reply banner
                    Obx(
                      () =>
                          replyingTo.value != null
                              ? Container(
                                color: const Color(0xFF2a2a2a),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.reply,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Replying to ${replyingTo.value!['user'] is Map ? replyingTo.value!['user']['username'] ?? 'comment' : 'comment'}',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        replyingTo.value = null;
                                        commentCtrl.clear();
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.grey,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),

                    // Input
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(ctx).viewInsets.bottom + 8,
                        left: 16,
                        right: 16,
                        top: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => TextField(
                                controller: commentCtrl,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.send,
                                onSubmitted:
                                    (_) => _submitComment(
                                      commentCtrl,
                                      comments,
                                      isSending,
                                      authCtrl,
                                      replyingTo,
                                    ),
                                decoration: InputDecoration(
                                  hintText:
                                      replyingTo.value != null
                                          ? 'Write a reply...'
                                          : 'Write a comment...',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF2a2a2a),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(
                            () => GestureDetector(
                              onTap:
                                  isSending.value
                                      ? null
                                      : () => _submitComment(
                                        commentCtrl,
                                        comments,
                                        isSending,
                                        authCtrl,
                                        replyingTo,
                                      ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      isSending.value
                                          ? Colors.grey[700]
                                          : depperBlue,
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    isSending.value
                                        ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _submitComment(
    TextEditingController commentCtrl,
    RxList<Map> comments,
    RxBool isSending,
    AuthController authCtrl,
    Rx<Map?> replyingTo,
  ) async {
    final text = commentCtrl.text.trim();
    if (text.isEmpty || isSending.value) {
      return;
    }

    isSending.value = true;
    final parentId = replyingTo.value?['id'] as int?;
    final res = await ApiService.postComment(
      widget.storySlug!,
      widget.chapterNumber!,
      text,
      parentId: parentId,
    );
    isSending.value = false;

    if (res['success']) {
      commentCtrl.clear();
      final raw = Map<String, dynamic>.from(res['data'] as Map);
      final userRes = raw['user'];
      if (userRes is! Map ||
          userRes['username']?.toString().isNotEmpty != true) {
        raw['user'] = {
          'id': authCtrl.currentUser.value?['id'],
          'username': authCtrl.username,
          'avatar': authCtrl.avatar ?? '',
        };
      }
      raw['likes_count'] ??= 0;
      raw['content'] ??= text;
      raw['replies'] ??= [];

      if (parentId != null) {
        final idx = comments.indexWhere((c) => c['id'] == parentId);
        if (idx != -1) {
          final updated = Map<String, dynamic>.from(comments[idx]);
          final reps = List<Map>.from(updated['replies'] ?? []);
          reps.add(raw);
          updated['replies'] = reps;
          comments[idx] = updated;
          comments.refresh();
        }
        replyingTo.value = null;
      } else {
        comments.insert(0, raw);
        comments.refresh();
      }
    } else {
      Get.snackbar(
        'Error',
        res['error'] ?? 'Could not post comment',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

// ── End of Chapter Section ────────────────────────────────────────────────────
class _Gift {
  final String emoji;
  final String label;
  final int coins;
  const _Gift(this.emoji, this.label, this.coins);
}

const _gifts = [
  _Gift('🌸', 'Flower', 0),
  _Gift('❤️', 'Like', 10),
  _Gift('🍦', 'Ice pop', 50),
  _Gift('☕', 'Coffee', 100),
  _Gift('🍾', 'Champagne', 500),
  _Gift('🚗', 'Luxury Car', 1000),
];

class _EndOfChapterSection extends StatefulWidget {
  final String? storySlug;
  final int? chapterNumber;
  final VoidCallback onCommentTap;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
  final ReadingInterfaceController controller;

  const _EndOfChapterSection({
    required this.storySlug,
    required this.chapterNumber,
    required this.onCommentTap,
    required this.controller,
    this.onNext,
    this.onPrev,
  });

  @override
  State<_EndOfChapterSection> createState() => _EndOfChapterSectionState();
}

class _EndOfChapterSectionState extends State<_EndOfChapterSection> {
  int? _selectedGiftIndex;
  bool _isSending = false;

  Future<void> _sendGift(_Gift gift) async {
    if (_isSending) {
      return;
    }
    if (gift.coins == 0) {
      Get.snackbar(
        '📺 Free Gift',
        'AdMob rewarded ad coming soon!',
        backgroundColor: const Color(0xFF2a2a2a),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    setState(() => _isSending = true);
    final res = await ApiService.sendTip(
      widget.storySlug!,
      gift.coins,
      message: 'Sent a ${gift.label} gift!',
    );
    setState(() => _isSending = false);
    if (res['success']) {
      Get.snackbar(
        '${gift.emoji} Gift Sent!',
        'You sent a ${gift.label} to the author!',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      setState(() => _selectedGiftIndex = null);
      Get.snackbar(
        'Error',
        res['error'] ?? 'Could not send gift',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Prev / Next buttons ──────────────────────────────────────────
        Obx(
          () => Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onPrev,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    margin: const EdgeInsets.only(bottom: 12, right: 5),
                    decoration: BoxDecoration(
                      color:
                          ctrl.hasPrevChapter
                              ? const Color(0xFF2a2a2a)
                              : const Color(0xFF1a1a1a),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            ctrl.hasPrevChapter
                                ? Colors.grey[600]!
                                : Colors.grey[800]!,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_rounded,
                          color:
                              ctrl.hasPrevChapter
                                  ? Colors.white
                                  : Colors.grey[700],
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Previous',
                          style: TextStyle(
                            color:
                                ctrl.hasPrevChapter
                                    ? Colors.white
                                    : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (ctrl.hasPrevChapter)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 2,
                              left: 8,
                              right: 8,
                            ),
                            child: Text(
                              ctrl.prevChapterTitle,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onNext,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    margin: const EdgeInsets.only(bottom: 12, left: 5),
                    decoration: BoxDecoration(
                      color:
                          ctrl.hasNextChapter
                              ? depperBlue
                              : const Color(0xFF1a1a1a),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            ctrl.hasNextChapter
                                ? depperBlue
                                : Colors.grey[800]!,
                      ),
                    ),
                    child:
                        ctrl.isLoadingChapter.value
                            ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                            : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color:
                                      ctrl.hasNextChapter
                                          ? Colors.white
                                          : Colors.grey[700],
                                  size: 18,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ctrl.hasNextChapter
                                      ? 'Next Chapter'
                                      : 'Last Chapter',
                                  style: TextStyle(
                                    color:
                                        ctrl.hasNextChapter
                                            ? Colors.white
                                            : Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (ctrl.hasNextChapter)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 2,
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Text(
                                      ctrl.nextChapterTitle,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Leave a comment bar ──────────────────────────────────────────
        GestureDetector(
          onTap: widget.onCommentTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2a2a2a),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  LucideIcons.messageCirclePlus300,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Leave a comment',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                //Text(ctrl.),
                Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),

        // ── Gift section ─────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a2a),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Author thank-you
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: depperBlue.withValues(alpha: .2),
                      child:
                      // Obx(
                      //   () =>
                      Text(
                        ctrl.currentStorySlug!.isNotEmpty
                            ? ctrl.currentStorySlug![0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: depperBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        //),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child:
                                // Obx(
                                //   () =>
                                Text(
                                  ctrl.currentStorySlug!
                                      .replaceAll('-', ' ')
                                      .capitalize
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                //  ),
                              ),
                              const SizedBox(width: 8),
                              // SizedBox(
                              //   width: 150,
                              //   child: Text(
                              //     ctrl.currentStorySlug.toString(),
                              //   ),
                              // ),
                              // Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: depperBlue.withValues(alpha: .2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Author',
                                  style: TextStyle(
                                    color: depperBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Thanks for your support, it motivates me to keep writing.',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF3a3a3a), height: 1),

              // Gift grid
              Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _gifts.length,
                  itemBuilder: (_, i) {
                    final gift = _gifts[i];
                    final isSelected = _selectedGiftIndex == i;
                    final isFree = gift.coins == 0;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedGiftIndex = i);
                        _sendGift(gift);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e1e1e),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                isSelected ? Colors.orange : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (isFree)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'Ad',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    gift.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    gift.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isFree ? 'Free' : '🪙 ${gift.coins}',
                                    style: TextStyle(
                                      color:
                                          isFree
                                              ? Colors.green
                                              : Colors.orange[300],
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Send button
              if (_selectedGiftIndex != null &&
                  _gifts[_selectedGiftIndex!].coins > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          _isSending
                              ? null
                              : () => _sendGift(_gifts[_selectedGiftIndex!]),
                      child:
                          _isSending
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _gifts[_selectedGiftIndex!].emoji,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Send ${_gifts[_selectedGiftIndex!].label}  •  🪙 ${_gifts[_selectedGiftIndex!].coins}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Like Button ───────────────────────────────────────────────────────────────
class _LikeButton extends StatefulWidget {
  final Map comment;
  final Function(bool liked, int newCount) onLikeChanged;
  const _LikeButton({required this.comment, required this.onLikeChanged});
  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late bool _liked;
  late int _count;
  bool _loading = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _liked = widget.comment['is_liked'] == true;
    _count = (widget.comment['likes_count'] ?? 0) as int;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_loading) {
      return;
    }
    final wasLiked = _liked;
    setState(() {
      _loading = true;
      if (wasLiked) {
        _liked = false;
        _count = (_count - 1).clamp(0, 99999);
      } else {
        _liked = true;
        _count++;
        _animCtrl.forward().then((_) => _animCtrl.reverse());
      }
    });
    widget.onLikeChanged(_liked, _count);
    final id = widget.comment['id'] as int;
    final res =
        wasLiked
            ? await ApiService.unlikeComment(id)
            : await ApiService.likeComment(id);
    setState(() => _loading = false);
    if (!res['success']) {
      setState(() {
        _liked = wasLiked;
        _count = wasLiked ? _count + 1 : (_count - 1).clamp(0, 99999);
      });
      widget.onLikeChanged(_liked, _count);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _toggle,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Icon(
              _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
              size: 16,
              color: _liked ? depperBlue : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder:
                (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Text(
              '$_count',
              key: ValueKey(_count),
              style: TextStyle(
                color: _liked ? depperBlue : Colors.grey[600],
                fontSize: 12,
                fontWeight: _liked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

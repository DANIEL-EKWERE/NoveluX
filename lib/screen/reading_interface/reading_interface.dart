import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/auth/auth_controller.dart';
import 'package:novelux/screen/reading_interface/controller/reading_interface_controller.dart';

class NovelUpReadingInterface extends StatelessWidget {
  final String? storySlug;
  final int? chapterNumber;
  final String? chapterTitle;

  NovelUpReadingInterface({
    super.key,
    this.storySlug,
    this.chapterNumber,
    this.chapterTitle,
  });

  final ReadingInterfaceController controller = Get.put(
    ReadingInterfaceController(),
  );

  @override
  Widget build(BuildContext context) {
    if (storySlug != null && chapterNumber != null) {
      controller.loadChapter(storySlug!, chapterNumber!, chapterTitle);
    }

    return Scaffold(
      body: Obx(
        () => Container(
          color: controller.currentBackgroundColor,
          child: Stack(
            children: [
              _buildMainContent(),
              if (controller.showTopBar) _buildTopBar(),
              if (controller.showBottomBar) _buildBottomBar(),
              if (controller.showListenButton &&
                  !controller.showSettings &&
                  !controller.showContents)
                _buildListenButton(),
              if (controller.showSettings)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(height: 420, child: _buildSettingsPanel()),
                ),
              if (controller.showContents) _buildContentsPanel(),
              if (controller.isLoadingChapter.value)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Main scrollable content ─────────────────────────────────────────────
  Widget _buildMainContent() {
    return GestureDetector(
      onTap: controller.onScreenTap,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Obx(
          () => SingleChildScrollView(
            controller: controller.scrollController,
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.currentChapter,
                  style: TextStyle(
                    fontSize: controller.fontSize + 4,
                    fontWeight: FontWeight.bold,
                    color: controller.currentTextColor,
                    fontFamily:
                        controller.selectedFont == 'System'
                            ? null
                            : controller.selectedFont,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  controller.chapterContent.value.isNotEmpty
                      ? controller.chapterContent.value
                      : 'Loading chapter content...',
                  style: TextStyle(
                    fontSize: controller.fontSize,
                    color: controller.currentTextColor,
                    height: controller.currentLineHeight,
                    fontFamily:
                        controller.selectedFont == 'System'
                            ? null
                            : controller.selectedFont,
                  ),
                ),
                const SizedBox(height: 40),
                if (!controller.isLoadingChapter.value &&
                    controller.chapterContent.value.isNotEmpty)
                  Builder(builder: (ctx) => _buildEndOfChapterActions(ctx)),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── End of chapter ──────────────────────────────────────────────────────
  Widget _buildEndOfChapterActions(BuildContext ctx) {
    return _EndOfChapterSection(
      storySlug: storySlug,
      chapterNumber: chapterNumber,
      onCommentTap: () => _showComments(ctx),
    );
  }

  void _sendTip(int coins) async {
    if (storySlug == null) {
      return;
    }
    final res = await ApiService.sendTip(storySlug!, coins);
    if (res['success']) {
      Get.snackbar(
        'Tip Sent! 🎉',
        'You sent $coins coins to the author',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        res['error'] ?? 'Could not send tip',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ── Comment sheet ────────────────────────────────────────────────────────
  void _showComments(BuildContext ctx) {
    if (storySlug == null || chapterNumber == null) {
      return;
    }

    final commentCtrl = TextEditingController();
    final comments = <Map>[].obs; // RxList — triggers Obx on any change
    final loading = true.obs;
    final isSending = false.obs;
    final authCtrl = Get.find<AuthController>();

    // Fetch existing comments
    ApiService.getComments(storySlug!, chapterNumber!).then((res) {
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

                    // ── Header with live count ──────────────────────────────────────
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

                    // ── Comment list ────────────────────────────────────────────────
                    Expanded(
                      child: Obx(() {
                        if (loading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
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

                            // Safely extract user — API may return Map or null
                            final user =
                                (c['user'] is Map)
                                    ? c['user'] as Map
                                    : <String, dynamic>{};

                            final username =
                                user['username']?.toString().isNotEmpty == true
                                    ? user['username'].toString()
                                    : authCtrl.username;

                            final avatarUrl = user['avatar']?.toString() ?? '';
                            final initial =
                                username.isNotEmpty
                                    ? username[0].toUpperCase()
                                    : '?';

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: depperBlue,
                                radius: 20,
                                backgroundImage:
                                    avatarUrl.isNotEmpty
                                        ? NetworkImage(
                                          avatarUrl.startsWith('http')
                                              ? avatarUrl
                                              : 'http://10.0.2.2:8000$avatarUrl',
                                        )
                                        : null,
                                child:
                                    avatarUrl.isEmpty
                                        ? Text(
                                          initial,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                        : null,
                              ),
                              title: Text(
                                username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  c['content']?.toString() ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              trailing: _LikeButton(
                                comment: c,
                                onLikeChanged: (liked, newCount) {
                                  // Update the map in place and refresh the list
                                  final updated = Map<String, dynamic>.from(c);
                                  updated['likes_count'] = newCount;
                                  updated['is_liked'] = liked;
                                  comments[i] = updated;
                                  comments.refresh();
                                },
                              ),
                            );
                          },
                        );
                      }),
                    ),

                    // ── Input row ──────────────────────────────────────────────────
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
                            child: TextField(
                              controller: commentCtrl,
                              style: const TextStyle(color: Colors.white),
                              textInputAction: TextInputAction.send,
                              onSubmitted:
                                  (_) => _submitComment(
                                    commentCtrl,
                                    comments,
                                    isSending,
                                    authCtrl,
                                  ),
                              decoration: InputDecoration(
                                hintText: 'Write a comment...',
                                hintStyle: const TextStyle(color: Colors.grey),
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

  // ── Submit comment ────────────────────────────────────────────────────────
  Future<void> _submitComment(
    TextEditingController commentCtrl,
    RxList<Map> comments,
    RxBool isSending,
    AuthController authCtrl,
  ) async {
    final text = commentCtrl.text.trim();
    if (text.isEmpty || isSending.value) {
      return;
    }

    isSending.value = true;
    final res = await ApiService.postComment(storySlug!, chapterNumber!, text);
    isSending.value = false;

    if (res['success']) {
      commentCtrl.clear();

      // Build a guaranteed-complete comment map so UI shows immediately
      final raw = Map<String, dynamic>.from(res['data'] as Map);

      // Inject current user if API didn't return full user object
      final userInResponse = raw['user'];
      final hasUsername =
          userInResponse is Map &&
          userInResponse['username']?.toString().isNotEmpty == true;

      if (!hasUsername) {
        raw['user'] = {
          'id': authCtrl.currentUser.value?['id'],
          'username': authCtrl.username,
          'avatar': authCtrl.avatar ?? '',
        };
      }

      // Ensure defaults for display fields
      raw['likes_count'] ??= 0;
      raw['content'] ??= text;

      // Insert at top + force refresh so Obx rebuilds immediately
      comments.insert(0, raw);
      comments.refresh();
    } else {
      Get.snackbar(
        'Error',
        res['error'] ?? 'Could not post comment',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ── Top bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar() => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      color: controller.currentBackgroundColor.withOpacity(0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color:
                      controller.selectedBackground == 4
                          ? Colors.white
                          : Colors.black87,
                  size: 18,
                ),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    controller.currentChapter,
                    style: TextStyle(
                      color:
                          controller.selectedBackground == 4
                              ? Colors.white
                              : Colors.black87,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(15),
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
                        ' ${controller.coins}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    ),
  );

  // ── Bottom bar ───────────────────────────────────────────────────────────
  Widget _buildBottomBar() => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btnBar(Icons.list, 'Contents', controller.toggleContents),
              _btnBar(Icons.settings, 'Settings', controller.toggleSettings),
              _btnBar(Icons.download, 'Download', () {}),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _btnBar(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      );

  // ── Listen button ────────────────────────────────────────────────────────
  Widget _buildListenButton() => Positioned(
    bottom: 100,
    right: 20,
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headphones, color: Colors.white, size: 22),
          Text('Listen', style: TextStyle(color: Colors.white, fontSize: 9)),
        ],
      ),
    ),
  );

  // ── Settings panel ───────────────────────────────────────────────────────
  Widget _buildSettingsPanel() => Container(
    color: controller.currentBackgroundColor,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _settingLabel('Brightness'),
        Row(
          children: [
            const Icon(Icons.brightness_low, color: Colors.grey, size: 18),
            Expanded(
              child: Obx(
                () => Slider(
                  value: controller.brightness,
                  onChanged: controller.setBrightness,
                  activeColor: Colors.orange,
                  inactiveColor: Colors.grey[700],
                ),
              ),
            ),
            const Icon(Icons.brightness_high, color: Colors.grey, size: 18),
          ],
        ),
        _settingLabel('Font Size'),
        Row(
          children: [
            Text('A', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            Expanded(
              child: Obx(
                () => Slider(
                  value: controller.fontSize,
                  min: 12,
                  max: 28,
                  onChanged: controller.setFontSize,
                  activeColor: Colors.orange,
                  inactiveColor: Colors.grey[700],
                ),
              ),
            ),
            Text('A', style: TextStyle(fontSize: 20, color: Colors.grey[500])),
          ],
        ),
        _settingLabel('Background'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            controller.backgroundColors.length,
            (i) => Obx(
              () => GestureDetector(
                onTap: () => controller.setBackground(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 24,
                  decoration: BoxDecoration(
                    color: controller.backgroundColors[i],
                    borderRadius: BorderRadius.circular(12),
                    border:
                        controller.selectedBackground == i
                            ? Border.all(color: Colors.orange, width: 2.5)
                            : Border.all(color: Colors.grey[600]!),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _settingLabel('Fonts'),
        const SizedBox(height: 10),
        Obx(
          () => Wrap(
            spacing: 10,
            children:
                controller.fonts
                    .map(
                      (f) => GestureDetector(
                        onTap: () => controller.setFont(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                controller.selectedFont == f
                                    ? Colors.orange
                                    : Colors.transparent,
                            border: Border.all(
                              color:
                                  controller.selectedFont == f
                                      ? Colors.orange
                                      : Colors.grey[500]!,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color:
                                  controller.selectedFont == f
                                      ? Colors.white
                                      : Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    ),
  );

  // ── Contents panel ───────────────────────────────────────────────────────
  Widget _buildContentsPanel() => Positioned.fill(
    child: Container(
      color: const Color(0xFF1a1a1a),
      child: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: controller.hideAllControls,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.bookTitle,
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
                    controller.chapters.isEmpty
                        ? const Center(
                          child: Text(
                            'No chapters loaded',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: controller.chapters.length,
                          itemBuilder: (_, i) {
                            final ch = controller.chapters[i];
                            final isCurrent =
                                controller.currentChapter == ch.title;
                            return ListTile(
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
                                controller.hideAllControls();
                                if (storySlug != null) {
                                  controller.loadChapter(
                                    storySlug!,
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

  Widget _settingLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
  );
}

// ─── Gift model ────────────────────────────────────────────────────────────────
class _Gift {
  final String emoji;
  final String label;
  final int coins; // 0 = free (AdMob rewarded ad)
  const _Gift(this.emoji, this.label, this.coins);
}

const _gifts = [
  _Gift('🌸', 'Flower', 0), // FREE — AdMob rewarded ad placeholder
  _Gift('❤️', 'Like', 200),
  _Gift('🍦', 'Ice pop', 2000),
  _Gift('☕', 'Coffee', 5000),
  _Gift('🍾', 'Champagne', 10000),
  _Gift('🚗', 'Luxury Car', 30000),
];

// ─── End-of-Chapter Section ─────────────────────────────────────────────────
class _EndOfChapterSection extends StatefulWidget {
  final String? storySlug;
  final int? chapterNumber;
  final VoidCallback onCommentTap;

  const _EndOfChapterSection({
    required this.storySlug,
    required this.chapterNumber,
    required this.onCommentTap,
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

    // FREE gift — AdMob rewarded ad placeholder
    if (gift.coins == 0) {
      _showAdPlaceholder();
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
        duration: const Duration(seconds: 2),
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

  void _showAdPlaceholder() {
    Get.snackbar(
      '📺 Free Gift',
      'AdMob rewarded ad coming soon! You\'ll earn a free gift after watching.',
      backgroundColor: const Color(0xFF2a2a2a),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final author = Get.find<ReadingInterfaceController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Leave a comment bar ─────────────────────────────────────────
        GestureDetector(
          onTap: widget.onCommentTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2a2a2a),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Leave a comment',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),

        // ── Gift section ────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a2a),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Author thank-you note
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange[800],
                      child: Text(
                        author.bookTitle.isNotEmpty
                            ? author.bookTitle[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  author.bookTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Author',
                                  style: TextStyle(
                                    color: Colors.white,
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
                            Positioned(
                              child: // Ad badge for free gift
                                  //if (isFree)
                                  isFree
                                      ? Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            right: 4,
                                            top: 4,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[700],
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
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
                                      )
                                      //else
                                      : const SizedBox(height: 4),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Emoji
                                  Text(
                                    gift.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(height: 4),

                                  // Label
                                  Text(
                                    gift.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Price / Free
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

              // Send button — only shows when a paid gift is selected
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

// ─── Like Button Widget ─────────────────────────────────────────────────────
// Stateful so each comment tracks its own liked/count state independently
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

    // Capture CURRENT state BEFORE toggling — this decides which API to call
    final wasLiked = _liked;

    // Optimistic UI — update immediately before API call
    setState(() {
      _loading = true;
      if (wasLiked) {
        _liked = false;
        _count = (_count - 1).clamp(0, 99999);
      } else {
        _liked = true;
        _count++;
        // Bounce animation on like
        _animCtrl.forward().then((_) => _animCtrl.reverse());
      }
    });

    widget.onLikeChanged(_liked, _count);

    final commentId = widget.comment['id'] as int;
    // Use wasLiked (the state BEFORE toggle) to decide the API call:
    // wasLiked=true  → user is unliking → DELETE
    // wasLiked=false → user is liking   → POST
    final res =
        wasLiked
            ? await ApiService.unlikeComment(commentId)
            : await ApiService.likeComment(commentId);

    setState(() => _loading = false);

    if (!res['success']) {
      // Revert on failure
      setState(() {
        _liked = wasLiked;
        _count = wasLiked ? _count + 1 : (_count - 1).clamp(0, 99999);
      });
      widget.onLikeChanged(_liked, _count);
      Get.snackbar(
        'Error',
        res['error'] ?? 'Could not update like',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
}

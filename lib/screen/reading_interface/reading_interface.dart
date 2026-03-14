import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/reading_interface/controller/reading_interface_controller.dart';

class NovelUpReadingInterface extends StatelessWidget {
  final String? storySlug;
  final int?    chapterNumber;
  final String? chapterTitle;

  NovelUpReadingInterface({
    super.key,
    this.storySlug,
    this.chapterNumber,
    this.chapterTitle,
  });

  final ReadingInterfaceController controller = Get.put(ReadingInterfaceController());

  @override
  Widget build(BuildContext context) {
    if (storySlug != null && chapterNumber != null) {
      controller.loadChapter(storySlug!, chapterNumber!, chapterTitle);
    }

    return Scaffold(
      body: Obx(() => Container(
        color: controller.currentBackgroundColor,
        child: Stack(children: [
          _buildMainContent(),
          if (controller.showTopBar)    _buildTopBar(),
          if (controller.showBottomBar) _buildBottomBar(),
          if (controller.showListenButton && !controller.showSettings && !controller.showContents)
            _buildListenButton(),
          if (controller.showSettings)
            Align(alignment: Alignment.bottomCenter,
                child: SizedBox(height: 420, child: _buildSettingsPanel())),
          if (controller.showContents)  _buildContentsPanel(),
          if (controller.isLoadingChapter.value)
            Container(color: Colors.black45,
                child: const Center(child: CircularProgressIndicator(color: Colors.blue))),
        ]),
      )),
    );
  }

  // ── Main scrollable content ──────────────────────────────────────────────
  Widget _buildMainContent() {
    return GestureDetector(
      onTap: controller.onScreenTap,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Obx(() => SingleChildScrollView(
          controller: controller.scrollController,
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Chapter title
            Text(
              controller.currentChapter,
              style: TextStyle(
                fontSize: controller.fontSize + 4,
                fontWeight: FontWeight.bold,
                color: controller.currentTextColor,
                fontFamily: controller.selectedFont == 'System' ? null : controller.selectedFont,
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Text(
              controller.chapterContent.value.isNotEmpty
                  ? controller.chapterContent.value
                  : 'Loading chapter content...',
              style: TextStyle(
                fontSize: controller.fontSize,
                color: controller.currentTextColor,
                height: controller.currentLineHeight,
                fontFamily: controller.selectedFont == 'System' ? null : controller.selectedFont,
              ),
            ),
            const SizedBox(height: 40),
            // End of chapter actions
            if (!controller.isLoadingChapter.value && controller.chapterContent.value.isNotEmpty)
              _buildEndOfChapterActions(),
            const SizedBox(height: 80),
          ]),
        )),
      ),
    );
  }

  // ── End-of-chapter: tip + comment ────────────────────────────────────────
  Widget _buildEndOfChapterActions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Container(width: 40, height: 3, decoration: BoxDecoration(
            color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        const Text('— End of Chapter —',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        const Text('Enjoyed this chapter? Tip the author 🎉',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [10, 50, 100, 500].map((coins) =>
              GestureDetector(
                onTap: () => _sendTip(coins),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.monetization_on, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text('$coins', style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                ),
              ),
            ).toList()),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => _showComments(Get.context!),
          icon: const Icon(Icons.comment_outlined, size: 16),
          label: const Text('Comments'),
          style: OutlinedButton.styleFrom(
            foregroundColor: depperBlue,
            side: BorderSide(color: depperBlue),
          ),
        ),
      ]),
    );
  }

  void _sendTip(int coins) async {
    if (storySlug == null) { return; }
    final res = await ApiService.sendTip(storySlug!, coins);
    if (res['success']) {
      Get.snackbar('Tip Sent! 🎉', 'You sent $coins coins to the author',
          backgroundColor: Colors.orange, colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } else {
      Get.snackbar('Error', res['error'] ?? 'Could not send tip',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showComments(BuildContext ctx) {
    if (storySlug == null || chapterNumber == null) { return; }
    final commentCtrl = TextEditingController();
    final comments    = <Map>[].obs;
    final loading     = true.obs;

    ApiService.getComments(storySlug!, chapterNumber!).then((res) {
      loading.value = false;
      if (res['success']) {
        final d = res['data'];
        comments.value = (d is List ? d : (d['results'] ?? [])).cast<Map>();
      }
    });

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.7, maxChildSize: 0.95,
        builder: (_, sc) => Column(children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Text('Comments',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(color: Color(0xFF2a2a2a)),
          Expanded(
            child: Obx(() => loading.value
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : comments.isEmpty
                    ? const Center(child: Text('Be the first to comment!',
                        style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        controller: sc,
                        itemCount: comments.length,
                        itemBuilder: (_, i) {
                          final c    = comments[i];
                          final user = c['user'] ?? {};
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: depperBlue,
                              radius: 18,
                              child: Text((user['username'] ?? 'A')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            title: Text(user['username'] ?? '',
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 13, fontWeight: FontWeight.bold)),
                            subtitle: Text(c['content'] ?? '',
                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('${c['likes_count'] ?? 0}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                            ]),
                          );
                        },
                      )),
          ),
          // Input
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 8,
                left: 16, right: 16, top: 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2a2a2a),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  if (commentCtrl.text.trim().isEmpty) { return; }
                  final res = await ApiService.postComment(
                      storySlug!, chapterNumber!, commentCtrl.text.trim());
                  if (res['success']) {
                    commentCtrl.clear();
                    comments.insert(0, res['data']);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: depperBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() => Positioned(
    top: 0, left: 0, right: 0,
    child: Container(
      color: controller.currentBackgroundColor.withOpacity(0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color: controller.selectedBackground == 4 ? Colors.white : Colors.black87,
                  size: 18),
              onPressed: () => Get.back(),
            ),
            Expanded(
              child: Obx(() => Text(controller.currentChapter,
                  style: TextStyle(
                    color: controller.selectedBackground == 4 ? Colors.white : Colors.black87,
                    fontSize: 12),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(15)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 14),
                Obx(() => Text(' ${controller.coins}',
                    style: const TextStyle(color: Colors.white, fontSize: 11))),
              ]),
            ),
            const SizedBox(width: 6),
          ]),
        ),
      ),
    ),
  );

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() => Positioned(
    bottom: 0, left: 0, right: 0,
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _btnBar(Icons.list,     'Contents', controller.toggleContents),
            _btnBar(Icons.settings, 'Settings', controller.toggleSettings),
            _btnBar(Icons.download, 'Download', () {}),
          ]),
        ),
      ),
    ),
  );

  Widget _btnBar(IconData icon, String label, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white, size: 24),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
    ]));

  // ── Listen button ─────────────────────────────────────────────────────────
  Widget _buildListenButton() => Positioned(
    bottom: 100, right: 20,
    child: Container(
      width: 60, height: 60,
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(30)),
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.headphones, color: Colors.white, size: 22),
        Text('Listen', style: TextStyle(color: Colors.white, fontSize: 9)),
      ]),
    ),
  );

  // ── Settings panel ────────────────────────────────────────────────────────
  Widget _buildSettingsPanel() => Container(
    color: controller.currentBackgroundColor,
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)))),
      const SizedBox(height: 16),
      _settingLabel('Brightness'),
      Row(children: [
        const Icon(Icons.brightness_low, color: Colors.grey, size: 18),
        Expanded(child: Obx(() => Slider(
          value: controller.brightness,
          onChanged: controller.setBrightness,
          activeColor: Colors.orange,
          inactiveColor: Colors.grey[700],
        ))),
        const Icon(Icons.brightness_high, color: Colors.grey, size: 18),
      ]),
      _settingLabel('Font Size'),
      Row(children: [
        Text('A', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        Expanded(child: Obx(() => Slider(
          value: controller.fontSize, min: 12, max: 28,
          onChanged: controller.setFontSize,
          activeColor: Colors.orange,
          inactiveColor: Colors.grey[700],
        ))),
        Text('A', style: TextStyle(fontSize: 20, color: Colors.grey[500])),
      ]),
      _settingLabel('Background'),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(controller.backgroundColors.length, (i) =>
          Obx(() => GestureDetector(
            onTap: () => controller.setBackground(i),
            child: Container(
              width: 38, height: 24,
              decoration: BoxDecoration(
                color: controller.backgroundColors[i],
                borderRadius: BorderRadius.circular(12),
                border: controller.selectedBackground == i
                    ? Border.all(color: Colors.orange, width: 2.5)
                    : Border.all(color: Colors.grey[600]!),
              ),
            ),
          )),
        ),
      ),
      const SizedBox(height: 16),
      _settingLabel('Fonts'),
      const SizedBox(height: 10),
      Obx(() => Wrap(
        spacing: 10,
        children: controller.fonts.map((f) =>
          GestureDetector(
            onTap: () => controller.setFont(f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: controller.selectedFont == f ? Colors.orange : Colors.transparent,
                border: Border.all(
                    color: controller.selectedFont == f ? Colors.orange : Colors.grey[500]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(f,
                  style: TextStyle(
                    color: controller.selectedFont == f ? Colors.white : Colors.grey[500],
                    fontSize: 11,
                  )),
            ),
          ),
        ).toList(),
      )),
    ]),
  );

  // ── Contents panel ────────────────────────────────────────────────────────
  Widget _buildContentsPanel() => Positioned.fill(
    child: Container(
      color: const Color(0xFF1a1a1a),
      child: SafeArea(
        child: Column(children: [
          GestureDetector(
            onTap: controller.hideAllControls,
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(controller.bookTitle,
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 17),
              textAlign: TextAlign.center)),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFF2a2a2a)),
          Expanded(
            child: Obx(() => controller.chapters.isEmpty
                ? const Center(child: Text('No chapters loaded',
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.chapters.length,
                    itemBuilder: (_, i) {
                      final ch = controller.chapters[i];
                      final isCurrent = controller.currentChapter == ch.title;
                      return ListTile(
                        title: Text(ch.title,
                            style: TextStyle(
                              color: isCurrent ? Colors.orange : Colors.white,
                              fontSize: 14,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            )),
                        trailing: ch.isRead
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                            : null,
                        onTap: () {
                          controller.hideAllControls();
                          if (storySlug != null) {
                            controller.loadChapter(storySlug!, i + 1, ch.title);
                          }
                        },
                      );
                    },
                  )),
          ),
        ]),
      ),
    ),
  );

  Widget _settingLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
  );
}

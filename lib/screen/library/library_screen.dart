import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/config/size_config.dart';
import 'package:novelux/screen/auth/auth_controller.dart';
import 'package:novelux/screen/auth/auth_screens.dart';
import 'package:novelux/screen/book_preview/story_detail_screen.dart';
import 'package:novelux/screen/library/controller/library_controller.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int initialIndex = 0;
  bool isProfile   = false;

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args != null) {
      initialIndex = args['value'] ?? 0;
      isProfile    = args['isProfile'] ?? false;
    }

    SizeConfig().init(context);
    final ctrl = Get.put(LibraryController());
    final auth = Get.find<AuthController>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: DefaultTabController(
          initialIndex: initialIndex,
          length: 2,
          child: Column(children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(color: background),
              child: Row(children: [
                if (isProfile)
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 30, color: kWhite),
                  )
                else
                  const SizedBox(width: 10),
                const Spacer(),
                TabBar(
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: depperBlue, width: 2),
                  ),
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                  tabAlignment: TabAlignment.center,
                  tabs: const [Tab(text: 'Library'), Tab(text: 'History')],
                ),
                const Spacer(),
                IconButton(
                  onPressed: ctrl.fetchBookmarks,
                  icon: const Icon(Icons.refresh_rounded, size: 26, color: kWhite),
                ),
                const SizedBox(width: 10),
              ]),
            ),

            // ── Tab Views ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(children: [
                // ── Library Tab ────────────────────────────────────────────
                Obx(() {
                  if (!auth.isLoggedIn.value) {
                    return _notLoggedIn();
                  }
                  return Column(children: [
                    // Filter chips
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        scrollDirection: Axis.horizontal,
                        itemCount: ctrl.filters.length,
                        itemBuilder: (_, i) {
                          final isActive = ctrl.activeFilter.value == ctrl.filters[i];
                          return GestureDetector(
                            onTap: () => ctrl.activeFilter.value = ctrl.filters[i],
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isActive ? depperBlue : kBrown,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Text(ctrl.filters[i],
                                    style: TextStyle(
                                        color: isActive ? Colors.white : kWhite,
                                        fontSize: 12)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (ctrl.isLoading.value)
                      const Expanded(child: Center(
                          child: CircularProgressIndicator(color: Colors.blue)))
                    else if (ctrl.filteredBookmarks.isEmpty)
                      Expanded(child: Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.bookmark_border, color: Colors.grey[700], size: 60),
                          const SizedBox(height: 16),
                          const Text('No bookmarks yet',
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text('Browse stories and tap the bookmark icon',
                              style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ]),
                      ))
                    else
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(10),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.52,
                          ),
                          itemCount: ctrl.filteredBookmarks.length,
                          itemBuilder: (_, i) {
                            final story    = ctrl.filteredBookmarks[i];
                            final coverUrl = ctrl.getCoverUrl(story);
                            return GestureDetector(
                              onLongPress: () => _showRemoveDialog(ctrl, story['slug']),
                              onTap: () => Navigator.push(context, CupertinoPageRoute(
                                  builder: (_) => StoryDetailScreen(slug: story['slug']))),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Stack(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      height: SizeConfig.blockSizeVertical! * 20,
                                      width: double.infinity,
                                      child: coverUrl.isNotEmpty
                                          ? Image.network(coverUrl, fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _coverPlaceholder())
                                          : _coverPlaceholder(),
                                    ),
                                  ),
                                  if (story['status'] == 'completed')
                                    Positioned(
                                      top: 4, left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Done',
                                            style: TextStyle(color: Colors.white, fontSize: 9)),
                                      ),
                                    ),
                                ]),
                                const SizedBox(height: 6),
                                Text(story['title'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.white),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              ]),
                            );
                          },
                        ),
                      ),
                  ]);
                }),

                // ── History Tab ───────────────────────────────────────────
                Obx(() {
                  if (!auth.isLoggedIn.value) {
                    return _notLoggedIn();
                  }
                  if (ctrl.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blue));
                  }
                  if (ctrl.bookmarks.isEmpty) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.history, color: Colors.grey[700], size: 60),
                        const SizedBox(height: 16),
                        const Text('No reading history yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ]),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: ctrl.bookmarks.length,
                    itemBuilder: (_, i) {
                      final story    = ctrl.bookmarks[i];
                      final coverUrl = ctrl.getCoverUrl(story);
                      return GestureDetector(
                        onTap: () => Navigator.push(context, CupertinoPageRoute(
                            builder: (_) => StoryDetailScreen(slug: story['slug']))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                height: SizeConfig.blockSizeVertical! * 11,
                                width: SizeConfig.blockSizeHorizontal! * 13,
                                child: coverUrl.isNotEmpty
                                    ? Image.network(coverUrl, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _coverPlaceholder())
                                    : _coverPlaceholder(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(story['title'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('${story['total_chapters'] ?? 0} chapters',
                                    style: const TextStyle(fontSize: 11, color: Colors.white54)),
                                const SizedBox(height: 4),
                                Text(story['description'] ?? '',
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            )),
                          ]),
                        ),
                      );
                    },
                  );
                }),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _notLoggedIn() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.lock_outline, color: Colors.grey[700], size: 60),
      const SizedBox(height: 16),
      const Text('Sign in to view your library',
          style: TextStyle(color: Colors.grey, fontSize: 16)),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: depperBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => Get.to(() => const LoginScreen()),
        child: const Text('Sign In', style: TextStyle(color: Colors.white)),
      ),
    ]),
  );

  Widget _coverPlaceholder() => Container(
    color: Colors.grey[800],
    child: const Center(child: Icon(Icons.book, color: Colors.grey)),
  );

  void _showRemoveDialog(LibraryController ctrl, String slug) {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF2a2a2a),
      title: const Text('Remove Bookmark', style: TextStyle(color: Colors.white)),
      content: const Text('Remove this story from your library?',
          style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () { Get.back(); ctrl.removeBookmark(slug); },
          child: const Text('Remove', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}

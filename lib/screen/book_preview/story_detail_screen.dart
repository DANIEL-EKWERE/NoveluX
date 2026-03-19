// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:novelux/config/api_service.dart';
// import 'package:novelux/config/app_style.dart';
// import 'package:novelux/screen/auth/auth_controller.dart';
// import 'package:novelux/screen/reading_interface/reading_interface.dart';

// class StoryDetailController extends GetxController {
//   final RxBool isLoading = false.obs;
//   final RxBool isLoadingChapters = false.obs;
//   final Rx<Map?> story = Rx<Map?>(null);
//   final RxList chapters = [].obs;
//   final RxBool isBookmarked = false.obs;

//   void loadStory(String slug) async {
//     isLoading.value = true;
//     final res = await ApiService.getStoryDetail(slug);
//     isLoading.value = false;
//     if (res['success']) {
//       story.value = res['data'];
//       isBookmarked.value = res['data']['is_bookmarked'] ?? false;
//       loadChapters(slug);
//     }
//   }

//   void loadChapters(String slug) async {
//     isLoadingChapters.value = true;
//     final res = await ApiService.getChapters(slug);
//     isLoadingChapters.value = false;
//     if (res['success']) {
//       chapters.value =
//           res['data'] is List ? res['data'] : (res['data']['results'] ?? []);
//     }
//   }

//   Future<void> toggleBookmark(String slug) async {
//     if (isBookmarked.value) {
//       await ApiService.removeBookmark(slug);
//       isBookmarked.value = false;
//     } else {
//       await ApiService.bookmarkStory(slug);
//       isBookmarked.value = true;
//     }
//   }

//   String getCoverUrl(Map? s) {
//     final cover = s?['cover_image'];
//     if (cover == null || cover.toString().isEmpty) {
//       return '';
//     }
//     if (cover.toString().startsWith('http')) {
//       return cover.toString();
//     }
//     return 'http://10.0.2.2:8000$cover';
//   }
// }

// class StoryDetailScreen extends StatelessWidget {
//   final String slug;
//   const StoryDetailScreen({super.key, required this.slug});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.put(StoryDetailController());
//     ctrl.loadStory(slug);
//     final auth = Get.find<AuthController>();

//     return Scaffold(
//       backgroundColor: const Color(0xFF1a1a1a),
//       body: Obx(() {
//         if (ctrl.isLoading.value) {
//           return const Center(
//             child: CircularProgressIndicator(color: Colors.blue),
//           );
//         }
//         final story = ctrl.story.value;
//         if (story == null) {
//           return const Center(
//             child: Text(
//               'Story not found',
//               style: TextStyle(color: Colors.white),
//             ),
//           );
//         }
//         final author = story['author'] ?? {};
//         final genre = story['genre'];
//         final tags = (story['tags'] as List? ?? []);

//         return CustomScrollView(
//           slivers: [
//             // ── App Bar ──────────────────────────────────────────────────────
//             SliverAppBar(
//               expandedHeight: 280,
//               pinned: true,
//               backgroundColor: const Color(0xFF1a1a1a),
//               leading: IconButton(
//                 icon: const Icon(
//                   Icons.chevron_left,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//                 onPressed: () => Navigator.of(Get.context!).pop(),
//                 //Get.back(),
//               ),
//               actions: [
//                 Obx(
//                   () => IconButton(
//                     icon: Icon(
//                       ctrl.isBookmarked.value
//                           ? Icons.bookmark
//                           : Icons.bookmark_border,
//                       color:
//                           ctrl.isBookmarked.value ? depperBlue : Colors.white,
//                     ),
//                     onPressed: () => ctrl.toggleBookmark(slug),
//                   ),
//                 ),
//                 PopupMenuButton<int>(
//                   icon: const Icon(Icons.more_vert, color: Colors.white),
//                   color: const Color(0xFF2a2a2a),
//                   itemBuilder:
//                       (context) => [
//                         const PopupMenuItem(
//                           value: 0,
//                           child: Text(
//                             'Share',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                         const PopupMenuItem(
//                           value: 1,
//                           child: Text(
//                             'Report',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ],
//                 ),
//               ],
//               flexibleSpace: FlexibleSpaceBar(
//                 background: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     ctrl.getCoverUrl(story).isNotEmpty
//                         ? Image.network(
//                           ctrl.getCoverUrl(story),
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => _coverPlaceholder(),
//                         )
//                         : _coverPlaceholder(),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [Colors.transparent, const Color(0xFF1a1a1a)],
//                           stops: const [0.4, 1.0],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Content ───────────────────────────────────────────────────────
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Title
//                     Text(
//                       story['title'] ?? '',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     // Author
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 14,
//                           backgroundColor: depperBlue,
//                           child: Text(
//                             (author['username'] ?? 'A')[0].toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           author['username'] ?? 'Unknown Author',
//                           style: const TextStyle(
//                             color: Colors.grey,
//                             fontSize: 13,
//                           ),
//                         ),
//                         if (story['status'] != null) ...[
//                           const SizedBox(width: 12),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 3,
//                             ),
//                             decoration: BoxDecoration(
//                               color:
//                                   story['status'] == 'completed'
//                                       ? Colors.green.withOpacity(0.2)
//                                       : Colors.orange.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               story['status'].toString().toUpperCase(),
//                               style: TextStyle(
//                                 color:
//                                     story['status'] == 'completed'
//                                         ? Colors.green
//                                         : Colors.orange,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Stats row
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF2a2a2a),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           _stat(
//                             '${story['total_views'] ?? 0}',
//                             'Views',
//                             Icons.visibility_outlined,
//                           ),
//                           _divider(),
//                           _stat(
//                             '${story['total_chapters'] ?? 0}',
//                             'Chapters',
//                             Icons.menu_book_outlined,
//                           ),
//                           _divider(),
//                           _stat(
//                             '${double.tryParse(story['average_rating'].toString())?.toStringAsFixed(1) ?? '0.0'}',
//                             'Rating',
//                             Icons.star_outline,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Tags
//                     if (tags.isNotEmpty) ...[
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 6,
//                         children:
//                             tags
//                                 .map(
//                                   (tag) => Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                       vertical: 4,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: depperBlue.withOpacity(0.15),
//                                       borderRadius: BorderRadius.circular(20),
//                                       border: Border.all(
//                                         color: depperBlue.withOpacity(0.3),
//                                       ),
//                                     ),
//                                     child: Text(
//                                       tag['name'] ?? '',
//                                       style: TextStyle(
//                                         color: depperBlue,
//                                         fontSize: 11,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                                 .toList(),
//                       ),
//                       const SizedBox(height: 16),
//                     ],

//                     // Description
//                     const Text(
//                       'Synopsis',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _ExpandableText(text: story['description'] ?? ''),
//                     const SizedBox(height: 24),

//                     // Read button
//                     Row(
//                       children: [
//                         Expanded(
//                           child: SizedBox(
//                             height: 48,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: depperBlue,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               onPressed: () {
//                                 if (ctrl.chapters.isNotEmpty) {
//                                   final firstChapter = ctrl.chapters[0];
//                                   Navigator.push(
//                                     context,
//                                     CupertinoPageRoute(
//                                       builder:
//                                           (_) => NovelUpReadingInterface(
//                                             storySlug: slug,
//                                             chapterNumber:
//                                                 firstChapter['chapter_number'],
//                                             chapterTitle: firstChapter['title'],
//                                           ),
//                                     ),
//                                   );
//                                 }
//                               },
//                               child: const Text(
//                                 'Start Reading',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),

//                     // Chapters header
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Chapters',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Obx(
//                           () => Text(
//                             '${ctrl.chapters.length} chapters',
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Chapter List ─────────────────────────────────────────────────
//             Obx(() {
//               if (ctrl.isLoadingChapters.value) {
//                 return const SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Center(
//                       child: CircularProgressIndicator(color: Colors.blue),
//                     ),
//                   ),
//                 );
//               }
//               return SliverList(
//                 delegate: SliverChildBuilderDelegate((context, index) {
//                   final ch = ctrl.chapters[index];
//                   final isLocked = ch['is_locked'] ?? false;
//                   final isUnlocked = ch['is_unlocked'] ?? false;

//                   return ListTile(
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 4,
//                     ),
//                     leading: Container(
//                       width: 36,
//                       height: 36,
//                       decoration: BoxDecoration(
//                         color:
//                             isUnlocked || !isLocked
//                                 ? depperBlue.withOpacity(0.2)
//                                 : const Color(0xFF2a2a2a),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${ch['chapter_number']}',
//                           style: TextStyle(
//                             color:
//                                 isUnlocked || !isLocked
//                                     ? depperBlue
//                                     : Colors.grey,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ),
//                     title: Text(
//                       ch['title'] ?? 'Chapter ${ch['chapter_number']}',
//                       style: TextStyle(
//                         color:
//                             isUnlocked || !isLocked
//                                 ? Colors.white
//                                 : Colors.grey,
//                         fontSize: 13,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     subtitle: Row(
//                       children: [
//                         Text(
//                           '${ch['word_count'] ?? 0} words',
//                           style: const TextStyle(
//                             color: Colors.grey,
//                             fontSize: 11,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (isLocked && !isUnlocked)
//                           Row(
//                             children: [
//                               const Icon(
//                                 Icons.monetization_on,
//                                 color: Colors.orange,
//                                 size: 12,
//                               ),
//                               const SizedBox(width: 2),
//                               Text(
//                                 '${ch['coin_cost']} coins',
//                                 style: const TextStyle(
//                                   color: Colors.orange,
//                                   fontSize: 11,
//                                 ),
//                               ),
//                             ],
//                           ),
//                       ],
//                     ),
//                     trailing: Icon(
//                       isLocked && !isUnlocked
//                           ? Icons.lock_outline
//                           : Icons.play_circle_outline,
//                       color:
//                           isLocked && !isUnlocked
//                               ? Colors.grey[600]
//                               : depperBlue,
//                       size: 20,
//                     ),
//                     onTap: () => _handleChapterTap(context, ch, slug, auth),
//                   );
//                 }, childCount: ctrl.chapters.length),
//               );
//             }),
//             const SliverToBoxAdapter(child: SizedBox(height: 80)),
//           ],
//         );
//       }),
//     );
//   }

//   void _handleChapterTap(
//     BuildContext context,
//     Map ch,
//     String slug,
//     AuthController auth,
//   ) async {
//     final isLocked = ch['is_locked'] ?? false;
//     final isUnlocked = ch['is_unlocked'] ?? false;

//     if (!isLocked || isUnlocked) {
//       Navigator.push(
//         context,
//         CupertinoPageRoute(
//           builder:
//               (_) => NovelUpReadingInterface(
//                 storySlug: slug,
//                 chapterNumber: ch['chapter_number'],
//                 chapterTitle: ch['title'],
//               ),
//         ),
//       );
//       return;
//     }

//     // Locked — show unlock dialog
//     final coinCost = ch['coin_cost'] ?? 0;
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             backgroundColor: const Color(0xFF2a2a2a),
//             title: const Text(
//               'Unlock Chapter',
//               style: TextStyle(color: Colors.white),
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.lock_open, color: Colors.orange, size: 40),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Unlock "${ch['title']}" for $coinCost coins?',
//                   style: const TextStyle(color: Colors.white70, fontSize: 14),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Obx(
//                   () => Text(
//                     'Your balance: ${auth.coins} coins',
//                     style: TextStyle(
//                       color:
//                           auth.coins >= coinCost
//                               ? Colors.green
//                               : Colors.redAccent,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: depperBlue),
//                 onPressed: () async {
//                   Get.back();
//                   final res = await ApiService.unlockChapter(
//                     slug,
//                     ch['chapter_number'],
//                   );
//                   if (res['success']) {
//                     await auth.fetchMe();
//                     Navigator.push(
//                       context,
//                       CupertinoPageRoute(
//                         builder:
//                             (_) => NovelUpReadingInterface(
//                               storySlug: slug,
//                               chapterNumber: ch['chapter_number'],
//                               chapterTitle: ch['title'],
//                             ),
//                       ),
//                     );
//                   } else {
//                     Get.snackbar(
//                       'Error',
//                       res['error'] ?? 'Failed to unlock',
//                       backgroundColor: Colors.red,
//                       colorText: Colors.white,
//                     );
//                   }
//                 },
//                 child: Text(
//                   'Unlock ($coinCost coins)',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }

//   Widget _coverPlaceholder() => Container(
//     color: const Color(0xFF2a2a2a),
//     child: const Center(child: Icon(Icons.book, color: Colors.grey, size: 60)),
//   );

//   Widget _stat(String value, String label, IconData icon) => Column(
//     children: [
//       Icon(icon, color: Colors.grey, size: 18),
//       const SizedBox(height: 4),
//       Text(
//         value,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//         ),
//       ),
//       Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
//     ],
//   );

//   Widget _divider() =>
//       Container(width: 0.5, height: 40, color: Colors.grey[800]);
// }

// class _ExpandableText extends StatefulWidget {
//   final String text;
//   const _ExpandableText({required this.text});

//   @override
//   State<_ExpandableText> createState() => _ExpandableTextState();
// }

// class _ExpandableTextState extends State<_ExpandableText> {
//   bool _expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.text,
//           maxLines: _expanded ? null : 3,
//           overflow: _expanded ? null : TextOverflow.ellipsis,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 13,
//             height: 1.6,
//           ),
//         ),
//         const SizedBox(height: 6),
//         GestureDetector(
//           onTap: () => setState(() => _expanded = !_expanded),
//           child: Text(
//             _expanded ? 'Show less' : 'Read more',
//             style: TextStyle(
//               color: depperBlue,
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/auth/auth_controller.dart';
import 'package:novelux/screen/reading_interface/reading_interface.dart';
import 'package:novelux/screen/review_comment_story/reviews_and_comments_screen.dart';
import 'package:novelux/widgets/custom_image_view.dart';

// ── Controller ────────────────────────────────────────────────────────────────
class StoryDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingChapters = false.obs;
  final Rx<Map?> story = Rx<Map?>(null);
  final RxList chapters = [].obs;
  final RxBool isBookmarked = false.obs;
  final RxDouble avgRating = 0.0.obs;

  void loadStory(String slug) async {
    isLoading.value = true;
    final res = await ApiService.getStoryDetail(slug);
    isLoading.value = false;
    if (res['success']) {
      story.value = res['data'];
      isBookmarked.value = res['data']['is_bookmarked'] ?? false;
      avgRating.value =
          double.tryParse(res['data']['average_rating'].toString()) ?? 0.0;
      loadChapters(slug);
    }
  }

  void loadChapters(String slug) async {
    isLoadingChapters.value = true;
    final res = await ApiService.getChapters(slug);
    isLoadingChapters.value = false;
    if (res['success']) {
      chapters.value =
          res['data'] is List ? res['data'] : (res['data']['results'] ?? []);
    }
  }

  Future<void> toggleBookmark(String slug) async {
    if (isBookmarked.value) {
      await ApiService.removeBookmark(slug);
      isBookmarked.value = false;
    } else {
      await ApiService.bookmarkStory(slug);
      isBookmarked.value = true;
    }
  }

  String getCoverUrl(Map? s) {
    final c = s?['cover_image'];
    if (c == null || c.toString().isEmpty) {
      return '';
    }
    if (c.toString().startsWith('http')) {
      return c.toString();
    }
    return 'http://10.0.2.2:8000$c';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class StoryDetailScreen extends StatelessWidget {
  final String slug;
  const StoryDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(StoryDetailController());
    ctrl.loadStory(slug);
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }
        final story = ctrl.story.value;
        if (story == null) {
          return const Center(
            child: Text(
              'Story not found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        final author = story['author'] ?? {};
        final tags = (story['tags'] as List? ?? []);

        return CustomScrollView(
          slivers: [
            // ── AppBar ───────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: const Color(0xFF1a1a1a),
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Get.back(),
              ),
              title: Text(
                story['title'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                Obx(
                  () => IconButton(
                    icon: Icon(
                      ctrl.isBookmarked.value
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color:
                          ctrl.isBookmarked.value
                              ? Colors.orange
                              : Colors.white,
                    ),
                    onPressed: () => ctrl.toggleBookmark(slug),
                  ),
                ),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: const Color(0xFF2a2a2a),
                  itemBuilder:
                      (_) => [
                        const PopupMenuItem(
                          value: 0,
                          child: Text(
                            'Share',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 1,
                          child: Text(
                            'Report',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    ctrl.getCoverUrl(story).isNotEmpty
                        ? CustomImageView(
                          imagePath: ctrl.getCoverUrl(story),
                          fit: BoxFit.cover,
                        
                        )
                        : _placeholder(),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFF1a1a1a)],
                          stops: [0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      story['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Author + status
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: depperBlue,
                          child: Text(
                            (author['username'] ?? 'A')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          author['username'] ?? 'Unknown Author',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (story['status'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  story['status'] == 'completed'
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              story['status'].toString().toUpperCase(),
                              style: TextStyle(
                                color:
                                    story['status'] == 'completed'
                                        ? Colors.green
                                        : Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stats row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _stat(
                            '${story['total_views'] ?? 0}',
                            'Views',
                            Icons.visibility_outlined,
                          ),
                          _divider(),
                          _stat(
                            '${story['total_chapters'] ?? 0}',
                            'Chapters',
                            Icons.menu_book_outlined,
                          ),
                          _divider(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder:
                                      (_) => ReviewsAndCommentsScreen(
                                        slug: slug,
                                        storyTitle: story['title'] ?? '',
                                        avgRating: ctrl.avgRating.value,
                                      ),
                                ),
                              );
                            },
                            child: _stat(
                              '${ctrl.avgRating.value.toStringAsFixed(1)}',
                              'Comments >',
                              Icons.star_outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    if (tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children:
                            tags
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: depperBlue.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: depperBlue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      tag['name'] ?? '',
                                      style: TextStyle(
                                        color: depperBlue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Synopsis
                    const Text(
                      'Synopsis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ExpandableText(text: story['description'] ?? ''),
                    const SizedBox(height: 24),

                    // ── Read Now Button ─────────────────────────────────────────
                    const Divider(color: Color(0xFF2a2a2a)),
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 50,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.orange,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(25),
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       if (ctrl.chapters.isNotEmpty) {
                    //         final ch = ctrl.chapters[0];
                    //         Navigator.push(
                    //           context,
                    //           CupertinoPageRoute(
                    //             builder:
                    //                 (_) => NovelUpReadingInterface(
                    //                   storySlug: slug,
                    //                   chapterNumber: ch['chapter_number'],
                    //                   chapterTitle: ch['title'],
                    //                 ),
                    //           ),
                    //         );
                    //       }
                    //     },
                    //     child: const Text(
                    //       'Read Now',
                    //       style: TextStyle(
                    //         color: Colors.black,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 24),

                    // ── Chapters ────────────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chapters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(
                          () => Text(
                            '${ctrl.chapters.length} chapters',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Chapter list ──────────────────────────────────────────────────
            Obx(() {
              if (ctrl.isLoadingChapters.value) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(color: depperBlue),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final ch = ctrl.chapters[i];
                  final isLocked = ch['is_locked'] ?? false;
                  final isUnlocked = ch['is_unlocked'] ?? false;
                  final canRead = !isLocked || isUnlocked;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            canRead
                                ? depperBlue.withOpacity(0.2)
                                : const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${ch['chapter_number']}',
                          style: TextStyle(
                            color: canRead ? depperBlue : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      ch['title'] ?? 'Chapter ${ch['chapter_number']}',
                      style: TextStyle(
                        color: canRead ? Colors.white : Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          '${ch['word_count'] ?? 0} words',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isLocked && !isUnlocked) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.orange,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${ch['coin_cost']} coins',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Icon(
                      isLocked && !isUnlocked
                          ? Icons.lock_outline
                          : Icons.play_circle_outline,
                      color:
                          isLocked && !isUnlocked
                              ? Colors.grey[600]
                              : depperBlue,
                      size: 20,
                    ),
                    onTap:
                        () => _handleChapterTap(context, ch, slug, auth, ctrl),
                  );
                }, childCount: ctrl.chapters.length),
              );
            }),

            // ── Reviews & Comments Section ────────────────────────────────────
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         const Divider(color: Color(0xFF2a2a2a)),
            //         const SizedBox(height: 16),
            //         SizedBox(
            //           width: double.infinity,
            //           height: 48,
            //           child: ElevatedButton(
            //             style: ElevatedButton.styleFrom(
            //               backgroundColor: depperBlue,
            //               shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(12),
            //               ),
            //             ),
            //             onPressed: () {
            //               Navigator.push(
            //                 context,
            //                 CupertinoPageRoute(
            //                   builder:
            //                       (_) => ReviewsAndCommentsScreen(
            //                         slug: slug,
            //                         storyTitle: story['title'] ?? '',
            //                         avgRating: ctrl.avgRating.value,
            //                       ),
            //                 ),
            //               );
            //             },
            //             child: const Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Icon(
            //                   Icons.chat_bubble_outline,
            //                   color: Colors.white,
            //                 ),
            //                 SizedBox(width: 8),
            //                 Text(
            //                   'View Reviews & Comments',
            //                   style: TextStyle(
            //                     color: Colors.white,
            //                     fontWeight: FontWeight.bold,
            //                     fontSize: 15,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        );
      }),
      // ── Sticky Read now button ──────────────────────────────────────────────
      bottomNavigationBar: Obx(() {
        if (ctrl.story.value == null) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: depperBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: () {
                if (ctrl.chapters.isNotEmpty) {
                  final ch = ctrl.chapters[0];
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder:
                          (_) => NovelUpReadingInterface(
                            storySlug: slug,
                            chapterNumber: ch['chapter_number'],
                            chapterTitle: ch['title'],
                          ),
                    ),
                  );
                }
              },
              child: const Text(
                'Read Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Chapter tap handler ─────────────────────────────────────────────────────
  void _handleChapterTap(
    BuildContext context,
    Map ch,
    String slug,
    AuthController auth,
    StoryDetailController ctrl,
  ) async {
    final isLocked = ch['is_locked'] ?? false;
    final isUnlocked = ch['is_unlocked'] ?? false;

    if (!isLocked || isUnlocked) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder:
              (_) => NovelUpReadingInterface(
                storySlug: slug,
                chapterNumber: ch['chapter_number'],
                chapterTitle: ch['title'],
              ),
        ),
      );
      return;
    }

    final coinCost = ch['coin_cost'] ?? 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1e1e1e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: Colors.orange,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unlock "${ch['title']}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$coinCost coins',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    'Balance: ${auth.coins} coins',
                    style: TextStyle(
                      color: auth.coins >= coinCost ? Colors.grey : Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Color(0xFF3a3a3a)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          Get.back();
                          final res = await ApiService.unlockChapter(
                            slug,
                            ch['chapter_number'],
                          );
                          if (res['success']) {
                            await auth.fetchMe();
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder:
                                    (_) => NovelUpReadingInterface(
                                      storySlug: slug,
                                      chapterNumber: ch['chapter_number'],
                                      chapterTitle: ch['title'],
                                    ),
                              ),
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              res['error'] ?? 'Failed to unlock',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Text(
                          'Unlock ($coinCost 🪙)',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _placeholder() => Container(
    color: const Color(0xFF2a2a2a),
    child: const Center(child: Icon(Icons.book, color: Colors.grey, size: 60)),
  );

  Widget _stat(String value, String label, IconData icon) => Column(
    children: [
      Row(
        spacing: 2,
        children: [
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Icon(icon, color: Colors.grey, size: 18),
        ],
      ),
      Text(
        label,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _divider() =>
      Container(width: 0.5, height: 40, color: Colors.grey[800]);
}

// ── Expandable text ───────────────────────────────────────────────────────────
class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.text,
        maxLines: _expanded ? null : 3,
        overflow: _expanded ? null : TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.6,
        ),
      ),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Text(
          _expanded ? 'Show less' : 'Read more',
          style: TextStyle(
            color: depperBlue,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

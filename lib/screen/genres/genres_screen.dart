import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/book_preview/story_detail_screen.dart';
import 'package:novelux/screen/genres/controller/genres_controller.dart';

class GenresScreen extends StatelessWidget {
  const GenresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(GenresController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: const Text('Genres',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF1a1a1a),
        child: Obx(() {
          if (ctrl.genres.isEmpty && ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          return Row(children: [
            // ── Left sidebar: genres ───────────────────────────────────────
            SizedBox(
              width: 95,
              child: ListView.builder(
                itemCount: ctrl.genres.length,
                itemBuilder: (_, i) {
                  final genre   = ctrl.genres[i];
                  final isSelected = ctrl.selectedIndex.value == i;
                  return GestureDetector(
                    onTap: () => ctrl.selectGenre(i, genre['slug'].toString()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? depperBlue : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        genre['name'] ?? '',
                        style: TextStyle(
                          color: isSelected ? depperBlue : Colors.grey[400],
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Right: stories for selected genre ─────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                ),
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blue));
                  }
                  if (ctrl.stories.isEmpty) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.book_outlined, color: Colors.grey[700], size: 50),
                        const SizedBox(height: 12),
                        const Text('No stories in this genre yet',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ]),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: ctrl.stories.length,
                    itemBuilder: (_, i) {
                      final story    = ctrl.stories[i];
                      final coverUrl = ctrl.getCoverUrl(story);
                      final tags     = (story['tags'] as List? ?? []);
                      return GestureDetector(
                        onTap: () => Navigator.push(context, CupertinoPageRoute(
                            builder: (_) => StoryDetailScreen(slug: story['slug']))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            // Cover
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 80, height: 108,
                                child: coverUrl.isNotEmpty
                                    ? Image.network(coverUrl, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _placeholder())
                                    : _placeholder(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(story['title'] ?? '',
                                    style: const TextStyle(color: Colors.white,
                                        fontSize: 13, fontWeight: FontWeight.w600),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(story['description'] ?? '',
                                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Text(
                                    '${double.tryParse(story['average_rating'].toString())?.toStringAsFixed(1) ?? '0.0'}',
                                    style: const TextStyle(color: Colors.white,
                                        fontSize: 11, fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
                                  const SizedBox(width: 10),
                                  Text('${story['total_views'] ?? 0} views',
                                      style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                ]),
                                const SizedBox(height: 6),
                                if (tags.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: depperBlue.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(tags[0]['name'] ?? '',
                                        style: TextStyle(color: depperBlue, fontSize: 10)),
                                  ),
                              ],
                            )),
                          ]),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFF3a3a3a),
    child: const Center(child: Icon(Icons.book, color: Colors.grey, size: 28)),
  );
}

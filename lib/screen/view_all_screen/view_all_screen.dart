import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/book_preview/story_detail_screen.dart';
import 'package:novelux/widgets/custom_image_view.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  final RxList stories = [].obs;
  final RxBool isLoading = true.obs;
  int page = 1;
  bool hasMore = true;
  late ScrollController _sc;
  String title = '';

  @override
  void initState() {
    super.initState();
    title = Get.arguments?.toString() ?? 'Stories';
    _sc = ScrollController()..addListener(_onScroll);
    _fetchStories();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_sc.position.pixels >= _sc.position.maxScrollExtent - 200 &&
        !isLoading.value &&
        hasMore) {
      page++;
      _fetchStories(append: true);
    }
  }

  Future<void> _fetchStories({bool append = false}) async {
    isLoading.value = true;
    Future<Map<String, dynamic>> Function() fetcher;

    switch (title) {
      case 'Trending Now':
        fetcher = () => ApiService.getTrending();
        break;
      case "Editor's Pick":
        fetcher = () => ApiService.getEditorsPick();
        break;
      case 'Featured':
        fetcher = () => ApiService.getFeatured();
        break;
      default:
        fetcher = () => ApiService.getStories(page: page);
    }

    final res = await fetcher();
    isLoading.value = false;
    if (res['success']) {
      final data = res['data'];
      final List newItems = data is List ? data : (data['results'] ?? []);
      if (append) {
        stories.addAll(newItems);
      } else {
        stories.value = newItems;
      }
      hasMore = (data is Map && data['next'] != null);
    }
  }

  String _getCoverUrl(Map story) {
    final c = story['cover_image'];
    if (c == null || c.toString().isEmpty) {
      return '';
    }
    if (c.toString().startsWith('http')) {
      return c.toString();
    }
    return 'http://10.0.2.2:8000$c';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (isLoading.value && stories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          if (stories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, color: Colors.grey[700], size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'No stories found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            controller: _sc,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: stories.length + (isLoading.value ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == stories.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                );
              }
              final story = stories[i];
              final coverUrl = _getCoverUrl(story);
              final tags = (story['tags'] as List? ?? []);
              final author = story['author'] ?? {};

              return GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => StoryDetailScreen(slug: story['slug']),
                      ),
                    ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 85,
                          height: 115,
                          child:
                              coverUrl.isNotEmpty
                                  ? CustomImageView(
                                    imagePath: coverUrl,
                                    fit: BoxFit.cover,
                                  )
                                  : _placeholder(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // const SizedBox(height: 4),
                            // Text(
                            //   author['username'] ?? '',
                            //   style: TextStyle(
                            //     color: Colors.grey[400],
                            //     fontSize: 12,
                            //   ),
                            // ),
                            const SizedBox(height: 6),
                            Text(
                              story['description'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Stats
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFD700),
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${double.tryParse(story['average_rating'].toString())?.toStringAsFixed(1) ?? '0.0'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.visibility_outlined,
                                  color: Colors.grey,
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${story['total_views'] ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.menu_book_outlined,
                                  color: Colors.grey,
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${story['total_chapters'] ?? 0} ch',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Tags
                            if (tags.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                children:
                                    tags
                                        .take(2)
                                        .map(
                                          (t) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: depperBlue.withOpacity(
                                                0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              t['name'] ?? '',
                                              style: TextStyle(
                                                color: depperBlue,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFF2a2a2a),
    child: const Center(child: Icon(Icons.book, color: Colors.grey, size: 30)),
  );
}

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/book_preview/story_detail_screen.dart';
import 'package:novelux/screen/explore/controller/explore_controller.dart';
import 'package:novelux/screen/view_all_screen/view_all_screen.dart';
import 'package:novelux/widgets/custom_image_view.dart';
import 'package:shimmer/shimmer.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ctrl = Get.put(ExploreController());
  final searchCtrl = TextEditingController();
  int selectedCategoryIndex = 0;
  int selectedRankingIndex = 0;
  int _current = 0;

  CarouselController carouselController = CarouselController();

  final List<String> promoImages = [
    'assets/images/promotion1.png',
    'assets/images/promotion2.png',
    'assets/images/promotion3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: false,
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => _showSearch(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnimatedTextKit(
                          repeatForever: true,
                          // textList: [
                          //   'Search novels, authors, genres...',
                          //   'The Ashboard CRown',
                          //   'sweet home alabama',
                          //   'sweet chaos',
                          //   'luna\'s betrayal',
                          //   'unexpected desires'
                          // ],
                          // style: TextStyle(color: Colors.grey, fontSize: 12),
                          // speed: const Duration(milliseconds: 100),
                          animatedTexts: [
                            //  FadeAnimatedText
                            FadeAnimatedText(
                              textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              'Search novels, authors, genres...',
                              duration: const Duration(milliseconds: 5000),
                            ),
                            FadeAnimatedText(
                              textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              'The Ashboard CRown',
                              duration: const Duration(milliseconds: 5000),
                            ),
                            FadeAnimatedText(
                              textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              'sweet home alabama',
                              duration: const Duration(milliseconds: 5000),
                            ),
                            FadeAnimatedText(
                              textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              'sweet chaos',
                              duration: const Duration(milliseconds: 5000),
                            ),
                            FadeAnimatedText(
                              textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              'luna\'s betrayal',
                              duration: const Duration(milliseconds: 5000),
                            ),
                            FadeAnimatedText(
                              textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              'unexpected desires',
                              duration: const Duration(milliseconds: 5000),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: ctrl.fetchAll,
                color: depperBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Featured Carousel ─────────────────────────────────────
                      Obx(
                        () =>
                            ctrl.featured.isNotEmpty
                                ? _section('Featured', _buildFeaturedCarousel())
                                : ctrl.isLoadingFeatured.value
                                ? _shimmerRow()
                                : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 10),

                      // ── For You / Genre filtered ──────────────────────────────
                      _section(
                        'For You',
                        Column(
                          children: [
                            _genreTabs(),
                            const SizedBox(height: 12),
                            Obx(
                              () =>
                                  ctrl.forYou.isEmpty
                                      ? _shimmerRow()
                                      : _storyRow(ctrl.forYou),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      Stack(
                        alignment:
                            Alignment.bottomRight, // Positions the counter
                        children: [
                          SizedBox(
                            width:
                                double
                                    .infinity, // Ensures the container takes full width
                            height:
                                100, // Increased height slightly for better visibility
                            child: CarouselSlider.builder(
                              itemCount: promoImages.length,
                              itemBuilder: (
                                BuildContext context,
                                int index,
                                int realIndex,
                              ) {
                                return Container(
                                  width:
                                      MediaQuery.of(
                                        context,
                                      ).size.width, // Full screen width
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CustomImageView(
                                      imagePath: promoImages[index],
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 100,
                                autoPlay: true,
                                viewportFraction:
                                    1.0, // This makes it span across the screen
                                enlargeCenterPage:
                                    false, // Turn off to keep it flat and full-width
                                autoPlayInterval: const Duration(seconds: 5),
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current =
                                        index; // Update your index variable here
                                  });
                                },
                              ),
                            ),
                          ),

                          // The Counter Overlay
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children:
                                    promoImages.asMap().entries.map((entry) {
                                      return Container(
                                        width:
                                            _current == entry.key
                                                ? 12.0
                                                : 8.0, // Active dot is slightly wider
                                        height: 8.0,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: depperBlue.withOpacity(
                                            _current == entry.key
                                                ? 0.9
                                                : 0.4, // Active dot is brighter
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                              // Text(
                              //   "${_current + 1} / ${promoImages.length}",
                              //   style: const TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      // ── Rankings ──────────────────────────────────────────────
                      _section(
                        'Best Novels',
                        Column(
                          children: [
                            _tabRow(
                              ['Must Read', 'Most Engaging', 'Top Rated'],
                              selectedRankingIndex,
                              (i) => setState(() => selectedRankingIndex = i),
                            ),
                            const SizedBox(height: 10),
                            Obx(
                              () =>
                                  ctrl.trending.isEmpty
                                      ? _shimmerRow()
                                      : _rankingsList(ctrl.trending),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Trending ──────────────────────────────────────────────
                      _section(
                        'Trending Now',
                        Obx(
                          () =>
                              ctrl.trending.isEmpty
                                  ? _shimmerRow()
                                  : _storyRow(ctrl.trending),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Editor's Pick ─────────────────────────────────────────
                      _section(
                        "Editor's Pick",
                        Obx(
                          () =>
                              ctrl.editorsPick.isEmpty
                                  ? _shimmerRow()
                                  : _featuredList(ctrl.editorsPick),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey[900],
    ),
    child: Column(
      children: [_sectionHeader(title), child, const SizedBox(height: 10)],
    ),
  );

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => Get.to(() => ViewAllScreen(), arguments: title),
          child: Row(
            children: [
              const Text(
                'View all',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _genreTabs() => Obx(() {
    final genres = [
      {'name': 'All', 'slug': ''},
      ...ctrl.genres,
    ];
    return Container(
      height: 28,
      margin: const EdgeInsets.only(left: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (_, i) {
          final isSelected = i == selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() => selectedCategoryIndex = i);
              final slug = genres[i]['slug'] ?? '';
              if (slug.isEmpty) {
                ctrl.fetchForYou();
              } else {
                ctrl.filterByGenre(slug.toString());
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? depperBlue : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genres[i]['name']?.toString() ?? '',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  });

  Widget _tabRow(List<String> tabs, int selected, Function(int) onTap) =>
      Container(
        height: 28,
        margin: const EdgeInsets.only(left: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          itemBuilder: (_, i) {
            final isSel = i == selected;
            return GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isSel ? depperBlue : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: isSel ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      );

  Widget _buildFeaturedCarousel() => Obx(() {
    if (ctrl.featured.isEmpty) {
      return const SizedBox(
        height: 170,
        child: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }
    return Container(
      height: 170,
      child: CarouselView(
        itemExtent:
            MediaQuery.of(context).size.width *
            0.8, // Shows 80% of one card, hinting at the next
        shrinkExtent:
            MediaQuery.of(context).size.width *
            0.7, // Minimum size when shrinking
        children:
            ctrl.featured.map((story) {
              final coverUrl = ctrl.getCoverUrl(story);
              return GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => StoryDetailScreen(slug: story['slug']),
                      ),
                    ),
                child: Container(
                  // Margin and decoration are handled well by CarouselView's internal padding
                  // but you can keep your styling here
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF2A2A2A),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child:
                        coverUrl.isNotEmpty
                            ? CustomImageView(
                              imagePath: coverUrl,
                              fit: BoxFit.cover,
                              placeHolder: coverUrl,
                            )
                            : _bookPlaceholder(),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  });

  Widget _storyRow(RxList stories) => SizedBox(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: stories.length,
      itemBuilder: (_, i) {
        final story = stories[i];
        final coverUrl = ctrl.getCoverUrl(story);
        final tags = (story['tags'] as List? ?? []);
        return GestureDetector(
          onTap:
              () =>
              //print('Tapped on ${story['title']} -  - cover: $coverUrl'),
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => StoryDetailScreen(slug: story['slug']),
                ),
              ),
          child: Container(
            width: 85,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 120,
                    width: 85,
                    child:
                        coverUrl.isNotEmpty
                            ? CustomImageView(
                              imagePath: coverUrl,
                              fit: BoxFit.cover,
                              //errorBuilder: (_, __, ___) => _bookPlaceholder(),
                            )
                            : _bookPlaceholder(),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  story['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tags.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: depperBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tags[0]['name'] ?? '',
                      style: TextStyle(color: depperBlue, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _rankingsList(RxList stories) => SizedBox(
    height: 300,
    child: GridView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: stories.length > 9 ? 9 : stories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 2.4 / 5.3,
        crossAxisCount: 3,
      ),
      itemBuilder: (_, i) {
        final story = stories[i];
        final coverUrl = ctrl.getCoverUrl(story);
        final tags = (story['tags'] as List? ?? []);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => StoryDetailScreen(slug: story['slug']),
                  ),
                ),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 55,
                        height: 75,
                        child:
                            coverUrl.isNotEmpty
                                ? CustomImageView(
                                  imagePath: coverUrl,
                                  fit: BoxFit.cover,
                                  //errorBuilder: (_, __, ___) => _bookPlaceholder(),
                                )
                                : _bookPlaceholder(),
                      ),
                    ),
                    Positioned(
                      child: Container(
                        width: 15,
                        height: 20,
                        decoration: BoxDecoration(
                          color: i < 3 ? depperBlue : const Color(0xFFA9AA6C),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        story['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story['description'] ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${double.tryParse(story['average_rating'].toString())?.toStringAsFixed(1) ?? '0.0'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          SizedBox(width: 8),
                          Text(
                            '${double.tryParse(story['total_views'].toString())?.toStringAsFixed(1)} views',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      if (tags.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: depperBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tags[0]['name'] ?? '',
                            style: TextStyle(color: depperBlue, fontSize: 10),
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
  );

  Widget _featuredList(RxList stories) => Column(
    children:
        stories.take(6).map((story) {
          final coverUrl = ctrl.getCoverUrl(story);
          return GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => StoryDetailScreen(slug: story['slug']),
                  ),
                ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 75,
                      height: 100,
                      child:
                          coverUrl.isNotEmpty
                              ? CustomImageView(
                                imagePath: coverUrl,
                                fit: BoxFit.cover,
                              )
                              : _bookPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story['title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          story['description'] ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${double.tryParse(story['average_rating'].toString())?.toStringAsFixed(1) ?? '0.0'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${story['total_views'] ?? 0} views',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
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
          );
        }).toList(),
  );

  Widget _shimmerRow() => Shimmer(
    gradient: LinearGradient(
      colors: [Colors.grey[800]!, Colors.grey[700]!, Colors.grey[800]!],
      stops: const [0.1, 0.3, 0.4],
      begin: Alignment(-1, -0.3),
      end: Alignment(1, 0.3),
    ),
    child: Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder:
            (_, __) => Container(
              width: 85,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
      ),
    ),
  );

  Widget _bookPlaceholder() => Container(
    color: const Color(0xFF2A2A2A),
    child: const Center(child: Icon(Icons.book, color: Colors.grey, size: 30)),
  );

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: _StorySearchDelegate(ctrl));
  }
}

class _StorySearchDelegate extends SearchDelegate {
  final ExploreController ctrl;
  _StorySearchDelegate(this.ctrl);

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeData.dark().copyWith(
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1a1a1a)),
  );

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    ctrl.search(query);
    return Obx(
      () => ListView.builder(
        itemCount: ctrl.forYou.length,
        itemBuilder: (_, i) {
          final story = ctrl.forYou[i];
          return ListTile(
            leading: const Icon(Icons.book, color: Colors.grey),
            title: Text(
              story['title'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              story['author']?['username'] ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              close(context, null);
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => StoryDetailScreen(slug: story['slug']),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchQuery = "One Pregnancy's Triplets: Daddy is So Am...";
  int selectedCategoryIndex = 0;
  int selectedRankingIndex = 0;
  int selectedCuteBabyIndex = 0;
  int selectedGetRichIndex = 0;

  int _currentIndex = 0;
  late CarouselSliderController carouselController;

  final List<String> title = [
    "For you",
    "Romance",
    "CEO",
    "Mafia",
    "CEO",
    "Mafia",
  ];
  final List<String> subTitle = [
    "For you roipwoeiweuoriwepd",
    "Romance rioowrwoeeproew",
    "CEO oeirpwoewerwoe[p[qwd]]",
    "Mafia dprpfokwepd[wpekfoww",
    "CEO oeirpwoewerwoe[p[qwd]]",
    "Mafia dprpfokwepd[wpekfoww",
  ];
  final List<String> views = [
    "503943.34 Views",
    "4829.4 Views",
    "432.54 Views",
    "34.5 View",
    "432.54 Views",
    "34.5 View",
  ];
  final List<String> chapters = [
    "503943.34 chpaters",
    "4829.4 chapters",
    "432.54 chapters",
    "34.5 chapters",
    "432.54 chapters",
    "34.5 chapters",
  ];

  final List<String> categories = ["For you", "Romance", "CEO", "Mafia"];
  final List<String> rankings = ["Must Read", "Most Engaging", "Top Rated"];
  final List<String> cuteBabyCategories = [
    "One Pregnancy's Triplets",
    "Single mom's baby",
  ];
  final List<String> getRichCategories = [
    "Heir of the Richest Man",
    "Get Rich System",
  ];

  @override
  void initState() {
    super.initState();
    carouselController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar and search
            Container(
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        searchQuery,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Best Novels Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          _buildSectionHeader("Best Novels"),
                          SizedBox(
                            height: 25,
                            child: _buildCategoryTabs(
                              categories,
                              selectedCategoryIndex,
                              (index) {
                                setState(() => selectedCategoryIndex = index);
                              },
                            ),
                          ),
                          _buildBestNovelsGrid(),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Rankings Section
                    // _buildSectionHeader("Rankings"),
                    // _buildCategoryTabs(rankings, selectedRankingIndex, (index) {
                    //   setState(() => selectedRankingIndex = index);
                    // }),
                    // _buildRankingsList(),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          _buildSectionHeader("Rankings"),

                          _buildCategoryTabs(rankings, selectedRankingIndex, (
                            index,
                          ) {
                            setState(() => selectedRankingIndex = index);
                          }),
                          SizedBox(height: 10),
                          _buildRankingsList(),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Daily Update Section
                    _buildSectionHeader("Daily Update"),
                    _buildDailyUpdateCard(),

                    SizedBox(height: 24),

                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          // Free Download Section
                          _buildSectionHeader("Free Download"),
                          _buildFreeDownloadGrid(),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          // Cute Baby Section
                          _buildSectionHeader("Cute Baby"),

                          _buildCategoryTabs(
                            cuteBabyCategories,
                            selectedCuteBabyIndex,
                            (index) {
                              setState(() => selectedCuteBabyIndex = index);
                            },
                          ),
                          SizedBox(height: 16),
                          _buildCuteBabyGrid(),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          // Get Rich Suddenly Section
                          _buildSectionHeader("Get Rich Suddenly"),
                          _buildCategoryTabs(
                            getRichCategories,
                            selectedGetRichIndex,
                            (index) {
                              setState(() => selectedGetRichIndex = index);
                            },
                          ),
                          SizedBox(height: 16),
                          _buildGetRichGrid(),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        children: [
                          // Completed Stories Section
                          _buildSectionHeader("Completed Stories"),
                          _buildCompletedStoriesGrid(),

                          SizedBox(height: 10),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // World Famous Section
                    _buildSectionHeader("World Famous"),
                    _buildWorldFamousGrid(),

                    SizedBox(height: 24),

                    // Featured for you Section
                    _buildSectionHeader("Featured for you"),
                    _buildFeaturedList(),

                    SizedBox(height: 100), // Bottom padding for navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //  bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                "View all",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Icon(Icons.chevron_right, color: Colors.grey, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(
    List<String> categories,
    int selectedIndex,
    Function(int) onTap,
  ) {
    return Container(
      height: 30,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow : Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBestNovelsGrid() {
    final novels = [
      {
        "title": "The Priceless Divine Doctor",
        "subtitle": "Medical Skills",
        "image": "assets/doctor.jpg",
      },
      {
        "title": "Super Rich Second Gene...",
        "subtitle": "Get rich Suddenly",
        "image": "assets/rich.jpg",
      },
      {
        "title": "Comatose Heir's Secret ...",
        "subtitle": "Reborn",
        "image": "assets/contract.jpg",
      },
      {"title": "Billi", "subtitle": "Love", "image": "assets/billionaire.jpg"},
    ];

    return Container(
      height: 200,
      //  margin: EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: novels.length,
        itemBuilder: (context, index) {
          final novel = novels[index];
          return Container(
            width: 80,
            margin: EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(Icons.book, color: Colors.grey, size: 40),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  novel["title"]!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  novel["subtitle"]!,
                  style: TextStyle(color: Colors.orange, fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankingsList() {
    final rankings = [
      {
        "rank": 1,
        "title": "Wed to the Forbidden Uncle",
        "rating": 4.6,
        "views": "177K Views",
        "tag": "Age gap",
      },
      {
        "rank": 2,
        "title": "Love Hate Relationship",
        "rating": 4.9,
        "views": "44.2K Views",
        "tag": "Marriage Before Love",
      },
      {
        "rank": 3,
        "title": "The Confessions of St. Augustine",
        "rating": 3.0,
        "views": "896 Views",
        "tag": "Spirituality",
      },
      {
        "rank": 4,
        "title": "Wed to the Forbidden Uncle",
        "rating": 4.6,
        "views": "177K Views",
        "tag": "Age gap",
      },
      {
        "rank": 5,
        "title": "Love Hate Relationship",
        "rating": 4.9,
        "views": "44.2K Views",
        "tag": "Marriage Before Love",
      },
      {
        "rank": 6,
        "title": "The Confessions of St. Augustine",
        "rating": 3.0,
        "views": "896 Views",
        "tag": "Spirituality",
      },
      {
        "rank": 7,
        "title": "Wed to the Forbidden Uncle",
        "rating": 4.6,
        "views": "177K Views",
        "tag": "Age gap",
      },
      {
        "rank": 8,
        "title": "Love Hate Relationship",
        "rating": 4.9,
        "views": "44.2K Views",
        "tag": "Marriage Before Love",
      },
      {
        "rank": 9,
        "title": "The Confessions of St. Augustine",
        "rating": 3.0,
        "views": "896 Views",
        "tag": "Spirituality",
      },
    ];

    return Column(
      //children: rankings.map((item) => _buildRankingItem(item)).toList(),
      children: [
        Container(
          height: 300,
          child: GridView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: 9,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,

              childAspectRatio: 2.4 / 5.3,
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              var item = rankings[index];
              return _buildRankingItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(child: Icon(Icons.book, color: Colors.grey)),
              ),
              Positioned(
                child: Container(
                  width: 15,
                  height: 20,
                  decoration: BoxDecoration(
                    color:
                        item["rank"] <= 3
                            ? Colors.orange
                            : Color.fromARGB(255, 169, 170, 108),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      "${item["rank"]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item["title"],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "${item["rating"]}",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Icon(Icons.star, color: Colors.yellow, size: 14),
                    SizedBox(width: 8),
                    Text(
                      item["views"],
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  item["tag"],
                  style: TextStyle(color: Colors.orange, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyUpdateCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ FIX: use CarouselSlider directly
                CarouselSlider(
                  items: [
                    _buildDailyUpdateItem("The Return of the Urban God of War"),
                    _buildDailyUpdateItem("A Dare To Kiss The Bad Boy"),
                    _buildDailyUpdateItem("The Billionaire's Fashion Designer"),
                    _buildDailyUpdateItem("The Return of the Urban God of War"),
                    _buildDailyUpdateItem("A Dare To Kiss The Bad Boy"),
                    _buildDailyUpdateItem("The Billionaire's Fashion Designer"),
                  ],
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    aspectRatio: 4 / 7,
                    height: 120,

                    // reverse: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    // initialPage: 1,
                    //  autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction:
                        0.34, // ✅ controls how much of next card shows
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title[_currentIndex], //"The Return of the Urban God of War",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        subTitle[_currentIndex], //"Original title: King of Modern Warfare Five years ago, I was framed and imprisoned! Five years later, I return I...",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text("4.5", style: TextStyle(color: Colors.white)),
                          Icon(Icons.star, color: Colors.yellow, size: 14),
                          SizedBox(width: 8),
                          Text(
                            views[_currentIndex], //"72.8K Views",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(width: 8),
                          Text(
                            chapters[_currentIndex], // "2570 chapters",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          _buildTag("Male Lead"),
                          _buildTag("King"),
                          _buildTag("Warrior"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyUpdateItem(String title) {
    return Container(
      width: 80,
      margin: EdgeInsets.only(right: 8),
      child: Column(
        children: [
          Container(
            height: 104,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 22, 21, 21),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(child: Icon(Icons.book, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeDownloadGrid() {
    final items = [
      "Tame My Ferocious CEO",
      "A Fulfilled Promise of M...",
      "A Dare To Kiss The Bad Boy",
      "Bou",
    ];

    return Container(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Icon(Icons.book, color: Colors.grey)),
                ),
                SizedBox(height: 8),
                Text(
                  items[index],
                  style: TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCuteBabyGrid() {
    final items = [
      {"title": "One Pregnancy's T...", "tag": "Marriage Before L..."},
      {"title": "Comatose Heir's Secret ...", "tag": "Reborn"},
      {"title": "One Pregnancy's T...", "tag": "Cute Babies"},
      {"title": "CEO", "tag": "Rom"},
    ];

    return Container(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Icon(Icons.book, color: Colors.grey)),
                ),
                SizedBox(height: 8),
                Text(
                  items[index]["title"]!,
                  style: TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  items[index]["tag"]!,
                  style: TextStyle(color: Colors.orange, fontSize: 9),
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGetRichGrid() {
    final items = [
      {"title": "The Son of The Richest Man", "tag": "Wealthy Heir"},
      {"title": "I'm the Heir to a Billionaire", "tag": "Wealthy Heiress"},
      {"title": "The Tycoon's Hidden Heir: ...", "tag": "Wealthy Heir"},
      {"title": "Fro", "tag": "Urba"},
    ];

    return Container(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Icon(Icons.book, color: Colors.grey)),
                ),
                SizedBox(height: 8),
                Text(
                  items[index]["title"]!,
                  style: TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  items[index]["tag"]!,
                  style: TextStyle(color: Colors.orange, fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletedStoriesGrid() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildCompletedStoryItem(
            "The Rejected Moon",
            "Mira Savera is a daughter of a beta. She was born perfect and everyone a...",
            3.0,
            "Werewolf",
          ),
          SizedBox(height: 16),
          Container(
            height: 420,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCompletedStoryGridItem(
                  "Mummy, Daddy Is On H...",
                  "Cute Baby",
                ),
                _buildCompletedStoryGridItem(
                  "The Tycoon's Hidden Heir: ...",
                  "Wealthy Heir",
                ),
                _buildCompletedStoryGridItem(
                  "Reborn Ugly Wife Shocks ...",
                  "Rebirth",
                ),
                _buildCompletedStoryGridItem("The Huu", "Reve"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedStoryItem(
    String title,
    String description,
    double rating,
    String tag,
  ) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 120,
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: Icon(Icons.book, color: Colors.grey)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text("$rating", style: TextStyle(color: Colors.white)),
                  Icon(Icons.star, color: Colors.yellow, size: 14),
                  SizedBox(width: 8),
                  Text(
                    tag,
                    style: TextStyle(color: Colors.orange, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedStoryGridItem(String title, String tag) {
    return Container(
      width: 80,
      margin: EdgeInsets.only(right: 8),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Icon(Icons.book, color: Colors.grey, size: 20),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(tag, style: TextStyle(color: Colors.orange, fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildWorldFamousGrid() {
    final items = [
      {
        "title": "Pride and Prejudice",
        "author": "Jane Austen",
        "rating": 4.5,
        "tag": "Social class",
      },
      {
        "title": "Othello, the Moor of Venice",
        "author": "William Shakespeare",
        "tag": "Military hero",
      },
      {"title": "Oliver Twist - Charles Dicke...", "tag": "London underworld"},
      {"title": "Heart of Darkness", "tag": "Colonialism"},
    ];

    return Container(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 100,
            margin: EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Icon(Icons.book, color: Colors.grey)),
                ),
                SizedBox(height: 8),
                Text(
                  item["title"].toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item["rating"] != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${item["rating"]}",
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                      Icon(Icons.star, color: Colors.yellow, size: 10),
                    ],
                  ),
                Text(
                  item["tag"].toString(),
                  style: TextStyle(color: Colors.orange, fontSize: 8),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedList() {
    final items = [
      {
        "title": "One Dollar Flash Sale",
        "description":
            "Charles Matthews, a recent college graduate, found himself in a tough spot...",
        "rating": 4.1,
        "views": "23.0K Views",
        "tags": ["System", "Rags-to-Riches"],
      },
      {
        "title": "THE SEVENTH SON",
        "description":
            "How far would a father go to save his sons?? What lengths would he take?? H...",
        "rating": 5.0,
        "views": "1.4K Views",
        "tags": ["Curse", "Revenge"],
      },
      {
        "title": "The Alchemist",
        "description":
            "\"The Alchemist\" by Ben Jonson is a comedic play likely written in the early ...",
        "rating": 3.0,
        "views": "2.3K Views",
        "tags": ["Hispanic culture", "Self - discovery"],
      },
    ];

    return Column(
      children: items.map((item) => _buildFeaturedItem(item)).toList(),
    );
  }

  Widget _buildFeaturedItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(child: Icon(Icons.book, color: Colors.grey)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item["description"],
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "${item["rating"]}",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.star, color: Colors.yellow, size: 14),
                    SizedBox(width: 8),
                    Text(
                      item["views"],
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Wrap(
                  children:
                      (item["tags"] as List<String>)
                          .map((tag) => _buildTag(tag))
                          .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      margin: EdgeInsets.only(right: 6, bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: Colors.orange, fontSize: 8)),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.library_books, "Library", false),
          _buildNavItem(Icons.explore, "Explore", true),
          _buildNavItem(Icons.apps, "Genres", false),
          _buildNavItem(Icons.person, "Me", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? Colors.yellow : Colors.grey, size: 24),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.yellow : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/config/size_config.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int selectedTabIndex = 0; // Add this line

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double sizeVertical = SizeConfig.blockSizeVertical!;
    double sizeHorizontal = SizeConfig.blockSizeHorizontal!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: background,
                    border: Border(bottom: BorderSide.none),
                  ),
                  child: Row(
                    
                    children: [
                      Spacer(),
                      TabBar(
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide.none,
                        ),
                        isScrollable: true,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: sizeHorizontal * 2,
                        ),
                        tabAlignment: TabAlignment.center,
                        padding: EdgeInsets.zero,
                        // overlayColor: WidgetStateProperty.all(background),
                        //   indicator: null,
                        indicatorColor: Colors.transparent,
                        tabs: [Tab(text: 'Library'), Tab(text: 'History')],
                      ),
                      SizedBox(width: sizeHorizontal * 5,),
                      IconButton(onPressed: (){}, icon: Icon(Icons.playlist_add_check_rounded,size: 30,color: kWhite)),
                      SizedBox(width: 10,),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Library tab content
                    Container(
                      color: background,
                      child: Column(
                        children: [
                          //   Text('data'),
                          SizedBox(
                            height: 28,
                            child: ListView(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildTab("All", 0),
                                _buildTab("completed", 1),
                                _buildTab("Reading", 2),
                                _buildTab("Wishlist", 3),
                                _buildTab("Favorites", 4),
                                _buildTab("Archived", 5),
                              ],
                            ),
                          ),
                          SizedBox(height: sizeVertical * 2),
                          Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.all(8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 0.5,
                                  ),
                              itemCount:
                                  20, // Adjust the number of items as needed
                              itemBuilder: (context, index) {
                                return _buildBookCard(index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // History tab content
                    Container(
                      color: background,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Today',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          // SizedBox(
                          //   height: sizeVertical * 2,
                          // ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount:
                                  20, // Adjust the number of items as needed
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: 10,
                                  child: _buildTabContent(index),
                                );
                              },
                            ),
                          ),
                        ],
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
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap:
          () => setState(() {
            // Handle tab selection logic here
            selectedTabIndex = index; // Toggle selection for demonstration
          }),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selectedTabIndex == index ? depperBlue : kBrown,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selectedTabIndex == index ? depperBlue : kBrown,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selectedTabIndex == index ? Colors.white : kWhite,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    final sampleTitle = [
      "Sample Book Title",
      "CEO Babysitter",
      "The CEO's Contract Wife",
      "The CEO's Secret Wife",
      "The CEO's Unexpected Baby",
      "The CEO's Love Contract",
      "The CEO's Forbidden Affair",
      "The CEO's Secret Baby",
      "The CEO's Fake Marriage",
      "The CEO's Hidden Love",
      "The CEO's Secret Crush",
      "The CEO's Hidden Identity",
      "The CEO's Secret Romance",
      "The CEO's Secret Affair",
      "The CEO's Hidden Desire",
      "The CEO's Secret Love",
      "The CEO's Hidden Past",
      "The CEO's Secret Life",
      "The CEO's Hidden Truth",
      "The CEO's Secret Deal",
      "The CEO's Hidden Agenda",
    ];

    final content = [
      "lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "lorem ipsum dolor sit amet,  consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "lorem ipsum dolor sit amet,  consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
    ];

    final chapter = [
      "911 chapters",
      "100 chapters",
      "200 chapters",
      "300 chapters",
      "400 chapters",
      "500 chapters",
      "600 chapters",
      "700 chapters",
      "800 chapters",
      "900 chapters",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: SizeConfig.blockSizeVertical! * 15,
            width: SizeConfig.blockSizeHorizontal! * 10,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(8),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sampleTitle[index % sampleTitle.length],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),

                  Text(
                    chapter[index % chapter.length],
                    style: TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                  SizedBox(height: 2),
                  Text(
                    content[index % content.length].substring(0, 75) + "...",
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(int index) {
    final sampleTitle = [
      "Sample Book Title",
      "CEO Babysitter",
      "The CEO's Contract Wife",
      "The CEO's Secret Wife",
      "The CEO's Unexpected Baby",
      "The CEO's Love Contract",
      "The CEO's Forbidden Affair",
      "The CEO's Secret Baby",
      "The CEO's Fake Marriage",
      "The CEO's Hidden Love",
      "The CEO's Secret Crush",
      "The CEO's Hidden Identity",
      "The CEO's Secret Romance",
      "The CEO's Secret Affair",
      "The CEO's Hidden Desire",
      "The CEO's Secret Love",
      "The CEO's Hidden Past",
      "The CEO's Secret Life",
      "The CEO's Hidden Truth",
      "The CEO's Secret Deal",
      "The CEO's Hidden Agenda",
    ];

    final sampleImages = [
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
    ];

    final isCompleted =
        index % 3 == 0; // Example condition for completion status

    final progress =
        index == 0
            ? 0.23
            : (index % 3 == 1 ? 0.0 : 0.14); // Example progress values

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical! * 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // image: DecorationImage(
                //   image: NetworkImage(
                //     sampleImages[index % sampleImages.length],
                //   ),
                //   fit: BoxFit.cover,
                // ),
                color: Colors.grey[800],
              ),
            ),
            if (isCompleted)
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          sampleTitle[index % sampleTitle.length],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        // SizedBox(height: 4),
        // LinearProgressIndicator(
        //   value: progress,
        //   backgroundColor: Colors.grey[300],
        //   color: kBrown,
        // ),
      ],
    );
  }
}

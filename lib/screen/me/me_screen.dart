import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/screen/about/about_screen.dart';
import 'package:novelux/screen/download_screen/download_screen.dart';
import 'package:novelux/screen/genres/genres_screen.dart';
import 'package:novelux/screen/library/library_screen.dart';
import 'package:novelux/screen/notification_screen/notification_screen.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a1a),

      body: SafeArea(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF6A5ACD),
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Daniel Ekwere',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // VIP Section
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            //   padding: EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Color(0xFF2a2a2a),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Column(
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: [
            //               Icon(
            //                 Icons.diamond,
            //                 color: Color(0xFFFFD700),
            //                 size: 20,
            //               ),
            //               SizedBox(width: 8),
            //               Text(
            //                 'VIP',
            //                 style: TextStyle(
            //                   color: Color(0xFFFFD700),
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ],
            //           ),
            //           Container(
            //             padding: EdgeInsets.symmetric(
            //               horizontal: 16,
            //               vertical: 8,
            //             ),
            //             decoration: BoxDecoration(
            //               color: Color(0xFFDEB887),
            //               borderRadius: BorderRadius.circular(20),
            //             ),
            //             child: Text(
            //               'Subscribe',
            //               style: TextStyle(
            //                 color: Colors.black,
            //                 fontSize: 12,
            //                 fontWeight: FontWeight.w500,
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 12),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceAround,
            //         children: [
            //           _buildVipFeature(Icons.menu_book, 'Ad-Free Reading'),
            //           _buildVipFeature(Icons.download, 'Ad-Free Download'),
            //           _buildVipFeature(Icons.more_horiz, 'More'),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // Menu items
            Expanded(
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // _buildMenuItem(
                        //   Icons.note_alt,
                        //   'Notes',
                        //   Colors.teal,

                        //   () => Get.to(() => NotificationScreen()),

                        //   //  print('notess')
                        // ),
                        _buildMenuItem(
                          Icons.timelapse_rounded,
                          'History',
                          Colors.lightBlueAccent,

                          () => Get.to(
                            () => LibraryScreen(),
                            arguments: {'value': 1, 'isProfile': true},
                          ),

                          //  print('notess')
                        ),
                        _buildMenuItem(
                          Icons.shopping_cart,
                          'Purchased',
                          Colors.red,
                          () {},
                        ),
                        _buildMenuItem(
                          Icons.dark_mode,
                          'Dark mode',
                          Colors.purple,
                          () {
                            showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    //padding: EdgeInsets.all(8),
                                    height: 230,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Color(0xFF1a1a1a),
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 10),
                                        Text(
                                          'Dark Mode',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(height: 5),
                                        Divider(
                                          color: Colors.black,
                                          thickness: 0.5,
                                        ),
                                        //  SizedBox(height: 5),
                                        ListTile(
                                          leading: Radio(
                                            value: false,
                                            groupValue: false,
                                            onChanged: (value) {},
                                          ),
                                          title: Text(
                                            'System Default',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.black,
                                          thickness: 0.5,
                                        ),
                                        ListTile(
                                          leading: Radio(
                                            value: false,
                                            groupValue: false,
                                            onChanged: (value) {},
                                          ),
                                          title: Text(
                                            'On',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.black,
                                          thickness: 0.5,
                                        ),
                                        ListTile(
                                          leading: Radio(
                                            value: false,
                                            groupValue: false,
                                            onChanged: (value) {},
                                          ),
                                          title: Text(
                                            'Off',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        _buildMenuItem(
                          Icons.download,
                          'Downloads',
                          Colors.blue,
                          () {
                            Get.to(() => DownloadScreen());
                          },
                        ),
                        _buildMenuItem(
                          Icons.favorite,
                          'Reading preferences',
                          Colors.pink,
                          () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildMenuItem(
                      Icons.notifications,
                      'Notifications',
                      Colors.orange,
                      () => Get.to(() => NotificationScreen()),
                    ),
                  ),

                  SizedBox(height: 10),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          Icons.edit,
                          'Becoming an author',
                          Colors.lightBlue,
                          () {},
                        ),

                        _buildMenuItem(Icons.info, 'About', Colors.amber, () {
                          Get.to(() => AboutScreen());
                        }),
                        _buildMenuItem(
                          Icons.help,
                          'Help & Feedback',
                          Colors.orange,
                          () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
      //  bottomNavigationBar: _buildBottomNavigationBar(3),
    );
  }

  Widget _buildVipFeature(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFFDEB887), size: 20),
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(color: Color(0xFFDEB887), fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color iconColor,
    Function() onPress,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[600],
          size: 12,
        ),
        onTap: //() {
            //Get.to(() => NotificationScreen());
            onPress,
        // },
      ),
    );
  }
}

Widget _buildBottomNavigationBar(int selectedIndex) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    backgroundColor: Color(0xFF1a1a1a),
    selectedItemColor: Color(0xFFFFD700),
    unselectedItemColor: Colors.grey[600],
    currentIndex: selectedIndex,
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.library_books),
        label: 'Library',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
      BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Genres'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
    ],
  );
}

// You can navigate between screens using this method
class NavigationHelper {
  static void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MeScreen()),
    );
  }

  static void navigateToGenres(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GenresScreen()),
    );
  }
}

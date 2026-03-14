import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novelux/config/app_style.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

String searchQuery = "One Pregnancy's Triplets: Daddy is So Am...";
int selectedIndex = 0;
List tags = [
  'completed',
  'childhood sweetheart',
  'Revenge',
  'Betrayal',
  'Strong female lead',
  'love Triangle',
  'Dating',
  'Age Group',
];

class _ViewAllScreenState extends State<ViewAllScreen> {
  @override
  Widget build(BuildContext context) {
    var title = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.chevron_left, color: Colors.white),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1A1A1A),
      ),
      backgroundColor: Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Container(
                //   padding: EdgeInsets.all(16),
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //     decoration: BoxDecoration(
                //       color: Color(0xFF2A2A2A),
                //       borderRadius: BorderRadius.circular(25),
                //     ),
                //     child: Row(
                //       children: [
                //         Icon(Icons.search, color: Colors.grey, size: 18),
                //         SizedBox(width: 10),
                //         Expanded(
                //           child: Text(
                //             searchQuery,
                //             style: TextStyle(color: Colors.grey, fontSize: 12),
                //             overflow: TextOverflow.ellipsis,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                viewAllCard(),
                viewAllCard(),
                viewAllCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget viewAllCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.book, color: Colors.grey, size: 40),
                    ),
                  ),
                  SizedBox(width: 5),
                  Column(
                    spacing: 65,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          maxLines: 2,
                          'rtererowrwiro rwoeowprrwei rtererowrwiro rwoeowprrwei',
                          style: TextStyle(
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      //  SizedBox(height: 20),
                      Row(
                        spacing: 30,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                color: Colors.grey,
                                size: 16,
                              ),
                              Text(
                                '1.3k',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                color: Colors.grey,
                                size: 16,
                              ),
                              Text(
                                '1.3k',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons.menu_rounded,
                                color: Colors.grey,
                                size: 16,
                              ),
                              Text(
                                '1.3k',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   height: 20,
            //   child: Row(
            //     children: List.generate(5, (index) {
            //       return Container(
            //         margin: EdgeInsets.symmetric(horizontal: 10),
            //         decoration: BoxDecoration(color: Colors.grey),
            //         child: Text('data'),
            //       );
            //     }),
            //   ),
            // ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 15,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        // margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color:
                              selectedIndex == index
                                  ? const Color.fromARGB(83, 2, 137, 209)
                                  : Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          tags[index],
                          style: TextStyle(
                            color:
                                selectedIndex == index
                                    ? depperBlue
                                    : Colors.grey[900],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(width: 8);
                  },
                  itemCount: 8,
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      'wiuworoe erieoirwfig eiorof feopweowifoio fwepwodpwocwpefioif rifwpdowipopwoc fofipofepofpwof eorffwofwpfwofi opwofpwopeif cwpocpwfwifpwof wpofwpeocwpowp fofpwofpwif pfor',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
}

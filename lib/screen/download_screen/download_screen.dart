import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/download_screen/controller/download_controller.dart';

DownloadController controller = Get.put(DownloadController());

class DownloadScreen extends GetWidget<DownloadController> {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        appBar: AppBar(
          centerTitle: true,

          leading: Obx(() {
            return controller.isMarked.value
                ? IconButton(
                  color: Colors.white,
                  onPressed: () {
                    controller.isMarked.value = false;
                  },
                  icon: Icon(Icons.close_outlined, color: Colors.grey),
                )
                : IconButton(
                  color: Colors.white,
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.chevron_left_rounded),
                );
          }),
          backgroundColor: Color(0xFF1A1A1A),
          title: Text(
            'Downloads',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [
            Obx(() {
              return controller.isMarked.value
                  ? IconButton(
                    onPressed: () {
                      controller.isAllSelected.value = true;
                    },
                    icon: Icon(
                      Icons.check_box_outline_blank_outlined,
                      size: 24,
                      color: Colors.grey,
                    ),
                  )
                  : IconButton(
                    onPressed: () {
                      controller.isMarked.value = true;
                    },
                    icon: Icon(
                      Icons.playlist_add_check_rounded,
                      size: 30,
                      color: kWhite,
                    ),
                  );
            }),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // ListTile(
                //   leading: Container(
                //     height: 120,
                //     width: 60,
                //     decoration: BoxDecoration(
                //       color: Color(0xFF2A2A2A),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Center(
                //       child: Icon(Icons.book, color: Colors.grey, size: 40),
                //     ),
                //   ),
                //   title: Text(
                //     'After i suicide by  his torture: the alpha\'s desperate leap in the house.',
                //   ),
                //   subtitle: Text('Downloaded to 11 chapters'),
                //   trailing: Icon(Icons.more_vert_rounded),
                // ),
                Container(
                  child: Row(
                    spacing: 4,
                    children: [
                      Container(
                        height: 110,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(Icons.book, color: Colors.grey, size: 40),
                        ),
                      ),
                      Spacer(),
                      Column(
                        spacing: 50,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Text(
                              'After i suicide by  his torture: the alpha\'s desperate leap in the house.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          //
                          Text(
                            'Downloaded to 11 chapters',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                      Obx(() {
                        return controller.isMarked.value
                            ? IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.check_box_outline_blank_outlined,
                                color: Colors.grey,
                              ),
                            )
                            : PopupMenuButton<int>(
                              icon: Icon(Icons.more_vert, color: Colors.grey),
                              color: Color(0xFF1a1a1a),
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem<int>(
                                      value: 0,
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),

                                      // Spacer(),
                                      // Icon(Icons.chevron_right, size: 16),
                                    ),

                                    // ),
                                  ],
                              onSelected: (value) {
                                // Handle menu selection

                                print(value);
                              },
                            );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

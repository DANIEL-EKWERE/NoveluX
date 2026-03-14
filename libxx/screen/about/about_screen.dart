import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:novelux/config/app_style.dart';
import 'package:novelux/screen/about/controller/about_controller.dart';

class AboutScreen extends GetWidget<AboutController> {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        appBar: AppBar(
          backgroundColor: Color(0xFF1a1a1a),
          centerTitle: true,
          title: Text(
            'About',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          leading: IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: Colors.grey),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 120),
              Container(
                height: 120,
                width: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.book, color: Colors.grey, size: 40),
                ),
              ),
              SizedBox(height: 12),
              Text('NovelUx', style: TextStyle(color: kWhite)),
              SizedBox(height: 12),
              Text('version 1.1.1.1', style: TextStyle(color: kGrey)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: depperBlue),
                child: Text(
                  'Check fot updates',
                  style: TextStyle(color: kBlack),
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Terms of services',
                        style: TextStyle(color: kWhite, fontSize: 10),
                      ),
                      Text(
                        'privacy policy',
                        style: TextStyle(color: kWhite, fontSize: 10),
                      ),
                      Text(
                        'copyright policy',
                        style: TextStyle(color: kWhite, fontSize: 10),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    'c copyright 2025 Colorful point pte. Ltd All righs Reserved.',
                    style: TextStyle(color: kGrey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

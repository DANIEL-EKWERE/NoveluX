import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:novelux/config/app_style.dart';
// import 'package:jara_market/screens/cart_screen/controller/cart_controller.dart';

// var controller = Get.put(CartController());

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
       // color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 4,
        //     offset: Offset(0, -2),
        //   ),
        // ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Color(0xFF1a1a1a),
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: depperBlue,
        unselectedItemColor: Colors.grey[600],
        items: [
           BottomNavigationBarItem(
            icon: Icon(Icons.library_books,), //SvgPicture.asset('assets/images/img_nav_home_unselected.svg'),   //Icon(Icons.home_outlined),
            activeIcon:  Icon(Icons.library_books,),  //SvgPicture.asset('assets/images/img_nav_home_selected.svg'),   //Icon(Icons.home),
            label: 'Library',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore,weight: 0.1,),
            activeIcon: Icon(Icons.explore,weight: 0.1,),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon:  Icon(Icons.apps,weight: 0.01,),
            activeIcon: const Icon(Icons.apps,weight: 0.01,)  ,
            label: 'Genres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,weight: 0.01,),
            activeIcon: Icon(Icons.person,weight: 0.01,),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}

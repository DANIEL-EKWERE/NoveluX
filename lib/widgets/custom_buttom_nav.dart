import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
       // backgroundColor: Colors.white,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff332052),
        unselectedItemColor: Colors.grey,
        items: [
           BottomNavigationBarItem(
            icon: Icon(LucideIcons.book,), //SvgPicture.asset('assets/images/img_nav_home_unselected.svg'),   //Icon(Icons.home_outlined),
            activeIcon:  Icon(Icons.book,),  //SvgPicture.asset('assets/images/img_nav_home_selected.svg'),   //Icon(Icons.home),
            label: 'Library',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.history,weight: 0.1,),
            activeIcon: Icon(LucideIcons.history,weight: 0.1,),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon:  Icon(LucideIcons.galleryHorizontalEnd400,weight: 0.01,),
            activeIcon: const Icon(LucideIcons.galleryHorizontalEnd400,weight: 0.01,)  ,
            label: 'Genres',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user,weight: 0.01,),
            activeIcon: Icon(LucideIcons.user,weight: 0.01,),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}

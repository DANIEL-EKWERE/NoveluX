import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:novelux/config/local_storage.dart';
import 'package:novelux/config/routes.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
   // await InAppWebViewController.setWebContentsDebuggingEnabled(true); // Optional
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  DataBase dataBase = Get.put(DataBase());

   var token = await dataBase.getToken();
  String initialRoute = token.isNotEmpty ? '/main_screen' : '/splash_screen';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NoveluX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      getPages: AppRoutes.pages,
      //home: ,
      initialRoute:  AppRoutes.splashScreen,
    );
  }
}




import 'package:get/get.dart';
import 'package:novelux/screen/explore/bindings/explore_bindings.dart';
import 'package:novelux/screen/explore/explore_screen.dart';
import 'package:novelux/screen/genres/bindings/genres_bindings.dart';
import 'package:novelux/screen/genres/genres_screen.dart';
import 'package:novelux/screen/library/bindings/library_bindings.dart';
import 'package:novelux/screen/library/library_screen.dart';
import 'package:novelux/screen/main_screen/main_screen.dart';
import 'package:novelux/screen/me/bindings/me_bindings.dart';
import 'package:novelux/screen/me/me_screen.dart';
import 'package:novelux/screen/onboarding/onboarding.dart';
import 'package:novelux/screen/splash_screen/splash_screen.dart';

class AppRoutes {
  static const splashScreen = '/splash_screen';

  static const meScreen = '/me_screen';
  static const onboardingScreen = '/onboarding_screen';

  static const genresScreen = '/genres_screen';
  static const exploreScreen = '/explore_screen';
  static const libraryScreen = '/library_screen';
  static const mainScreen = '/main_screen';

  static List<GetPage> pages = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(
      name: onboardingScreen,
      page: () => const Onboarding(),
    ),
    GetPage(
      name: genresScreen,
      page: () => const GenresScreen(),
      bindings: [GenresBindings()],
    ),
    GetPage(
      name: libraryScreen,
      page: () => const LibraryScreen(),
      bindings: [LibraryBindings()],
    ),
    GetPage(
      name: exploreScreen,
      page: () => const ExploreScreen(),
      bindings: [ExploreBindings()],
    ),

    GetPage(
      name: mainScreen,
      page: () => const MainScreen(),
    ),
    // GetPage(
    //     name: termsOfServiceScreen, page: () => const TermsOfServiceScreen()),
    GetPage(
      name: meScreen,
      page: () => const MeScreen(),
      bindings: [MeBindings()],
    ),

    //     GetPage(
    //       name: loginEmailVerification,
    //       page: () => const LoginEmailVerification(),
    //       bindings: [LoginEmailVerificationBindings()]
    //     ),
  ];
}

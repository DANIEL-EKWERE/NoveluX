import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';
import 'package:novelux/screen/auth/auth_controller.dart';

class LibraryController extends GetxController {
  final RxBool isLoading     = false.obs;
  final RxList bookmarks     = [].obs;
  final RxString activeFilter= 'All'.obs;

  final List<String> filters = ['All', 'Completed', 'Reading', 'Wishlist'];

  @override
  void onInit() {
    super.onInit();
    if (Get.find<AuthController>().isLoggedIn.value) {
      fetchBookmarks();
    }
  }

  Future<void> fetchBookmarks() async {
    isLoading.value = true;
    final res = await ApiService.getMyBookmarks();
    isLoading.value = false;
    if (res['success']) {
      final d = res['data'];
      bookmarks.value = d is List ? d : (d['results'] ?? []);
    }
  }

  List get filteredBookmarks {
    if (activeFilter.value == 'All') { return bookmarks; }
    return bookmarks.where((s) {
      final status = s['status'] ?? '';
      switch (activeFilter.value) {
        case 'Completed': return status == 'completed';
        case 'Reading':   return status == 'ongoing';
        default:          return true;
      }
    }).toList();
  }

  String getCoverUrl(Map story) {
    final c = story['cover_image'];
    if (c == null || c.toString().isEmpty) { return ''; }
    if (c.toString().startsWith('http')) { return c.toString(); }
    return 'https://10.0.2.2:8000$c';
  }

  Future<void> removeBookmark(String slug) async {
    await ApiService.removeBookmark(slug);
    bookmarks.removeWhere((s) => s['slug'] == slug);
  }
}

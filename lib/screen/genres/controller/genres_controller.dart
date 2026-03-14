import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';

class GenresController extends GetxController {
  final RxBool isLoading       = false.obs;
  final RxList genres          = [].obs;
  final RxList stories         = [].obs;
  final RxInt  selectedIndex   = 0.obs;
  final RxString selectedSlug  = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGenres();
  }

  Future<void> fetchGenres() async {
    isLoading.value = true;
    final res = await ApiService.getGenres();
    isLoading.value = false;
    if (res['success']) {
      genres.value = res['data'] is List ? res['data'] : [];
      if (genres.isNotEmpty) {
        selectGenre(0, genres[0]['slug'].toString());
      }
    }
  }

  Future<void> selectGenre(int index, String slug) async {
    selectedIndex.value = index;
    selectedSlug.value  = slug;
    isLoading.value     = true;
    final res = await ApiService.getStories(genre: slug);
    isLoading.value     = false;
    if (res['success']) {
      final d = res['data'];
      stories.value = d is List ? d : (d['results'] ?? []);
    }
  }

  String getCoverUrl(Map story) {
    final c = story['cover_image'];
    if (c == null || c.toString().isEmpty) { return ''; }
    if (c.toString().startsWith('http')) { return c.toString(); }
    return 'http://10.0.2.2:8000$c';
  }
}

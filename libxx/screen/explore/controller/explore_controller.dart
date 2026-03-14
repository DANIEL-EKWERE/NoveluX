import 'package:get/get.dart';
import 'package:novelux/config/api_service.dart';

class ExploreController extends GetxController {
  final RxBool isLoadingTrending = false.obs;
  final RxBool isLoadingFeatured = false.obs;
  final RxBool isLoadingEditors  = false.obs;

  final RxList trending    = [].obs;
  final RxList featured    = [].obs;
  final RxList editorsPick = [].obs;
  final RxList forYou      = [].obs;
  final RxList genres      = [].obs;
  final RxString searchQuery   = ''.obs;
  final RxString selectedGenre = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    fetchTrending();
    fetchFeatured();
    fetchEditorsPick();
    fetchGenres();
    fetchForYou();
  }

  Future<void> fetchTrending() async {
    isLoadingTrending.value = true;
    final res = await ApiService.getTrending();
    isLoadingTrending.value = false;
    if (res['success']) {
      trending.value = res['data'] is List ? res['data'] : (res['data']['results'] ?? []);
    }
  }

  Future<void> fetchFeatured() async {
    isLoadingFeatured.value = true;
    final res = await ApiService.getFeatured();
    isLoadingFeatured.value = false;
    if (res['success']) {
      featured.value = res['data'] is List ? res['data'] : (res['data']['results'] ?? []);
    }
  }

  Future<void> fetchEditorsPick() async {
    isLoadingEditors.value = true;
    final res = await ApiService.getEditorsPick();
    isLoadingEditors.value = false;
    if (res['success']) {
      editorsPick.value = res['data'] is List ? res['data'] : (res['data']['results'] ?? []);
    }
  }

  Future<void> fetchGenres() async {
    final res = await ApiService.getGenres();
    if (res['success']) {
      genres.value = res['data'] is List ? res['data'] : [];
    }
  }

  Future<void> fetchForYou() async {
    final res = await ApiService.getStories(page: 1);
    if (res['success']) {
      forYou.value = res['data'] is List ? res['data'] : (res['data']['results'] ?? []);
    }
  }

  Future<void> search(String query) async {
    searchQuery.value = query;
    final res = await ApiService.getStories(search: query);
    if (res['success']) {
      forYou.value = res['data'] is List ? res['data'] : (res['data']['results'] ?? []);
    }
  }

  String getCoverUrl(Map story) {
    final cover = story['cover_image'];
    if (cover == null || cover.toString().isEmpty) return '';
    if (cover.toString().startsWith('http')) return cover.toString();
    return 'http://10.0.2.2:8000$cover';
  }
}

import 'package:get/get.dart';
import 'package:novelux/screen/book_preview/book_preview.dart';

class BookPreviewController extends GetxController {
  var isLoading = true.obs;
  var bookPreviewList = <BookPreview>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookPreviews();
  }

  void fetchBookPreviews() async {
    try {
      isLoading(true);
      // Simulate a network call
      await Future.delayed(Duration(seconds: 2));
      var previews = List.generate(
          10, (index) => BookPreview()); // Replace with actual data fetching
      bookPreviewList.assignAll(previews);
    } finally {
      isLoading(false);
    }
  }
} 
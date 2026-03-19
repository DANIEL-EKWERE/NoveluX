import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:novelux/config/local_storage.dart';
import 'dart:developer' as myLog;

// class ApiService {
//   static const String baseUrl = 'https://novelux-backend.onrender.com/api';
//   //'http://127.0.0.1:8000/api';

//   //'http://10.0.2.2:8000/api';
//   // Use http://localhost:8000/api for iOS simulator
//   // Use http://192.168.222.146:8000/api for physical device

//   static final DataBase _db = Get.find<DataBase>();

//   // ── Generic request handler ────────────────────────────────────────────────
//   static Future<Map<String, dynamic>> _request(
//     String method,
//     String endpoint, {
//     Map<String, dynamic>? body,
//     bool requiresAuth = true,
//     bool isFormData = false,
//   }) async {
//     final token = await _db.getToken();
//     final headers = <String, String>{
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       if (requiresAuth && token.isNotEmpty) 'Authorization': 'Bearer $token',
//     };

//     final uri = Uri.parse('$baseUrl$endpoint');
//     http.Response response;

//     try {
//       switch (method.toUpperCase()) {
//         case 'GET':
//           response = await http.get(uri, headers: headers);
//           break;
//         case 'POST':
//           response = await http.post(uri,
//               headers: headers, body: body != null ? jsonEncode(body) : null);
//           break;
//         case 'PATCH':
//           response = await http.patch(uri,
//               headers: headers, body: body != null ? jsonEncode(body) : null);
//           break;
//         case 'DELETE':
//           response = await http.delete(uri, headers: headers);
//           break;
//         default:
//           throw Exception('Unsupported HTTP method: $method');
//       }

//       final decoded = jsonDecode(utf8.decode(response.bodyBytes));

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         return {'success': true, 'data': decoded, 'status': response.statusCode};
//       } else {
//         return {
//           'success': false,
//           'data': decoded,
//           'status': response.statusCode,
//           'error': _extractError(decoded),
//         };
//       }
//     } catch (e) {
//       return {'success': false, 'error': 'Network error: $e', 'status': 0};
//     }
//   }

//   static String _extractError(dynamic decoded) {
//     if (decoded is Map) {
//       if (decoded.containsKey('detail')) {
//         return decoded['detail'].toString();
//       }
//       final firstKey = decoded.keys.first;
//       final firstVal = decoded[firstKey];
//       if (firstVal is List) {
//         return '$firstKey: ${firstVal.first}';
//       }
//       return firstVal.toString();
//     }
//     return decoded.toString();
//   }

//   // ── Auth ───────────────────────────────────────────────────────────────────
//   static Future<Map<String, dynamic>> register({
//     required String username,
//     required String email,
//     required String password1,
//     required String password2,
//     String role = 'reader',
//   }) =>
//       _request('POST', '/auth/dj/registration/', body: {
//         'username': username,
//         'email': email,
//         'password1': password1,
//         'password2': password2,
//         'role': role,
//       }, requiresAuth: false);

//   static Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) =>
//       _request('POST', '/auth/token/', body: {
//         'email': email,
//         'password': password,
//       }, requiresAuth: false);

//   static Future<Map<String, dynamic>> refreshToken(String refresh) =>
//       _request('POST', '/auth/token/refresh/', body: {'refresh': refresh},
//           requiresAuth: false);

//   static Future<Map<String, dynamic>> getMe() =>
//       _request('GET', '/auth/me/');

//   static Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) =>
//       _request('PATCH', '/auth/me/', body: data);

//   static Future<Map<String, dynamic>> becomeAuthor() =>
//       _request('POST', '/auth/become-author/');

//   static Future<Map<String, dynamic>> followUser(String username) =>
//       _request('POST', '/auth/follow/$username/');

//   static Future<Map<String, dynamic>> unfollowUser(String username) =>
//       _request('DELETE', '/auth/follow/$username/');

//   // ── Stories ────────────────────────────────────────────────────────────────
//   static Future<Map<String, dynamic>> getStories({
//     String? genre,
//     String? tag,
//     String? search,
//     String? language,
//     String? status,
//     int page = 1,
//   }) {
//     var params = '?page=$page';
//     if (genre != null) params += '&genre=$genre';
//     if (tag != null) params += '&tag=$tag';
//     if (search != null) params += '&search=$search';
//     if (language != null) params += '&language=$language';
//     if (status != null) params += '&status=$status';
//     return _request('GET', '/stories/$params', requiresAuth: false);
//   }

//   static Future<Map<String, dynamic>> getTrending() =>
//       _request('GET', '/stories/trending/', requiresAuth: false);

//   static Future<Map<String, dynamic>> getFeatured() =>
//       _request('GET', '/stories/featured/', requiresAuth: false);

//   static Future<Map<String, dynamic>> getEditorsPick() =>
//       _request('GET', '/stories/editors-pick/', requiresAuth: false);

//   static Future<Map<String, dynamic>> getStoryDetail(String slug) =>
//       _request('GET', '/stories/$slug/', requiresAuth: false);

//   static Future<Map<String, dynamic>> getGenres() =>
//       _request('GET', '/stories/genres/', requiresAuth: false);

//   static Future<Map<String, dynamic>> getTags() =>
//       _request('GET', '/stories/tags/', requiresAuth: false);

//   static Future<Map<String, dynamic>> getMyBookmarks() =>
//       _request('GET', '/stories/bookmarks/');

//   static Future<Map<String, dynamic>> bookmarkStory(String slug) =>
//       _request('POST', '/stories/$slug/bookmark/');

//   static Future<Map<String, dynamic>> removeBookmark(String slug) =>
//       _request('DELETE', '/stories/$slug/bookmark/');

//   static Future<Map<String, dynamic>> rateStory(
//           String slug, int score, String review) =>
//       _request('POST', '/stories/$slug/rate/', body: {'score': score, 'review': review});

//   static Future<Map<String, dynamic>> createStory(Map<String, dynamic> data) =>
//       _request('POST', '/stories/', body: data);

//   static Future<Map<String, dynamic>> updateStory(
//           String slug, Map<String, dynamic> data) =>
//       _request('PATCH', '/stories/$slug/', body: data);

//   static Future<Map<String, dynamic>> getMyStories() =>
//       _request('GET', '/stories/mine/');

//   // ── Chapters ───────────────────────────────────────────────────────────────
//   static Future<Map<String, dynamic>> getChapters(String storySlug) =>
//       _request('GET', '/chapters/$storySlug/chapters/', requiresAuth: true);

//   static Future<Map<String, dynamic>> getChapter(
//           String storySlug, int chapterNumber) =>
//       _request('GET', '/chapters/$storySlug/chapters/$chapterNumber/');

//   static Future<Map<String, dynamic>> unlockChapter(
//           String storySlug, int chapterNumber) =>
//       _request('POST', '/chapters/$storySlug/chapters/$chapterNumber/unlock/');

//   static Future<Map<String, dynamic>> createChapter(
//           String storySlug, Map<String, dynamic> data) =>
//       _request('POST', '/chapters/$storySlug/chapters/', body: data);

//   // ── Coins ──────────────────────────────────────────────────────────────────
//   static Future<Map<String, dynamic>> getCoinPackages() =>
//       _request('GET', '/coins/packages/', requiresAuth: false);

//   static Future<Map<String, dynamic>> getSubscriptionPlans() =>
//       _request('GET', '/coins/plans/', requiresAuth: false);

//   static Future<Map<String, dynamic>> getCoinBalance() =>
//       _request('GET', '/coins/balance/');

//   static Future<Map<String, dynamic>> createCheckout(
//           String purchaseType, {String? packageId, String? planId}) =>
//       _request('POST', '/coins/checkout/', body: {
//         'purchase_type': purchaseType,
//         if (packageId != null) 'package_id': packageId,
//         if (planId != null) 'plan_id': planId,
//       });

//   // ── Comments ───────────────────────────────────────────────────────────────
//   static Future<Map<String, dynamic>> getComments(
//           String storySlug, int chapterNumber) =>
//       _request('GET', '/comments/$storySlug/chapters/$chapterNumber/comments/',
//           requiresAuth: false);

//   static Future<Map<String, dynamic>> postComment(
//           String storySlug, int chapterNumber, String content,
//           {int? parentId, int? paragraphIndex}) =>
//       _request('POST',
//           '/comments/$storySlug/chapters/$chapterNumber/comments/',
//           body: {
//             'content': content,
//             if (parentId != null) 'parent': parentId,
//             if (paragraphIndex != null) 'paragraph_index': paragraphIndex,
//           });

//   static Future<Map<String, dynamic>> likeComment(int commentId) =>
//       _request('POST', '/comments/comment/$commentId/like/');

//   static Future<Map<String, dynamic>> unlikeComment(int commentId) =>
//       _request('DELETE', '/comments/comment/$commentId/like/');

//   // ── Tips ───────────────────────────────────────────────────────────────────
//   static Future<Map<String, dynamic>> sendTip(
//           String storySlug, int coins, {String? message}) =>
//       _request('POST', '/tips/$storySlug/tip/', body: {
//         'coins_amount': coins,
//         if (message != null) 'message': message,
//       });

//   static Future<Map<String, dynamic>> getTopTippers(String storySlug) =>
//       _request('GET', '/tips/$storySlug/top-tippers/', requiresAuth: false);

//   // ── Notifications ──────────────────────────────────────────────────────────
//   static Future<Map<String, dynamic>> getNotifications() =>
//       _request('GET', '/notifications/');

//   static Future<Map<String, dynamic>> getUnreadCount() =>
//       _request('GET', '/notifications/unread/');

//   static Future<Map<String, dynamic>> markAllRead() =>
//       _request('POST', '/notifications/mark-all-read/');

//   static Future<Map<String, dynamic>> markRead(int id) =>
//       _request('POST', '/notifications/$id/read/');
// //}

//   static Future<Map<String, dynamic>> requestPayout() =>
//       _request('POST', '/coins/payout/request/', body: {
//         'payout_method': 'bank_transfer',
//       });

//   static Future<Map<String, dynamic>> getPublicProfile(String username) =>
//       _request('GET', '/auth/profile/$username/', requiresAuth: false);
// }

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:novelux/config/local_storage.dart';

class ApiService {
  static const String baseUrl = 'https://novelux-backend.onrender.com/api';
  //'http://10.0.2.2:8000/api';
  // Use http://localhost:8000/api for iOS simulator
  // Use http://YOUR_PC_IP:8000/api for physical device

  static final DataBase _db = Get.find<DataBase>();

  // ── Generic request handler ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    bool isFormData = false,
  }) async {
    final token = await _db.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (requiresAuth && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$baseUrl$endpoint');
    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // myLog.log(decoded);
        return {
          'success': true,
          'data': decoded,
          'status': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'data': decoded,
          'status': response.statusCode,
          'error': _extractError(decoded),
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e', 'status': 0};
    }
  }

  static String _extractError(dynamic decoded) {
    if (decoded is Map) {
      if (decoded.containsKey('detail')) {
        return decoded['detail'].toString();
      }
      final firstKey = decoded.keys.first;
      final firstVal = decoded[firstKey];
      if (firstVal is List) {
        return '$firstKey: ${firstVal.first}';
      }
      return firstVal.toString();
    }
    return decoded.toString();
  }

  // ── Auth ───────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password1,
    required String password2,
    String role = 'reader',
  }) => _request(
    'POST',
    '/auth/dj/registration/',
    body: {
      'username': username,
      'email': email,
      'password1': password1,
      'password2': password2,
      'role': role,
    },
    requiresAuth: false,
  );

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => _request(
    'POST',
    '/auth/token/',
    body: {'email': email, 'password': password},
    requiresAuth: false,
  );

  static Future<Map<String, dynamic>> refreshToken(String refresh) => _request(
    'POST',
    '/auth/token/refresh/',
    body: {'refresh': refresh},
    requiresAuth: false,
  );

  static Future<Map<String, dynamic>> getMe() => _request('GET', '/auth/me/');

  static Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) =>
      _request('PATCH', '/auth/me/', body: data);

  static Future<Map<String, dynamic>> becomeAuthor() =>
      _request('POST', '/auth/become-author/');

  static Future<Map<String, dynamic>> followUser(String username) =>
      _request('POST', '/auth/follow/$username/');

  static Future<Map<String, dynamic>> unfollowUser(String username) =>
      _request('DELETE', '/auth/follow/$username/');

  // ── Stories ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getStories({
    String? genre,
    String? tag,
    String? search,
    String? language,
    String? status,
    int page = 1,
  }) {
    var params = '?page=$page';
    if (genre != null) params += '&genre=$genre';
    if (tag != null) params += '&tag=$tag';
    if (search != null) params += '&search=$search';
    if (language != null) params += '&language=$language';
    if (status != null) params += '&status=$status';
    return _request('GET', '/stories/$params', requiresAuth: false);
  }

  static Future<Map<String, dynamic>> getTrending() =>
      _request('GET', '/stories/trending/', requiresAuth: false);

  static Future<Map<String, dynamic>> getFeatured() =>
      _request('GET', '/stories/featured/', requiresAuth: false);

  static Future<Map<String, dynamic>> getEditorsPick() =>
      _request('GET', '/stories/editors-pick/', requiresAuth: false);

  static Future<Map<String, dynamic>> getStoryDetail(String slug) =>
      _request('GET', '/stories/$slug/', requiresAuth: false);

  static Future<Map<String, dynamic>> getGenres() =>
      _request('GET', '/stories/genres/', requiresAuth: false);

  static Future<Map<String, dynamic>> getTags() =>
      _request('GET', '/stories/tags/', requiresAuth: false);

  static Future<Map<String, dynamic>> getMyBookmarks() =>
      _request('GET', '/stories/bookmarks/');

  static Future<Map<String, dynamic>> bookmarkStory(String slug) =>
      _request('POST', '/stories/$slug/bookmark/');

  static Future<Map<String, dynamic>> removeBookmark(String slug) =>
      _request('DELETE', '/stories/$slug/bookmark/');

  static Future<Map<String, dynamic>> rateStory(
    String slug,
    int score,
    String review,
  ) => _request(
    'POST',
    '/stories/$slug/rate/',
    body: {'score': score, 'review': review},
  );

  static Future<Map<String, dynamic>> createStory(Map<String, dynamic> data) =>
      _request('POST', '/stories/', body: data);

  static Future<Map<String, dynamic>> updateStory(
    String slug,
    Map<String, dynamic> data,
  ) => _request('PATCH', '/stories/$slug/', body: data);

  static Future<Map<String, dynamic>> getMyStories() =>
      _request('GET', '/stories/mine/');

  // ── Chapters ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getChapters(String storySlug) =>
      _request('GET', '/chapters/$storySlug/chapters/', requiresAuth: true);

  static Future<Map<String, dynamic>> getChapter(
    String storySlug,
    int chapterNumber,
  ) => _request('GET', '/chapters/$storySlug/chapters/$chapterNumber/');

  static Future<Map<String, dynamic>> unlockChapter(
    String storySlug,
    int chapterNumber,
  ) => _request('POST', '/chapters/$storySlug/chapters/$chapterNumber/unlock/');

  static Future<Map<String, dynamic>> createChapter(
    String storySlug,
    Map<String, dynamic> data,
  ) => _request('POST', '/chapters/$storySlug/chapters/', body: data);

  // ── Coins ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCoinPackages() =>
      _request('GET', '/coins/packages/', requiresAuth: false);

  static Future<Map<String, dynamic>> getSubscriptionPlans() =>
      _request('GET', '/coins/plans/', requiresAuth: false);

  static Future<Map<String, dynamic>> getCoinBalance() =>
      _request('GET', '/coins/balance/');

  static Future<Map<String, dynamic>> createCheckout(
    String purchaseType, {
    String? packageId,
    String? planId,
  }) => _request(
    'POST',
    '/coins/checkout/',
    body: {
      'purchase_type': purchaseType,
      if (packageId != null) 'package_id': packageId,
      if (planId != null) 'plan_id': planId,
    },
  );

  // ── Comments ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getComments(
    String storySlug,
    int chapterNumber,
  ) => _request(
    'GET',
    '/comments/$storySlug/chapters/$chapterNumber/comments/',
    requiresAuth: false,
  );

  static Future<Map<String, dynamic>> postComment(
    String storySlug,
    int chapterNumber,
    String content, {
    int? parentId,
    int? paragraphIndex,
  }) => _request(
    'POST',
    '/comments/$storySlug/chapters/$chapterNumber/comments/',
    body: {
      'content': content,
      if (parentId != null) 'parent': parentId,
      if (paragraphIndex != null) 'paragraph_index': paragraphIndex,
    },
  );

  static Future<Map<String, dynamic>> likeComment(int commentId) =>
      _request('POST', '/comments/comment/$commentId/like/');

  static Future<Map<String, dynamic>> unlikeComment(int commentId) =>
      _request('DELETE', '/comments/comment/$commentId/like/');

  // ── Tips ───────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> sendTip(
    String storySlug,
    int coins, {
    String? message,
  }) => _request(
    'POST',
    '/tips/$storySlug/tip/',
    body: {
      'coins_amount':
          coins.toInt(), // explicit int — prevents string serialisation
      if (message != null && message.isNotEmpty) 'message': message,
    },
  );

  static Future<Map<String, dynamic>> getTopTippers(String storySlug) =>
      _request('GET', '/tips/$storySlug/top-tippers/', requiresAuth: false);

  // ── Notifications ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotifications() =>
      _request('GET', '/notifications/');

  static Future<Map<String, dynamic>> getUnreadCount() =>
      _request('GET', '/notifications/unread/');

  static Future<Map<String, dynamic>> markAllRead() =>
      _request('POST', '/notifications/mark-all-read/');

  static Future<Map<String, dynamic>> markRead(int id) =>
      _request('POST', '/notifications/$id/read/');
  //}

  static Future<Map<String, dynamic>> requestPayout() => _request(
    'POST',
    '/coins/payout/request/',
    body: {'payout_method': 'bank_transfer'},
  );

  static Future<Map<String, dynamic>> getPublicProfile(String username) =>
      _request('GET', '/auth/profile/$username/', requiresAuth: false);

  // ── Reviews ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getStoryReviews(
    String slug, {
    String type = 'all',
  }) {
    final query = type == 'all' ? '' : '?rating=$type';
    return _request(
      'GET',
      '/stories/$slug/reviews/$query',
      requiresAuth: false,
    );
  }

  static Future<Map<String, dynamic>> submitReview(
    String slug, {
    required String rating,
    String content = '',
  }) => _request(
    'POST',
    '/stories/$slug/reviews/',
    body: {'rating': rating, 'content': content},
  );
}

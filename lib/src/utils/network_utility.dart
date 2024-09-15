import 'package:http/http.dart' as http;

mixin NetworkUtility {
  static Future<String?> fetchUrl(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
      print('NetworkUtility : response : $response');
      return null;
    } catch (e) {
      print('NetworkUtility : error : $e');
      return null;
    }
  }
}

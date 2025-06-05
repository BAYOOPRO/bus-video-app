import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = "http://192.168.1.10:8080/ms_company_api/get_video.php";

  static Future<String?> fetchVideoUrl() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData["status"] == "success") {
        return jsonData["video_url"];
      }
    }
    return null;
  }
}

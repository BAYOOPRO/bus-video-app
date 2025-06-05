import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/api_handler.dart';
import 'package:ms/core/AppLink.dart';

class VideoScreenController {
  VideoPlayerController? controller;
  bool isLoading = true;

  /// ✅ تحميل الفيديو من السيرفر أو الكاش + إرسال حالة online
  Future<void> fetchAndCacheVideo(
      Function onSuccess,
      Function onFailure,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final dir = await getApplicationDocumentsDirectory();
    final connectivity = await Connectivity().checkConnectivity();

    String? cachedName = prefs.getString("cached_video_name");

    if (connectivity != ConnectivityResult.none) {
      try {
        final response = await ApiHandler.get(AppLink.getCurrentVideo);
        print("📦 Response from API: $response");

        if (response["status"] == "success" && response["video"] != null) {
          final video = response["video"];
          final videoUrl = video["video_url"];
          final fileName = videoUrl.split('/').last;
          final filePath = '${dir.path}/$fileName';
          final file = File(filePath);

          if (cachedName != fileName || !await file.exists()) {
            final res = await http.get(Uri.parse(videoUrl));
            await file.writeAsBytes(res.bodyBytes);
            await prefs.setString("cached_video_name", fileName);
            cachedName = fileName;
          }
        }
      } catch (e) {
        print("⚠️ Failed to fetch video from server: $e");
      }
    }

    if (cachedName != null) {
      final cachedFile = File('${dir.path}/$cachedName');
      if (await cachedFile.exists()) {
        controller = VideoPlayerController.file(cachedFile);
        await controller!.initialize();
        await controller!.setLooping(true);
        controller!.play();
        isLoading = false;

        // ✅ نرسل online فقط بدون وقت
        await markBusStatus("online");

        onSuccess();
        return;
      }
    }

    onFailure();
  }
  /// ✅ تشغيل فيديو مباشر من URL بدون كاش (للأدمن)
  Future<void> initializeVideo(String url) async {
    controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller!.initialize();
    await controller!.setLooping(true);
    controller!.play();
    isLoading = false;
  }

  /// ✅ إرسال حالة الأتوبيس (online/offline) للسيرفر
  Future<void> markBusStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    final busNumber = prefs.getString('bus_number');

    if (busNumber != null) {
      try {
        final body = {
          'bus_number': busNumber,
          'status': status,
        };

        // ⏱️ نرسل last_seen فقط عند الخروج (offline)
        if (status == "offline") {
          final now = DateTime.now().toIso8601String();
          body['last_seen'] = now;
        }

        final response = await http.post(
          Uri.parse(AppLink.updateBusStatus),
          body: body,
        );

        print("📡 Sent status '$status' for bus $busNumber ✅");
        print("🧾 Server response: ${response.body}");
      } catch (e) {
        print("❌ Failed to send status: $e");
      }
    } else {
      print("⚠️ No bus number saved locally.");
    }
  }

  void dispose() {
    controller?.dispose();
  }
}

import 'package:ms/core/api_handler.dart';

import '../core/app_link.dart';


class SelectVideoController {
  bool isLoading = true;
  List videos = [];
  int? currentVideoId;

  Future<void> fetchVideos() async {
    isLoading = true;

    final response = await ApiHandler.get(AppLink.getAllVideos);

    isLoading = false;

    if (response["status"] == "success" && response["videos"] != null) {
      videos = List.from(response["videos"]);

      final current = videos.firstWhere(
            (v) => v["is_active"] == "1" || v["is_active"] == 1,
        orElse: () => null,
      );

      if (current != null) {
        currentVideoId = int.tryParse(current["id"].toString());
      }
    } else {
      videos = [];
    }
  }

  Future<void> setCurrentVideo(String id) async {
    final response = await ApiHandler.post(AppLink.setCurrentVideo, {
      "video_id": id,
    });

    if (response["status"] == "success") {
      currentVideoId = int.tryParse(id); // ✅ خليه يحدّث القيمة
      for (var v in videos) {
        v["is_active"] = v["id"].toString() == id ? 1 : 0;
      }
    }


  }

}

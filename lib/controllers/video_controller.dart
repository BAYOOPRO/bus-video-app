import 'package:get/get.dart';
import 'package:ms/core/AppLink.dart';
import '../core/api_handler.dart';
import '../models/video_model.dart';

class VideoController extends GetxController {
  var videoList = <VideoModel>[].obs;
  var isLoading = false.obs;

  Future<void> fetchAllVideos() async {
    isLoading.value = true;
    final response = await ApiHandler.get(AppLink.getCurrentVideo);

    if (response['status'] == 'success') {
      videoList.value = (response['videos'] as List)
          .map((e) => VideoModel.fromJson(e))
          .toList();
    } else {
      videoList.clear();
    }

    isLoading.value = false;
  }
}

import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:ms/core/AppLink.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class UploadVideoController {
  final ValueNotifier<double> uploadProgress = ValueNotifier<double>(0);

  Future<String> uploadVideo(File videoFile) async {
    final uri = Uri.parse("https://handasiasw.com/ms_company_api/upload_video.php");
    final request = http.MultipartRequest('POST', uri);

// أضف headers تمنع الريديركت التلقائي
    request.headers.addAll({
      "Connection": "keep-alive",
      "Accept": "*/*",
    });

    final mimeType = lookupMimeType(videoFile.path) ?? 'video/mp4';
    final totalLength = await videoFile.length();

    int uploaded = 0;
    final stream = http.ByteStream(
      Stream.castFrom(videoFile.openRead().transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (data, sink) {
            uploaded += data.length;
            uploadProgress.value = uploaded / totalLength;
            sink.add(data);
          },
        ),
      )),
    );

    final video = http.MultipartFile(
      'file',
      stream,
      totalLength,
      filename: basename(videoFile.path),
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(video);

    try {
      final streamedResponse = await request.send();

      // ✅ لو حصل redirect نعرضه
      if (streamedResponse.statusCode == 307) {
        final redirectUrl = streamedResponse.headers['location'];
        return "❌ السيرفر عمل إعادة توجيه إلى: $redirectUrl";
      }

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return "تم رفع '${basename(videoFile.path)}' بنجاح";
      } else {
        return "فشل في الرفع: ${response.body}";
      }
    } catch (e) {
      return "حدث خطأ أثناء الرفع: $e";
    }
}
    void dispose() {
    uploadProgress.dispose();
  }
}

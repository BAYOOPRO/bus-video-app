import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ChunkedUploadController {
  final ValueNotifier<double> chunkProgress = ValueNotifier<double>(0);
  final ValueNotifier<double> totalProgress = ValueNotifier<double>(0);
  final Dio _dio = Dio();

  Future<String> uploadFileInChunks(
    File file, {
    int chunkSize = 10 * 1024 * 1024,
  }) async {
    final fileLength = await file.length();
    final totalChunks = (fileLength / chunkSize).ceil();
    final fileName = "ms_${DateTime.now().millisecondsSinceEpoch}.mp4";

    // ignore: avoid_print
    print("🚀 بدء رفع الملف على شكل أجزاء");
    print("📁 اسم الملف: $fileName");
    print("🧩 عدد الأجزاء: $totalChunks");

    try {
      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end =
            ((i + 1) * chunkSize > fileLength)
                ? fileLength
                : (i + 1) * chunkSize;
        final chunkStream = file.openRead(start, end);
        final chunkSizeBytes = end - start;

        // ignore: avoid_print
        print(
          "📦 رفع الجزء رقم ${i + 1} من $totalChunks (الحجم: $chunkSizeBytes بايت)",
        );

        final formData = FormData.fromMap({
          'file':  MultipartFile.fromStream(
            () => chunkStream, // ← ده المطلوب
            chunkSizeBytes,
            filename: '$fileName.part$i',
          ),

          'name': fileName,
          'chunk_index': i.toString(),
          'total_chunks': totalChunks.toString(),
        });

        final response = await _dio.post(
          "https://handasiasw.com/ms_company_api/upload_chunk.php",
          data: formData,
          onSendProgress: (sent, total) {
            chunkProgress.value = sent / total;
            totalProgress.value = (i + sent / total) / totalChunks;
          },
        );

        if (response.statusCode == 200 &&
            response.data.toString().contains("success")) {
          // ignore: avoid_print
          print("✅ الجزء ${i + 1} تم رفعه بنجاح");
          await Future.delayed(const Duration(seconds: 1));
        } else {
          print("❌ فشل في رفع الجزء رقم ${i + 1}");
          return "فشل في رفع الجزء رقم ${i + 1}";
        }
      }

      // ignore: avoid_print
      print("🧬 جاري إرسال طلب الدمج النهائي...");
      final finalizeResponse = await _dio.post(
        'https://handasiasw.com/ms_company_api/finalize_upload.php',
        data: FormData.fromMap({
          'name': fileName,
          'total_chunks': totalChunks.toString(),
        }),
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );

      // ignore: avoid_print
      print("📨 رد الدمج النهائي: ${finalizeResponse.data}");

      if (finalizeResponse.statusCode == 200 &&
          finalizeResponse.data.toString().contains("success")) {
        print("🎉 تم رفع '$fileName' ودمجه بنجاح");
        return "تم رفع '$fileName' بنجاح على شكل أجزاء";
      } else {
        return "❌ فشل أثناء دمج الأجزاء";
      }
    } catch (e) {
      print("⚠️ استثناء أثناء الرفع: $e");
      return "حدث خطأ أثناء الرفع: $e";
    }
  }

  void dispose() {
    chunkProgress.dispose();
    totalProgress.dispose();
  }
}

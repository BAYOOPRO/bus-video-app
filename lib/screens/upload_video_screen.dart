import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import '../controllers/chunked_upload_controller.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  File? _videoFile;
  String? _statusMessage;
  bool _isUploading = false;

  final ChunkedUploadController _controller = ChunkedUploadController();

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
        _statusMessage = null;
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) return;

    setState(() {
      _isUploading = true;
      _statusMessage = null;
    });

    final result = await _controller.uploadFileInChunks(_videoFile!);

    setState(() {
      _isUploading = false;
      _statusMessage = result;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("📤 رفع فيديو مجزأ"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 80, color: Colors.teal.shade300),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_library),
              label: const Text("اختر فيديو"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_videoFile != null)
              Text(
                "🎬 تم اختيار: ${basename(_videoFile!.path)}",
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 30),

            // بروجرس لكل جزء
            ValueListenableBuilder<double>(
              valueListenable: _controller.chunkProgress,
              builder: (context, chunkProgress, child) {
                return chunkProgress > 0 && chunkProgress < 1
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: chunkProgress),
                    const SizedBox(height: 8),
                    Text("رفع جزء: ${(chunkProgress * 100).toStringAsFixed(0)}%"),
                    const SizedBox(height: 20),
                  ],
                )
                    : const SizedBox();
              },
            ),

            // بروجرس الإجمالي
            ValueListenableBuilder<double>(
              valueListenable: _controller.totalProgress,
              builder: (context, totalProgress, child) {
                return totalProgress > 0
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: totalProgress),
                    const SizedBox(height: 8),
                    Text("📊 إجمالي التقدم: ${(totalProgress * 100).toStringAsFixed(0)}%"),
                    const SizedBox(height: 30),
                  ],
                )
                    : const SizedBox();
              },
            ),

            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _videoFile == null ? null : _uploadVideo,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("بدء الرفع المجزأ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (_statusMessage != null)
              Text(
                _statusMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _statusMessage!.contains("تم") ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

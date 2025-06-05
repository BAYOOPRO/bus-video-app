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
      appBar: AppBar(title: const Text("رفع فيديو مجزأ")),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text("اختر فيديو"),
            ),
            const SizedBox(height: 20),
            if (_videoFile != null)
              Text("تم اختيار: ${basename(_videoFile!.path)}"),
            const SizedBox(height: 20),

            // بروجرس لكل جزء
            ValueListenableBuilder<double>(
              valueListenable: _controller.chunkProgress,
              builder: (context, chunkProgress, child) {
                return chunkProgress > 0 && chunkProgress < 1
                    ? Column(
                  children: [
                    LinearProgressIndicator(value: chunkProgress),
                    const SizedBox(height: 8),
                    Text("رفع جزء: ${(chunkProgress * 100).toStringAsFixed(0)}%"),
                  ],
                )
                    : const SizedBox();
              },
            ),

            const SizedBox(height: 10),

            // بروجرس الإجمالي
            ValueListenableBuilder<double>(
              valueListenable: _controller.totalProgress,
              builder: (context, totalProgress, child) {
                return totalProgress > 0
                    ? Column(
                  children: [
                    LinearProgressIndicator(value: totalProgress),
                    const SizedBox(height: 8),
                    Text("إجمالي التقدم: ${(totalProgress * 100).toStringAsFixed(0)}%"),
                  ],
                )
                    : const SizedBox();
              },
            ),

            const SizedBox(height: 20),

            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _videoFile == null ? null : _uploadVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text("بدء الرفع المجزأ"),
            ),

            const SizedBox(height: 20),

            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.contains("تم") ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

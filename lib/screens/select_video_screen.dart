// ✅ lib/screens/select_video_screen.dart
import 'package:flutter/material.dart';
import 'package:ms/core/app_link.dart';
import 'package:ms/screens/video_screen.dart';

import '../controllers/select_video_controller.dart';

class SelectVideoScreen extends StatefulWidget {
  const SelectVideoScreen({super.key});

  @override
  State<SelectVideoScreen> createState() => _SelectVideoScreenState();
}

class _SelectVideoScreenState extends State<SelectVideoScreen> {
  final controller = SelectVideoController();

  @override
  void initState() {
    super.initState();
    controller.fetchVideos().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("اختيار فيديو")),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.videos.length,
        itemBuilder: (context, index) {
          final video = controller.videos[index];
          final isCurrent =
              int.tryParse(video["id"].toString()) == controller.currentVideoId;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      video["video_url"].replaceAll(".mp4", ".jpg"),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black12,
                        child: Image.network(
                          AppLink.logo, // ← هنا حط رابط الصورة بتاعتك
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.black12,
                            child: const Center(
                              child: Icon(Icons.video_file_rounded, size: 50),
                            ),
                          ),
                        ),

                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "الاسم: ${video["video_url"].split("/").last}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("التاريخ: ${video["created_at"]}"),
                  if (isCurrent)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        "✅ الفيديو المعروض حالياً",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoScreen(
                                videoUrl: video["video_url"],
                                cameFromGuest: false,
                              ),
                            ),
                          );

                        },
                        child: const Text("مشاهدة"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: isCurrent
                            ? null
                            : () async {
                          await controller.setCurrentVideo(
                              video["id"].toString());
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCurrent
                              ? Colors.grey.shade400
                              : Colors.green,
                        ),
                        child: Text(
                          isCurrent
                              ? "✅ الفيديو الحالي"
                              : "تعيين كالفيديو الحالي",
                          style: TextStyle(
                            color: isCurrent
                                ? Colors.black54
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

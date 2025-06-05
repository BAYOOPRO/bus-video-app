import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ms/screens/welcome_screen.dart';
import 'package:video_player/video_player.dart';
import '../controllers/video_screen_controller.dart';

class VideoScreen extends StatefulWidget {
  final String? videoUrl;
  final bool cameFromGuest;

  const VideoScreen({super.key, this.videoUrl, this.cameFromGuest = false});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoScreenController? _videoController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // ✅ نخلي الشاشة وضع أفقي
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _videoController = VideoScreenController();

    if (widget.videoUrl != null) {
      // ✅ لو جاي من SelectVideoScreen بفيديو معين
      _videoController!.initializeVideo(widget.videoUrl!).then((_) {
        setState(() => _isLoading = false);
      });
    } else {
      // ✅ لو جاي كجيست أو بدون رابط → نجيب الفيديو الحالي
      _videoController!.fetchAndCacheVideo(
            () => setState(() => _isLoading = false),
            () {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ فشل تحميل الفيديو")),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    // ✅ نرجع الشاشة للوضع الطبيعي (عمودي)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _videoController?.markBusStatus("offline");
    _videoController?.controller?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _handleBackNavigation() async {
    await _videoController?.markBusStatus("offline");
    _videoController?.controller?.pause();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (widget.cameFromGuest) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBackNavigation();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("عرض الفيديو"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackNavigation,
          ),
        ),
        body: Center(
          child: _isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: _videoController!.loadingStatus,
                builder: (context, value, _) => Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

            ],
          )
              : _videoController?.controller != null &&
              _videoController!.controller!.value.isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: _videoController!.controller!.value.size.width,
                height:
                _videoController!.controller!.value.size.height,
                child:
                VideoPlayer(_videoController!.controller!),
              ),
            ),
          )
              : const Text("⚠️ لا يوجد فيديو مفعل"),
        ),
      ),
    );
  }
}

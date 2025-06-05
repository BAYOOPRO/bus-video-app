import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:ms/screens/welcome_screen.dart';
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

  bool _showAppBar = false;
  Timer? _hideAppBarTimer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _videoController = VideoScreenController();

    if (widget.videoUrl != null) {
      _videoController!.initializeVideo(widget.videoUrl!).then((_) {
        if (!mounted) return;
        setState(() => _isLoading = false);
      });
    } else {
      _videoController!.fetchAndCacheVideo(
            () {
          if (!mounted) return;
          setState(() => _isLoading = false);
        },
            () {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ فشل تحميل الفيديو")),
          );
        },
      );
    }

    // أول ما يفتح الفيديو يختفي الـ AppBar
    _startAppBarHideTimer();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _hideAppBarTimer?.cancel();
    _videoController?.markBusStatus("offline");
    _videoController?.controller?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() => _showAppBar = !_showAppBar);
    if (_showAppBar) {
      _startAppBarHideTimer();
    }
  }

  void _startAppBarHideTimer() {
    _hideAppBarTimer?.cancel();
    _hideAppBarTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showAppBar = false);
    });
  }

  Future<void> _handleBackNavigation() async {
    await _videoController?.markBusStatus("offline");
    _videoController?.controller?.pause();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (!mounted) return;

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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: _showAppBar
            ? AppBar(
          title: const Text("عرض الفيديو"),
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackNavigation,
          ),
        )
            : null,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _toggleAppBar();
          },
          child: Center(
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
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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
                : const Text(
              "⚠️ لا يوجد فيديو مفعل",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

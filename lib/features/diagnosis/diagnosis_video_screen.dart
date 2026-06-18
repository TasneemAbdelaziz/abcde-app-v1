// [STATIC] screen — owner: Beginner 2.
//
// Plays a single local (bundled) diagnosis video with tap-to-pause and a
// scrub bar. Uses ONLY the video_player package — no chewie — to keep deps
// minimal. Push it with the DiagnosisVideo to play:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => DiagnosisVideoScreen(video: v)));
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../core/models/diagnosis.dart';
import '../../core/theme/app_theme.dart';

class DiagnosisVideoScreen extends StatefulWidget {
  final DiagnosisVideo video;
  const DiagnosisVideoScreen({super.key, required this.video});

  @override
  State<DiagnosisVideoScreen> createState() => _DiagnosisVideoScreenState();
}

class _DiagnosisVideoScreenState extends State<DiagnosisVideoScreen> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.video.assetPath)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      }).catchError((Object e) {
        if (!mounted) return;
        setState(() => _error = '$e');
      });
    // Rebuild on play/pause/position changes so the overlay stays in sync.
    _controller.addListener(_onTick);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playing = _controller.value.isPlaying;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.video.title,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: _error != null
            ? Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  'Could not play this video.\n\n${widget.video.assetPath}\n\n$_error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                ),
              )
            : !_ready
                ? const CircularProgressIndicator(color: Colors.white)
                : GestureDetector(
                    onTap: _togglePlay,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller),

                          // Play/pause overlay icon (fades when playing).
                          AnimatedOpacity(
                            opacity: playing ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width: 64.r,
                              height: 64.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                              child: Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 38.sp,
                              ),
                            ),
                          ),

                          // Scrub bar pinned to the bottom.
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              colors: const VideoProgressColors(
                                playedColor: AppColors.blueLight,
                                bufferedColor: Colors.white24,
                                backgroundColor: Colors.white12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
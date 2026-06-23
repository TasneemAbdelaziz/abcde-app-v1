// [STATIC] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';

/// In-room entertainment (TV, music, games).
class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  int _selectedTab = 0;

  final List<LocalVideo> _videos = const [
    LocalVideo(
      title: 'Understanding Coronary Catheterization',
      subtitle: 'What was done and why',
      titleKey: 'ent_v1_title',
      subKey: 'ent_v1_sub',
      duration: '3:24',
      assetPath: 'assets/videos/understanding_your_case.mp4',
      background: LinearGradient(
        colors: [Color(0xFF0D427D), Color(0xFF1C7BDD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: '❤️',
    ),
    LocalVideo(
      title: 'Your Surgery Explained',
      subtitle: 'What to expect in the procedure',
      titleKey: 'ent_v2_title',
      subKey: 'ent_v2_sub',
      duration: '4:02',
      assetPath: 'assets/videos/your_surgery_explained.mp4',
      background: LinearGradient(
        colors: [Color(0xFF4A1C73), Color(0xFF8115B6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: '💊',
    ),
    LocalVideo(
      title: 'Financials & Insurance',
      subtitle: 'How billing works and what to ask about',
      titleKey: 'ent_v3_title',
      subKey: 'ent_v3_sub',
      duration: '5:10',
      assetPath: 'assets/videos/Financial.mp4',
      background: LinearGradient(
        colors: [Color(0xFF1F6F20), Color(0xFF3AAA3D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: '💰',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandBar(title: context.watch<LocaleController>().t('title_entertainment')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(),
            SizedBox(height: 20.h),
            Expanded(
              child: _selectedTab == 0
                  ? _buildLearnContent()
                  : _buildRelaxContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnContent() {
    return ListView.separated(
      itemCount: _videos.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return _buildVideoCard(context, _videos[index]);
      },
    );
  }

  Widget _buildRelaxContent() {
    final loc = context.watch<LocaleController>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('games'),
            style: TextStyle(
              color: AppColors.text,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _buildGameCard(
                  loc.t('game_puzzle'), Icons.extension_rounded, AppColors.teal),
              _buildGameCard(
                  loc.t('game_memory'), Icons.memory_rounded, AppColors.blue),
              _buildGameCard(
                loc.t('game_breathing'),
                Icons.self_improvement_rounded,
                AppColors.amber,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            loc.t('music'),
            style: TextStyle(
              color: AppColors.text,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 12.h),
          _buildMusicTile(loc.t('music_calm'), '4:20', isPlaying: false),
          _buildMusicTile(loc.t('music_ocean'), '6:00', isPlaying: true),
          _buildMusicTile(loc.t('music_piano'), '5:15', isPlaying: false),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildGameCard(String title, IconData icon, Color iconColor) {
    return SizedBox(
      width: 164.w,
      height: 112.h,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        elevation: 0,
        color: AppColors.bgCard,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.2),
                      iconColor.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 26.sp),
                ),
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusicTile(
    String title,
    String duration, {
    bool isPlaying = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isPlaying ? AppColors.bluePale2 : AppColors.bgCard,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isPlaying ? AppColors.blueLight : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.music_note_rounded,
            color: isPlaying ? AppColors.blue : AppColors.textMuted,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isPlaying)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      context.read<LocaleController>().t('playing'),
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isPlaying)
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(Icons.stop_rounded, color: Colors.white, size: 16.sp),
            )
          else
            Text(
              duration,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        _buildTab(context.read<LocaleController>().t('tab_learn'), 0),
        _buildTab(context.read<LocaleController>().t('tab_relax'), 1),
      ]),
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = _selectedTab == index;
    final icon = index == 0
        ? Icons.menu_book_rounded
        : Icons.music_note_rounded;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.blue : AppColors.bgCard,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, LocalVideo video) {
    final loc = context.watch<LocaleController>();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EntertainmentVideoScreen(video: video),
          ),
        );
      },
      child: Container(
        height: 132.h,
        decoration: BoxDecoration(
          gradient: video.background,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 16.w,
              top: 16.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  video.duration,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.icon, style: TextStyle(fontSize: 28.sp)),
                  const Spacer(),
                  Text(
                    video.titleKey.isEmpty ? video.title : loc.t(video.titleKey),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    video.subKey.isEmpty ? video.subtitle : loc.t(video.subKey),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocalVideo {
  final String title;
  final String subtitle;
  final String duration;
  final String assetPath;
  final LinearGradient background;
  final String icon;
  final String titleKey;
  final String subKey;

  const LocalVideo({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.assetPath,
    required this.background,
    required this.icon,
    this.titleKey = '',
    this.subKey = '',
  });
}

class EntertainmentVideoScreen extends StatefulWidget {
  final LocalVideo video;

  const EntertainmentVideoScreen({super.key, required this.video});

  @override
  State<EntertainmentVideoScreen> createState() =>
      _EntertainmentVideoScreenState();
}

class _EntertainmentVideoScreenState extends State<EntertainmentVideoScreen> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.video.assetPath)
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() => _ready = true);
            _controller.play();
          })
          .catchError((error) {
            if (!mounted) return;
            setState(() => _error = '$error');
          });
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
    final loc = context.watch<LocaleController>();
    final title = widget.video.titleKey.isEmpty
        ? widget.video.title
        : loc.t(widget.video.titleKey);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(title),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  '${loc.t('video_load_error')}\n${widget.video.assetPath}\n\n$_error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
                ),
              ),
            )
          : !_ready
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: _togglePlay,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: playing ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

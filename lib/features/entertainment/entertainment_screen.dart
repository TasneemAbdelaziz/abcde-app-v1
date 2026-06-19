// [STATIC] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/models/entertainment_video.dart';
import '../../core/repositories/patient_api_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';

/// Learn & Relax videos.
class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

enum _EntertainmentTab { learn, relax }

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  late Future<List<EntertainmentVideo>> _videosFuture;
  _EntertainmentTab _activeTab = _EntertainmentTab.learn;
  String _playingMusicId = 'calm-healing-tones';

  static final List<EntertainmentVideo> _placeholderVideos = [
    EntertainmentVideo(
      id: 'learn-1',
      title: 'Understanding Coronary Catheterization',
      description: 'What was done and why',
      duration: '3:24',
      category: 'learn',
      icon: 'heart',
    ),
    EntertainmentVideo(
      id: 'learn-2',
      title: 'Life After a Cardiac Event',
      description: 'Recovery, habits, and warning signs',
      duration: '5:10',
      category: 'learn',
      icon: 'run',
    ),
    EntertainmentVideo(
      id: 'learn-3',
      title: 'Taking Your Medication Safely',
      description: 'Doses, timing, and what to avoid',
      duration: '4:02',
      category: 'learn',
      icon: 'pill',
    ),
  ];

  static final List<_RelaxGame> _relaxGames = [
    _RelaxGame(title: 'Puzzle', icon: Icons.extension),
    _RelaxGame(title: 'Memory', icon: Icons.memory),
    _RelaxGame(title: 'Breathing', icon: Icons.self_improvement),
  ];

  static final List<_RelaxMusic> _relaxMusic = [
    _RelaxMusic(
      id: 'calm-healing-tones',
      title: 'Calm Healing Tones',
      duration: '4:20',
    ),
    _RelaxMusic(id: 'ocean-waves', title: 'Ocean Waves', duration: '6:00'),
    _RelaxMusic(id: 'soft-piano', title: 'Soft Piano', duration: '5:15'),
  ];

  @override
  void initState() {
    super.initState();
    _videosFuture = _loadVideos();
  }

  Future<List<EntertainmentVideo>> _loadVideos() async {
    final api = context.read<PatientApiRepository>();
    // TODO: replace this stub with the real backend endpoint.
    return api.getEntertainmentVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Learn & Relax'),
      backgroundColor: AppColors.bgSoft,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          children: [
            _TabHeader(
              active: _activeTab,
              onTabSelected: (tab) => setState(() => _activeTab = tab),
            ),
            SizedBox(height: 18.h),
            if (_activeTab == _EntertainmentTab.learn)
              _buildLearnView()
            else
              _buildRelaxView(),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnView() {
    return FutureBuilder<List<EntertainmentVideo>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final videos = snapshot.data?.isNotEmpty == true
            ? snapshot.data!
            : _placeholderVideos;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: videos.map((video) => _VideoCard(video: video)).toList(),
        );
      },
    );
  }

  Widget _buildRelaxView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GAMES',
          style: TextStyle(
            color: AppColors.blueDeep,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: _relaxGames
              .map((game) => _RelaxGameCard(game: game))
              .toList(),
        ),
        SizedBox(height: 24.h),
        Text(
          'MUSIC',
          style: TextStyle(
            color: AppColors.blueDeep,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12.h),
        ..._relaxMusic.map(
          (track) => _RelaxMusicRow(
            track: track,
            isPlaying: track.id == _playingMusicId,
            onTap: () => setState(() => _playingMusicId = track.id),
          ),
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _videosFuture = _loadVideos();
    });
    await _videosFuture;
  }
}

class _TabHeader extends StatelessWidget {
  final _EntertainmentTab active;
  final ValueChanged<_EntertainmentTab> onTabSelected;

  const _TabHeader({required this.active, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Learn',
            active: active == _EntertainmentTab.learn,
            onTap: () => onTabSelected(_EntertainmentTab.learn),
          ),
          SizedBox(width: 8.w),
          _TabButton(
            label: 'Relax',
            active: active == _EntertainmentTab.relax,
            onTap: () => onTabSelected(_EntertainmentTab.relax),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42.h,
          decoration: BoxDecoration(
            color: active ? AppColors.blue : AppColors.bgSoft,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: active ? AppColors.blue : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final EntertainmentVideo video;

  const _VideoCard({required this.video});

  Color get _startColor {
    switch (video.category.toLowerCase()) {
      case 'relax':
        return const Color(0xFF2D6A4F);
      case 'med':
      case 'medicine':
        return const Color(0xFF5E239D);
      default:
        return AppColors.blueDeep;
    }
  }

  Color get _endColor {
    switch (video.category.toLowerCase()) {
      case 'relax':
        return const Color(0xFF2B7A0B);
      case 'med':
      case 'medicine':
        return const Color(0xFF4A148C);
      default:
        return AppColors.blueLight;
    }
  }

  IconData get _heroIcon {
    switch (video.icon.toLowerCase()) {
      case 'heart':
        return Icons.favorite;
      case 'run':
      case 'runner':
        return Icons.directions_run;
      case 'pill':
      case 'medicine':
        return Icons.medication;
      default:
        return Icons.play_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_endColor, _startColor],
              ),
            ),
            child: Center(
              child: Icon(
                _heroIcon,
                color: Colors.white.withOpacity(0.88),
                size: 52.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  video.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    _InfoChip(label: video.category.toUpperCase()),
                    SizedBox(width: 8.w),
                    _InfoChip(label: video.duration),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: implement video playback.
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 10.h,
                        ),
                      ),
                      child: Text('Play', style: TextStyle(fontSize: 13.sp)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.bluePale,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.blueDeep,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RelaxGameCard extends StatelessWidget {
  final _RelaxGame game;

  const _RelaxGameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64.w) / 2,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: AppTheme.shadow,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.bluePale,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(game.icon, color: AppColors.blueDeep, size: 28.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              game.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelaxMusicRow extends StatelessWidget {
  final _RelaxMusic track;
  final bool isPlaying;
  final VoidCallback onTap;

  const _RelaxMusicRow({
    required this.track,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isPlaying ? AppColors.bluePale2 : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.music_note, color: AppColors.blueDeep, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (isPlaying)
                    Text(
                      'Playing',
                      style: TextStyle(color: AppColors.blue, fontSize: 12.sp),
                    ),
                ],
              ),
            ),
            Text(
              track.duration,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
            ),
            SizedBox(width: 12.w),
            Icon(
              isPlaying ? Icons.stop_circle : Icons.play_circle,
              color: AppColors.blueDeep,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _RelaxGame {
  final String title;
  final IconData icon;

  const _RelaxGame({required this.title, required this.icon});
}

class _RelaxMusic {
  final String id;
  final String title;
  final String duration;

  const _RelaxMusic({
    required this.id,
    required this.title,
    required this.duration,
  });
}

class _EmptyHint extends StatelessWidget {
  final String message;

  const _EmptyHint(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

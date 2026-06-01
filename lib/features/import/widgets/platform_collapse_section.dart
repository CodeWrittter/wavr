import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class PlatformCollapseSection extends StatefulWidget {
  const PlatformCollapseSection({super.key});

  @override
  State<PlatformCollapseSection> createState() =>
      _PlatformCollapseSectionState();
}

class _PlatformCollapseSectionState extends State<PlatformCollapseSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _expandAnim;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:  0.07)),
      ),
      child: Column(
        children: [
          // header row
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width:  32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.theme.withValues(alpha:  0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: AppColors.theme,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Supported Links',
                          style: TextStyle(
                            fontFamily: AppFonts.outfit,
                            fontSize:   14,
                            fontWeight: FontWeight.w700,
                            color:      Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '9 sources available',
                          style: TextStyle(
                            fontFamily: AppFonts.jetbrainsMono,
                            fontSize:   11,
                            color: Colors.white.withValues(alpha:  0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns:    _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withValues(alpha:  0.4),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // expandable list
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha:  0.06),
                ),
                const SizedBox(height: 4),
                ..._platforms.map((p) => _PlatformRow(platform: p)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Platform row ───────────────────────────────────────────────────────────

class _PlatformRow extends StatelessWidget {
  final _PlatformData platform;
  const _PlatformRow({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            width:  36,
            height: 36,
            decoration: BoxDecoration(
              color:        platform.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                platform.assetPath,
                width:  36,
                height: 36,
                fit:    BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  platform.fallback,
                  color: Colors.white.withValues(alpha:  0.5),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform.name,
                  style: const TextStyle(
                    fontFamily: AppFonts.outfit,
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color:      Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  platform.hint,
                  style: TextStyle(
                    fontFamily: AppFonts.jetbrainsMono,
                    fontSize:   10,
                    color: Colors.white.withValues(alpha:  0.35),
                  ),
                ),
              ],
            ),
          ),
          if (platform.isNew)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.theme.withValues(alpha:  0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.theme.withValues(alpha:  0.25),
                ),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize:   9,
                  fontWeight: FontWeight.w800,
                  color:      AppColors.theme,
                  letterSpacing: 0.08,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Platform data ──────────────────────────────────────────────────────────

class _PlatformData {
  final String    name;
  final String    hint;
  final String    assetPath;
  final Color     bgColor;
  final IconData  fallback;
  final bool      isNew;

  const _PlatformData({
    required this.name,
    required this.hint,
    required this.assetPath,
    required this.bgColor,
    required this.fallback,
    this.isNew = false,
  });
}

const _platforms = [
  _PlatformData(
    name:      'Spotify',
    hint:      'playlist · album',
    assetPath: 'assets/images/spotify.png',
    bgColor:   AppColors.srcSpotifyBg,
    fallback:  Icons.queue_music_rounded,
  ),
  _PlatformData(
    name:      'Apple Music',
    hint:      'playlist · album',
    assetPath: 'assets/images/apple_music.png',
    bgColor:   AppColors.srcAppleBg,
    fallback:  Icons.music_note_rounded,
  ),
  _PlatformData(
    name:      'Deezer',
    hint:      'playlist · album',
    assetPath: 'assets/images/deezer.png',
    bgColor:   AppColors.srcDeezerBg,
    fallback:  Icons.library_music_rounded,
  ),
  _PlatformData(
    name:      'YouTube Music',
    hint:      'playlist · album',
    assetPath: 'assets/images/youtube.png',
    bgColor:   AppColors.srcAppleBg,
    fallback:  Icons.play_circle_outline_rounded,
  ),
  _PlatformData(
    name:      'SoundCloud',
    hint:      'playlist · public tracks',
    assetPath: 'assets/images/soundcloud.png',
    bgColor:   AppColors.srcSoundcloudBg,
    fallback:  Icons.cloud_rounded,
  ),
  _PlatformData(
    name:      'Audius',
    hint:      'playlist · album',
    assetPath: 'assets/images/audius.png',
    bgColor:   AppColors.srcDeezerBg,
    fallback:  Icons.graphic_eq_rounded,
  ),
  _PlatformData(
    name:      'Jamendo',
    hint:      'CC-licensed · free',
    assetPath: 'assets/images/jamendo.png',
    bgColor:   AppColors.srcJamendoBg,
    fallback:  Icons.eco_rounded,
  ),
  _PlatformData(
    name:      'Local Files',
    hint:      'device storage',
    assetPath: 'assets/images/local.png',
    bgColor:   AppColors.srcLocalBg,
    fallback:  Icons.folder_rounded,
  ),
  _PlatformData(
    name:      'Wavr Share',
    hint:      'shared by another user',
    assetPath: 'assets/images/wavr_share.png',
    bgColor:   AppColors.srcWavrBg,
    fallback:  Icons.bolt_rounded,
    isNew:     true,
  ),
];

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/playlist.dart';
import '../../../data/models/album.dart';
import '../../../data/models/track.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

// ── Source logo widget ─────────────────────────────────────────────────────

class SourceLogo extends StatelessWidget {
  final TrackSource source;
  final double      size;

  const SourceLogo({super.key, required this.source, this.size = 52});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _bgColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          _assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            _fallbackIcon,
            color: Colors.white.withOpacity(0.5),
            size: size * 0.45,
          ),
        ),
      ),
    );
  }

  String get _assetPath => switch (source) {
        TrackSource.spotify    => 'assets/images/spotify.png',
        TrackSource.appleMusic => 'assets/images/apple_music.png',
        TrackSource.deezer     => 'assets/images/deezer.png',
        TrackSource.ytMusic    => 'assets/images/youtube.png',
        TrackSource.soundcloud => 'assets/images/soundcloud.png',
        TrackSource.audius     => 'assets/images/audius.png',
        TrackSource.jamendo    => 'assets/images/jamendo.png',
        TrackSource.wavrShare  => 'assets/images/wavr_share.png',
        TrackSource.manual     => 'assets/images/manual.png',
        TrackSource.local      => 'assets/images/local.png',
      };

  Color get _bgColor => switch (source) {
        TrackSource.spotify    => AppColors.srcSpotifyBg,
        TrackSource.appleMusic => AppColors.srcAppleBg,
        TrackSource.deezer     => AppColors.srcDeezerBg,
        TrackSource.ytMusic    => AppColors.srcAppleBg,
        TrackSource.soundcloud => AppColors.srcSoundcloudBg,
        TrackSource.audius     => AppColors.srcDeezerBg,
        TrackSource.jamendo    => AppColors.srcJamendoBg,
        TrackSource.wavrShare  => AppColors.srcWavrBg,
        TrackSource.manual     => AppColors.srcSoundcloudBg,
        TrackSource.local      => AppColors.srcLocalBg,
      };

  IconData get _fallbackIcon => switch (source) {
        TrackSource.spotify    => Icons.queue_music_rounded,
        TrackSource.appleMusic => Icons.apple_rounded,
        TrackSource.deezer     => Icons.music_note_rounded,
        _                      => Icons.library_music_rounded,
      };
}

// ── Playlist list item ─────────────────────────────────────────────────────

class PlaylistListItem extends StatelessWidget {
  final Playlist     playlist;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const PlaylistListItem({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            SourceLogo(source: playlist.source),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${playlist.totalTracks ?? 0} tracks',
                    style: TextStyle(
                      fontFamily: AppFonts.jetbrainsMono,
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            // download badge
            if (playlist.isFullyDownloaded)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: AppColors.theme3,
                  shape: BoxShape.circle,
                ),
              ),
            GestureDetector(
              onTap: onMoreTap,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Album list item ────────────────────────────────────────────────────────

class AlbumListItem extends StatelessWidget {
  final Album        album;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const AlbumListItem({
    super.key,
    required this.album,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // artwork
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.surfaceElevated,
              ),
              child: album.artworkLocalPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        album.artworkLocalPath!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.album_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 26,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: const TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${album.artist} · ${album.totalTracks ?? 0} tracks',
                    style: TextStyle(
                      fontFamily: AppFonts.jetbrainsMono,
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.45),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (album.isFullyDownloaded)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: AppColors.theme3,
                  shape: BoxShape.circle,
                ),
              ),
            GestureDetector(
              onTap: onMoreTap,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

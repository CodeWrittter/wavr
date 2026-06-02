import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/playlist.dart';
import '../../data/models/track.dart';
import '../player/providers/player_provider.dart';
import '../player/widgets/mini_player.dart';
import 'providers/library_provider.dart';
import 'widgets/library_filter_chips.dart';
import 'widgets/pinned_all_songs_card.dart';
import 'widgets/playlist_list_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../player/widgets/mini_player.dart';


class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter      = ref.watch(libraryFilterProvider);
    final allTracks   = ref.watch(allTracksProvider);
    final favTracks   = ref.watch(favoritesProvider);
    final playlists   = ref.watch(allPlaylistsProvider);

    return Column(
      children: [
        // header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
          child: Row(
            children: [
              const Text(
                'Library',
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showCreatePlaylistModal(context, ref),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha:  0.07),
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white.withValues(alpha:  0.7),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // filter chips
        const LibraryFilterChips(),
        const SizedBox(height: 16),

        // content
        Expanded(
          child: _buildContent(context, ref, filter, allTracks, favTracks, playlists),
        ),

        // mini player — visible on library
        const MiniPlayer(),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    LibraryFilter filter,
    AsyncValue<List<Track>> allTracks,
    AsyncValue<List<Track>> favTracks,
    AsyncValue<List<Playlist>> playlists,
  ) {
    return switch (filter) {
      LibraryFilter.all      => _AllTab(
          allTracks: allTracks,
          favTracks: favTracks,
          playlists: playlists,
        ),
      LibraryFilter.playlists => _PlaylistsTab(playlists: playlists),
      LibraryFilter.albums    => const _AlbumsTab(),
      LibraryFilter.artists   => const _ArtistsTab(),
      LibraryFilter.local     => _LocalTab(allTracks: allTracks),
    };
  }

  // ── Create playlist modal ────────────────────────────────────────────────

  void _showCreatePlaylistModal(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context:            context,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      useSafeArea:        true,
      builder: (ctx) => AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve:    Curves.easeOut,
        padding:  EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('New Playlist',
                style: TextStyle(
                  fontFamily: AppFonts.outfit, fontSize: 18,
                  fontWeight: FontWeight.w800, color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161624),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.07)),
                ),
                child: TextField(
                  controller: ctrl,
                  autofocus:  true,
                  style: const TextStyle(
                    fontFamily: AppFonts.outfit,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Playlist name…',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontFamily: AppFonts.outfit,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;
                  await _createPlaylist(context, ref, name);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FF5A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('Create Playlist',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.outfit, fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPlaylist(
      BuildContext context, WidgetRef ref, String name) async {
    final repo = ref.read(libraryRepositoryProvider);
    final playlist = Playlist(
      id:        const Uuid().v4(),
      name:      name,
      type:      PlaylistType.manual,
      source:    TrackSource.manual,
      createdAt: DateTime.now(),
    );
    await repo.savePlaylist(playlist);
    ref.invalidate(allPlaylistsProvider);
  }
}

// ── ALL tab ────────────────────────────────────────────────────────────────

class _AllTab extends ConsumerWidget {
  final AsyncValue<List<Track>>    allTracks;
  final AsyncValue<List<Track>>    favTracks;
  final AsyncValue<List<Playlist>> playlists;

  const _AllTab({
    required this.allTracks,
    required this.favTracks,
    required this.playlists,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // pinned — All Songs
        allTracks.when(
          data: (t) => PinnedCard(
            type:       PinnedCardType.allSongs,
            trackCount: t.length,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => _TrackListScreen(
                title: 'All Songs',
                tracksFuture: ref.read(libraryRepositoryProvider).getAllTracks(),
              ),
            )),
          ),
          loading: () => const SizedBox(height: 86),
          error:   (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 10),
        // pinned — Favorites
        favTracks.when(
          data: (t) => PinnedCard(
            type:       PinnedCardType.favorites,
            trackCount: t.length,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => _TrackListScreen(
                title: 'Favorite Songs',
                tracksFuture: ref.read(libraryRepositoryProvider).getFavorites(),
              ),
            )),
          ),
          loading: () => const SizedBox(height: 86),
          error:   (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),

        // playlists section
        playlists.when(
          data: (list) {
            if (list.isEmpty) return const SizedBox.shrink();
            final sorted = [...list]
              ..sort((a, b) => a.name.compareTo(b.name));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'PLAYLISTS',
                  onSort: () {},
                ),
                ...sorted.map((p) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PlaylistListItem(
                        playlist: p,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => _TrackListScreen(
                            title: 'Favorite Songs',
                            tracksFuture: ref.read(libraryRepositoryProvider).getFavorites(),
                          ),
                        )),
                        onMoreTap: () =>
                            _showPlaylistMenu(context, ref, p),
                      ),
                    )),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error:   (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showPlaylistMenu(
      BuildContext context, WidgetRef ref, Playlist p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlaylistContextMenu(playlist: p),
    );
  }
}

// ── PLAYLISTS tab ──────────────────────────────────────────────────────────

class _PlaylistsTab extends ConsumerWidget {
  final AsyncValue<List<Playlist>> playlists;
  const _PlaylistsTab({required this.playlists});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return playlists.when(
      data: (list) {
        final sorted = [...list]
          ..sort((a, b) => a.name.compareTo(b.name));
        return Column(
          children: [
            _SortBar(
              onSort: (order) {},
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sorted.length,
                itemBuilder: (_, i) => PlaylistListItem(
                  playlist:  sorted[i],
                  onTap:     () {},
                  onMoreTap: () =>
                      _showPlaylistMenu(context, ref, sorted[i]),
                ),
              ),
            ),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  void _showPlaylistMenu(
      BuildContext context, WidgetRef ref, Playlist p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlaylistContextMenu(playlist: p),
    );
  }
}

// ── ALBUMS tab ─────────────────────────────────────────────────────────────

class _AlbumsTab extends ConsumerWidget {
  const _AlbumsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: wire allAlbumsProvider when album import is implemented
    return Center(
      child: Text(
        'No albums yet',
        style: TextStyle(
          fontFamily: AppFonts.outfit,
          color: Colors.white.withValues(alpha:  0.3),
        ),
      ),
    );
  }
}

// ── ARTISTS tab ────────────────────────────────────────────────────────────

class _ArtistsTab extends ConsumerWidget {
  const _ArtistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTracks = ref.watch(allTracksProvider);
    return allTracks.when(
      data: (tracks) {
        // group by artist
        final artistMap = <String, int>{};
        for (final t in tracks) {
          artistMap[t.artist] = (artistMap[t.artist] ?? 0) + 1;
        }
        final sorted = artistMap.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final entry = sorted[i];
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white.withValues(alpha:  0.3),
                  size: 22,
                ),
              ),
              title: Text(
                entry.key,
                style: const TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                '${entry.value} tracks',
                style: TextStyle(
                  fontFamily: AppFonts.jetbrainsMono,
                  fontSize: 11,
                  color: Colors.white.withValues(alpha:  0.4),
                ),
              ),
            );
          },
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── LOCAL tab ──────────────────────────────────────────────────────────────

class _LocalTab extends ConsumerWidget {
  final AsyncValue<List<Track>> allTracks;
  const _LocalTab({required this.allTracks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return allTracks.when(
      data: (tracks) {
        final local = tracks
            .where((t) => t.localFilePath != null)
            .toList()
          ..sort((a, b) => a.title.compareTo(b.title));

        if (local.isEmpty) {
          return Center(
            child: Text(
              'No local files yet',
              style: TextStyle(
                fontFamily: AppFonts.outfit,
                color: Colors.white.withValues(alpha:  0.3),
              ),
            ),
          );
        }

        return Column(
          children: [
            _SortBar(onSort: (_) {}),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: local.length,
                itemBuilder: (_, i) =>
                    _TrackTile(track: local[i]),
              ),
            ),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── Track tile (used in Local + All Songs) ─────────────────────────────────

class _TrackTile extends StatelessWidget {
  final Track track;
  const _TrackTile({required this.track});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Stack(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: track.artworkLocalPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      track.artworkLocalPath!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.music_note_rounded,
                    color: Colors.white.withValues(alpha:  0.3),
                    size: 20,
                  ),
          ),
          // green downloaded badge
          if (track.downloadStatus == DownloadStatus.done)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.theme3,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 9,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        track.title,
        style: const TextStyle(
          fontFamily: AppFonts.outfit,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist,
        style: TextStyle(
          fontFamily: AppFonts.jetbrainsMono,
          fontSize: 11,
          color: Colors.white.withValues(alpha:  0.4),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.more_vert_rounded,
        color: Colors.white.withValues(alpha:  0.3),
        size: 18,
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String       title;
  final VoidCallback onSort;
  const _SectionHeader({required this.title, required this.onSort});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.12,
              color: Colors.white.withValues(alpha:  0.35),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSort,
            child: Row(
              children: [
                Icon(
                  Icons.sort_rounded,
                  color: Colors.white.withValues(alpha:  0.3),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'A–Z',
                  style: TextStyle(
                    fontFamily: AppFonts.jetbrainsMono,
                    fontSize: 10,
                    color: Colors.white.withValues(alpha:  0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sort bar ───────────────────────────────────────────────────────────────

enum SortOrder { nameAZ, nameZA, recentFirst, oldestFirst }

class _SortBar extends StatefulWidget {
  final void Function(SortOrder) onSort;
  const _SortBar({required this.onSort});

  @override
  State<_SortBar> createState() => _SortBarState();
}

class _SortBarState extends State<_SortBar> {
  SortOrder _order = SortOrder.nameAZ;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Row(
        children: [
          Text(
            _label(_order),
            style: TextStyle(
              fontFamily: AppFonts.jetbrainsMono,
              fontSize: 11,
              color: Colors.white.withValues(alpha:  0.35),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _cycle,
            child: Icon(
              Icons.swap_vert_rounded,
              color: Colors.white.withValues(alpha:  0.35),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _cycle() {
    final next = SortOrder.values[
        (_order.index + 1) % SortOrder.values.length];
    setState(() => _order = next);
    widget.onSort(next);
  }

  String _label(SortOrder o) => switch (o) {
        SortOrder.nameAZ      => 'A – Z',
        SortOrder.nameZA      => 'Z – A',
        SortOrder.recentFirst => 'Recent first',
        SortOrder.oldestFirst => 'Oldest first',
      };
}

// ── Playlist context menu ──────────────────────────────────────────────────

class _PlaylistContextMenu extends ConsumerWidget {
  final Playlist playlist;
  const _PlaylistContextMenu({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:  0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // playlist info header
          Row(
            children: [
              SourceLogo(source: playlist.source, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        fontFamily: AppFonts.outfit,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${playlist.totalTracks ?? 0} tracks',
                      style: TextStyle(
                        fontFamily: AppFonts.jetbrainsMono,
                        fontSize: 11,
                        color: Colors.white.withValues(alpha:  0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MenuItem(
            icon: Icons.download_rounded,
            label: 'Download whole playlist',
            accent: true,
            onTap: () {
              Navigator.pop(context);
              // TODO: trigger downloadPlaylist
            },
          ),
          _MenuItem(
            icon: Icons.play_circle_outline_rounded,
            label: 'Play',
            onTap: () => Navigator.pop(context),
          ),
          _MenuItem(
            icon: Icons.shuffle_rounded,
            label: 'Shuffle play',
            onTap: () => Navigator.pop(context),
          ),
          _MenuItem(
            icon: Icons.edit_rounded,
            label: 'Rename',
            onTap: () => Navigator.pop(context),
          ),
          _MenuItem(
            icon: Icons.share_rounded,
            label: 'Share via Wavr',
            onTap: () => Navigator.pop(context),
          ),
          _MenuItem(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            color: AppColors.error,
            onTap: () {
              ref.read(playlistRepositoryProvider).delete(playlist.id);
              ref.invalidate(allPlaylistsProvider);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color?   color;
  final bool     accent;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ??
        (accent
            ? AppColors.theme
            : Colors.white.withValues(alpha:  0.75));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.outfit,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackListScreen extends ConsumerWidget {
  final String title;
  final Future<List<Track>> tracksFuture;

  const _TrackListScreen({
    required this.title,
    required this.tracksFuture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        title: Text(title,
          style: const TextStyle(
            fontFamily: AppFonts.outfit,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Track>>(
            future: tracksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(
                    color: Color(0xFFE8FF5A),
                  ));
                }
                final tracks = snapshot.data ?? [];
                if (tracks.isEmpty) {
                  return Center(
                    child: Text('No tracks yet',
                      style: TextStyle(
                        fontFamily: AppFonts.outfit,
                        color: Colors.white.withValues(alpha:  0.3),
                      )),
                  );
                }
                return ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (_, i) {
                    final track = tracks[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Stack(
                        children: [
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E2E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.music_note_rounded,
                              color: Colors.white.withValues(alpha:  0.3), size: 20),
                          ),
                          if (track.downloadStatus == DownloadStatus.done)
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 14, height: 14,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 9),
                              ),
                            ),
                        ],
                      ),
                      title: Text(track.title,
                        style: const TextStyle(
                          fontFamily: AppFonts.outfit, fontSize: 13,
                          fontWeight: FontWeight.w600, color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(track.artist,
                        style: TextStyle(
                          fontFamily: AppFonts.jetbrainsMono, fontSize: 11,
                          color: Colors.white.withValues(alpha:  0.4),
                        ),
                      ),
                      onTap: () => ref.read(playerProvider.notifier)
                          .play(track, queue: tracks),
                      trailing: Icon(Icons.more_vert_rounded,
                        color: Colors.white.withValues(alpha:  0.3), size: 18),
                    );
                  },
                );
              },
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/import_provider.dart';
import 'widgets/platform_collapse_section.dart';
// import 'widgets/txt_file_drop.dart';
import 'widgets/manual_input_sheet.dart';
import '../../services/playlist_decoder/models/decoded_track.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import '../../data/models/track.dart';

// ── Tab enum ───────────────────────────────────────────────────────────────
enum _ImportTab { link, file, manual }

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  _ImportTab _tab = _ImportTab.link;

  // link tab
  final _urlCtrl = TextEditingController();

  // file tab
  String? _fileTxtContent;
  String? _fileName;
  // final _fileDropKey = GlobalKey<TxtFileDropState>();

  // manual tab
  final _manualKey = GlobalKey<ManualInputSheetState>();

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width:  38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Import A Playlist',
                    style: TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize:   20,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _TabBtn(
                      label:    '🔗 Link',
                      active:   _tab == _ImportTab.link,
                      onTap: () => setState(() => _tab = _ImportTab.link),
                    ),
                    _TabBtn(
                      label:    '📄 File',
                      active:   _tab == _ImportTab.file,
                      onTap: () => setState(() => _tab = _ImportTab.file),
                    ),
                    _TabBtn(
                      label:    '✏️ Manual',
                      active:   _tab == _ImportTab.manual,
                      onTap: () =>
                          setState(() => _tab = _ImportTab.manual),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // tab content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: switch (_tab) {
                  _ImportTab.link   => _LinkTab(urlCtrl: _urlCtrl),
                  _ImportTab.file   => _LinkTab(urlCtrl: _urlCtrl),
                  // _ImportTab.file   => _FileTab(
                      // fileDropKey: _fileDropKey,
                      // onFilePicked: (content, name) {
                      //   setState(() {
                      //     _fileTxtContent = content;
                      //     _fileName       = name;
                      //   });
                      // },
                    // ),
                  _ImportTab.manual => ManualInputSheet(
                      key:      _manualKey,
                      onImport: _onManualImport,
                    ),
                },
              ),
            ),

            // action button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: _ActionButton(
                tab: _tab,
                onPressed: _onActionPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _onActionPressed() {
    switch (_tab) {
      case _ImportTab.link:
        final url = _urlCtrl.text.trim();
        if (url.isEmpty) return;
        _showProgressModal(
          title: 'Fetching Playlist',
          onStart: () =>
              ref.read(importProvider.notifier).importFromUrl(url),
        );
      case _ImportTab.file:
        if (_fileTxtContent == null) {
          // _fileDropKey.currentState?.pick();
          return;
        }
        _showProgressModal(
          title: 'Importing File',
          onStart: () => ref
              .read(importProvider.notifier)
              .importFromManualList(
                  _parseTxt(_fileTxtContent!)),
        );
      case _ImportTab.manual:
        _manualKey.currentState?.submit();
    }
  }

  void _onManualImport(List<DecodedTrack> tracks) {
    _showProgressModal(
      title: 'Importing List',
      onStart: () => ref
          .read(importProvider.notifier)
          .importFromManualList(tracks),
    );
  }

  List<DecodedTrack> _parseTxt(String content) {
    // reuse the same logic as ManualInputSheet
    final lines =
        content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.map((line) {
      final sep = line.contains(' — ')
          ? ' — '
          : line.contains(' - ')
              ? ' - '
              : null;
      if (sep == null) {
        return DecodedTrack(
          title:  line.trim(),
          artist: 'Unknown',
          source: TrackSource.manual,
        );
      }
      final parts = line.split(sep);
      return DecodedTrack(
        artist: parts.first.trim(),
        title:  parts.sublist(1).join(sep).trim(),
        source: TrackSource.manual,
      );
    }).toList();
  }

  // ── Progress modal ────────────────────────────────────────────────────────

  void _showProgressModal({
    required String    title,
    required Future<void> Function() onStart,
  }) {
    showModalBottomSheet(
      context:            context,
      isDismissible:      false,
      enableDrag:         false,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ImportProgressModal(
        title:   title,
        onStart: onStart,
        onDone: () {
          Navigator.of(context).pop(); // close modal
          Navigator.of(context).pop(); // go back to settings
        },
      ),
    );
    onStart();
  }
}

// ── Link tab ───────────────────────────────────────────────────────────────

class _LinkTab extends StatelessWidget {
  final TextEditingController urlCtrl;
  const _LinkTab({required this.urlCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // URL input
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                Icons.link_rounded,
                color: Colors.white.withOpacity(0.25),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: urlCtrl,
                  style: TextStyle(
                    fontFamily: AppFonts.jetbrainsMono,
                    fontSize:   12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Paste playlist or album URL...',
                    hintStyle: TextStyle(
                      fontFamily: AppFonts.jetbrainsMono,
                      fontSize:   12,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    border:         InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // paste from clipboard
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    urlCtrl.text = data!.text!;
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:        AppColors.theme,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Text(
                    'Paste',
                    style: TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize:   12,
                      fontWeight: FontWeight.w800,
                      color:      AppColors.surfaceDeep,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // collapsible platforms
        const PlatformCollapseSection(),
        const SizedBox(height: 24),

        // recently imported
        _RecentlyImported(),
      ],
    );
  }
}

// ── File tab ───────────────────────────────────────────────────────────────

// class _FileTab extends StatelessWidget {
//   // final GlobalKey<TxtFileDropState> fileDropKey;
//   // final _fileDropKey = GlobalKey<TxtFileDropState>();

//   final void Function(String, String) onFilePicked;

//   const _FileTab({
//     // required this.fileDropKey,
//     required this.onFilePicked,
//   });

//   // @override
//   // Widget build(BuildContext context) {
//     // return TxtFileDrop(
//     //   key:          fileDropKey,
//     //   onFilePicked: onFilePicked,
//     // );
//   // }
// }

// ── Recently imported ──────────────────────────────────────────────────────

class _RecentlyImported extends StatelessWidget {
  final _recent = const [
    _RecentItem(
      icon:    '🎧',
      name:    'AfroBeats 2025',
      meta:    'Spotify · 24 tracks · 2h ago',
    ),
    _RecentItem(
      icon:    '🎵',
      name:    'Chill Vibes',
      meta:    'Deezer · 31 tracks · 3 days ago',
    ),
  ];

  const _RecentlyImported();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENTLY IMPORTED',
          style: TextStyle(
            fontFamily:    AppFonts.outfit,
            fontSize:      11,
            fontWeight:    FontWeight.w700,
            letterSpacing: 0.12,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 12),
        ..._recent.map((r) => _RecentRow(item: r)),
      ],
    );
  }
}

class _RecentItem {
  final String icon;
  final String name;
  final String meta;
  const _RecentItem({
    required this.icon,
    required this.name,
    required this.meta,
  });
}

class _RecentRow extends StatelessWidget {
  final _RecentItem item;
  const _RecentRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width:  42,
            height: 42,
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item.icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: AppFonts.outfit,
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color:      Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.meta,
                  style: TextStyle(
                    fontFamily: AppFonts.jetbrainsMono,
                    fontSize:   10,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.25),
            size: 18,
          ),
        ],
      ),
    );
  }
}

// ── Action button ──────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final _ImportTab   tab;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.tab,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = switch (tab) {
      _ImportTab.link   => 'Fetch Playlist',
      _ImportTab.file   => 'Browse Files',
      _ImportTab.manual => 'Import List',
    };

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width:  double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color:        AppColors.theme,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:       AppColors.theme.withOpacity(0.25),
              blurRadius:  20,
              offset:      const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize:   15,
              fontWeight: FontWeight.w800,
              color:      AppColors.surfaceDeep,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab button ─────────────────────────────────────────────────────────────

class _TabBtn extends StatelessWidget {
  final String       label;
  final bool         active;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:  const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppColors.theme
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign:  TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize:   12,
              fontWeight: FontWeight.w700,
              color: active
                  ? AppColors.surfaceDeep
                  : Colors.white.withOpacity(0.45),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Import progress modal ──────────────────────────────────────────────────

class _ImportProgressModal extends ConsumerWidget {
  final String                 title;
  final Future<void> Function() onStart;
  final VoidCallback            onDone;

  const _ImportProgressModal({
    required this.title,
    required this.onStart,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importProvider);

    // close when done
    ref.listen(importProvider, (_, next) {
      if (next.step == ImportStep.done ||
          next.step == ImportStep.error) {
        Future.delayed(
          const Duration(milliseconds: 800),
          onDone,
        );
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
          Container(
            width:  36,
            height: 4,
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            title,
            style: const TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize:   18,
              fontWeight: FontWeight.w800,
              color:      Colors.white,
            ),
          ),
          const SizedBox(height: 28),

          // step indicator
          _StepRow(
            icon:   Icons.search_rounded,
            label:  'Decoding playlist',
            active: state.step == ImportStep.decoding,
            done:   state.step.index > ImportStep.decoding.index,
          ),
          const SizedBox(height: 16),
          _StepRow(
            icon:   Icons.track_changes_rounded,
            label:  'Resolving tracks',
            active: state.step == ImportStep.resolving,
            done:   state.step.index > ImportStep.resolving.index,
            progress: state.step == ImportStep.resolving
                ? state.progress
                : null,
            subtitle: state.step == ImportStep.resolving
                ? '${state.done} / ${state.total} tracks'
                : null,
          ),
          const SizedBox(height: 16),
          _StepRow(
            icon:   Icons.download_rounded,
            label:  'Queuing downloads',
            active: state.step == ImportStep.queuing,
            done:   state.step.index > ImportStep.queuing.index,
          ),
          const SizedBox(height: 16),
          _StepRow(
            icon:   state.step == ImportStep.error
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            label:  state.step == ImportStep.error
                ? state.errorMessage ?? 'Something went wrong'
                : 'Done',
            active: state.step == ImportStep.done ||
                    state.step == ImportStep.error,
            done:   false,
            isError: state.step == ImportStep.error,
          ),

          const SizedBox(height: 28),

          // overall progress bar
          if (state.step == ImportStep.resolving) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:           state.progress,
                backgroundColor: AppColors.surfaceElevated,
                color:           AppColors.theme,
                minHeight:       4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(state.progress * 100).toInt()}%',
              style: TextStyle(
                fontFamily: AppFonts.jetbrainsMono,
                fontSize:   11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     active;
  final bool     done;
  final bool     isError;
  final double?  progress;
  final String?  subtitle;

  const _StepRow({
    required this.icon,
    required this.label,
    required this.active,
    required this.done,
    this.isError  = false,
    this.progress,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    if (isError)     iconColor = AppColors.error;
    else if (done)   iconColor = AppColors.theme3;
    else if (active) iconColor = AppColors.theme;
    else             iconColor = Colors.white.withOpacity(0.2);

    return Row(
      children: [
        Container(
          width:  38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color: active || done
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: AppFonts.jetbrainsMono,
                    fontSize:   10,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (active && !done && !isError)
          const SizedBox(
            width:  16,
            height: 16,
            child:  CircularProgressIndicator(
              color:       AppColors.theme,
              strokeWidth: 2,
            ),
          ),
        if (done)
          Icon(Icons.check_rounded,
              color: AppColors.theme3, size: 16),
      ],
    );
  }
}

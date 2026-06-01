import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_credentials.dart';
import '../../shared/providers/offline_mode_provider.dart';
import '../import/import_screen.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_row.dart';
import 'widgets/donation_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioQuality   = ref.watch(audioQualityProvider);
    final crossfade      = ref.watch(crossfadeProvider);
    final normalize      = ref.watch(normalizeProvider);
    final equalizer      = ref.watch(equalizerProvider);
    final animArtwork    = ref.watch(animatedArtworkProvider);
    final offlineMode    = ref.watch(offlineModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: AppFonts.outfit,
                        fontSize:   26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color:      Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'wavr · v${AppCredentials.currentVersion}',
                      style: TextStyle(
                        fontFamily: AppFonts.jetbrainsMono,
                        fontSize:   11,
                        color: Colors.white.withValues(alpha:  0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Offline mode ──────────────────────────────────────────
                  const SettingsSectionLabel(text: 'NETWORK'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.wifi_off_rounded,
                          bg:   AppColors.srcSoundcloudBg,
                          fg:   AppColors.warning,
                        ),
                        label:    'Offline Mode',
                        subtitle: 'Only play downloaded tracks',
                        trailing: SettingsToggle(
                          value:     offlineMode,
                          onChanged: (_) =>
                              ref
                                  .read(offlineModeProvider.notifier)
                                  .toggle(),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),

                  // ── Music Sources ─────────────────────────────────────────
                  const SettingsSectionLabel(text: 'MUSIC SOURCES'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.download_rounded,
                          bg:   AppColors.srcSpotifyBg,
                          fg:   AppColors.success,
                        ),
                        label:    'Import A Playlist',
                        subtitle: 'Link, file (.txt) or manual list',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha:  0.25),
                          size: 18,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ImportScreen(),
                          ),
                        ),
                      ),
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.music_note_rounded,
                          bg:   AppColors.srcSpotifyBg,
                          fg:   AppColors.success,
                        ),
                        label:    'Local Music Folder',
                        subtitle: _localFolderSubtitle(ref),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha:  0.25),
                          size: 18,
                        ),
                        onTap: () =>
                            _showLocalFolderModal(context, ref),
                      ),
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.upload_rounded,
                          bg:   AppColors.srcLocalBg,
                          fg:   AppColors.info,
                        ),
                        label:    'Auto-sync Playlists',
                        subtitle: 'Refresh imported playlists on open',
                        trailing: SettingsToggle(
                          value:     true,
                          onChanged: (_) {},
                        ),
                        isLast: true,
                      ),
                    ],
                  ),

                  // ── Audio ─────────────────────────────────────────────────
                  const SettingsSectionLabel(text: 'AUDIO'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.volume_up_rounded,
                          bg:   AppColors.srcDeezerBg,
                          fg:   AppColors.srcPurpleFg,
                        ),
                        label:    'Audio Quality',
                        subtitle: 'Stream & download resolution',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            audioQuality.when(
                              data: (q) => Text(
                                _qualityLabel(q),
                                style: TextStyle(
                                  fontFamily: AppFonts.jetbrainsMono,
                                  fontSize:   12,
                                  color: Colors.white.withValues(alpha:  0.35),
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error:   (_, __) => const SizedBox.shrink(),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withValues(alpha:  0.25),
                              size: 18,
                            ),
                          ],
                        ),
                        onTap: () =>
                            _showQualityPicker(context, ref),
                      ),
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.equalizer_rounded,
                          bg:   AppColors.srcLocalBg,
                          fg:   AppColors.srcTealFg,
                        ),
                        label:    'Equalizer',
                        subtitle: 'Custom EQ bands',
                        trailing: equalizer.when(
                          data: (v) => SettingsToggle(
                            value:     v,
                            onChanged: (_) =>
                                ref
                                    .read(equalizerProvider.notifier)
                                    .toggle(),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error:   (_, __) => const SizedBox.shrink(),
                        ),
                      ),
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.wb_sunny_rounded,
                          bg:   AppColors.srcSoundcloudBg,
                          fg:   AppColors.warning,
                        ),
                        label:    'Crossfade',
                        subtitle: 'Smooth transitions between tracks',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            crossfade.when(
                              data: (s) => Text(
                                '${s}s',
                                style: TextStyle(
                                  fontFamily: AppFonts.jetbrainsMono,
                                  fontSize:   12,
                                  color: Colors.white.withValues(alpha:  0.35),
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error:   (_, __) => const SizedBox.shrink(),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withValues(alpha:  0.25),
                              size: 18,
                            ),
                          ],
                        ),
                        onTap: () =>
                            _showCrossfadePicker(context, ref),
                      ),
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.check_circle_rounded,
                          bg:   AppColors.srcSpotifyBg,
                          fg:   AppColors.success,
                        ),
                        label:    'Normalize Volume',
                        subtitle: 'Same loudness across all tracks',
                        trailing: normalize.when(
                          data: (v) => SettingsToggle(
                            value:     v,
                            onChanged: (_) =>
                                ref
                                    .read(normalizeProvider.notifier)
                                    .toggle(),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error:   (_, __) => const SizedBox.shrink(),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),

                  // ── Appearance ────────────────────────────────────────────
                  const SettingsSectionLabel(text: 'APPEARANCE'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.dark_mode_rounded,
                          bg:   AppColors.srcThemeBg,
                          fg:   AppColors.srcPinkFg,
                        ),
                        label:    'Theme',
                        subtitle: 'App color scheme',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Dark',
                              style: TextStyle(
                                fontFamily: AppFonts.jetbrainsMono,
                                fontSize:   12,
                                color: Colors.white.withValues(alpha:  0.35),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withValues(alpha:  0.25),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.palette_rounded,
                          bg:   AppColors.srcWavrBg,
                          fg:   AppColors.theme,
                        ),
                        label:    'Accent Color',
                        subtitle: 'Highlight color throughout app',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width:  20,
                              height: 20,
                              decoration: BoxDecoration(
                                color:        AppColors.theme,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha:  0.1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withValues(alpha:  0.25),
                              size: 18,
                            ),
                          ],
                        ),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF0F0F1A),
                            title: const Text('Accent Color',
                              style: TextStyle(fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700, color: Colors.white)),
                            content: Wrap(
                              spacing: 12, runSpacing: 12,
                              children: [
                                0xFFE8FF5A, 0xFF5AE8FF, 0xFFFF5A5A,
                                0xFFA05AFF, 0xFF5AFF8C, 0xFFFFAA5A,
                                0xFFFF5AA0, 0xFF5A8CFF,
                              ].map((color) => GestureDetector(
                                onTap: () {
                                  ref.read(accentColorProvider.notifier).set(color);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: Color(color),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                      ),
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.image_rounded,
                          bg:   AppColors.srcLocalBg,
                          fg:   AppColors.info,
                        ),
                        label:    'Animated Artwork',
                        subtitle: 'Waveform visualizer on player',
                        trailing: animArtwork.when(
                          data: (v) => SettingsToggle(
                            value:     v,
                            onChanged: (_) =>
                                ref
                                    .read(animatedArtworkProvider.notifier)
                                    .toggle(),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error:   (_, __) => const SizedBox.shrink(),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),

                  // ── Storage ───────────────────────────────────────────────
                  const SettingsSectionLabel(text: 'STORAGE'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.storage_rounded,
                          bg:   AppColors.srcSoundcloudBg,
                          fg:   AppColors.warning,
                        ),
                        label:    'Cache Size',
                        subtitle: 'Buffered audio data',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ref.watch(cacheSizeProvider).when(
                              data: (size) => Text(size,
                                style: TextStyle(fontFamily: 'JetBrains Mono',
                                    fontSize: 12, color: Colors.white.withValues(alpha:  0.35))),
                              loading: () => const SizedBox(width: 14, height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2,
                                      color: Color(0xFFE8FF5A))),
                              error: (_, __) => const Text('? MB'),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withValues(alpha:  0.25),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.delete_outline_rounded,
                          bg:   AppColors.srcAppleBg,
                          fg:   AppColors.error,
                        ),
                        label:    'Clear Cache',
                        subtitle: 'Free up space',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha:  0.25),
                          size: 18,
                        ),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF0F0F1A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text('Clear Cache', style: TextStyle(
                                fontFamily: 'Outfit', fontSize: 17,
                                fontWeight: FontWeight.w800, color: Colors.white)),
                            content: Text(
                              'This will delete all buffered audio. '
                              'Downloaded songs will not be affected.',
                              style: TextStyle(fontFamily: 'JetBrains Mono',
                                  fontSize: 12, color: Colors.white.withValues(alpha:  0.5),
                                  height: 1.6)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel', style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Colors.white.withValues(alpha:  0.5)))),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final dir = await getTemporaryDirectory();
                                  if (await dir.exists()) await dir.delete(recursive: true);
                                  await dir.create();
                                  ref.invalidate(cacheSizeProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Cache cleared')));
                                  }
                                },
                                child: const Text('Clear', style: TextStyle(
                                    fontFamily: 'Outfit', fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF5A5A)))),
                            ],
                          ),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),

                  // ── About ─────────────────────────────────────────────────
                  const SettingsSectionLabel(text: 'ABOUT'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.info_outline_rounded,
                          bg:   AppColors.srcLocalBg,
                          fg:   AppColors.info,
                        ),
                        label:    'Version',
                        subtitle: 'Check for updates',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppCredentials.currentVersion,
                              style: TextStyle(
                                fontFamily: AppFonts.jetbrainsMono,
                                fontSize:   12,
                                color: Colors.white.withValues(alpha:  0.35),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withValues(alpha:  0.25),
                              size: 18,
                            ),
                          ],
                        ),
                        onTap: () =>
                            _showVersionModal(context),
                      ),
                      SettingsRow(
                        icon: const RowIcon(
                          icon: Icons.shield_outlined,
                          bg:   AppColors.srcDeezerBg,
                          fg:   AppColors.srcPurpleFg,
                        ),
                        label:    'Privacy & Legal',
                        subtitle: 'How we handle your data',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha:  0.25),
                          size: 18,
                        ),
                        onTap: () =>
                            _showPrivacyModal(context),
                        isLast: true,
                      ),
                    ],
                  ),

                  // ── Support ───────────────────────────────────────────────
                  const SettingsSectionLabel(
                      text: 'SUPPORT THE PROJECT'),
                  const DonationCard(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Local folder modal ─────────────────────────────────────────────────

  String _localFolderSubtitle(WidgetRef ref) {
    final folders = ref.watch(_localFoldersProvider);
    if (folders.isEmpty) return 'No folders selected';
    return '${folders.length} folder${folders.length > 1 ? 's' : ''} selected';
  }

  void _showLocalFolderModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context:            context,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LocalFolderModal(),
    );
  }

  // ── Quality picker ─────────────────────────────────────────────────────

  String _qualityLabel(AudioQuality q) => switch (q) {
        AudioQuality.low    => 'Low',
        AudioQuality.medium => 'Medium',
        AudioQuality.high   => 'High',
      };

  void _showQualityPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerModal(
        title:   'Audio Quality',
        options: ['Low', 'Medium', 'High'],
        current: ref.read(audioQualityProvider).value?.name ?? 'high',
        onSelect: (v) => ref.read(audioQualityProvider.notifier).set(
              AudioQuality.values.byName(v.toLowerCase()),
            ),
      ),
    );
  }

  // ── Crossfade picker ───────────────────────────────────────────────────

  void _showCrossfadePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerModal(
        title:   'Crossfade',
        options: ['0s', '1s', '3s', '5s', '8s'],
        current: '${ref.read(crossfadeProvider).value ?? 3}s',
        onSelect: (v) => ref
            .read(crossfadeProvider.notifier)
            .set(int.parse(v.replaceAll('s', ''))),
      ),
    );
  }

  // ── Clear cache dialog ─────────────────────────────────────────────────

  // void _showClearCacheDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       backgroundColor: AppColors.surfaceAlt,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       title: const Text(
  //         'Clear Cache',
  //         style: TextStyle(
  //           fontFamily: AppFonts.outfit,
  //           fontSize:   17,
  //           fontWeight: FontWeight.w800,
  //           color:      Colors.white,
  //         ),
  //       ),
  //       content: Text(
  //         'This will delete all buffered audio. '
  //         'Downloaded songs will not be affected.',
  //         style: TextStyle(
  //           fontFamily: AppFonts.jetbrainsMono,
  //           fontSize:   12,
  //           color: Colors.white.withValues(alpha:  0.5),
  //           height:    1.6,
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Cancel',
  //             style: TextStyle(
  //               fontFamily: AppFonts.outfit,
  //               color: Colors.white.withValues(alpha:  0.5),
  //             ),
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text(
  //             'Clear',
  //             style: TextStyle(
  //               fontFamily: AppFonts.outfit,
  //               fontWeight: FontWeight.w700,
  //               color:      AppColors.error,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── Version modal ──────────────────────────────────────────────────────

  void _showVersionModal(BuildContext context) {
    showModalBottomSheet(
      context:            context,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _VersionModal(),
    );
  }

  // ── Privacy modal ──────────────────────────────────────────────────────

  void _showPrivacyModal(BuildContext context) {
    showModalBottomSheet(
      context:            context,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _PrivacyModal(),
    );
  }
}

// ── Local folders provider & modal ────────────────────────────────────────

class _LocalFoldersNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];
  void add(String path) => state = [...state, path];
  void removeAt(int index) {
    final copy = [...state];
    copy.removeAt(index);
    state = copy;
  }
}

final cacheSizeProvider = FutureProvider<String>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final wavr = Directory('${dir.path}/wavr');
  if (!await wavr.exists()) return '0 MB';
  int total = 0;
  await for (final f in wavr.list(recursive: true)) {
    if (f is File) total += await f.length();
  }
  final mb = (total / (1024 * 1024)).toStringAsFixed(1);
  return '$mb MB';
});

final _localFoldersProvider =
    NotifierProvider<_LocalFoldersNotifier, List<String>>(
  _LocalFoldersNotifier.new,
);

class _LocalFolderModal extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(_localFoldersProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
          Center(
            child: Container(
              width:  36,
              height: 4,
              decoration: BoxDecoration(
                color:        Colors.white.withValues(alpha:  0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Text(
                'Local Music Folders',
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize:   17,
                  fontWeight: FontWeight.w800,
                  color:      Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final result =
                      await FilePicker.getDirectoryPath();
                  if (result != null) {
                    ref.read(_localFoldersProvider.notifier).add(result);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.theme,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '+ Add',
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
          const SizedBox(height: 16),

          if (folders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No folders selected yet.\nTap "+ Add" to choose a folder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.jetbrainsMono,
                  fontSize:   12,
                  color: Colors.white.withValues(alpha:  0.3),
                  height:    1.6,
                ),
              ),
            )
          else
            ...folders.asMap().entries.map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:  0.07),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_rounded,
                          color: AppColors.theme
                              .withValues(alpha:  0.7),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e.value.split('/').last,
                            style: const TextStyle(
                              fontFamily: AppFonts.jetbrainsMono,
                              fontSize:   12,
                              color:      Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ref.read(_localFoldersProvider.notifier).removeAt(e.key),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withValues(alpha:  0.3),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Generic picker modal ───────────────────────────────────────────────────

class _PickerModal extends StatelessWidget {
  final String                title;
  final List<String>          options;
  final String                current;
  final void Function(String) onSelect;

  const _PickerModal({
    required this.title,
    required this.options,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width:  36,
                height: 4,
                decoration: BoxDecoration(
                  color:        Colors.white.withValues(alpha:  0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppFonts.outfit,
                fontSize:   17,
                fontWeight: FontWeight.w800,
                color:      Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: options.map(
                    (opt) => GestureDetector(
                      onTap: () {
                        onSelect(opt);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: opt == current
                              ? const Color(0xFFE8FF5A).withValues(alpha:  0.1)
                              : const Color(0xFF161624),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: opt == current
                                ? const Color(0xFFE8FF5A).withValues(alpha:  0.3)
                                : Colors.white.withValues(alpha:  0.07),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              opt,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: opt == current
                                    ? const Color(0xFFE8FF5A)
                                    : Colors.white,
                              ),
                            ),
                            const Spacer(),
                            if (opt == current)
                              const Icon(
                                Icons.check_rounded,
                                color: Color(0xFFE8FF5A),
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Version modal ──────────────────────────────────────────────────────────

class _VersionModal extends StatefulWidget {
  const _VersionModal();

  @override
  State<_VersionModal> createState() => _VersionModalState();
}

class _VersionModalState extends State<_VersionModal> {
  bool    _checking   = true;
  bool    _upToDate   = false;
  String? _newVersion;
  String? _downloadUrl;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final dio = Dio();
      final res = await dio.get(AppCredentials.updateCheckUrl);
      // expects JSON: { "version": "1.0.1", "download_url": "..." }
      final data       = res.data as Map<String, dynamic>;
      final latest     = data['version'] as String;
      final downloadUrl = data['download_url'] as String?;

      final isNewer = _isNewerVersion(
          latest, AppCredentials.currentVersion);

      setState(() {
        _checking    = false;
        _upToDate    = !isNewer;
        _newVersion  = isNewer ? latest : null;
        _downloadUrl = isNewer ? downloadUrl : null;
      });
    } catch (_) {
      setState(() {
        _checking = false;
        _upToDate = true; // assume up to date on error
      });
    }
  }

  bool _isNewerVersion(String remote, String current) {
    final r = remote.split('.').map(int.parse).toList();
    final c = current.split('.').map(int.parse).toList();
    for (var i = 0; i < r.length; i++) {
      if (r[i] > c[i]) return true;
      if (r[i] < c[i]) return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width:  36,
              height: 4,
              decoration: BoxDecoration(
                color:        Colors.white.withValues(alpha:  0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Check for Updates',
            style: TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize:   18,
              fontWeight: FontWeight.w800,
              color:      Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current version: ${AppCredentials.currentVersion}',
            style: TextStyle(
              fontFamily: AppFonts.jetbrainsMono,
              fontSize:   11,
              color: Colors.white.withValues(alpha:  0.35),
            ),
          ),
          const SizedBox(height: 32),

          if (_checking) ...[
            const CircularProgressIndicator(
              color:       AppColors.theme,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Checking for updates…',
              style: TextStyle(
                fontFamily: AppFonts.jetbrainsMono,
                fontSize:   12,
                color: Colors.white.withValues(alpha:  0.4),
              ),
            ),
          ] else if (_upToDate) ...[
            Container(
              width:  64,
              height: 64,
              decoration: BoxDecoration(
                color:        AppColors.success.withValues(alpha:  0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.theme3,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You\'re up to date!',
              style: TextStyle(
                fontFamily: AppFonts.outfit,
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      Colors.white,
              ),
            ),
          ] else ...[
            Container(
              width:  64,
              height: 64,
              decoration: BoxDecoration(
                color:        AppColors.theme.withValues(alpha:  0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: AppColors.theme,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'v$_newVersion available',
              style: const TextStyle(
                fontFamily: AppFonts.outfit,
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(_downloadUrl ?? '');
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
              child: Container(
                width:  double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color:        AppColors.theme,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Download Update',
                    style: TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize:   14,
                      fontWeight: FontWeight.w800,
                      color:      AppColors.surfaceDeep,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Privacy modal ──────────────────────────────────────────────────────────

class _PrivacyModal extends StatefulWidget {
  const _PrivacyModal();

  @override
  State<_PrivacyModal> createState() => _PrivacyModalState();
}

class _PrivacyModalState extends State<_PrivacyModal> {
  String _content = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text = await rootBundle
          .loadString('assets/legal/privacy.txt');
      setState(() => _content = text);
    } catch (_) {
      setState(() =>
          _content = 'Privacy policy not available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width:  36,
              height: 4,
              decoration: BoxDecoration(
                color:        Colors.white.withValues(alpha:  0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Privacy & Legal',
            style: TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize:   18,
              fontWeight: FontWeight.w800,
              color:      Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _content.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color:       AppColors.theme,
                      strokeWidth: 2,
                    ),
                  )
                : SingleChildScrollView(
                    child: Text(
                      _content,
                      style: TextStyle(
                        fontFamily: AppFonts.jetbrainsMono,
                        fontSize:   12,
                        color: Colors.white.withValues(alpha:  0.55),
                        height:    1.7,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

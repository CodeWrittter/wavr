import 'package:flutter/material.dart';
import '../../../services/playlist_decoder/models/decoded_track.dart';
import '../../../data/models/track.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class ManualInputSheet extends StatefulWidget {
  final void Function(List<DecodedTrack> tracks) onImport;

  const ManualInputSheet({super.key, required this.onImport});

  @override
  State<ManualInputSheet> createState() => ManualInputSheetState();
}

class ManualInputSheetState extends State<ManualInputSheet> {
  final _ctrl = TextEditingController();
  int   _lineCount = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // text area
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            children: [
              // header bar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'SONG LIST',
                      style: TextStyle(
                        fontFamily: AppFonts.outfit,
                        fontSize:   11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$_lineCount song${_lineCount != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontFamily: AppFonts.jetbrainsMono,
                        fontSize:   10,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              // textarea
              TextField(
                controller:   _ctrl,
                maxLines:     10,
                style: TextStyle(
                  fontFamily: AppFonts.jetbrainsMono,
                  fontSize:   12,
                  color: Colors.white.withOpacity(0.8),
                  height:     1.8,
                ),
                decoration: InputDecoration(
                  hintText: 'Type or paste your list here…\nOne song per line',
                  hintStyle: TextStyle(
                    fontFamily: AppFonts.jetbrainsMono,
                    fontSize:   12,
                    color: Colors.white.withOpacity(0.2),
                    height:    1.8,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
                onChanged: (v) {
                  setState(() {
                    _lineCount = v
                        .split('\n')
                        .where((l) => l.trim().isNotEmpty)
                        .length;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // format hint
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: AppFonts.jetbrainsMono,
              fontSize:   11,
              color: Colors.white.withOpacity(0.35),
              height:    1.6,
            ),
            children: const [
              TextSpan(text: 'Format: '),
              TextSpan(
                text:  'Artist — Title',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color:      Colors.white,
                ),
              ),
              TextSpan(text: ' or '),
              TextSpan(
                text:  'Title — Artist',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color:      Colors.white,
                ),
              ),
              TextSpan(
                text: "\nWe'll auto-detect and match both orders.",
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<DecodedTrack> _parse() {
    final lines = _ctrl.text
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    return lines.map((line) {
      // support both em-dash and regular dash
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
      // try to detect order: if first part looks like an artist
      // (shorter, no common song words) use Artist — Title
      // otherwise fall back to Title — Artist
      return DecodedTrack(
        artist: parts.first.trim(),
        title:  parts.sublist(1).join(sep).trim(),
        source: TrackSource.manual,
      );
    }).toList();
  }

  void submit() {
    final tracks = _parse();
    if (tracks.isEmpty) return;
    widget.onImport(tracks);
  }
}

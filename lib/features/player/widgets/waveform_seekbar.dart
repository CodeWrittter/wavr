import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class WaveformSeekbar extends ConsumerWidget {
  const WaveformSeekbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(playerProvider);
    final notifier = ref.read(playerProvider.notifier);

    final position = state.position.inMilliseconds.toDouble();
    final duration = state.duration.inMilliseconds.toDouble();
    final maxVal   = duration > 0 ? duration : 1.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        // track
        trackHeight:          4,
        activeTrackColor:     AppColors.theme,
        inactiveTrackColor:   Colors.white.withValues(alpha: 0.12),
        // thumb
        thumbColor:           AppColors.theme,
        thumbShape:           const RoundSliderThumbShape(
          enabledThumbRadius: 7,
        ),
        // overlay shown while dragging
        overlayColor:         AppColors.theme.withValues(alpha: 0.2),
        overlayShape:         const RoundSliderOverlayShape(
          overlayRadius: 16,
        ),
        // no tick marks
        tickMarkShape:        SliderTickMarkShape.noTickMark,
        // value indicator (tooltip while dragging)
        showValueIndicator:   ShowValueIndicator.onDrag,
        valueIndicatorShape:  const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor:  AppColors.theme,
        valueIndicatorTextStyle: const TextStyle(
          fontFamily: AppFonts.jetbrainsMono,
          fontSize:   11,
          fontWeight: FontWeight.w600,
          color:      AppColors.surfaceDeep,
        ),
      ),
      child: Slider(
        value:    position.clamp(0.0, maxVal),
        min:      0,
        max:      maxVal,
        label:    _format(state.position),
        onChanged: (v) => notifier.seekTo(
          Duration(milliseconds: v.toInt()),
        ),
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

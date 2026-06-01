import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../../../core/theme/app_colors.dart';

class WaveformSeekbar extends ConsumerWidget {
  const WaveformSeekbar({super.key});

  static const _heights = [
    10.0, 16.0, 22.0, 14.0, 28.0, 20.0, 30.0, 18.0, 32.0, 24.0,
    26.0, 16.0, 28.0, 14.0, 22.0, 20.0, 18.0, 30.0, 24.0, 20.0,
    16.0, 28.0, 12.0, 22.0, 26.0, 16.0, 32.0, 18.0, 24.0, 20.0,
    18.0, 28.0, 22.0, 30.0, 14.0, 26.0, 20.0, 24.0, 18.0, 28.0,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    final player   = ref.read(playerProvider.notifier);
    final playedCount = (_heights.length * progress).floor();

    return GestureDetector(
      onTapDown: (d) => _seek(context, d.localPosition.dx, player),
      onHorizontalDragUpdate: (d) =>
          _seek(context, d.localPosition.dx, player),
      child: SizedBox(
        height: 40,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final barWidth =
                (constraints.maxWidth - (_heights.length - 1) * 2) /
                    _heights.length;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_heights.length, (i) {
                final played = i < playedCount;
                return Container(
                  width: barWidth,
                  height: _heights[i],
                  margin: i < _heights.length - 1
                      ? const EdgeInsets.only(right: 2)
                      : null,
                  decoration: BoxDecoration(
                    color: played
                        ? AppColors.theme
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  void _seek(BuildContext ctx, double dx, PlayerNotifier player) {
    final width = ctx.size?.width ?? 1;
    final fraction = (dx / width).clamp(0.0, 1.0);
    player.seekToFraction(fraction);
  }
}

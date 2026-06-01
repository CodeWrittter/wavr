import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class DonationCard extends StatelessWidget {
  const DonationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [
            AppColors.theme.withValues(alpha:  0.07),
            AppColors.theme.withValues(alpha:  0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.theme.withValues(alpha:  0.2),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          const Row(
            children: [
              Text(
                'Keep Wavr free & ad-free ',
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize:   16,
                  fontWeight: FontWeight.w800,
                  color:      Colors.white,
                ),
              ),
              Text('❤️', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'If Wavr brings joy to your listening, a small '
            'contribution helps keep it alive and growing — '
            'no ads, ever.',
            style: TextStyle(
              fontFamily: AppFonts.jetbrainsMono,
              fontSize:   11,
              color: Colors.white.withValues(alpha:  0.5),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // payment method chips
          Wrap(
            spacing:  8,
            runSpacing: 8,
            children: const [
              _MethodChip(emoji: '💳', label: 'PayPal'),
              _MethodChip(emoji: '☕', label: 'Buy Me a Coffee'),
              _MethodChip(emoji: '📱', label: 'Mobile Money'),
              _MethodChip(emoji: '₿',  label: 'Crypto'),
            ],
          ),
          const SizedBox(height: 16),

          // donate button
          GestureDetector(
            onTap: () => _openDonation(context),
            child: Container(
              width:  double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color:        AppColors.theme,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color:      AppColors.theme.withValues(alpha:  0.25),
                    blurRadius: 16,
                    offset:     const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Donate',
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
      ),
    );
  }

  void _openDonation(BuildContext context) {
    showModalBottomSheet(
      context:            context,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _DonationModal(),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String emoji;
  final String label;
  const _MethodChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:  0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha:  0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Donation modal ─────────────────────────────────────────────────────────

class _DonationModal extends StatelessWidget {
  const _DonationModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        AppColors.surfaceAlt,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
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
          const SizedBox(height: 28),

          // app icon placeholder
          Container(
            width:  72,
            height: 72,
            decoration: BoxDecoration(
              color:        AppColors.theme.withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.theme.withValues(alpha:  0.2),
              ),
            ),
            child: const Center(
              child: Text('🎵', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 14),

          // app name
          const Text(
            'Wavr',
            style: TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize:   22,
              fontWeight: FontWeight.w900,
              color:      Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v${AppCredentials.currentVersion}',
            style: TextStyle(
              fontFamily: AppFonts.jetbrainsMono,
              fontSize:   11,
              color: Colors.white.withValues(alpha:  0.35),
            ),
          ),
          const SizedBox(height: 24),

          // developer info card
          Container(
            width:  double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha:  0.07),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width:  40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.theme.withValues(alpha:  0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('👨‍💻',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppCredentials.developerName,
                          style: const TextStyle(
                            fontFamily: AppFonts.outfit,
                            fontSize:   14,
                            fontWeight: FontWeight.w700,
                            color:      Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppCredentials.developerAddress,
                          style: TextStyle(
                            fontFamily: AppFonts.jetbrainsMono,
                            fontSize:   11,
                            color: Colors.white.withValues(alpha:  0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  AppCredentials.developerMessage,
                  style: TextStyle(
                    fontFamily: AppFonts.jetbrainsMono,
                    fontSize:   11,
                    color: Colors.white.withValues(alpha:  0.5),
                    height:     1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // redirect to website button
          GestureDetector(
            onTap: () async {
              final uri =
                  Uri.parse(AppCredentials.donationWebsiteUrl);
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
                  'Support on the Web',
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
      ),
    );
  }
}

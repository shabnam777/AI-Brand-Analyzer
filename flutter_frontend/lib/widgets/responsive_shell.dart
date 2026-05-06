import 'package:flutter/material.dart';

import '../theme.dart';

/// Wraps any screen content.
/// On web/desktop (width > 1024): content is centered at 1/3 screen width,
/// rest of the screen gets a soft gradient background.
/// On mobile (width <= 1024): full width as normal.
class ResponsiveShell extends StatelessWidget {
  final Widget child;
  final bool scrollable;

  const ResponsiveShell({
    super.key,
    required this.child,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    if (!isDesktop) return child;

    // Desktop: center panel
    final panelWidth = screenWidth / 2;

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      body: Row(children: [
        // Left decorative area
        Expanded(child: _buildSidePanel(context, isLeft: true)),

        // Center panel — the app
        Container(
          width: panelWidth,
          decoration: const BoxDecoration(
            color: AppColors.bg,
            boxShadow: [
              BoxShadow(color: Color(0x18000000), blurRadius: 40, spreadRadius: 0),
            ],
          ),
          child: ClipRect(child: child),
        ),

        // Right decorative area
        Expanded(child: _buildSidePanel(context, isLeft: false)),
      ]),
    );
  }

  Widget _buildSidePanel(BuildContext context, {required bool isLeft}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            const Color(0xFFEEF2FF),
            const Color(0xFFE8EAF6),
          ],
        ),
      ),
      child: Center(
        child: isLeft
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.indigo, AppColors.violet],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'AEO\nDiagnostic',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        color: AppColors.indigo,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'See how your brand ranks\nwhen AI answers shoppers.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _sideBadge('🟢 DeepSeek R1 70B'),
                    const SizedBox(height: 4),
                    _sideBadge('🟠 Llama 3.3 70B'),
                    const SizedBox(height: 4),
                    _sideBadge('🟡 Cloudflare AI'),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statBox('3', 'AI Models'),
                    const SizedBox(height: 16),
                    _statBox('100%', 'Free APIs'),
                    const SizedBox(height: 16),
                    _statBox('~5s', 'Analysis Time'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sideBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: AppColors.indigo,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ]),
    );
  }
}

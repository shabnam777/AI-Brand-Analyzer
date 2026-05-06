import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../theme.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────
int? _getUserRank(ModelResult model, String userBrand) {
  final found = model.topBrands.firstWhere(
    (b) => b.brand.toLowerCase().contains(userBrand.toLowerCase()) || userBrand.toLowerCase().contains(b.brand.toLowerCase()),
    orElse: () => BrandMention(brand: '', position: 0, mentions: 0),
  );
  return found.position == 0 ? null : found.position;
}

int? _getCompRank(ModelResult model, String compBrand) {
  final found = model.topBrands.firstWhere(
    (b) => b.brand.toLowerCase().contains(compBrand.toLowerCase()) || compBrand.toLowerCase().contains(b.brand.toLowerCase()),
    orElse: () => BrandMention(brand: '', position: 0, mentions: 0),
  );
  return found.position == 0 ? null : found.position;
}

enum MatchResult { win, lose, tie, absent }

MatchResult _getResult(int? userRank, int? compRank) {
  if (userRank == null && compRank == null) return MatchResult.absent;
  if (userRank == null) return MatchResult.lose;
  if (compRank == null) return MatchResult.win;
  if (userRank < compRank) return MatchResult.win;
  if (userRank > compRank) return MatchResult.lose;
  return MatchResult.tie;
}

// ─── Style config ─────────────────────────────────────────────────────────────
class _ResultStyle {
  final Color bg, border, text;
  final String label, icon;
  const _ResultStyle({required this.bg, required this.border, required this.text, required this.label, required this.icon});
}

const _styles = {
  MatchResult.win: _ResultStyle(bg: Color(0xFFECFDF5), border: Color(0xFF059669), text: Color(0xFF059669), label: 'WIN', icon: '🏆'),
  MatchResult.lose: _ResultStyle(bg: Color(0xFFFEF2F2), border: Color(0xFFEF4444), text: Color(0xFFEF4444), label: 'LOSE', icon: '📉'),
  MatchResult.tie: _ResultStyle(bg: Color(0xFFFFFBEB), border: Color(0xFFF59E0B), text: Color(0xFFF59E0B), label: 'TIE', icon: '🤝'),
  MatchResult.absent: _ResultStyle(bg: Color(0xFFF5F6FF), border: Color(0xFFE5E7EB), text: Color(0xFFADB5BD), label: '–', icon: '–'),
};

const _modelIcons = {
  'DeepSeek R1 70B': '🟢',
  'Llama 3.3 70B': '🟠',
  'Llama 3.1 8B': '🟡',
  'Mistral 7B': '🟤',
};

String _shortModel(String model) => model.replaceAll('Gemini 1.5 Flash', 'Gemini').replaceAll('Llama 3.3 70B', 'Llama');

// ─── Main Widget ──────────────────────────────────────────────────────────────
class VSCompetitors extends StatefulWidget {
  final AnalysisResult data;
  const VSCompetitors({super.key, required this.data});

  @override
  State<VSCompetitors> createState() => _VSCompetitorsState();
}

class _VSCompetitorsState extends State<VSCompetitors> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final competitors = widget.data.topCompetitors.take(5).toList();
    if (competitors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text('No competitor data found', style: AppText.body(13, color: AppColors.textMuted)),
        ),
      );
    }

    final competitor = competitors[_selected];
    final modelComparisons = widget.data.modelResults.map((r) {
      final uRank = _getUserRank(r, widget.data.userBrand);
      final cRank = _getCompRank(r, competitor.brand);
      return (model: r.model, uRank: uRank, cRank: cRank, result: _getResult(uRank, cRank));
    }).toList();

    final wins = modelComparisons.where((m) => m.result == MatchResult.win).length;
    final losses = modelComparisons.where((m) => m.result == MatchResult.lose).length;
    final overall = wins > losses
        ? MatchResult.win
        : losses > wins
            ? MatchResult.lose
            : MatchResult.tie;
    final overallStyle = _styles[overall]!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: AppColors.indigoLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.sports_kabaddi_rounded, color: AppColors.indigo, size: 16),
              ),
              const SizedBox(width: 10),
              Text('Your Brand vs Competitors', style: AppText.display(15)),
            ]),
          ),

          // Competitor tabs
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: competitors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final isSelected = _selected == i;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.indigoLight : AppColors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected ? AppColors.indigo : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      competitors[i].brand,
                      style: AppText.body(
                        12,
                        color: isSelected ? AppColors.indigo : AppColors.textSecondary,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // VS Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              // Overall header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: overallStyle.bg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                ),
                child: Row(children: [
                  // Your brand
                  Expanded(
                      child: Column(children: [
                    Text('YOU', style: AppText.mono(9, color: AppColors.indigo, weight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(widget.data.userBrand,
                        style: AppText.display(13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    _pillBadge('$wins won', AppColors.indigo, Colors.white),
                  ])),

                  // VS badge
                  Column(children: [
                    Text(overallStyle.icon, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 2),
                    Text(overallStyle.label, style: AppText.mono(11, color: overallStyle.text, weight: FontWeight.w700)),
                  ]),

                  // Competitor
                  Expanded(
                      child: Column(children: [
                    Text('COMPETITOR', style: AppText.mono(9, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(competitor.brand, style: AppText.display(13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    _pillBadge('$losses won', AppColors.border, AppColors.textSecondary),
                  ])),
                ]),
              ),

              // Per model rows
              ...modelComparisons.asMap().entries.map((e) {
                final i = e.key;
                final m = e.value;
                final rs = _styles[m.result]!;
                final isLast = i == modelComparisons.length - 1;
                final icon = _modelIcons[m.model] ?? '🤖';

                return Container(
                  decoration: BoxDecoration(
                    border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF5F6FF), width: 1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    // User rank
                    Expanded(
                        child: Center(
                      child: m.uRank != null
                          ? Text('#${m.uRank}',
                              style: AppText.mono(14,
                                  color: m.result == MatchResult.win ? AppColors.gradeA : AppColors.textPrimary, weight: FontWeight.w700))
                          : Text('—', style: AppText.mono(13, color: AppColors.textMuted)),
                    )),

                    // Model + badge
                    Expanded(
                      flex: 2,
                      child: Column(children: [
                        Text('$icon ${_shortModel(m.model)}', style: AppText.mono(10, color: AppColors.textSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: rs.bg,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: rs.border.withOpacity(0.3)),
                          ),
                          child: Text(rs.label, style: AppText.mono(9, color: rs.text, weight: FontWeight.w700)),
                        ),
                      ]),
                    ),

                    // Competitor rank
                    Expanded(
                        child: Center(
                      child: m.cRank != null
                          ? Text('#${m.cRank}',
                              style: AppText.mono(14,
                                  color: m.result == MatchResult.lose ? AppColors.gradeF : AppColors.textPrimary, weight: FontWeight.w700))
                          : Text('—', style: AppText.mono(13, color: AppColors.textMuted)),
                    )),
                  ]),
                );
              }),
            ]),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _legendItem(_styles[MatchResult.win]!, 'Your rank is higher'),
                _legendItem(_styles[MatchResult.lose]!, 'Competitor ranks higher'),
                _legendItem(_styles[MatchResult.tie]!, 'Same rank'),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('—', style: AppText.mono(10, color: AppColors.textMuted)),
                  const SizedBox(width: 5),
                  Text('Not mentioned', style: AppText.body(10, color: AppColors.textMuted)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillBadge(String text, Color bg, Color textColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: AppText.mono(9, color: textColor, weight: FontWeight.w700)),
      );

  Widget _legendItem(_ResultStyle rs, String desc) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: rs.bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: rs.border.withOpacity(0.3)),
          ),
          child: Text(rs.label, style: AppText.mono(9, color: rs.text, weight: FontWeight.w700)),
        ),
        const SizedBox(width: 5),
        Text(desc, style: AppText.body(10, color: AppColors.textMuted)),
      ]);
}

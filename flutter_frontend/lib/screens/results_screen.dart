import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../theme.dart';
import '../widgets/vs_competitors.dart';
import 'landing_screen.dart';

class ResultsScreen extends StatefulWidget {
  final AnalysisResult result;
  const ResultsScreen({super.key, required this.result});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scoreCtrl;
  late Animation<double> _scoreAnim;
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scoreAnim = CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOutCubic);
    _scoreCtrl.forward();
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    super.dispose();
  }

  Color get gc => AppTheme.gradeColor(widget.result.grade);
  Color get gbg => AppTheme.gradeBg(widget.result.grade);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          _buildNav(),
          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildScoreHero(),
              const SizedBox(height: 14),
              _buildStatRow(),
              const SizedBox(height: 24),
              _buildSectionLabel('Per-Model Breakdown', Icons.smart_toy_rounded, AppColors.indigo),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.result.modelResults.length,
                itemBuilder: (context, index) {
                  return _modelCard(
                    widget.result.modelResults[index],
                    index,
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionLabel('Your Brand vs Competitors', Icons.sports_kabaddi_rounded, AppColors.indigo),
              const SizedBox(height: 10),
              VSCompetitors(data: widget.result),
              const SizedBox(height: 24),
              _buildSectionLabel('Top Competitors in AI', Icons.track_changes_rounded, AppColors.violet),
              const SizedBox(height: 10),
              _buildCompetitors(),
              const SizedBox(height: 24),
              _buildSectionLabel('How to Improve', Icons.lightbulb_rounded, AppColors.gold),
              const SizedBox(height: 10),
              ...widget.result.recommendations.asMap().entries.map((e) => _recCard(e.value, e.key)),
              const SizedBox(height: 24),
              _buildFooterCta(),
              const SizedBox(height: 24),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.indigo, AppColors.violet]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('AEO Report', style: AppText.display(15)),
          ]),
          GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingScreen()), (_) => false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 15),
                const SizedBox(width: 6),
                Text('New Analysis', style: AppText.body(12, color: AppColors.textSecondary)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.result.userBrand, style: AppText.display(22)),
      Text('"${widget.result.query}"', style: AppText.body(13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
    ]);
  }

  Widget _buildScoreHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: gbg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gc.withOpacity(0.25)),
      ),
      child: Row(children: [
        AnimatedBuilder(
          animation: _scoreAnim,
          builder: (_, __) => SizedBox(
            width: 110,
            height: 110,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: _scoreAnim.value * widget.result.overallScore / 100,
                  strokeWidth: 9,
                  backgroundColor: gc.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(gc),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${(_scoreAnim.value * widget.result.overallScore).round()}', style: AppText.display(30, color: gc)),
                Text('/100', style: AppText.mono(10, color: AppColors.textMuted)),
              ]),
            ]),
          ),
        ),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.result.grade, style: AppText.display(52, color: gc)),
          Text(widget.result.gradeLabel, style: AppText.display(14, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Overall AEO Score', style: AppText.mono(11, color: AppColors.textMuted)),
        ]),
      ]),
    );
  }

  Widget _buildStatRow() {
    return Row(children: [
      Expanded(child: _statCard(Icons.people_outline_rounded, 'AI Visibility', '${widget.result.modelsFound}/3', 'models found brand')),
      const SizedBox(width: 12),
      Expanded(
          child: _statCard(
              Icons.trending_up_rounded, 'Avg Rank', widget.result.avgRank != null ? '#${widget.result.avgRank}' : 'N/A', 'when mentioned',
              valueColor: widget.result.avgRank != null ? null : AppColors.gradeF)),
    ]);
  }

  Widget _statCard(IconData icon, String label, String value, String sub, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.indigo, size: 15),
          const SizedBox(width: 6),
          Text(label, style: AppText.mono(10, color: AppColors.textMuted)),
        ]),
        const SizedBox(height: 8),
        Text(value, style: AppText.display(26, color: valueColor ?? AppColors.textPrimary)),
        Text(sub, style: AppText.mono(9, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(width: 10),
      Text(title, style: AppText.display(16)),
    ]);
  }

  Widget _modelCard(ModelResult r, int index) {
    final isExp = _expanded.contains(index);
    final scoreColor = r.userScore != null
        ? AppTheme.gradeColor(r.userScore! >= 80
            ? 'A'
            : r.userScore! >= 65
                ? 'B'
                : r.userScore! >= 50
                    ? 'C'
                    : r.userScore! >= 35
                        ? 'D'
                        : 'F')
        : AppColors.gradeF;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Text(r.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.model, style: AppText.body(13, weight: FontWeight.w600)),
                Text('${r.provider} · ${r.latency}ms', style: AppText.mono(10, color: AppColors.textMuted)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${r.userScore ?? 0}', style: AppText.display(22, color: scoreColor)),
                Text('score', style: AppText.mono(9, color: AppColors.textMuted)),
              ]),
            ]),
          ),
          if (r.topBrands.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: SingleChildScrollView(
                child: Column(
                  children: r.topBrands.take(3).map((b) {
                    final isUser = b.brand.toLowerCase().contains(widget.result.userBrand.toLowerCase()) ||
                        widget.result.userBrand.toLowerCase().contains(b.brand.toLowerCase());
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.indigoLight : AppColors.bg,
                        borderRadius: BorderRadius.circular(9),
                        border: isUser ? Border.all(color: AppColors.indigo.withOpacity(0.25)) : null,
                      ),
                      child: Row(children: [
                        Text('#${b.position}', style: AppText.mono(10, color: AppColors.textMuted)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(b.brand,
                                style: AppText.mono(11,
                                    color: isUser ? AppColors.indigo : AppColors.textSecondary, weight: isUser ? FontWeight.w600 : FontWeight.w400))),
                        Text('${b.mentions}x', style: AppText.mono(9, color: AppColors.textMuted)),
                      ]),
                    );
                  }).toList(),
                ),
              ),
            ),
          GestureDetector(
            onTap: () => setState(() {
              isExp ? _expanded.remove(index) : _expanded.add(index);
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: Row(children: [
                Icon(isExp ? Icons.expand_less : Icons.expand_more, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 4),
                Text(isExp ? 'Hide response' : 'View AI response', style: AppText.mono(10, color: AppColors.textMuted)),
              ]),
            ),
          ),
          if (isExp)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(r.text, style: AppText.mono(11, color: AppColors.textSecondary)),
            ),
        ]),
      ),
    );
  }

  Widget _buildCompetitors() {
    if (widget.result.topCompetitors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(child: Text('No competitor data found', style: AppText.body(13, color: AppColors.textMuted))),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        children: widget.result.topCompetitors.take(5).toList().asMap().entries.map((e) {
          final op = 1.0 - e.key * 0.15;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(e.value.brand, style: AppText.body(12, weight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                Text('${e.value.modelCount}/3 models', style: AppText.mono(10, color: AppColors.textMuted)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: e.value.modelCount / 3,
                  backgroundColor: AppColors.bg,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet.withOpacity(op)),
                  minHeight: 7,
                ),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _recCard(Recommendation rec, int index) {
    final impactColors = {'high': AppColors.gradeA, 'medium': AppColors.gradeC, 'low': AppColors.textMuted};
    final effortLabels = {'high': '⚠️ High effort', 'medium': '⚡ Medium', 'low': '✅ Quick win'};
    final ic = impactColors[rec.impact] ?? AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: ic.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text('${index + 1}', style: AppText.mono(11, color: ic, weight: FontWeight.w700))),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rec.title, style: AppText.body(13, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(rec.description, style: AppText.body(12, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: [
            _chip('${rec.impact} impact', ic.withOpacity(0.12), ic),
            _chip(effortLabels[rec.effort] ?? rec.effort, AppColors.bg, AppColors.textSecondary),
          ]),
        ])),
      ]),
    );
  }

  Widget _chip(String text, Color bg, Color textColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: AppText.mono(9, color: textColor)),
      );

  Widget _buildFooterCta() {
    return GestureDetector(
      onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingScreen()), (_) => false),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.indigo, AppColors.violet]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.indigo.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(child: Text('Analyze Another Brand →', style: AppText.display(15, color: Colors.white))),
      ),
    );
  }
}
// second test

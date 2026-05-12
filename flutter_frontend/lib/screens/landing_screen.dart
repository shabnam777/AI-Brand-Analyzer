import 'package:flutter/material.dart';

import '../theme.dart';
import 'analysis_screen.dart';
import 'results_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  final _queryCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final _examples = [
    ('best magnesium glycinate', 'Doctor\'s Best'),
    ('best fish oil supplement', 'Nordic Naturals'),
    ('best budget bluetooth speaker', 'JBL'),
    ('best sunscreen for oily skin', 'Neutrogena'),
    ('best vitamin d3 supplement', 'NOW Foods'),
    ('best calcium tablets for women', 'Citracal'),
    ('best probiotics for gut health', 'Culturelle'),

    ('best running shoes', 'Nike'),
    ('best gym shoes for men', 'Adidas'),
    ('best yoga mat', 'Liforme'),
    ('best protein bars', 'Quest'),
    ('best creatine monohydrate', 'Optimum Nutrition'),

    ('best office chair for back pain', 'Green Soul'),
    ('best ergonomic keyboard', 'Microsoft'),
    ('best standing desk', 'FlexiSpot'),
    ('best study lamp', 'Philips'),
    ('best air purifier', 'Dyson'),
    ('best running shoes', 'Nike'),
    ('best coffee beans', 'Lavazza'),
    ('best earbuds', 'Soundcore'), // partial brand
    ('best earbuds', 'Anker'), // parent brand
    ('best earbuds', 'Anker Soundcore') // full brand
  ];

  // 4 models matching React exactly
  final _models = [
    (Icons.memory_rounded, '🟢', 'DeepSeek R1 70B', 'Groq', const Color(0xFF059669)),
    (Icons.memory_outlined, '🟠', 'Llama 3.3 70B', 'Groq', const Color(0xFFFF6B35)),
    (Icons.cloud_rounded, '🟡', 'Llama 3.1 8B', 'Cloudflare AI', const Color(0xFFF59E0B)),
  ];

  final _steps = [
    (Icons.send_rounded, AppColors.indigo, 'Query 4 AI Models', 'Simultaneously queries DeepSeek, Llama, Gemini, Cloudflare & HuggingFace.'),
    (Icons.manage_search_rounded, AppColors.violet, 'Extract Rankings', 'Parses each response — brand mentions, positions, and frequency.'),
    (Icons.insights_rounded, AppColors.gold, 'Get Your AEO Score', 'Score 0–100, competitor breakdown, and 4 actions to improve.'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _queryCtrl.dispose();
    _brandCtrl.dispose();
    super.dispose();
  }

  void _analyze() {
    final query = _queryCtrl.text.trim();
    final brand = _brandCtrl.text.trim();
    if (query.isEmpty || brand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill both fields'), backgroundColor: AppColors.gradeF));
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(
            query: query,
            brand: brand,
            onComplete: (result) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultsScreen(result: result))),
            onError: (err) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err'), backgroundColor: AppColors.gradeF));
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
            child: SingleChildScrollView(
          child: Column(children: [
            _buildNav(),
            _buildHero(),
            _buildQueryCard(),
            _buildModelsGrid(),
            _buildHowItWorks(),
            const SizedBox(height: 40),
          ]),
        )),
      ),
    );
  }

  // ── Nav ────────────────────────────────────────────────────────────────────
  Widget _buildNav() => Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.indigo, AppColors.violet]), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text('AEO Diagnostic', style: AppText.display(16)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: AppColors.indigoLight, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Icon(Icons.circle, color: AppColors.gradeA, size: 8),
              const SizedBox(width: 6),
              Text('3 AI Models', style: AppText.mono(10, color: AppColors.indigo)),
            ]),
          ),
        ]),
      );

  // ── Hero ───────────────────────────────────────────────────────────────────
  Widget _buildHero() => Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.indigo, AppColors.violet], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        padding: const EdgeInsets.fromLTRB(16, 36, 16, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
              const SizedBox(width: 6),
              Text('Answer Engine Optimization', style: AppText.mono(10, color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 20),
          Text('How does your\nbrand rank in\nAI search?', style: AppText.display(30, color: Colors.white)),
          const SizedBox(height: 12),
          Text('Shoppers ask 3 AI models what to buy — not Google.\nSee where your brand appears across all of them.',
              style: AppText.body(14, color: Colors.white.withOpacity(0.8), height: 1.5)),
        ]),
      );

  // ── Query Card ─────────────────────────────────────────────────────────────
  Widget _buildQueryCard() => Transform.translate(
        offset: const Offset(0, -20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.indigo.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('WHAT SHOPPERS ASK AI', style: AppText.mono(10, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: _queryCtrl,
              style: AppText.body(14),
              decoration: const InputDecoration(
                  hintText: 'e.g. best magnesium supplement for seniors',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.bg),
            ),
            const SizedBox(height: 14),
            Text('YOUR BRAND NAME', style: AppText.mono(10, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: _brandCtrl,
              style: AppText.body(14),
              decoration: const InputDecoration(
                  hintText: 'e.g. Nature Made, Anker',
                  prefixIcon: Icon(Icons.storefront_rounded, color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.bg),
              onSubmitted: (_) => _analyze(),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _analyze,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.indigo, AppColors.violet]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.indigo.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Run AEO Diagnostic', style: AppText.display(15, color: Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            Text('TRY AN EXAMPLE', style: AppText.mono(10, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _examples
                  .map((ex) => GestureDetector(
                        onTap: () => setState(() {
                          _queryCtrl.text = ex.$1;
                          _brandCtrl.text = ex.$2;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.indigoLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.indigo.withOpacity(0.15))),
                          child: Text(ex.$1, style: AppText.body(11, color: AppColors.indigo)),
                        ),
                      ))
                  .toList(),
            ),
          ]),
        ),
      );

  Widget _buildModelsGrid() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('POWERED BY 3 FREE AI MODELS', style: AppText.mono(10, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 500 ? 3 : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _models.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 4, // 👈 tweak based on UI
                ),
                itemBuilder: (context, index) {
                  final m = _models[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: m.$5.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(m.$2, style: const TextStyle(fontSize: 17)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                m.$3,
                                style: AppText.body(10, weight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                m.$4,
                                style: AppText.mono(8, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )
        ]),
      );

  // ── How it Works ───────────────────────────────────────────────────────────
  Widget _buildHowItWorks() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('How It Works', style: AppText.display(18)),
          const SizedBox(height: 14),
          ..._steps.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration:
                    BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: s.$2.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(s.$1, color: s.$2, size: 22)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.$3, style: AppText.body(13, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(s.$4, style: AppText.body(12, color: AppColors.textSecondary, height: 1.4)),
                  ])),
                ]),
              )),
        ]),
      );
}
 
 // check new yml
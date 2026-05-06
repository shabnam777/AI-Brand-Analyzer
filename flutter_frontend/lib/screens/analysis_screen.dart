import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../theme.dart';

class AnalysisScreen extends StatefulWidget {
  final String query;
  final String brand;
  final void Function(AnalysisResult) onComplete;
  final void Function(String) onError;
  const AnalysisScreen({super.key, required this.query, required this.brand, required this.onComplete, required this.onError});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final List<int> _stepState = List.filled(9, 0);

  final _steps = [
    (Icons.memory_rounded, Color(0xFF059669), 'Querying DeepSeek R1 70B...', 1400),
    (Icons.memory_outlined, Color(0xFFFF6B35), 'Querying Llama 3.3 70B...', 1400),
    (Icons.cloud_rounded, Color(0xFFF59E0B), 'Querying Cloudflare AI...', 1400),
    (Icons.manage_search_rounded, AppColors.indigo, 'Extracting brand mentions...', 700),
    (Icons.bar_chart_rounded, AppColors.violet, 'Calculating AEO scores...', 700),
    (Icons.lightbulb_rounded, AppColors.gold, 'Generating recommendations...', 900),
  ];

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 22))..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _runSteps();
    _callApi();
  }

  Future<void> _runSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() => _stepState[i] = 1);
      await Future.delayed(Duration(milliseconds: _steps[i].$4));
      if (!mounted) return;
      setState(() => _stepState[i] = 2);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _callApi() async {
    try {
      final result = await ApiService.analyze(query: widget.query, brand: widget.brand);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) widget.onComplete(result);
    } catch (e) {
      if (mounted) widget.onError(e.toString());
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  double get _progress {
    final done = _stepState.where((s) => s == 2).length;
    final active = _stepState.where((s) => s == 1).length;
    return (done + active * 0.5) / _steps.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                const Spacer(),
                _buildTop(),
                const SizedBox(height: 24),
                _buildProgressBar(),
                const SizedBox(height: 16),
                _buildStepsList(),
                const SizedBox(height: 16),
                Text('Checking "${widget.brand}"', style: AppText.mono(11, color: AppColors.textMuted), textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTop() => Column(children: [
        AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.indigo, AppColors.violet]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: AppColors.indigo.withOpacity(.3 + _pulseAnim.value * .2), blurRadius: 20, offset: const Offset(0, 6))
                    ],
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 34),
                )),
        const SizedBox(height: 10),
        Text('Analyzing Your Brand', style: AppText.display(20)),
        const SizedBox(height: 4),
        RichText(
            text: TextSpan(children: [
          TextSpan(text: 'Querying ', style: AppText.body(13, color: AppColors.textSecondary)),
          TextSpan(text: '3 AI models', style: AppText.body(13, color: AppColors.indigo, weight: FontWeight.w600)),
          TextSpan(text: ' for "${widget.query}"', style: AppText.body(13, color: AppColors.textSecondary)),
        ])),
      ]);

  Widget _buildProgressBar() => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Scanning AI models', style: AppText.body(12, color: AppColors.textSecondary)),
          Text('${(_progress * 100).round()}%', style: AppText.mono(12, color: AppColors.indigo, weight: FontWeight.w600)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
                value: _progress, backgroundColor: AppColors.indigoLight, valueColor: const AlwaysStoppedAnimation(AppColors.indigo), minHeight: 7)),
      ]);

  Widget _buildStepsList() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12)]),
        child: Column(
            children: _steps.asMap().entries.map((e) {
          final i = e.key;
          final step = e.value;
          final isDone = _stepState[i] == 2;
          final isCurrent = _stepState[i] == 1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(color: isCurrent ? AppColors.indigoLight : Colors.transparent, borderRadius: BorderRadius.circular(11)),
            child: Row(children: [
              AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isDone
                      ? Container(
                          key: const ValueKey('d'),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(color: AppColors.gradeA.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.check_rounded, color: AppColors.gradeA, size: 16))
                      : Container(
                          key: ValueKey(isCurrent),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(color: step.$2.withOpacity(isCurrent ? 0.14 : .04), borderRadius: BorderRadius.circular(8)),
                          child: Icon(step.$1, color: isCurrent ? step.$2 : AppColors.textMuted, size: 16))),
              const SizedBox(width: 9),
              Expanded(
                  child: Text(
                step.$3,
                style: AppText.body(12,
                    color: isDone
                        ? AppColors.textMuted
                        : isCurrent
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                    weight: isCurrent ? FontWeight.w600 : FontWeight.w400),
              )),
              if (isCurrent)
                AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Row(
                        children: List.generate(
                            3,
                            (j) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.indigo.withOpacity(
                                      (j == 0)
                                          ? _pulseAnim.value
                                          : (j == 1)
                                              ? 0.5
                                              : 0.2,
                                    ))))))
            ]),
          );
        }).toList()),
      );
}

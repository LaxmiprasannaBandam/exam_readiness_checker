import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/assessment.dart';
import '../state/app_scope.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';

/// Collects the preparation numbers and calculates the readiness score.
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _syllabus;
  late double _mockScore;
  late int _confidence;
  late final TextEditingController _questionsCtrl;
  late final TextEditingController _revisionsCtrl;

  static const List<String> _confidenceLabels = [
    'Not confident',
    'A little unsure',
    'Fairly confident',
    'Confident',
    'Very confident',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill with the previous answers.
    final input = AppScope.read(context).input;
    _syllabus = input.syllabus.clamp(0.0, 100.0).toDouble();
    _mockScore = input.mockScore.clamp(0.0, 100.0).toDouble();
    _confidence = input.confidence.clamp(1, 5).toInt();
    _questionsCtrl = TextEditingController(text: input.questions.toString());
    _revisionsCtrl = TextEditingController(text: input.revisions.toString());
  }

  @override
  void dispose() {
    _questionsCtrl.dispose();
    _revisionsCtrl.dispose();
    super.dispose();
  }

  /// Copies the average syllabus completion and total questions from the
  /// subject list into this form.
  void _fillFromSubjects() {
    final state = AppScope.read(context);
    if (state.subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add subjects first in Exam Setup')),
      );
      return;
    }
    setState(() {
      _syllabus = state.averageCompletion.clamp(0.0, 100.0).toDouble();
      _questionsCtrl.text = state.totalSubjectQuestions.toString();
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final input = AssessmentInput(
      syllabus: _syllabus.roundToDouble(),
      questions: int.parse(_questionsCtrl.text.trim()),
      mockScore: _mockScore.roundToDouble(),
      revisions: int.parse(_revisionsCtrl.text.trim()),
      confidence: _confidence,
    );

    // 1) Calculate + save, 2) open the results (replacing this screen).
    final result = AppScope.read(context).submitAssessment(input);
    Navigator.pushReplacementNamed(context, AppRoutes.results,
        arguments: result);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Readiness Assessment')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Text(
                'Tell us how your preparation is going. This gives a simple, '
                'app-generated estimate to help you plan - it is not a professional assessment.',
                style: TextStyle(color: onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _fillFromSubjects,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: const Text('Fill from my subjects'),
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SliderField(
                      icon: Icons.menu_book_rounded,
                      label: 'Syllabus completion',
                      value: _syllabus,
                      onChanged: (v) => setState(() => _syllabus = v),
                    ),
                    const SizedBox(height: 10),
                    _SliderField(
                      icon: Icons.quiz_rounded,
                      label: 'Mock test score',
                      value: _mockScore,
                      onChanged: (v) => setState(() => _mockScore = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _questionsCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: fieldDecoration(context,
                          label: 'Practice questions solved',
                          hint: 'e.g. 250',
                          icon: Icons.edit_note_rounded),
                      validator: (v) => Validators.wholeNumber(
                          v, 'Practice questions',
                          max: 100000),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _revisionsCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: fieldDecoration(context,
                          label: 'Revision sessions completed',
                          hint: 'e.g. 5',
                          icon: Icons.replay_rounded),
                      validator: (v) => Validators.wholeNumber(
                          v, 'Revision sessions',
                          max: 1000),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.emoji_events_rounded,
                            color: AppColors.warning),
                        SizedBox(width: 8),
                        Text('Confidence level',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<int>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 1, label: Text('1')),
                          ButtonSegment(value: 2, label: Text('2')),
                          ButtonSegment(value: 3, label: Text('3')),
                          ButtonSegment(value: 4, label: Text('4')),
                          ButtonSegment(value: 5, label: Text('5')),
                        ],
                        selected: {_confidence},
                        onSelectionChanged: (set) =>
                            setState(() => _confidence = set.first),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_confidence / 5  -  ${_confidenceLabels[_confidence - 1]}',
                      style: TextStyle(color: onSurface.withOpacity(0.65)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Calculate Readiness'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled slider from 0 to 100 that shows its current value.
class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            Text('${value.round()}%',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${value.round()}%',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

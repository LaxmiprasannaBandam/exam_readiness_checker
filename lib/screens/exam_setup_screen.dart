import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exam.dart';
import '../models/subject.dart';
import '../state/app_scope.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/subject_form_sheet.dart';

/// Lets the student enter the exam details and manage the subject list.
class ExamSetupScreen extends StatefulWidget {
  const ExamSetupScreen({super.key});

  @override
  State<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends State<ExamSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _totalCtrl;
  DateTime? _date;
  late List<Subject> _subjects;

  @override
  void initState() {
    super.initState();
    // Start with whatever is already saved (empty on a fresh install).
    final state = AppScope.read(context);
    final exam = state.exam;
    _nameCtrl = TextEditingController(text: exam?.name ?? '');
    _date = exam?.date;
    _dateCtrl = TextEditingController(
        text: exam == null ? '' : DateHelper.format(exam.date));
    _totalCtrl = TextEditingController(
        text: exam == null ? '' : exam.totalSubjects.toString());
    _subjects = List.of(state.subjects);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: (_date != null && !_date!.isBefore(today))
          ? _date!
          : today.add(const Duration(days: 14)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 3)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateCtrl.text = DateHelper.format(picked);
    });
  }

  Future<void> _addSubject() async {
    final subject = await showSubjectForm(context);
    if (subject == null || !mounted) return;
    setState(() {
      _subjects.add(subject);
      // If the user added more subjects than the "Total subjects" number,
      // raise the number automatically.
      final total = int.tryParse(_totalCtrl.text.trim()) ?? 0;
      if (_subjects.length > total) _totalCtrl.text = _subjects.length.toString();
    });
  }

  Future<void> _editSubject(int index) async {
    final updated = await showSubjectForm(context, existing: _subjects[index]);
    if (updated == null || !mounted) return;
    setState(() => _subjects[index] = updated);
  }

  Future<void> _deleteSubject(int index) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete subject?',
      message: 'Remove "${_subjects[index].name}" from your list?',
      confirmLabel: 'Delete',
    );
    if (!ok || !mounted) return;
    setState(() => _subjects.removeAt(index));
  }

  /// Validates the form and saves it. Returns true when saved.
  bool _save() {
    if (!_formKey.currentState!.validate()) return false;
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one subject')),
      );
      return false;
    }
    final exam = Exam(
      name: _nameCtrl.text.trim(),
      date: _date!,
      totalSubjects: int.parse(_totalCtrl.text.trim()),
    );
    AppScope.read(context).saveExamSetup(exam, _subjects);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Setup')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: fieldDecoration(context,
                          label: 'Exam name',
                          hint: 'e.g. Semester End Examination',
                          icon: Icons.school_rounded),
                      validator: (v) => Validators.requiredText(v, 'Exam name'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _dateCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: fieldDecoration(context,
                          label: 'Exam date',
                          hint: 'Tap to choose a date',
                          icon: Icons.event_rounded),
                      validator: (_) => Validators.examDate(_date),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _totalCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: fieldDecoration(context,
                          label: 'Total subjects',
                          icon: Icons.format_list_numbered_rounded),
                      validator: (v) {
                        final basic = Validators.wholeNumber(v, 'Total subjects',
                            min: 1, max: 20);
                        if (basic != null) return basic;
                        final total = int.parse(v!.trim());
                        if (total < _subjects.length) {
                          return 'You already added ${_subjects.length} subjects';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text('Subjects',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  Text('${_subjects.length} added',
                      style: TextStyle(color: onSurface.withOpacity(0.6))),
                ],
              ),
              const SizedBox(height: 12),
              if (_subjects.isEmpty)
                AppCard(
                  child: Column(
                    children: [
                      Icon(Icons.library_books_outlined,
                          size: 36, color: onSurface.withOpacity(0.4)),
                      const SizedBox(height: 8),
                      Text(
                        'No subjects yet. Tap "Add Subject" to begin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: onSurface.withOpacity(0.65)),
                      ),
                    ],
                  ),
                ),
              for (var i = 0; i < _subjects.length; i++)
                AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
                  onTap: () => _editSubject(i),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_subjects[i].name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              '${_subjects[i].completion.round()}% done  •  '
                              '${_subjects[i].questionsPracticed} questions  •  '
                              'confidence ${_subjects[i].confidence}/5',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: onSurface.withOpacity(0.65)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete subject',
                        onPressed: () => _deleteSubject(i),
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _addSubject,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Subject'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final messenger = ScaffoldMessenger.of(context);
                        if (_save()) {
                          Navigator.pop(context);
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Exam saved')),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        // Save, then replace this screen with the assessment.
                        if (_save()) {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.assessment);
                        }
                      },
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

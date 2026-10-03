import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/subject.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';

/// Opens a bottom sheet to ADD a subject (existing == null)
/// or EDIT one (existing != null). Returns the saved [Subject], or null
/// if the user closed the sheet.
Future<Subject?> showSubjectForm(BuildContext context, {Subject? existing}) {
  return showModalBottomSheet<Subject>(
    context: context,
    isScrollControlled: true, // lets the sheet move above the keyboard
    showDragHandle: true,
    builder: (ctx) => SubjectFormSheet(existing: existing),
  );
}

class SubjectFormSheet extends StatefulWidget {
  const SubjectFormSheet({super.key, this.existing});

  final Subject? existing;

  @override
  State<SubjectFormSheet> createState() => _SubjectFormSheetState();
}

class _SubjectFormSheetState extends State<SubjectFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _completionCtrl;
  late final TextEditingController _questionsCtrl;
  late int _confidence;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _completionCtrl = TextEditingController(
        text: s == null ? '' : s.completion.round().toString());
    _questionsCtrl =
        TextEditingController(text: s == null ? '' : s.questionsPracticed.toString());
    _confidence = s?.confidence ?? 3;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _completionCtrl.dispose();
    _questionsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final subject = Subject(
      id: widget.existing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      completion: double.parse(_completionCtrl.text.trim()),
      questionsPracticed: int.parse(_questionsCtrl.text.trim()),
      confidence: _confidence,
    );
    Navigator.pop(context, subject);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Update subject' : 'Add subject',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: fieldDecoration(context,
                    label: 'Subject name',
                    hint: 'e.g. Operating Systems',
                    icon: Icons.menu_book_rounded),
                validator: (v) =>
                    Validators.requiredText(v, 'Subject name', maxLength: 40),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _completionCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: fieldDecoration(context,
                    label: 'Syllabus completed',
                    suffix: '%',
                    icon: Icons.pie_chart_rounded),
                validator: (v) => Validators.percentage(v, 'Syllabus completion'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _questionsCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: fieldDecoration(context,
                    label: 'Questions practiced', icon: Icons.edit_note_rounded),
                validator: (v) => Validators.wholeNumber(
                    v, 'Questions practiced',
                    max: 10000),
              ),
              const SizedBox(height: 18),
              const Text('Confidence level',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
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
              const SizedBox(height: 4),
              Text(
                '1 = not confident, 5 = very confident',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save changes' : 'Add subject'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

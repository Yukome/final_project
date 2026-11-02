import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diagnosis.dart';
import '../repositories/diagnosis_repository.dart';
import '../widgets/entity_form.dart';
import '../core/validators.dart';

class DiagnosisFormScreen extends StatefulWidget {
  final String? id;
  const DiagnosisFormScreen({super.key, this.id});

  @override
  State<DiagnosisFormScreen> createState() => _DiagnosisFormScreenState();
}

class _DiagnosisFormScreenState extends State<DiagnosisFormScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = true;
  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadDiagnosis();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadDiagnosis() async {
    final repo = context.read<DiagnosisRepository>();
    final result = await repo.findAll(size: 1000);
    final diag = result.items.where((d) => d.id == widget.id).firstOrNull;
    if (diag != null && mounted) {
      _nameController.text = diag.name;
      _descController.text = diag.description;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = context.read<DiagnosisRepository>();
    final diagnosis = Diagnosis(
      id: widget.id ?? '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
    );
    
    if (isEditing) {
      await repo.update(widget.id!, diagnosis.toJson());
    } else {
      await repo.create(diagnosis);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return EntityForm(
      title: isEditing ? 'Редактирование диагноза' : 'Новый диагноз',
      isEditing: isEditing,
      backPath: '/diagnoses',
      onSubmit: _submit,
      fields: [
        FormFieldSpec(label: 'Название', controller: _nameController, validator: (v) => Validators.required(v), fieldKey: 'name'),
        FormFieldSpec(label: 'Описание', controller: _descController, maxLines: 3, fieldKey: 'description'),
      ],
    );
  }
}
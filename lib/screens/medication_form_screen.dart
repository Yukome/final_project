import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../repositories/medication_repository.dart';
import '../widgets/entity_form.dart';
import '../core/validators.dart';

class MedicationFormScreen extends StatefulWidget {
  final String? id;
  const MedicationFormScreen({super.key, this.id});

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  bool _isLoading = true;
  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadMedication();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadMedication() async {
    final repo = context.read<MedicationRepository>();
    final result = await repo.findAll(size: 1000);
    final med = result.items.where((m) => m.id == widget.id).firstOrNull;
    if (med != null && mounted) {
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = context.read<MedicationRepository>();
    final medication = Medication(
      id: widget.id ?? '',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
    );
    
    if (isEditing) {
      await repo.update(widget.id!, medication.toJson());
    } else {
      await repo.create(medication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return EntityForm(
      title: isEditing ? 'Редактирование лекарства' : 'Новое лекарство',
      isEditing: isEditing,
      backPath: '/medications',
      onSubmit: _submit,
      fields: [
        FormFieldSpec(label: 'Название', controller: _nameController, validator: (v) => Validators.required(v), fieldKey: 'name'),
        FormFieldSpec(label: 'Дозировка', controller: _dosageController, validator: (v) => Validators.required(v), fieldKey: 'dosage'),
      ],
    );
  }
}
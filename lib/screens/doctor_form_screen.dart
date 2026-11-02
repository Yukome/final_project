import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../repositories/doctor_repository.dart';
import '../widgets/entity_form.dart';
import '../core/validators.dart';

class DoctorFormScreen extends StatefulWidget {
  final String? id;
  const DoctorFormScreen({super.key, this.id});

  @override
  State<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends State<DoctorFormScreen> {
  final _nameController = TextEditingController();
  final _specController = TextEditingController();
  bool _isLoading = true;
  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadDoctor();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadDoctor() async {
    final repo = context.read<DoctorRepository>();
    final result = await repo.findAll(size: 1000);
    final doctor = result.items.where((d) => d.id == widget.id).firstOrNull;
    if (doctor != null && mounted) {
      _nameController.text = doctor.fullName;
      _specController.text = doctor.specialization;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = context.read<DoctorRepository>();
    final doctor = Doctor(
      id: widget.id ?? '',
      fullName: _nameController.text.trim(),
      specialization: _specController.text.trim(),
      serviceIds: [],
    );
    
    if (isEditing) {
      await repo.update(widget.id!, doctor.toJson());
    } else {
      await repo.create(doctor);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return EntityForm(
      title: isEditing ? 'Редактирование врача' : 'Новый врач',
      isEditing: isEditing,
      backPath: '/doctors',
      onSubmit: _submit,
      fields: [
        FormFieldSpec(label: 'ФИО', controller: _nameController, validator: (v) => Validators.length(v, 3, 100), fieldKey: 'fullName'),
        FormFieldSpec(label: 'Специализация', controller: _specController, validator: (v) => Validators.required(v), fieldKey: 'specialization'),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medical_record.dart';
import '../models/pet.dart';
import '../repositories/medical_record_repository.dart';
import '../repositories/pet_repository.dart';
import '../widgets/entity_form.dart';

class MedicalRecordFormScreen extends StatefulWidget {
  final String? id;
  const MedicalRecordFormScreen({super.key, this.id});

  @override
  State<MedicalRecordFormScreen> createState() => _MedicalRecordFormScreenState();
}

class _MedicalRecordFormScreenState extends State<MedicalRecordFormScreen> {
  final _notesController = TextEditingController();
  String? _selectedPetId;
  List<Pet> _pets = [];
  bool _isLoading = true;
  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final petsResult = await context.read<PetRepository>().findAll(size: 1000);
    if (!mounted) return;
    setState(() => _pets = petsResult.items);

    if (isEditing) {
      final recordsResult = await context.read<MedicalRecordRepository>().findAll(size: 1000);
      final record = recordsResult.items.where((r) => r.id == widget.id).firstOrNull;
      if (record != null && mounted) {
        _notesController.text = record.notes;
        _selectedPetId = record.petId;
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedPetId == null) throw Exception('Выберите питомца');
    final repo = context.read<MedicalRecordRepository>();
    
    final record = MedicalRecord(
      id: widget.id ?? '',
      date: DateTime.now(),
      notes: _notesController.text.trim(),
      petId: _selectedPetId!,
    );
    
    if (isEditing) {
      await repo.update(widget.id!, record.toJson());
    } else {
      await repo.create(record);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return EntityForm(
      title: isEditing ? 'Редактирование мед. карты' : 'Новая мед. карта',
      isEditing: isEditing,
      backPath: '/medical_records',
      onSubmit: _submit,
      fields: [
        FormFieldSpec(label: 'Заметки', controller: _notesController, maxLines: 3),
      ],
      customContent: DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Питомец', border: OutlineInputBorder()),
        value: _selectedPetId,
        items: _pets.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
        onChanged: (val) => setState(() => _selectedPetId = val),
        validator: (v) => v == null ? 'Выберите питомца' : null,
      ),
    );
  }
}
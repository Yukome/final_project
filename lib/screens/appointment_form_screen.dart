import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/pet.dart';
import '../models/doctor.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/pet_repository.dart';
import '../repositories/doctor_repository.dart';
import '../widgets/entity_form.dart';

class AppointmentFormScreen extends StatefulWidget {
  final String? id;
  const AppointmentFormScreen({super.key, this.id});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  String? _selectedPetId;
  String? _selectedDoctorId;
  List<Pet> _pets = [];
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final petRepo = context.read<PetRepository>();
    final doctorRepo = context.read<DoctorRepository>();
    final appointmentRepo = context.read<AppointmentRepository>();
    
    final petsResult = await petRepo.findAll(size: 1000);
    final doctorsResult = await doctorRepo.findAll(size: 1000);
    
    if (!mounted) return;
    setState(() { 
      _pets = petsResult.items; 
      _doctors = doctorsResult.items; 
    });

    if (isEditing) {
      final appsResult = await appointmentRepo.findAll(size: 1000);
      final app = appsResult.items.where((a) => a.id == widget.id).firstOrNull;
      
      if (!mounted) return;
      if (app != null) {
        setState(() {
          _selectedPetId = app.petId;
          _selectedDoctorId = app.doctorId;
        });
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _submit() async {
    if (_selectedPetId == null || _selectedDoctorId == null) throw Exception('Заполните все поля');
    final repo = context.read<AppointmentRepository>();
    
    final appointment = Appointment(
      id: widget.id ?? '',
      date: DateTime.now(),
      status: 'waiting',
      petId: _selectedPetId!,
      doctorId: _selectedDoctorId!,
    );
    
    if (isEditing) {
      await repo.update(widget.id!, appointment.toJson());
    } else {
      await repo.create(appointment);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return EntityForm(
      title: isEditing ? 'Редактирование записи' : 'Новая запись',
      isEditing: isEditing,
      backPath: '/appointments',
      onSubmit: _submit,
      fields: const [],
      customContent: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Питомец', border: OutlineInputBorder()),
            value: _selectedPetId,
            items: _pets.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
            onChanged: (val) => setState(() => _selectedPetId = val),
            validator: (v) => v == null ? 'Выберите питомца' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Врач', border: OutlineInputBorder()),
            value: _selectedDoctorId,
            items: _doctors.map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName))).toList(),
            onChanged: (val) => setState(() => _selectedDoctorId = val),
            validator: (v) => v == null ? 'Выберите врача' : null,
          ),
        ],
      ),
    );
  }
}
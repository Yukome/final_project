import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../repositories/pet_repository.dart';
import '../state/auth_notifier.dart';
import '../widgets/entity_form.dart';
import '../core/validators.dart';

class AddMyPetScreen extends StatefulWidget {
  const AddMyPetScreen({super.key});

  @override
  State<AddMyPetScreen> createState() => _AddMyPetScreenState();
}

class _AddMyPetScreenState extends State<AddMyPetScreen> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = context.read<PetRepository>();
    final auth = context.read<AuthNotifier>();
    final ownerId = auth.user?.ownerId;
    if (ownerId == null) throw Exception('Ошибка: профиль владельца не найден');

    final pet = Pet(
      id: '',
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      breed: _breedController.text.trim(),
      ownerId: ownerId,
    );

    await repo.create(pet);
  }

  @override
  Widget build(BuildContext context) {
    return EntityForm(
      title: 'Новый питомец',
      isEditing: false,
      backPath: '/my-pets',
      onSubmit: _submit,
      fields: [
        FormFieldSpec(
          label: 'Кличка',
          controller: _nameController,
          validator: (v) => Validators.required(v, 'Введите кличку'),
          fieldKey: 'name',
        ),
        FormFieldSpec(
          label: 'Вид (Собака/Кошка)',
          controller: _speciesController,
          validator: (v) => Validators.required(v, 'Введите вид'),
          fieldKey: 'species',
        ),
        FormFieldSpec(
          label: 'Порода',
          controller: _breedController,
          validator: (v) => Validators.required(v, 'Введите породу'),
          fieldKey: 'breed',
        ),
      ],
    );
  }
}
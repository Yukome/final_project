import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../models/owner.dart';
import '../repositories/pet_repository.dart';
import '../repositories/owner_repository.dart';
import '../widgets/entity_form.dart';
import '../core/validators.dart';

class PetFormScreen extends StatefulWidget {
  final String? id;
  const PetFormScreen({super.key, this.id});

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  String? _selectedOwnerId;

  List<Owner> _owners = [];
  bool _isLoading = true;
  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final ownerRepo = context.read<OwnerRepository>();
    final petRepo = context.read<PetRepository>();
    final ownersResult = await ownerRepo.findAll(size: 1000);
    if (!mounted) return;
    setState(() => _owners = ownersResult.items);

    if (isEditing) {
      final petsResult = await petRepo.findAll(size: 1000);
      final pet = petsResult.items.where((p) => p.id == widget.id).firstOrNull;
      if (pet != null && mounted) {
        _nameController.text = pet.name;
        _speciesController.text = pet.species;
        _breedController.text = pet.breed;
        _selectedOwnerId = pet.ownerId;
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedOwnerId == null) throw Exception('Выберите владельца');
    final repo = context.read<PetRepository>();
    
    final pet = Pet(
      id: widget.id ?? '',
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      breed: _breedController.text.trim(),
      ownerId: _selectedOwnerId!,
    );
    
    if (isEditing) {
      await repo.update(widget.id!, pet.toJson());
    } else {
      await repo.create(pet);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return EntityForm(
      title: isEditing ? 'Редактирование питомца' : 'Новый питомец',
      isEditing: isEditing,
      backPath: '/pets',
      onSubmit: _submit,
      fields: [
        FormFieldSpec(label: 'Кличка', controller: _nameController, validator: (v) => Validators.required(v, 'Введите кличку'), fieldKey: 'name'),
        FormFieldSpec(label: 'Вид (Собака/Кошка)', controller: _speciesController, validator: (v) => Validators.required(v, 'Введите вид'), fieldKey: 'species'),
        FormFieldSpec(label: 'Порода', controller: _breedController, validator: (v) => Validators.required(v, 'Введите породу'), fieldKey: 'breed'),
      ],
      customContent: DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Владелец', border: OutlineInputBorder()),
        value: _selectedOwnerId,
        items: _owners.map((o) => DropdownMenuItem(value: o.id, child: Text(o.fullName))).toList(),
        onChanged: (val) => setState(() => _selectedOwnerId = val),
        validator: (v) => v == null ? 'Выберите владельца' : null,
      ),
    );
  }
}
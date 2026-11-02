import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../repositories/service_repository.dart';
import '../widgets/entity_form.dart';
import '../core/validators.dart';

class ServiceFormScreen extends StatefulWidget {
  final String? id;
  const ServiceFormScreen({super.key, this.id});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = true;
  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadService();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadService() async {
    final repo = context.read<ServiceRepository>();
    final result = await repo.findAll(size: 1000);
    final service = result.items.where((s) => s.id == widget.id).firstOrNull;
    if (service != null && mounted) {
      _nameController.text = service.name;
      _priceController.text = service.price.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = context.read<ServiceRepository>();
    final service = Service(
      id: widget.id ?? '',
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
    );
    
    if (isEditing) {
      await repo.update(widget.id!, service.toJson());
    } else {
      await repo.create(service);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return EntityForm(
      title: isEditing ? 'Редактирование услуги' : 'Новая услуга',
      isEditing: isEditing,
      backPath: '/services',
      onSubmit: _submit,
      fields: [
        FormFieldSpec(label: 'Название', controller: _nameController, validator: (v) => Validators.length(v, 2, 100), fieldKey: 'name'),
        FormFieldSpec(label: 'Цена', controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => Validators.number(v, min: 0.1), fieldKey: 'price'),
      ],
    );
  }
}
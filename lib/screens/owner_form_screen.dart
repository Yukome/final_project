import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/owner.dart';
import '../repositories/owner_repository.dart';
import '../widgets/entity_form.dart';
import '../core/validators.dart';

class OwnerFormScreen extends StatefulWidget {
  final String? id;
  const OwnerFormScreen({super.key, this.id});

  @override
  State<OwnerFormScreen> createState() => _OwnerFormScreenState();
}

class _OwnerFormScreenState extends State<OwnerFormScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = true;
  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadData();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadData() async {
    final repo = context.read<OwnerRepository>();
    final result = await repo.findAll(size: 1000); 
    final owner = result.items.where((o) => o.id == widget.id).firstOrNull;
    
    if (owner != null && mounted) {
      _nameController.text = owner.fullName;
      _phoneController.text = owner.phone;
      _emailController.text = owner.email;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = context.read<OwnerRepository>();
    final owner = Owner(
      id: widget.id ?? '',
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
    );
    
    if (isEditing) {
      await repo.update(widget.id!, owner.toJson());
    } else {
      await repo.create(owner);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return EntityForm(
      title: isEditing ? 'Редактирование владельца' : 'Новый владелец',
      isEditing: isEditing,
      backPath: '/owners',
      onSubmit: _submit,
      fields: [
        FormFieldSpec(label: 'ФИО', controller: _nameController, validator: (v) => Validators.length(v, 3, 100), fieldKey: 'fullName'),
        FormFieldSpec(label: 'Телефон', controller: _phoneController, keyboardType: TextInputType.phone, validator: Validators.phone, fieldKey: 'phone'),
        FormFieldSpec(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress, validator: Validators.email, fieldKey: 'email'),
      ],
    );
  }
}
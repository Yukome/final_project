import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/pet_list_notifier.dart';
import '../state/auth_notifier.dart';
import '../core/load_status.dart';
import '../widgets/entity_table.dart';
import '../models/pet.dart';
import '../core/router.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});
  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerId = context.read<AuthNotifier>().user?.ownerId;
      final notifier = context.read<PetListNotifier>();
      
      if (ownerId != null) {
        notifier.setOwnerId(ownerId);
      } else {
        notifier.load();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    final ownerId = context.read<AuthNotifier>().user?.ownerId;
    if (ownerId != null) {
      context.read<PetListNotifier>().setOwnerId(ownerId);
    } else {
      context.read<PetListNotifier>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PetListNotifier>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        title: const Text('Мои питомцы'),
      ),
      body: switch (notifier.status) {
        LoadStatus.idle || LoadStatus.loading => const Center(child: CircularProgressIndicator()),
        LoadStatus.error => Center(child: Text(notifier.error ?? 'Ошибка')),
        LoadStatus.success when notifier.result.items.isEmpty => const Center(child: Text('У вас пока нет питомцев')),
        LoadStatus.success => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: EntityTable<Pet>(
              items: notifier.result.items,
              idOf: (p) => p.id,
              isAdmin: false,
              isDeleted: (p) => p.isDeleted,
              columns: [
                TableColumnSpec(label: 'Кличка', build: (p) => Text(p.name)),
                TableColumnSpec(label: 'Вид', build: (p) => Text(p.species)),
                TableColumnSpec(label: 'Порода', build: (p) => Text(p.breed)),
              ],
            ),
          ),
        ),
      },
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.go('/my-pets/new'),
      ),
    );
  }
}
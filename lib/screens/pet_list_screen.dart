import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/pet_list_notifier.dart';
import '../state/auth_notifier.dart';
import '../models/app_user.dart';
import '../core/load_status.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../models/pet.dart';
import '../core/router.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> with RouteAware {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final uri = GoRouterState.of(context).uri;
      final q = uri.queryParameters;

      if (q.isNotEmpty) {
        final currentQuery = context.read<PetListNotifier>();
        if (q['search'] != null) currentQuery.setSearch(q['search']!);
        if (q['page'] != null) currentQuery.setPage(int.tryParse(q['page']!) ?? 1);
        if (q['size'] != null) currentQuery.setSize(int.tryParse(q['size']!) ?? 10);
        if (q['sortField'] != null) currentQuery.setSort(q['sortField']!, q['sortAscending'] != 'false');
        if (q['includeDeleted'] != null) currentQuery.setIncludeDeleted(q['includeDeleted'] == 'true');
      } else {
        context.read<PetListNotifier>().load();
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
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<PetListNotifier>().load();
  }

  void _updateQueryUrl() {
    final notifier = context.read<PetListNotifier>();
    final uri = GoRouterState.of(context).uri;
    final newParams = <String, String>{};

    if (notifier.search.isNotEmpty) newParams['search'] = notifier.search;
    if (notifier.sortField != 'name') newParams['sortField'] = notifier.sortField;
    if (!notifier.sortAscending) newParams['sortAscending'] = 'false';
    if (notifier.page != 1) newParams['page'] = notifier.page.toString();
    if (notifier.size != 10) newParams['size'] = notifier.size.toString();
    if (notifier.includeDeleted) newParams['includeDeleted'] = 'true';

    context.go(uri.replace(queryParameters: newParams).toString());
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<PetListNotifier>().setSearch(value);
      _updateQueryUrl();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PetListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final isAdmin = auth.has(Role.admin);
    final canEdit = auth.has(Role.doctor);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSidePagination = screenWidth >= 600 && screenWidth < 1280;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), tooltip: 'На главную', onPressed: () => context.go('/')),
        title: const Text('Питомцы'),
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Поиск по кличке или породе', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), isDense: true),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: notifier.sortField,
                          items: const [
                            DropdownMenuItem(value: 'name', child: Text('По кличке')),
                            DropdownMenuItem(value: 'species', child: Text('По виду')),
                            DropdownMenuItem(value: 'breed', child: Text('По породе')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              notifier.setSort(val, notifier.sortAscending);
                              _updateQueryUrl();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(notifier.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                          onPressed: () {
                            notifier.setSort(notifier.sortField, !notifier.sortAscending);
                            _updateQueryUrl();
                          },
                        ),
                      ],
                    ),
                    if (isAdmin)
                      Row(
                        children: [
                          Checkbox(
                            value: notifier.includeDeleted,
                            onChanged: (val) {
                              notifier.setIncludeDeleted(val ?? false);
                              _updateQueryUrl();
                            },
                          ),
                          const Text('Показать удалённые'),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: switch (notifier.status) {
                          LoadStatus.idle || LoadStatus.loading => const Center(child: CircularProgressIndicator()),
                          LoadStatus.error => Center(child: Text(notifier.error ?? 'Ошибка')),
                          LoadStatus.success when notifier.result.items.isEmpty => const Center(child: Text('Список пуст')),
                          LoadStatus.success => EntityTable<Pet>(
                              items: notifier.result.items,
                              idOf: (p) => p.id,
                              isAdmin: isAdmin,
                              isDeleted: (p) => p.isDeleted,
                              columns: [
                                TableColumnSpec(label: 'Кличка', build: (p) => Text(p.name)),
                                TableColumnSpec(label: 'Вид', build: (p) => Text(p.species)),
                                TableColumnSpec(label: 'Порода', build: (p) => Text(p.breed)),
                              ],
                              actions: (p) => [
                                if (!p.isDeleted && canEdit)
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), tooltip: 'Редактировать', onPressed: () => context.go('/pets/${p.id}/edit')),
                                if (!p.isDeleted)
                                  if (isAdmin)
                                    PopupMenuButton<String>(
                                      tooltip: 'Действия',
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) async {
                                        if (value == 'soft') {await notifier.softDelete(p.id);}
                                        else if (value == 'hard') {_confirmHardDelete(context, notifier, p.id);}
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'soft', child: Text('В корзину (логически)')),
                                        const PopupMenuItem(value: 'hard', child: Text('Удалить навсегда', style: TextStyle(color: Colors.red))),
                                      ],
                                    )
                                  else
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'В корзину', onPressed: () => notifier.softDelete(p.id)),
                                if (p.isDeleted && isAdmin)
                                  IconButton(icon: const Icon(Icons.restore, color: Colors.green), tooltip: 'Восстановить', onPressed: () => notifier.restore(p.id)),
                                if (p.isDeleted && isAdmin)
                                  IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), tooltip: 'Удалить навсегда', onPressed: () => _confirmHardDelete(context, notifier, p.id)),
                              ],
                            ),
                        },
                      ),
                      if (!isSidePagination)
                        PaginationBar(
                          currentPage: notifier.page,
                          totalPages: notifier.result.totalPages,
                          totalItems: notifier.result.total,
                          pageSize: notifier.size,
                          hasPrevious: notifier.result.hasPrevious,
                          hasNext: notifier.result.hasNext,
                          onPageChanged: (p) { notifier.setPage(p); _updateQueryUrl(); },
                          onSizeChanged: (s) { notifier.setSize(s); _updateQueryUrl(); },
                        ),
                    ],
                  ),
                ),
                if (isSidePagination)
                  SizedBox(
                    width: 80,
                    child: PaginationBar(
                      currentPage: notifier.page,
                      totalPages: notifier.result.totalPages,
                      totalItems: notifier.result.total,
                      pageSize: notifier.size,
                      hasPrevious: notifier.result.hasPrevious,
                      hasNext: notifier.result.hasNext,
                      onPageChanged: (p) { notifier.setPage(p); _updateQueryUrl(); },
                      onSizeChanged: (s) { notifier.setSize(s); _updateQueryUrl(); },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => context.go('/pets/new'),
        ),
      ),
    );
  }

  void _confirmHardDelete(BuildContext context, PetListNotifier notifier, String id) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Удалить навсегда?'),
        content: const Text('Восстановить будет невозможно.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Отмена')),
          FilledButton(onPressed: () { Navigator.pop(c); notifier.hardDelete(id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Удалить')),
        ],
      ),
    );
  }
}
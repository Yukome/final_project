import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/service_list_notifier.dart';
import '../state/auth_notifier.dart';
import '../models/app_user.dart';
import '../core/load_status.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../models/service.dart';
import '../core/router.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});
  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> with RouteAware {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final q = GoRouterState.of(context).uri.queryParameters;
      if (q.isNotEmpty) {
        final notifier = context.read<ServiceListNotifier>();
        if (q['search'] != null) notifier.setSearch(q['search']!);
        if (q['page'] != null) notifier.setPage(int.tryParse(q['page']!) ?? 1);
        if (q['size'] != null) notifier.setSize(int.tryParse(q['size']!) ?? 10);
        if (q['sortField'] != null) notifier.setSort(q['sortField']!, q['sortAscending'] != 'false');
        if (q['includeDeleted'] != null) notifier.setIncludeDeleted(q['includeDeleted'] == 'true');
      } else {
        context.read<ServiceListNotifier>().load();
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
    context.read<ServiceListNotifier>().load();
  }

  void _updateQueryUrl() {
    final notifier = context.read<ServiceListNotifier>();
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
      context.read<ServiceListNotifier>().setSearch(value);
      _updateQueryUrl();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ServiceListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final isAdmin = auth.has(Role.admin);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSidePagination = screenWidth >= 600 && screenWidth < 1280;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), tooltip: 'На главную', onPressed: () => context.go('/')),
        title: const Text('Услуги'),
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
                            decoration: const InputDecoration(labelText: 'Поиск по названию', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), isDense: true),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: notifier.sortField,
                          items: const [
                            DropdownMenuItem(value: 'name', child: Text('По названию')),
                            DropdownMenuItem(value: 'price', child: Text('По цене')),
                          ],
                          onChanged: (val) { if (val != null) { notifier.setSort(val, notifier.sortAscending); _updateQueryUrl(); } },
                        ),
                        IconButton(icon: Icon(notifier.sortAscending ? Icons.arrow_upward : Icons.arrow_downward), onPressed: () { notifier.setSort(notifier.sortField, !notifier.sortAscending); _updateQueryUrl(); }),
                      ],
                    ),
                    if (isAdmin)
                      Row(
                        children: [
                          Checkbox(value: notifier.includeDeleted, onChanged: (val) { notifier.setIncludeDeleted(val ?? false); _updateQueryUrl(); }),
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
                          LoadStatus.success => EntityTable<Service>(
                              items: notifier.result.items,
                              idOf: (s) => s.id,
                              isAdmin: isAdmin,
                              isDeleted: (s) => s.isDeleted,
                              columns: [
                                TableColumnSpec(label: 'Название', build: (s) => Text(s.name)),
                                TableColumnSpec(label: 'Цена', build: (s) => Text('${s.price} руб.')),
                              ],
                              actions: (s) => [
                                if (!s.isDeleted && isAdmin)
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), tooltip: 'Редактировать', onPressed: () => context.go('/services/${s.id}/edit')),
                                if (!s.isDeleted && isAdmin)
                                  PopupMenuButton<String>(
                                    tooltip: 'Действия',
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) async {
                                      if (value == 'soft') {await notifier.softDelete(s.id);}
                                      else if (value == 'hard') {_confirmHardDelete(context, notifier, s.id);}
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'soft', child: Text('В корзину (логически)')),
                                      const PopupMenuItem(value: 'hard', child: Text('Удалить навсегда', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                if (s.isDeleted && isAdmin)
                                  IconButton(icon: const Icon(Icons.restore, color: Colors.green), tooltip: 'Восстановить', onPressed: () => notifier.restore(s.id)),
                                if (s.isDeleted && isAdmin)
                                  IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), tooltip: 'Удалить навсегда', onPressed: () => _confirmHardDelete(context, notifier, s.id)),
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
      floatingActionButton: isAdmin ? Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(child: const Icon(Icons.add), onPressed: () => context.go('/services/new')),
      ) : null,
    );
  }

  void _confirmHardDelete(BuildContext context, ServiceListNotifier notifier, String id) {
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Удалить навсегда?'), content: const Text('Восстановить будет невозможно.'), actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Отмена')),
      FilledButton(onPressed: () { Navigator.pop(c); notifier.hardDelete(id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Удалить')),
    ]));
  }
}
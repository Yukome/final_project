import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/doctor_list_notifier.dart';
import '../state/auth_notifier.dart';
import '../models/app_user.dart';
import '../core/load_status.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../models/doctor.dart';
import '../core/router.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});
  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> with RouteAware {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final q = GoRouterState.of(context).uri.queryParameters;
      if (q.isNotEmpty) {
        final notifier = context.read<DoctorListNotifier>();
        if (q['search'] != null) notifier.setSearch(q['search']!);
        if (q['page'] != null) notifier.setPage(int.tryParse(q['page']!) ?? 1);
        if (q['size'] != null) notifier.setSize(int.tryParse(q['size']!) ?? 10);
        if (q['sortField'] != null) notifier.setSort(q['sortField']!, q['sortAscending'] != 'false');
        if (q['includeDeleted'] != null) notifier.setIncludeDeleted(q['includeDeleted'] == 'true');
      } else {
        context.read<DoctorListNotifier>().load();
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
    context.read<DoctorListNotifier>().load();
  }

  void _updateQueryUrl() {
    final notifier = context.read<DoctorListNotifier>();
    final uri = GoRouterState.of(context).uri;
    final newParams = <String, String>{};
    if (notifier.search.isNotEmpty) newParams['search'] = notifier.search;
    if (notifier.sortField != 'fullName') newParams['sortField'] = notifier.sortField;
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
      context.read<DoctorListNotifier>().setSearch(value);
      _updateQueryUrl();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DoctorListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final isAdmin = auth.has(Role.admin);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSidePagination = screenWidth >= 600 && screenWidth < 1280;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), tooltip: 'На главную', onPressed: () => context.go('/')),
        title: const Text('Врачи'),
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
                            decoration: const InputDecoration(labelText: 'Поиск по ФИО или специализации', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), isDense: true),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: notifier.sortField,
                          items: const [
                            DropdownMenuItem(value: 'fullName', child: Text('По ФИО')),
                            DropdownMenuItem(value: 'specialization', child: Text('По специализации')),
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
                          LoadStatus.success => EntityTable<Doctor>(
                              items: notifier.result.items,
                              idOf: (d) => d.id,
                              isAdmin: isAdmin,
                              isDeleted: (d) => d.isDeleted,
                              columns: [
                                TableColumnSpec(label: 'ФИО', build: (d) => Text(d.fullName)),
                                TableColumnSpec(label: 'Специализация', build: (d) => Text(d.specialization)),
                              ],
                              actions: (d) => [
                                if (!d.isDeleted && isAdmin)
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), tooltip: 'Редактировать', onPressed: () => context.go('/doctors/${d.id}/edit')),
                                if (!d.isDeleted && isAdmin)
                                  PopupMenuButton<String>(
                                    tooltip: 'Действия',
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) async {
                                      if (value == 'soft') {await notifier.softDelete(d.id);}
                                      else if (value == 'hard') {_confirmHardDelete(context, notifier, d.id);}
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'soft', child: Text('В корзину (логически)')),
                                      const PopupMenuItem(value: 'hard', child: Text('Удалить навсегда', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                if (d.isDeleted && isAdmin)
                                  IconButton(icon: const Icon(Icons.restore, color: Colors.green), tooltip: 'Восстановить', onPressed: () => notifier.restore(d.id)),
                                if (d.isDeleted && isAdmin)
                                  IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), tooltip: 'Удалить навсегда', onPressed: () => _confirmHardDelete(context, notifier, d.id)),
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
        child: FloatingActionButton(child: const Icon(Icons.add), onPressed: () => context.go('/doctors/new')),
      ) : null,
    );
  }

  void _confirmHardDelete(BuildContext context, DoctorListNotifier notifier, String id) {
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Удалить навсегда?'), content: const Text('Восстановить будет невозможно.'), actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Отмена')),
      FilledButton(onPressed: () { Navigator.pop(c); notifier.hardDelete(id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Удалить')),
    ]));
  }
}
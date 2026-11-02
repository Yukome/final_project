import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final String Function(T item) idOf;
  final Set<String> selected;
  final List<Widget> Function(T item)? actions;
  final bool isAdmin;
  final bool Function(T item)? isDeleted;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.actions,
    this.isAdmin = false,
    this.isDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return _buildCards(context, crossAxisCount: 1);
    if (width < 1280) return _buildCards(context, crossAxisCount: 2);
    return _buildTable(context);
  }

  Widget _buildTable(BuildContext context) {
    Widget buildCellWrapper(Widget child, {bool deleted = false}) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 150, maxWidth: 300),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 14,
              color: deleted ? Colors.grey : Colors.black,
              decoration: deleted ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            child: child,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: DataTable(
            columnSpacing: 30,
            horizontalMargin: 24,
            dataRowMinHeight: 44,
            dataRowMaxHeight: 52,
            headingRowHeight: 44,
            columns: [
              ...columns.map(
                (col) => DataColumn(
                  label: buildCellWrapper(
                    Text(
                      col.label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              if (actions != null && items.isNotEmpty && actions!(items.first).isNotEmpty)
                DataColumn(label: buildCellWrapper(const Text('Действия', style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
            rows: items.map((item) {
              final deleted = isDeleted?.call(item) ?? false;
              return DataRow(
                selected: selected.contains(idOf(item)),
                cells: [
                  ...columns.map((col) => DataCell(buildCellWrapper(col.build(item), deleted: deleted))),
                  if (actions != null)
                    DataCell(buildCellWrapper(Row(mainAxisSize: MainAxisSize.min, children: actions!(item)))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context, {required int crossAxisCount}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 12;
        final double totalWidth = constraints.maxWidth;
        final double cardWidth = crossAxisCount == 1 ? totalWidth - 32 : (totalWidth - 32 - spacing) / 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: items.map((item) {
              return SizedBox(
                width: cardWidth,
                child: _buildCard(context, item),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, T item) {
    final deleted = isDeleted?.call(item) ?? false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: deleted ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16, 
                color: deleted ? Colors.grey : Colors.black,
                decoration: deleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              child: columns.first.build(item),
            ),
            const Divider(height: 16),
            ...columns.skip(1).map(
              (col) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text('${col.label}:', style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 13, 
                          color: deleted ? Colors.grey : Colors.black,
                          decoration: deleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        child: col.build(item),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (actions != null)
              Align(
                alignment: Alignment.centerRight,
                child: Row(mainAxisSize: MainAxisSize.min, children: actions!(item)),
              ),
          ],
        ),
      ),
    );
  }
}
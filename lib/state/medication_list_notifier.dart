import 'package:flutter/foundation.dart';
import '../models/medication.dart';
import '../repositories/medication_repository.dart';
import '../core/load_status.dart';
import '../widgets/page_result.dart';

class MedicationListNotifier extends ChangeNotifier {
  final MedicationRepository _repository;
  MedicationListNotifier(this._repository);

  LoadStatus _status = LoadStatus.idle;
  String? _error;
  String _search = '';
  bool _includeDeleted = false;
  String _sortField = 'name';
  bool _sortAscending = true;
  int _page = 1;
  int _size = 10;
  PageResult<Medication> _result = PageResult.empty();

  LoadStatus get status => _status;
  String? get error => _error;
  String get search => _search;
  bool get includeDeleted => _includeDeleted;
  String get sortField => _sortField;
  bool get sortAscending => _sortAscending;
  int get page => _page;
  int get size => _size;
  PageResult<Medication> get result => _result;
  List<Medication> get items => _result.items;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.findAll(
        search: _search, includeDeleted: _includeDeleted,
        sortField: _sortField, sortAscending: _sortAscending,
        page: _page, size: _size,
      );
      _status = LoadStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void setSearch(String value) { _search = value; _page = 1; load(); }
  void setIncludeDeleted(bool value) { _includeDeleted = value; _page = 1; load(); }
  void setSort(String field, bool ascending) { _sortField = field; _sortAscending = ascending; load(); }
  void setPage(int page) { _page = page; load(); }
  void setSize(int size) { _size = size; _page = 1; load(); }

  Future<void> softDelete(String id) async { await _repository.update(id, {'deletedAt': DateTime.now().toIso8601String()}); await load(); }
  Future<void> restore(String id) async { await _repository.update(id, {'deletedAt': null}); await load(); }
  Future<void> hardDelete(String id) async { await _repository.delete(id); await load(); }
}
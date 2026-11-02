import 'package:dio/dio.dart';
import '../models/medication.dart';
import '../widgets/page_result.dart';

abstract interface class MedicationRepository {
  Future<PageResult<Medication>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'name', bool sortAscending = true});
  Future<Medication> create(Medication medication);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class ApiMedicationRepository implements MedicationRepository {
  final Dio _dio;
  ApiMedicationRepository(this._dio);

  @override
  Future<PageResult<Medication>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'name', bool sortAscending = true}) async {
    String filter = '';
    if (search != null && search.trim().isNotEmpty) {
      filter += '(name ~ "${search.trim()}" || dosage ~ "${search.trim()}")';
    }
    if (!includeDeleted) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += '(deletedAt = null || deletedAt = "")';
    }

    final sortParam = '${sortAscending ? "" : "-"}$sortField';

    final response = await _dio.get('/api/collections/medications/records', queryParameters: {
      if (filter.isNotEmpty) 'filter': filter,
      'sort': sortParam,
      'page': page,
      'perPage': size,
    });
    
    final data = response.data as Map<String, dynamic>;
    return PageResult(
      items: (data['items'] as List).map((json) => Medication.fromJson(json)).toList(),
      page: data['page'] as int? ?? 1,
      size: data['perPage'] as int? ?? size,
      total: data['totalItems'] as int? ?? 0,
    );
  }

  @override
  Future<Medication> create(Medication medication) async {
    final response = await _dio.post('/api/collections/medications/records', data: medication.toJson());
    return Medication.fromJson(response.data);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch('/api/collections/medications/records/$id', data: data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/api/collections/medications/records/$id');
  }
}
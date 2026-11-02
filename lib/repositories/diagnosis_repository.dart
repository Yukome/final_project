import 'package:dio/dio.dart';
import '../models/diagnosis.dart';
import '../widgets/page_result.dart';

abstract interface class DiagnosisRepository {
  Future<PageResult<Diagnosis>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'name', bool sortAscending = true});
  Future<Diagnosis> create(Diagnosis diagnosis);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class ApiDiagnosisRepository implements DiagnosisRepository {
  final Dio _dio;
  ApiDiagnosisRepository(this._dio);

  @override
  Future<PageResult<Diagnosis>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'name', bool sortAscending = true}) async {
    String filter = '';
    if (search != null && search.trim().isNotEmpty) {
      filter += '(name ~ "${search.trim()}" || description ~ "${search.trim()}")';
    }
    if (!includeDeleted) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += '(deletedAt = null || deletedAt = "")';
    }

    final sortParam = '${sortAscending ? "" : "-"}$sortField';

    final response = await _dio.get('/api/collections/diagnoses/records', queryParameters: {
      if (filter.isNotEmpty) 'filter': filter,
      'sort': sortParam,
      'page': page,
      'perPage': size,
    });
    
    final data = response.data as Map<String, dynamic>;
    return PageResult(
      items: (data['items'] as List).map((json) => Diagnosis.fromJson(json)).toList(),
      page: data['page'] as int? ?? 1,
      size: data['perPage'] as int? ?? size,
      total: data['totalItems'] as int? ?? 0,
    );
  }

  @override
  Future<Diagnosis> create(Diagnosis diagnosis) async {
    final response = await _dio.post('/api/collections/diagnoses/records', data: diagnosis.toJson());
    return Diagnosis.fromJson(response.data);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch('/api/collections/diagnoses/records/$id', data: data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/api/collections/diagnoses/records/$id');
  }
}
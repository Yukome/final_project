import 'package:dio/dio.dart';
import '../models/medical_record.dart';
import '../widgets/page_result.dart';

abstract interface class MedicalRecordRepository {
  Future<PageResult<MedicalRecord>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'date', bool sortAscending = false});
  Future<MedicalRecord> create(MedicalRecord record);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class ApiMedicalRecordRepository implements MedicalRecordRepository {
  final Dio _dio;
  ApiMedicalRecordRepository(this._dio);

  @override
  Future<PageResult<MedicalRecord>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'date', bool sortAscending = false}) async {
    String filter = '';
    if (search != null && search.trim().isNotEmpty) {
      filter += '(notes ~ "${search.trim()}")';
    }
    if (!includeDeleted) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += '(deletedAt = null || deletedAt = "")';
    }

    final sortParam = '${sortAscending ? "" : "-"}$sortField';

    final response = await _dio.get('/api/collections/medical_records/records', queryParameters: {
      if (filter.isNotEmpty) 'filter': filter,
      'sort': sortParam,
      'page': page,
      'perPage': size,
      'expand': 'pet',
    });
    
    final data = response.data as Map<String, dynamic>;
    return PageResult(
      items: (data['items'] as List).map((json) => MedicalRecord.fromJson(json)).toList(),
      page: data['page'] as int? ?? 1,
      size: data['perPage'] as int? ?? size,
      total: data['totalItems'] as int? ?? 0,
    );
  }

  @override
  Future<MedicalRecord> create(MedicalRecord record) async {
    final response = await _dio.post('/api/collections/medical_records/records', data: record.toJson());
    return MedicalRecord.fromJson(response.data);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch('/api/collections/medical_records/records/$id', data: data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/api/collections/medical_records/records/$id');
  }
}
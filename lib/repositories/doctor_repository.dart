import 'package:dio/dio.dart';
import '../models/doctor.dart';
import '../widgets/page_result.dart';

abstract interface class DoctorRepository {
  Future<PageResult<Doctor>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'fullName', bool sortAscending = true});
  Future<Doctor> create(Doctor doctor);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class ApiDoctorRepository implements DoctorRepository {
  final Dio _dio;
  ApiDoctorRepository(this._dio);

  @override
  Future<PageResult<Doctor>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'fullName', bool sortAscending = true}) async {
    String filter = '';
    if (search != null && search.trim().isNotEmpty) {
      filter += '(fullName ~ "${search.trim()}" || specialization ~ "${search.trim()}")';
    }
    if (!includeDeleted) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += '(deletedAt = null || deletedAt = "")';
    }

    final sortParam = '${sortAscending ? "" : "-"}$sortField';

    final response = await _dio.get('/api/collections/doctors/records', queryParameters: {
      if (filter.isNotEmpty) 'filter': filter,
      'sort': sortParam,
      'page': page,
      'perPage': size,
    });
    
    final data = response.data as Map<String, dynamic>;
    return PageResult(
      items: (data['items'] as List).map((json) => Doctor.fromJson(json)).toList(),
      page: data['page'] as int? ?? 1,
      size: data['perPage'] as int? ?? size,
      total: data['totalItems'] as int? ?? 0,
    );
  }

  @override
  Future<Doctor> create(Doctor doctor) async {
    final response = await _dio.post('/api/collections/doctors/records', data: doctor.toJson());
    return Doctor.fromJson(response.data);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch('/api/collections/doctors/records/$id', data: data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/api/collections/doctors/records/$id');
  }
}
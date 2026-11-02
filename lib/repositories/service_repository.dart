import 'package:dio/dio.dart';
import '../models/service.dart';
import '../widgets/page_result.dart';

abstract interface class ServiceRepository {
  Future<PageResult<Service>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'name', bool sortAscending = true});
  Future<Service> create(Service service);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class ApiServiceRepository implements ServiceRepository {
  final Dio _dio;
  ApiServiceRepository(this._dio);

  @override
  Future<PageResult<Service>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'name', bool sortAscending = true}) async {
    String filter = '';
    
    if (search != null && search.trim().isNotEmpty) {
      final cleanSearch = search.trim().replaceAll('"', '');
      filter += '(name ~ "$cleanSearch")';
    }
    
    if (!includeDeleted) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += '(deletedAt = null || deletedAt = "")';
    }

    final sortParam = '${sortAscending ? "" : "-"}$sortField';

    final response = await _dio.get('/api/collections/services/records', queryParameters: {
      if (filter.isNotEmpty) 'filter': filter,
      'sort': sortParam,
      'page': page,
      'perPage': size,
    });
    
    final data = response.data as Map<String, dynamic>;
    return PageResult(
      items: (data['items'] as List).map((json) => Service.fromJson(json)).toList(),
      page: data['page'] as int? ?? 1,
      size: data['perPage'] as int? ?? size,
      total: data['totalItems'] as int? ?? 0,
    );
  }

  @override
  Future<Service> create(Service service) async {
    final response = await _dio.post('/api/collections/services/records', data: service.toJson());
    return Service.fromJson(response.data);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch('/api/collections/services/records/$id', data: data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/api/collections/services/records/$id');
  }
}
import 'package:dio/dio.dart';
import '../models/owner.dart';
import '../widgets/page_result.dart';

abstract interface class OwnerRepository {
  Future<PageResult<Owner>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'fullName', bool sortAscending = true});
  Future<Owner> create(Owner owner);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class ApiOwnerRepository implements OwnerRepository {
  final Dio _dio;
  ApiOwnerRepository(this._dio);

  @override
  Future<PageResult<Owner>> findAll({String? search, bool includeDeleted = false, int page = 1, int size = 10, String sortField = 'fullName', bool sortAscending = true}) async {
    String filter = '';
    if (search != null && search.trim().isNotEmpty) {
      filter += '(fullName ~ "${search.trim()}" || phone ~ "${search.trim()}")';
    }
    if (!includeDeleted) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += '(deletedAt = null || deletedAt = "")';
    }

    final sortParam = '${sortAscending ? "" : "-"}$sortField';

    final response = await _dio.get('/api/collections/owners/records', queryParameters: {
      if (filter.isNotEmpty) 'filter': filter,
      'sort': sortParam,
      'page': page,
      'perPage': size,
    });
    
    final data = response.data as Map<String, dynamic>;
    return PageResult(
      items: (data['items'] as List).map((json) => Owner.fromJson(json)).toList(),
      page: data['page'] as int? ?? 1,
      size: data['perPage'] as int? ?? size,
      total: data['totalItems'] as int? ?? 0,
    );
  }

  @override
  Future<Owner> create(Owner owner) async {
    final response = await _dio.post('/api/collections/owners/records', data: owner.toJson());
    return Owner.fromJson(response.data);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch('/api/collections/owners/records/$id', data: data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/api/collections/owners/records/$id');
  }
}
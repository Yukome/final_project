import 'package:dio/dio.dart';
import '../models/pet.dart';
import '../widgets/page_result.dart';

abstract interface class PetRepository {
  Future<PageResult<Pet>> findAll({
    String? search, 
    bool includeDeleted = false, 
    int page = 1, 
    int size = 10, 
    String sortField = 'name', 
    bool sortAscending = true,
    String? ownerId,
  });
  Future<Pet> create(Pet pet);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class ApiPetRepository implements PetRepository {
  final Dio _dio;
  ApiPetRepository(this._dio);

  @override
  Future<PageResult<Pet>> findAll({
    String? search, 
    bool includeDeleted = false, 
    int page = 1, 
    int size = 10, 
    String sortField = 'name', 
    bool sortAscending = true,
    String? ownerId,
  }) async {
    String filter = '';
    
    if (search != null && search.trim().isNotEmpty) {
      filter += '(name ~ "${search.trim()}")';
    }
    
    if (ownerId != null) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += 'owner = "$ownerId"';
    }

    if (!includeDeleted) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += '(deletedAt = null || deletedAt = "")'; 
    }

    final sortParam = '${sortAscending ? "" : "-"}$sortField';

    final response = await _dio.get('/api/collections/pets/records', queryParameters: {
      if (filter.isNotEmpty) 'filter': filter,
      'sort': sortParam,
      'page': page,
      'perPage': size,
    });
    
    final data = response.data as Map<String, dynamic>;
    return PageResult(
      items: (data['items'] as List).map((json) => Pet.fromJson(json)).toList(),
      page: data['page'] as int? ?? 1,
      size: data['perPage'] as int? ?? size,
      total: data['totalItems'] as int? ?? 0,
    );
  }

  @override
  Future<Pet> create(Pet pet) async {
    final response = await _dio.post('/api/collections/pets/records', data: pet.toJson());
    return Pet.fromJson(response.data);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch('/api/collections/pets/records/$id', data: data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/api/collections/pets/records/$id');
  }
}
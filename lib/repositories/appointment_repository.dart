import 'package:dio/dio.dart';
import '../models/appointment.dart';
import '../widgets/page_result.dart';

abstract interface class AppointmentRepository {
  Future<PageResult<Appointment>> findAll({
    String? search, 
    bool includeDeleted = false, 
    int page = 1, 
    int size = 10, 
    String sortField = 'date', 
    bool sortAscending = false,
    String? ownerId,
    String? doctorId,
  });
  Future<Appointment> create(Appointment appointment);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class ApiAppointmentRepository implements AppointmentRepository {
  final Dio _dio;
  ApiAppointmentRepository(this._dio);

  @override
  Future<PageResult<Appointment>> findAll({
    String? search, 
    bool includeDeleted = false, 
    int page = 1, 
    int size = 10, 
    String sortField = 'date', 
    bool sortAscending = false,
    String? ownerId,
    String? doctorId,
  }) async {
    String filter = '';
    
    if (search != null && search.trim().isNotEmpty) {
      filter += '(status ~ "${search.trim()}")';
    }

    if (ownerId != null) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += 'pet.owner = "$ownerId"';
    }
    
    if (doctorId != null) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += 'doctor = "$doctorId"';
    }

    if (!includeDeleted) {
      if (filter.isNotEmpty) filter += ' && ';
      filter += '(deletedAt = null || deletedAt = "")';
    }

    final sortParam = '${sortAscending ? "" : "-"}$sortField';

    final response = await _dio.get('/api/collections/appointments/records', queryParameters: {
      if (filter.isNotEmpty) 'filter': filter,
      'sort': sortParam,
      'page': page,
      'perPage': size,
      'expand': 'pet,doctor',
    });
    
    final data = response.data as Map<String, dynamic>;
    return PageResult(
      items: (data['items'] as List).map((json) => Appointment.fromJson(json)).toList(),
      page: data['page'] as int? ?? 1,
      size: data['perPage'] as int? ?? size,
      total: data['totalItems'] as int? ?? 0,
    );
  }

  @override
  Future<Appointment> create(Appointment appointment) async {
    final response = await _dio.post('/api/collections/appointments/records', data: appointment.toJson());
    return Appointment.fromJson(response.data);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch('/api/collections/appointments/records/$id', data: data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/api/collections/appointments/records/$id');
  }
}
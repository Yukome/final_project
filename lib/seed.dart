import 'package:dio/dio.dart';

Future<void> main() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8090'));
  final authRes = await dio.post('/api/collections/users/auth-with-password', data: {
    'identity': 'admin@vet.com',
    'password': 'admin123',
  });
  final token = authRes.data['token'];
  dio.options.headers['Authorization'] = token;

  final ownerIds = <String>[];
  for (var i = 1; i <= 30; i++) {
    final res = await dio.post('/api/collections/owners/records', data: {
      'fullName': 'Владелец Тестовый $i',
      'phone': '+7 900 000-00-${i.toString().padLeft(2, '0')}',
      'email': 'owner$i@test.ru',
    });
    ownerIds.add(res.data['id']);
  }

  final petIds = <String>[];
  for (var i = 0; i < 30; i++) {
    final res = await dio.post('/api/collections/pets/records', data: {
      'name': 'Питомец ${i + 1}',
      'species': i % 2 == 0 ? 'Собака' : 'Кошка',
      'breed': 'Порода ${i + 1}',
      'owner': ownerIds[i],
    });
    petIds.add(res.data['id']);
  }

  final doctorIds = <String>[];
  for (var i = 1; i <= 10; i++) {
    final res = await dio.post('/api/collections/doctors/records', data: {
      'fullName': 'Врач Номер $i',
      'specialization': i % 2 == 0 ? 'Хирург' : 'Терапевт',
    });
    doctorIds.add(res.data['id']);
  }

  for (var i = 1; i <= 10; i++) {
    await dio.post('/api/collections/services/records', data: {
      'name': 'Услуга $i',
      'price': 500 + (i * 100),
    });
  }

  for (var i = 0; i < 30; i++) {
    await dio.post('/api/collections/appointments/records', data: {
      'date': DateTime.now().add(Duration(days: i)).toIso8601String(),
      'status': i % 3 == 0 ? 'completed' : 'waiting',
      'pet': petIds[i],
      'doctor': doctorIds[i % 10],
    });
  }

  for (var i = 1; i <= 10; i++) {
    await dio.post('/api/collections/diagnoses/records', data: {
      'name': 'Диагноз $i',
      'description': 'Описание диагноза $i',
    });
  }

  for (var i = 1; i <= 10; i++) {
    await dio.post('/api/collections/medications/records', data: {
      'name': 'Лекарство $i',
      'dosage': '${i * 10} мг',
    });
  }
}
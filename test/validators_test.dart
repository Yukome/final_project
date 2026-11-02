import 'package:flutter_test/flutter_test.dart';
import 'package:final_proj/core/validators.dart';
import 'package:final_proj/models/pet.dart';

void main() {
  group('Валидаторы (Validators)', () {
    test('Проверка обязательного поля', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required('   '), isNotNull);
      expect(Validators.required('Текст'), isNull);
    });

    test('Проверка длины строки', () {
      expect(Validators.length('a', 2, 10), isNotNull);
      expect(Validators.length('abcdefghijk', 2, 10), isNotNull);
      expect(Validators.length('Норма', 2, 10), isNull);
    });

    test('Проверка телефона', () {
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('+7 900 123-45-67'), isNull);
    });

    test('Проверка Email', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('test@mail.ru'), isNull);
    });
  });

  group('Разбор моделей', () {
    test('Pet.fromJson корректно разбирает данные', () {
      final json = {
        'id': '1',
        'name': 'Барсик',
        'species': 'Кошка',
        'breed': 'Британская',
        'owner': 'owner123',
      };
      final pet = Pet.fromJson(json);
      expect(pet.id, '1');
      expect(pet.name, 'Барсик');
      expect(pet.ownerId, 'owner123');
    });

    test('Pet.fromJson не падает при отсутствии полей', () {
      final json = {'id': '2'};
      final pet = Pet.fromJson(json);
      expect(pet.name, '');
      expect(pet.ownerId, '');
    });
  });
}
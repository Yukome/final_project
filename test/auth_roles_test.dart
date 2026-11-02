import 'package:flutter_test/flutter_test.dart';
import 'package:final_proj/models/app_user.dart';

void main() {
  group('Логика разграничения прав (Role)', () {
    test('Читатель (владелец) не имеет прав врача и админа', () {
      expect(Role.owner.level >= Role.owner.level, isTrue);
      expect(Role.owner.level >= Role.doctor.level, isFalse);
      expect(Role.owner.level >= Role.admin.level, isFalse);
    });

    test('Врач имеет права врача, но не админа', () {
      expect(Role.doctor.level >= Role.owner.level, isTrue);
      expect(Role.doctor.level >= Role.doctor.level, isTrue);
      expect(Role.doctor.level >= Role.admin.level, isFalse);
    });

    test('Админ имеет права всех ролей', () {
      expect(Role.admin.level >= Role.owner.level, isTrue);
      expect(Role.admin.level >= Role.doctor.level, isTrue);
      expect(Role.admin.level >= Role.admin.level, isTrue);
    });

    test('Проверка иерархии ролей', () {
      expect(Role.owner.level, 1);
      expect(Role.doctor.level, 2);
      expect(Role.admin.level, 3);
    });
  });
}
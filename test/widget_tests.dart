import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:final_proj/models/app_user.dart';
import 'package:final_proj/state/auth_notifier.dart';
import 'package:final_proj/screens/login_screen.dart';
import 'package:final_proj/screens/dashboard_screen.dart';

class FakeAuthNotifier extends AuthNotifier {
  AppUser? _mockUser;
  FakeAuthNotifier(this._mockUser) : super(null as dynamic, null as dynamic);

  @override
  AppUser? get user => _mockUser;
  @override
  bool get isAuthenticated => _mockUser != null;
  @override
  bool has(Role role) => _mockUser != null && _mockUser!.role.level >= role.level;
}

void main() {
  testWidgets('Экран входа содержит поля и кнопку', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => FakeAuthNotifier(null),
          child: const LoginScreen(),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Войти'), findsOneWidget);
  });

  testWidgets('Владелец не видит кнопку "Управление врачами"', (tester) async {
    final user = AppUser(id: '1', email: 'test@test.com', name: 'Test', role: Role.owner);
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => FakeAuthNotifier(user),
          child: const DashboardScreen(),
        ),
      ),
    );

    expect(find.text('Мои питомцы'), findsOneWidget);
    expect(find.text('Управление врачами'), findsNothing);
    expect(find.text('Статистика'), findsNothing);
  });

  testWidgets('Админ видит кнопку "Статистика"', (tester) async {
    final user = AppUser(id: '1', email: 'test@test.com', name: 'Test', role: Role.admin);
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => FakeAuthNotifier(user),
          child: const DashboardScreen(),
        ),
      ),
    );

    expect(find.text('Статистика'), findsOneWidget);
    expect(find.text('Управление врачами'), findsOneWidget);
  });

  testWidgets('Врач видит "Моё расписание"', (tester) async {
    final user = AppUser(id: '1', email: 'test@test.com', name: 'Test', role: Role.doctor);
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => FakeAuthNotifier(user),
          child: const DashboardScreen(),
        ),
      ),
    );

    expect(find.text('Моё расписание'), findsOneWidget);
    expect(find.text('Статистика'), findsNothing);
  });

  testWidgets('Вход не выполняется с пустыми полями', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => FakeAuthNotifier(null),
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Войти'));
    await tester.pump();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
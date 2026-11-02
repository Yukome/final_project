import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_notifier.dart';
import '../models/app_user.dart';

import '../screens/register_screen.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/owner_list_screen.dart';
import '../screens/pet_list_screen.dart';
import '../screens/doctor_list_screen.dart';
import '../screens/service_list_screen.dart';
import '../screens/appointment_list_screen.dart';
import '../screens/diagnosis_list_screen.dart';
import '../screens/medication_list_screen.dart';
import '../screens/medical_record_list_screen.dart';
import '../screens/owner_form_screen.dart';
import '../screens/pet_form_screen.dart';
import '../screens/doctor_form_screen.dart';
import '../screens/service_form_screen.dart';
import '../screens/appointment_form_screen.dart';
import '../screens/diagnosis_form_screen.dart';
import '../screens/medication_form_screen.dart';
import '../screens/medical_record_form_screen.dart';
import '../screens/my_appointments_screen.dart';
import '../screens/my_pets_screen.dart';
import '../screens/services_catalog_screen.dart';
import '../screens/admin_stats_screen.dart';
import '../screens/doctor_schedule_screen.dart';
import '../screens/add_my_pet_screen.dart';
import '../screens/admin_users_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Доступ запрещён')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('У вас нет прав для просмотра этой страницы', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    );
  }
}

GoRouter buildRouter(AuthNotifier auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: auth,
    observers: [routeObserver],
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final path = state.matchedLocation;
      if (!loggedIn && !isLoggingIn) return '/login';
      if (loggedIn && isLoggingIn) return '/';
      if (loggedIn) {
        if ((path.startsWith('/doctors') || (path.startsWith('/services') && path != '/services-catalog')) && !auth.has(Role.admin)) {
          return '/forbidden';
        }
        if ((path.startsWith('/owners') || path.startsWith('/diagnoses') || 
             path.startsWith('/medications') || path.startsWith('/medical_records')) 
            && !auth.has(Role.doctor)) {
          return '/forbidden';
        }
      }
      if (path.startsWith('/pets') || path.startsWith('/appointments')) {
        if (auth.user?.role == Role.owner) {
          return '/'; 
        }
      }
      if (path.startsWith('/doctor-schedule') && auth.user?.role != Role.doctor) {
        return '/forbidden';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/forbidden', builder: (context, state) => const ForbiddenScreen()),
      GoRoute(path: '/my-pets', builder: (context, state) => const MyPetsScreen()),
      GoRoute(path: '/my-appointments', builder: (context, state) => const MyAppointmentsScreen()),
      GoRoute(path: '/services-catalog', builder: (context, state) => const ServicesCatalogScreen()),
      GoRoute(path: '/admin/stats', builder: (context, state) => const AdminStatsScreen()),
      GoRoute(path: '/doctor-schedule', builder: (context, state) => const DoctorScheduleScreen()),
      GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen()),
      GoRoute(
        path: '/my-pets',
        builder: (context, state) => const MyPetsScreen(),
        routes: [
          GoRoute(path: 'new', builder: (context, state) => const AddMyPetScreen()),
        ],
      ),

      GoRoute(path: '/owners', builder: (context, state) => const OwnerListScreen(), routes: [
        GoRoute(path: 'new', builder: (context, state) => const OwnerFormScreen()),
        GoRoute(path: ':id/edit', builder: (context, state) => OwnerFormScreen(id: state.pathParameters['id'])),
      ]),
      GoRoute(path: '/pets', builder: (context, state) => const PetListScreen(), routes: [
        GoRoute(path: 'new', builder: (context, state) => const PetFormScreen()),
        GoRoute(path: ':id/edit', builder: (context, state) => PetFormScreen(id: state.pathParameters['id'])),
      ]),
      GoRoute(path: '/doctors', builder: (context, state) => const DoctorListScreen(), routes: [
        GoRoute(path: 'new', builder: (context, state) => const DoctorFormScreen()),
        GoRoute(path: ':id/edit', builder: (context, state) => DoctorFormScreen(id: state.pathParameters['id'])),
      ]),
      GoRoute(path: '/services', builder: (context, state) => const ServiceListScreen(), routes: [
        GoRoute(path: 'new', builder: (context, state) => const ServiceFormScreen()),
        GoRoute(path: ':id/edit', builder: (context, state) => ServiceFormScreen(id: state.pathParameters['id'])),
      ]),
      GoRoute(path: '/appointments', builder: (context, state) => const AppointmentListScreen(), routes: [
        GoRoute(path: 'new', builder: (context, state) => const AppointmentFormScreen()),
        GoRoute(path: ':id/edit', builder: (context, state) => AppointmentFormScreen(id: state.pathParameters['id'])),
      ]),
      GoRoute(path: '/diagnoses', builder: (context, state) => const DiagnosisListScreen(), routes: [
        GoRoute(path: 'new', builder: (context, state) => const DiagnosisFormScreen()),
        GoRoute(path: ':id/edit', builder: (context, state) => DiagnosisFormScreen(id: state.pathParameters['id'])),
      ]),
      GoRoute(path: '/medications', builder: (context, state) => const MedicationListScreen(), routes: [
        GoRoute(path: 'new', builder: (context, state) => const MedicationFormScreen()),
        GoRoute(path: ':id/edit', builder: (context, state) => MedicationFormScreen(id: state.pathParameters['id'])),
      ]),
      GoRoute(path: '/medical_records', builder: (context, state) => const MedicalRecordListScreen(), routes: [
        GoRoute(path: 'new', builder: (context, state) => const MedicalRecordFormScreen()),
        GoRoute(path: ':id/edit', builder: (context, state) => MedicalRecordFormScreen(id: state.pathParameters['id'])),
      ]),
    ],
  );
}
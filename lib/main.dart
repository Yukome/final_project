import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'core/api_client.dart';
import 'core/router.dart';
import 'state/auth_notifier.dart';
import 'widgets/inactivity_watcher.dart';

import 'repositories/owner_repository.dart';
import 'repositories/pet_repository.dart';
import 'repositories/doctor_repository.dart';
import 'repositories/service_repository.dart';
import 'repositories/appointment_repository.dart';
import 'repositories/diagnosis_repository.dart';
import 'repositories/medication_repository.dart';
import 'repositories/medical_record_repository.dart';

import 'state/owner_list_notifier.dart';
import 'state/pet_list_notifier.dart';
import 'state/doctor_list_notifier.dart';
import 'state/service_list_notifier.dart';
import 'state/appointment_list_notifier.dart';
import 'state/diagnosis_list_notifier.dart';
import 'state/medication_list_notifier.dart';
import 'state/medical_record_list_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();
  final dio = buildDio();
  final authNotifier = AuthNotifier(dio, prefs);
  await authNotifier.restore();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: dio),
        ChangeNotifierProvider.value(value: authNotifier),

        Provider<OwnerRepository>(create: (c) => ApiOwnerRepository(c.read<Dio>())),
        Provider<PetRepository>(create: (c) => ApiPetRepository(c.read<Dio>())),
        Provider<DoctorRepository>(create: (c) => ApiDoctorRepository(c.read<Dio>())),
        Provider<ServiceRepository>(create: (c) => ApiServiceRepository(c.read<Dio>())),
        Provider<AppointmentRepository>(create: (c) => ApiAppointmentRepository(c.read<Dio>())),
        Provider<DiagnosisRepository>(create: (c) => ApiDiagnosisRepository(c.read<Dio>())),
        Provider<MedicationRepository>(create: (c) => ApiMedicationRepository(c.read<Dio>())),
        Provider<MedicalRecordRepository>(create: (c) => ApiMedicalRecordRepository(c.read<Dio>())),

        ChangeNotifierProvider(create: (c) => OwnerListNotifier(c.read<OwnerRepository>())),
        ChangeNotifierProvider(create: (c) => PetListNotifier(c.read<PetRepository>())),
        ChangeNotifierProvider(create: (c) => DoctorListNotifier(c.read<DoctorRepository>())),
        ChangeNotifierProvider(create: (c) => ServiceListNotifier(c.read<ServiceRepository>())),
        ChangeNotifierProvider(create: (c) => AppointmentListNotifier(c.read<AppointmentRepository>())),
        ChangeNotifierProvider(create: (c) => DiagnosisListNotifier(c.read<DiagnosisRepository>())),
        ChangeNotifierProvider(create: (c) => MedicationListNotifier(c.read<MedicationRepository>())),
        ChangeNotifierProvider(create: (c) => MedicalRecordListNotifier(c.read<MedicalRecordRepository>())),
      ],
      child: const VetApp(),
    ),
  );
}

class VetApp extends StatelessWidget {
  const VetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    
    return MaterialApp.router(
      title: 'Ветеринарная клиника',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: buildRouter(auth),
      builder: (context, child) {
        if (!auth.isAuthenticated) return child!;
        return InactivityWatcher(
          timeout: const Duration(minutes: 3),
          warningTime: const Duration(seconds: 30),
          onTimeout: () async => context.read<AuthNotifier>().logout(),
          child: child!,
        );
      },
    );
  }
}
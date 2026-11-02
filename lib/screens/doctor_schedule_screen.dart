import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/appointment_list_notifier.dart';
import '../state/auth_notifier.dart';
import '../core/load_status.dart';
import '../widgets/entity_table.dart';
import '../models/appointment.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});
  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorId = context.read<AuthNotifier>().user?.doctorId;
      if (doctorId != null) {
        context.read<AppointmentListNotifier>().setDoctorId(doctorId);
      } else {
        context.read<AppointmentListNotifier>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AppointmentListNotifier>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        title: const Text('Моё расписание'),
      ),
      body: switch (notifier.status) {
        LoadStatus.idle || LoadStatus.loading => const Center(child: CircularProgressIndicator()),
        LoadStatus.error => Center(child: Text(notifier.error ?? 'Ошибка')),
        LoadStatus.success when notifier.result.items.isEmpty => const Center(child: Text('У вас пока нет записей')),
        LoadStatus.success => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: EntityTable<Appointment>(
              items: notifier.result.items,
              idOf: (a) => a.id,
              isAdmin: false,
              isDeleted: (a) => a.isDeleted,
              columns: [
                TableColumnSpec(label: 'Дата', build: (a) => Text(a.date.toLocal().toString().split(' ')[0])),
                TableColumnSpec(label: 'Пациент', build: (a) => Text(a.petName)),
                TableColumnSpec(label: 'Статус', build: (a) => Text(a.status)),
              ],
            ),
          ),
        ),
      },
    );
  }
}
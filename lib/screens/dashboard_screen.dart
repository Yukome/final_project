import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../state/auth_notifier.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ветеринарная клиника'),
        actions: [
          if (MediaQuery.sizeOf(context).width > 600)
            Center(child: Text('${user?.name ?? "Гость"}', style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await context.read<AuthNotifier>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GridView.count(
            padding: const EdgeInsets.all(24),
            crossAxisCount: MediaQuery.sizeOf(context).width > 800 ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3.5,
            children: [
              if (user?.role == Role.owner) ...[
                _buildCard(context, 'Мои питомцы', Icons.pets, '/my-pets'),
                _buildCard(context, 'Мои записи', Icons.calendar_today, '/my-appointments'),
                _buildCard(context, 'Каталог услуг', Icons.medical_services, '/services-catalog'),
              ],

              if (user?.role == Role.doctor) ...[
                _buildCard(context, 'Моё расписание', Icons.schedule, '/doctor-schedule'),
                _buildCard(context, 'Все питомцы', Icons.pets, '/pets'),
                _buildCard(context, 'Владельцы', Icons.people, '/owners'),
                _buildCard(context, 'Мед. карты', Icons.folder_shared, '/medical_records'),
                _buildCard(context, 'Диагнозы', Icons.sick, '/diagnoses'),
                _buildCard(context, 'Лекарства', Icons.medication, '/medications'),
              ],

              if (user?.role == Role.admin) ...[
                _buildCard(context, 'Пользователи', Icons.manage_accounts, '/admin/users'),
                _buildCard(context, 'Статистика', Icons.analytics, '/admin/stats'),
                _buildCard(context, 'Врачи', Icons.medical_services, '/doctors'),
                _buildCard(context, 'Услуги', Icons.list_alt, '/services'),
                _buildCard(context, 'Все питомцы', Icons.pets, '/pets'),
                _buildCard(context, 'Записи на приём', Icons.calendar_today, '/appointments'),
                _buildCard(context, 'Владельцы', Icons.people, '/owners'),
                _buildCard(context, 'Мед. карты', Icons.folder_shared, '/medical_records'),
                _buildCard(context, 'Диагнозы', Icons.sick, '/diagnoses'),
                _buildCard(context, 'Лекарства', Icons.medication, '/medications'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
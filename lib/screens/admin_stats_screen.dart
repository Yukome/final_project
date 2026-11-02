import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});
  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  bool _isLoading = true;
  int _ownersCount = 0;
  int _petsCount = 0;
  int _appointmentsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final dio = context.read<Dio>();
      final results = await Future.wait([
        dio.get('/api/collections/owners/records?perPage=1'),
        dio.get('/api/collections/pets/records?perPage=1'),
        dio.get('/api/collections/appointments/records?perPage=1'),
      ]);
      if (mounted) {
        setState(() {
          _ownersCount = results[0].data['totalItems'] ?? 0;
          _petsCount = results[1].data['totalItems'] ?? 0;
          _appointmentsCount = results[2].data['totalItems'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        title: const Text('Статистика клиники'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: GridView.count(
                  padding: const EdgeInsets.all(24),
                  crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.0,
                  children: [
                    _buildStatCard('Всего владельцев', _ownersCount, Icons.people, Colors.blue),
                    _buildStatCard('Всего питомцев', _petsCount, Icons.pets, Colors.green),
                    _buildStatCard('Всего записей', _appointmentsCount, Icons.calendar_today, Colors.orange),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text('$count', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
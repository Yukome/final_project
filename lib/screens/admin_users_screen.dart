import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../models/app_user.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final dio = context.read<Dio>();
      final res = await dio.get('/api/collections/users/records', queryParameters: {
        'perPage': 100,
        'sort': 'email',
      });
      final items = (res.data['items'] as List).map((json) => AppUser.fromJson(json)).toList();
      
      if (mounted) {
        setState(() {
          _users = items;
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
        title: const Text('Пользователи системы'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, i) {
                    final u = _users[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(u.role).withOpacity(0.1),
                          child: Icon(Icons.person, color: _getRoleColor(u.role)),
                        ),
                        title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${u.email} | Роль: ${_getRoleText(u.role)}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRoleColor(u.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getRoleText(u.role),
                            style: TextStyle(color: _getRoleColor(u.role), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  String _getRoleText(Role role) {
    switch (role) {
      case Role.admin: return 'Администратор';
      case Role.doctor: return 'Врач';
      case Role.owner: return 'Владелец';
    }
  }

  Color _getRoleColor(Role role) {
    switch (role) {
      case Role.admin: return Colors.red;
      case Role.doctor: return Colors.teal;
      case Role.owner: return Colors.blue;
    }
  }
}
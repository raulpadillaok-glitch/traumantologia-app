import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/db_service.dart';
import '../services/theme_service.dart';
import '../widgets/glass_container.dart';
import 'admin_exercises_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      users = DBService.getUsers();
    });
  }

  void _toggleRole(User user) async {
    final newRole = user.role == 'admin' ? 'user' : 'admin';
    final updatedUser = User(
      id: user.id,
      name: user.name,
      email: user.email,
      password: user.password,
      role: newRole,
    );
    await DBService.updateUser(updatedUser);
    _loadUsers();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rol de ${user.name} actualizado a $newRole')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final u = users[index];
            final isAdmin = u.role == 'admin';

            return GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isAdmin ? Colors.blueAccent : Colors.greenAccent,
                    child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                        Text(u.email, style: TextStyle(color: Colors.grey[400])),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.blueAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAdmin ? 'ADMINISTRADOR' : 'USUARIO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAdmin ? Colors.blueAccent : Colors.greenAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'role') {
                        _toggleRole(u);
                      } else if (value == 'exercises') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminExercisesScreen(targetUser: u),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'exercises',
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center, color: Colors.greenAccent, size: 20),
                            const SizedBox(width: 8),
                            const Text('Editar Ejercicios'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'role',
                        child: Row(
                          children: [
                            Icon(isAdmin ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text(isAdmin ? 'Quitar Admin' : 'Hacer Admin'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

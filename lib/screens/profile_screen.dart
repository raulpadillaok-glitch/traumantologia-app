import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    final user = authService.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  Future<void> _saveProfile() async {
    if (_passwordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }

    await authService.updateUser(_nameController.text.trim(), _passwordController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado exitosamente', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
    _passwordController.clear();
    _confirmPasswordController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.greenAccent),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Nueva Contraseña (Opcional)',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nueva Contraseña',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Text('Apariencia del Sistema', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ThemeButton(themeName: 'Oscuro', color: Colors.black87),
                _ThemeButton(themeName: 'Claro', color: Colors.white),
                _ThemeButton(themeName: 'Océano', color: Colors.teal[900]!),
                _ThemeButton(themeName: 'Bosque', color: Colors.green[900]!),
                _ThemeButton(themeName: 'Fuego', color: Colors.red[900]!),
                _ThemeButton(themeName: 'Lavanda', color: Colors.purple[900]!),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String themeName;
  final Color color;

  const _ThemeButton({required this.themeName, required this.color});

  @override
  Widget build(BuildContext context) {
    final isSelected = themeService.currentThemeName == themeName;
    return InkWell(
      onTap: () {
        // Al seleccionar, se actualiza en el ThemeService Y se guarda en el usuario
        authService.updateUser('', '', themeName: themeName);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: isSelected ? Colors.greenAccent : Colors.grey, width: isSelected ? 3 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          themeName,
          style: TextStyle(
            color: themeName == 'Claro' ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

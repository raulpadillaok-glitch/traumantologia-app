import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/user.dart';
import '../services/db_service.dart';

class AdminExercisesScreen extends StatefulWidget {
  final User targetUser;
  const AdminExercisesScreen({super.key, required this.targetUser});

  @override
  State<AdminExercisesScreen> createState() => _AdminExercisesScreenState();
}

class _AdminExercisesScreenState extends State<AdminExercisesScreen> {
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() {
      _exercises = DBService.getExercisesByUser(widget.targetUser.id);
    });
  }

  void _showEditDialog(Exercise? exercise) {
    final isEditing = exercise != null;
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final descController = TextEditingController(text: exercise?.description ?? '');
    final videoController = TextEditingController(text: exercise?.videoUrl ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Ejercicio' : 'Nuevo Ejercicio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
                const SizedBox(height: 8),
                TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripción')),
                const SizedBox(height: 8),
                TextField(controller: videoController, decoration: const InputDecoration(labelText: 'URL del Video (.mp4 o YouTube)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final newEx = Exercise(
                  id: isEditing ? exercise.id : '${widget.targetUser.id}_${DateTime.now().millisecondsSinceEpoch}',
                  userId: widget.targetUser.id,
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  videoUrl: videoController.text.trim(),
                );
                
                if (isEditing) {
                  await DBService.updateExercise(newEx);
                } else {
                  await DBService.addExercise(newEx);
                }
                
                if (mounted) Navigator.pop(context);
                _loadExercises();
              },
              child: const Text('Guardar'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejercicios de ${widget.targetUser.name}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(null),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          final ex = _exercises[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(ex.videoUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditDialog(ex),
              ),
            ),
          );
        },
      ),
    );
  }
}

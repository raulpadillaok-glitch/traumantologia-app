import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/theme_service.dart';
import '../widgets/glass_container.dart';
import 'exercise_detail_screen.dart';
import '../services/auth_service.dart';
import '../models/exercise.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Exercise> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndSeedIfNeeded();
  }

  Future<void> _loadAndSeedIfNeeded() async {
    final user = authService.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    var userExercises = DBService.getExercisesByUser(user.id);
    
    // Si es un usuario antiguo y no tiene ejercicios, generamos su paquete base
    if (userExercises.isEmpty) {
      await DBService.seedExercisesForUser(user.id);
      userExercises = DBService.getExercisesByUser(user.id);
    }

    setState(() {
      exercises = userExercises;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Catálogo Clínico', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exercises.isEmpty
              ? const Center(child: Text('No hay ejercicios disponibles.', style: TextStyle(color: Colors.white)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: exercises.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Hero(
                      tag: 'exercise_${exercise.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (_, __, ___) => ExerciseDetailScreen(exercise: exercise),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.fitness_center, size: 40, color: Colors.greenAccent),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        exercise.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.greenAccent, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

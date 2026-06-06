import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../models/user.dart';

class DBService {
  static const String exercisesBoxName = 'exercisesBox';
  static const String sessionsBoxName = 'sessionsBox';
  static const String usersBoxName = 'usersBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(exercisesBoxName);
    await Hive.openBox(sessionsBoxName);
    await Hive.openBox(usersBoxName);

    // Solo sembrar para el usuario de prueba si está vacío
    if (Hive.box(sessionsBoxName).isEmpty) {
      await _seedSessions();
    }
    
    // Check if admin has exercises, if not seed for admin
    if (getExercisesByUser('admin@test.com').isEmpty) {
      await seedExercisesForUser('admin@test.com');
    }
  }

  static Future<void> seedExercisesForUser(String userId) async {
    final box = Hive.box(exercisesBoxName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final defaultExercises = [
      Exercise(
        id: '${userId}_1_$timestamp',
        userId: userId,
        name: 'Flexión Plantar (Fase 1)',
        description: 'Sentado con la pierna estirada, empuja la punta del pie hacia abajo como si presionaras un pedal. Mantén 3 segundos y regresa lentamente. Ideal para recuperar movilidad temprana tras un esguince.',
        videoUrl: 'assets/videos/ej.1.mp4', 
      ),
      Exercise(
        id: '${userId}_2_$timestamp',
        userId: userId,
        name: 'Dorsiflexión con Banda (Fase 2)',
        description: 'Con una banda elástica de resistencia leve anclada frente a ti, jala la punta del pie hacia tu cuerpo contra la resistencia. Fortalece los músculos tibiales anteriores.',
        videoUrl: 'assets/videos/ej.2.mp4', 
      ),
      Exercise(
        id: '${userId}_3_$timestamp',
        userId: userId,
        name: 'Eversión Isométrica',
        description: 'Empuja el borde externo del pie contra una pared o superficie fija sin mover la articulación. Contracción de 5 segundos. Estabiliza los ligamentos laterales afectados.',
        videoUrl: 'assets/videos/ej.3.mp4', 
      ),
      Exercise(
        id: '${userId}_4_$timestamp',
        userId: userId,
        name: 'Propiocepción (Equilibrio a 1 pie)',
        description: 'Párate únicamente sobre el tobillo lesionado, manteniendo la rodilla ligeramente flexionada. Intenta mantener el equilibrio por 30 segundos para recuperar la estabilidad neuromuscular.',
        videoUrl: 'assets/videos/ej.4.mp4', 
      ),
      Exercise(
        id: '${userId}_5_$timestamp',
        userId: userId,
        name: 'Inversión con Banda Elástica',
        description: 'Sentado, con una banda anclada lateralmente hacia afuera, mueve el pie hacia adentro venciendo la resistencia. Fortalece los tendones mediales del tobillo.',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', 
      ),
    ];

    for (var ex in defaultExercises) {
      await box.put(ex.id, ex.toJson());
    }
  }

  static Future<void> _seedSessions() async {
    final box = Hive.box(sessionsBoxName);
    final now = DateTime.now();
    final double startAngle = 15.0; 
    
    for (int i = 0; i < 14; i++) {
      final sessionDate = now.subtract(Duration(days: 14 - i));
      final currentAngle = startAngle + (i * 2.5) + (i % 3 == 0 ? -1.0 : 1.5);
      
      final dummySession = Session(
        id: 'dummy_$i',
        userId: 'test_user',
        exerciseId: 'test_user_1_dummy', 
        date: sessionDate,
        maxAngle: currentAngle > 45.0 ? 45.0 : currentAngle,
        anglesHistory: [startAngle, currentAngle], // dummy history
      );
      
      await box.put(dummySession.id, dummySession.toJson());
    }
  }

  // Users Management
  static List<User> getUsers() {
    final box = Hive.box(usersBoxName);
    return box.values.map((e) => User.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> updateUser(User user) async {
    final box = Hive.box(usersBoxName);
    await box.put(user.id, user.toJson());
  }

  // Exercises Management
  static List<Exercise> getExercisesByUser(String userId) {
    final box = Hive.box(exercisesBoxName);
    final allExercises = box.values.map((e) => Exercise.fromJson(Map<String, dynamic>.from(e))).toList();
    return allExercises.where((e) => e.userId == userId).toList();
  }

  static Future<void> addExercise(Exercise exercise) async {
    final box = Hive.box(exercisesBoxName);
    await box.put(exercise.id, exercise.toJson());
  }

  static Future<void> updateExercise(Exercise exercise) async {
    final box = Hive.box(exercisesBoxName);
    await box.put(exercise.id, exercise.toJson());
  }

  // Sessions Management
  static List<Session> getSessionsByUser(String userId) {
    final box = Hive.box(sessionsBoxName);
    final allSessions = box.values.map((e) => Session.fromJson(Map<String, dynamic>.from(e))).toList();
    return allSessions.where((s) => s.userId == userId).toList();
  }

  static Future<void> saveSession(Session session) async {
    final box = Hive.box(sessionsBoxName);
    await box.put(session.id, session.toJson());
  }

  static Future<void> deleteSession(String sessionId) async {
    final box = Hive.box(sessionsBoxName);
    await box.delete(sessionId);
  }
}

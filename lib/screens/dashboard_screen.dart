import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/theme_service.dart';
import '../widgets/glass_container.dart';
import 'admin_users_screen.dart';
import 'catalog_screen.dart';
import 'chatbot_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'admin_exercises_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final sessions = user != null ? DBService.getSessionsByUser(user.id) : <Session>[];
    final totalSessions = sessions.length;
    final maxAngleEver = sessions.isEmpty ? 0 : sessions.map((s) => s.maxAngle).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Colors.transparent, // Uses global gradient
      appBar: AppBar(
        title: Text('Hola, ${user?.name ?? 'Usuario'}', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (user?.role == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.blueAccent),
              tooltip: 'Panel de Administrador',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
              },
            ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())).then((_) {
                setState(() {});
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Elevar el botón para que no sea tapado
        child: FloatingActionButton(
          backgroundColor: Colors.greenAccent,
          elevation: 10,
          child: const Icon(Icons.support_agent, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()));
          },
        ),
      ),
      body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Sesiones Totales',
                        value: totalSessions.toString(),
                        icon: Icons.fitness_center,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Ángulo Máx',
                        value: '${maxAngleEver.toStringAsFixed(3)}°',
                        icon: Icons.show_chart,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Curva de Recuperación',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: GlassContainer(
                    child: sessions.isEmpty 
                      ? const Center(child: Text('Aún no hay datos de sesiones.', style: TextStyle(color: Colors.grey)))
                      : Padding(
                          padding: const EdgeInsets.only(right: 18, top: 24, bottom: 12),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 45,
                                    getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(3)}°', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                  ),
                                ),
                              ),
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) => LineTooltipItem(
                                      '${spot.y.toStringAsFixed(3)}°\nSesión ${spot.x.toInt() + 1}',
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    )).toList();
                                  },
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: sessions.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.maxAngle)).toList(),
                                  isCurved: true,
                                  color: Colors.greenAccent,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.greenAccent.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Historial de Sesiones (Base de Datos)',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                if (sessions.isEmpty)
                  const Center(child: Text('Aún no hay historial de sesiones.', style: TextStyle(color: Colors.grey)))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length.clamp(0, 10), // Mostramos las ultimas 10
                    itemBuilder: (context, index) {
                      final session = sessions[sessions.length - 1 - index]; // Orden descendente
                      final date = session.date;
                      final dateString = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            if (session.anglesHistory.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay historial de ángulos')));
                              return;
                            }
                            final exerciseList = DBService.getExercisesByUser(user!.id);
                            final targetExercise = exerciseList.firstWhere((e) => e.id == session.exerciseId, orElse: () => Exercise(id: '', name: 'Ejercicio Eliminado', description: '', videoUrl: '', userId: ''));
                            
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E2C),
                                  title: Text('${targetExercise.name} - Detalle', style: const TextStyle(color: Colors.white)),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    height: 300,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(show: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1)),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 45,
                                              getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(3)}°', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                            ),
                                          ),
                                        ),
                                        lineTouchData: LineTouchData(
                                          touchTooltipData: LineTouchTooltipData(
                                            getTooltipItems: (touchedSpots) {
                                              return touchedSpots.map((spot) => LineTooltipItem(
                                                '${spot.y.toStringAsFixed(3)}°\nT: ${(spot.x * 0.5).toStringAsFixed(1)}s',
                                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              )).toList();
                                            },
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: session.anglesHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                            isCurved: true,
                                            color: Colors.blueAccent,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(show: false),
                                            belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.2)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                                );
                              },
                            );
                          },
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.history, color: Colors.greenAccent),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            final exerciseList = DBService.getExercisesByUser(user!.id);
                                            final targetExercise = exerciseList.firstWhere((e) => e.id == session.exerciseId, orElse: () => Exercise(id: '', name: 'Ejercicio Eliminado', description: '', videoUrl: '', userId: ''));
                                            return Text('${targetExercise.name} - ${user!.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white));
                                          }
                                        ),
                                        const SizedBox(height: 4),
                                        Text(dateString, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${session.maxAngle.toStringAsFixed(3)}°',
                                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Eliminar Sesión'),
                                        content: const Text('¿Estás seguro de que deseas eliminar este historial?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await DBService.deleteSession(session.id);
                                      setState(() {}); // Reload
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      color: color.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../widgets/glass_container.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"sender": "bot", "text": "¡Hola! Soy PhysioBot, tu asistente de Inteligencia Artificial para rehabilitación. ¿En qué te puedo ayudar hoy?"}
  ];
  bool _isTyping = false;

  Future<String> _getAiResponse(String userInput) async {
    final lowerCaseText = userInput.toLowerCase();
    
    // 1. Detección de temas fuera de contexto (Rechazo)
    final outOfContextKeywords = [
      'política', 'politica', 'fútbol', 'futbol', 'receta', 'cocina', 'clima', 'película', 'pelicula',
      'programación', 'programacion', 'matemáticas', 'matematicas', 'historia', 'dinero', 'juego', 'musica', 'música'
    ];
    
    for (final word in outOfContextKeywords) {
      if (lowerCaseText.contains(word)) {
        await Future.delayed(const Duration(milliseconds: 800));
        return "Lo siento, soy PhysioBot, un asistente médico especializado. Solo puedo responder preguntas relacionadas con fisioterapia, rehabilitación de tobillo y ejercicios físicos. No puedo hablar sobre otros temas.";
      }
    }

    // 2. Palabras clave válidas
    final validKeywords = [
      'tobillo', 'pie', 'rehabilitación', 'rehabilitacion', 'fisioterapia', 'dolor', 
      'esguince', 'hueso', 'músculo', 'musculo', 'tendón', 'tendon', 'ejercicio', 
      'articulación', 'articulacion', 'movilidad', 'lesión', 'lesion', 'recuperación', 
      'recuperacion', 'inflamación', 'inflamacion', 'terapia', 'ligamento', 'gemelos', 
      'plantar', 'dorsiflexión', 'dorsiflexion', 'rutina', 'físico', 'fisico'
    ];
    
    bool isRelevant = false;
    for (final keyword in validKeywords) {
      if (lowerCaseText.contains(keyword)) {
        isRelevant = true;
        break;
      }
    }

    await Future.delayed(const Duration(milliseconds: 1200));

    // 3. Generar respuesta específica basada en el contexto médico
    if (isRelevant) {
      if (lowerCaseText.contains('dolor') || lowerCaseText.contains('inflamación') || lowerCaseText.contains('inflamacion') || lowerCaseText.contains('hinchado')) {
        return "Si presentas dolor o inflamación, te recomiendo aplicar hielo en la zona afectada durante 15-20 minutos, y elevar el pie por encima del nivel del corazón. Si el dolor es agudo al hacer los ejercicios, debes suspenderlos y consultar a un especialista de inmediato.";
      } else if (lowerCaseText.contains('ejercicio') || lowerCaseText.contains('rutina') || lowerCaseText.contains('dorsiflexión')) {
        return "Para mejorar la movilidad de tu tobillo, puedes realizar ejercicios de dorsiflexión y flexión plantar. Te sugiero hacer 3 series de 10 repeticiones diarias, usando una banda elástica suave. Recuerda hacer los movimientos lentos y controlados.";
      } else if (lowerCaseText.contains('esguince') || lowerCaseText.contains('ligamento') || lowerCaseText.contains('lesión')) {
        return "Tras un esguince, los ligamentos quedan inestables. En la primera fase necesitas reposo y hielo. En la fase de recuperación, es fundamental trabajar la propiocepción (como pararte en un solo pie) para recuperar el equilibrio y evitar futuras lesiones.";
      } else {
        return "Para tu rehabilitación de tobillo, la constancia es vital. Sigue tus sesiones en la aplicación para monitorear tu progreso articular. ¿Te gustaría saber más sobre un ejercicio específico?";
      }
    }

    // 4. Saludos generales
    if (lowerCaseText.contains('hola') || lowerCaseText.contains('saludos') || lowerCaseText.contains('ayuda')) {
      return "¡Hola! Soy PhysioBot, tu IA enfocada en fisioterapia. Estoy aquí para resolver tus dudas sobre la rehabilitación de tu tobillo. ¿En qué te puedo ayudar hoy?";
    }

    // 5. Si no contiene nada relacionado
    return "Como asistente virtual enfocado estrictamente en fisioterapia, necesito que me des más detalles sobre tu lesión, dolor o ejercicios de tobillo para poder orientarte correctamente.";
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final userText = _controller.text.trim();

    setState(() {
      _messages.add({"sender": "user", "text": userText});
      _isTyping = true;
    });
    
    _controller.clear();

    final responseText = await _getAiResponse(userText);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({"sender": "bot", "text": responseText});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('PhysioBot', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg["sender"] == "user";
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: GlassContainer(
                          color: isUser ? Colors.greenAccent.withOpacity(0.2) : Colors.white10,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            msg["text"]!,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("PhysioBot está escribiendo...", style: TextStyle(color: Colors.greenAccent, fontStyle: FontStyle.italic)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Escribe tu duda médica...",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

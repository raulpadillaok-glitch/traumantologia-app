# UNIVERSIDAD PRIVADA FRANZ TAMAYO
## CARRERA DE INGENIERÍA
### PROYECTO SEMESTRAL PROCESUAL

**Título:** PhysioVision: Sistema Móvil de Monitoreo Inteligente para Rehabilitación de Esguinces de Tobillo con Flutter  
**Materia:** Dispositivos Móviles  
**Docente:** Msc. Ing. Milton Cayo Blanco  
**Estudiante:** Jhordan Leonidas Illanes Suxo  
**Fecha:** 6 de junio de 2026  

---

## Índice General
1. Marco Introductorio
2. Marco Teórico
3. Marco Metodológico
4. Ingeniería del Proyecto
5. Arquitectura del Sistema
6. Implementación
7. Resultados Esperados
8. Conclusiones y Recomendaciones
   - Anexos

---

## 1. Marco Introductorio

### 1.1. Antecedentes
El esguince de tobillo constituye la lesión musculoesquelética aguda más frecuente en la práctica médica y deportiva a nivel global. En muchas regiones de topografía irregular (como La Paz, Bolivia), la incidencia de este traumatismo en la población civil es sumamente alta. A pesar de su cotidianidad, un porcentaje significativo de pacientes desarrolla **Inestabilidad Crónica de Tobillo (ICT)** debido a procesos de rehabilitación incompletos, mal ejecutados o abandonados prematuramente. 

Tradicionalmente, la fisioterapia requiere la presencia física del especialista para medir el rango de movimiento con un goniómetro manual. Sin embargo, las barreras socioeconómicas limitan la continuidad del tratamiento domiciliario.

### 1.2. Planteamiento del Problema
La desconexión terapéutica entre las sesiones presenciales y los ejercicios domiciliarios es el vector principal de las recaídas musculares. Cuando el paciente es instruido a realizar ejercicios en su domicilio, carece de retroalimentación en tiempo real. 
- ¿Cómo puede el paciente saber si está alcanzando el grado de flexión adecuado?
- ¿Cómo puede evitar movimientos compensatorios que dañen otros ligamentos?

**Problema Central:** La carencia de sistemas tecnológicos accesibles que permitan el monitoreo biométrico, la cuantificación del progreso y la corrección postural autónoma durante la rehabilitación domiciliaria de pacientes con esguinces de tobillo.

### 1.3. Justificación
- **Justificación Tecnológica (Edge AI):** A diferencia de sistemas tradicionales, PhysioVision procesa la inteligencia artificial directamente en el dispositivo móvil utilizando modelos cuantizados. Esto elimina la latencia de red, protege la privacidad y fluye a altos FPS.
- **Justificación Social:** Actúa como un asistente terapéutico gratuito, 24/7 y fácilmente accesible, democratizando la salud al permitir que cualquier persona con un smartphone pueda monitorear objetivamente su mejora.
- **Justificación Académica:** Pone en manifiesto competencias avanzadas en Dart, Flutter, bases de datos locales (Hive) y Computer Vision (Pose Detection).

### 1.4. Objetivo General
Desarrollar un sistema de software móvil inteligente bajo arquitectura nativa con Flutter que automatice el monitoreo y registro de la rehabilitación de esguinces de tobillo, empleando modelos de Inteligencia Artificial para el análisis cinemático del paciente en tiempo real.

### 1.5. Objetivos Específicos
- **Implementación de Visión Artificial:** Integrar la red neuronal de Pose Detection (Google ML Kit) para extraer coordenadas anatómicas y medir los ángulos del tobillo sin internet.
- **Persistencia de Datos:** Diseñar un motor de almacenamiento local ultrarrápido (NoSQL con Hive) para registrar historiales clínicos de las sesiones e ilustrar el progreso de flexibilidad mediante gráficos.
- **Diseño Inclusivo:** Construir una interfaz aplicando *Glassmorphism* que fomente la tranquilidad, asegurando facilidad de uso para cualquier paciente.

### 1.6. Alcance
El proyecto abarca el prototipo funcional completo de la aplicación móvil (frontend, IA, base de datos local y gráficos), así como su documentación técnica y arquitectura.

---

## 2. Marco Teórico

### 2.1. Anatomía del Esguince de Tobillo
Ocurre cuando los ligamentos se estiran más allá de sus límites. La rehabilitación clínica exige realizar ejercicios continuos para recuperar gradualmente la **Dorsiflexión** y **Flexión Plantar**, las cuales son el foco central de medición de la aplicación.

### 2.2. Flutter para Salud y Fisioterapia
Flutter permite compilar el código de manera nativa (ARM), logrando que el procesamiento de la cámara sea extremadamente fluido, factor crítico cuando se analizan 30 frames por segundo para detectar micro-movimientos musculares.

### 2.3. Machine Learning y Computer Vision (Pose Detection)
La visión artificial interpreta el mundo visual transformando píxeles en vectores. **Pose Detection** localiza de forma precisa los 33 *landmarks* del cuerpo humano. Para la app, se descartan los puntos superiores y se concentra la inferencia matricial exclusivamente en las coordenadas del tobillo.

### 2.4. Bases de Datos Locales (Hive NoSQL)
Para un funcionamiento verdaderamente autónomo (offline), se utiliza **Hive**, una base de datos embebida en formato clave-valor de altísimo rendimiento, que cifra y guarda los perfiles, rutinas y registros de ángulos.

---

## 3. Marco Metodológico

### 3.1. Tipo de Investigación
Desarrollo tecnológico aplicado (I+D+i), empleando modelado ágil.

### 3.2. Método de Desarrollo
Desarrollo en ciclos de trabajo modulares basados en sprints, enfocados primero en la viabilidad de la IA y posteriormente en la Experiencia de Usuario.

### 3.3. Fases del Proyecto
- **Fase 1:** Pruebas de concepto de la librería `google_mlkit_pose_detection`.
- **Fase 2:** Implementación de cálculo trigonométrico espacial para el ángulo del tobillo.
- **Fase 3:** Desarrollo de almacenamiento de datos (`Hive`) y visualización (`fl_chart`).
- **Fase 4:** Diseño visual (Glassmorphism) e integración de animaciones.
- **Fase 5:** Documentación y despliegue local del producto.

---

## 4. Ingeniería del Proyecto

### 4.1. Requisitos del Sistema

**4.1.1. Requisitos Funcionales:**
- **Inferencia en Tiempo Real:** La app debe abrir la cámara y superponer líneas e indicadores numéricos calculando el ángulo del tobillo.
- **Gestión de Ejercicios:** Módulo para ver el catálogo de ejercicios (en video) y su descripción.
- **Historial de Progreso:** Un panel de gráficos vectoriales (curvas de recuperación) mostrando el ángulo máximo logrado por día.
- **Autenticación y Perfil:** Registro de usuarios e inicio de sesión local.

**4.1.2. Requisitos No Funcionales:**
- **Edge Computing:** La IA no debe enviar ninguna foto/video a internet.
- **Rendimiento:** Mantener el cálculo biométrico fluido a un mínimo de 24fps.
- **Seguridad:** Los datos biométricos y progresos deben guardarse de forma privada y autónoma en el dispositivo del usuario.

### 4.2. Análisis de Riesgos
- **Riesgo:** Limitación de recursos del celular en teléfonos muy antiguos que no soporten ML Kit.
  - *Mitigación:* Reducción de la resolución de entrada al tensor de IA.
- **Riesgo:** Falsos positivos en la detección (reconocer otro objeto como tobillo).
  - *Mitigación:* Filtro estricto que requiere un nivel de confianza estadístico >80% (Likelihood).

### 4.3. Tecnologías y Librerías Utilizadas
- **Core:** Flutter 3.x, Dart.
- **IA y Sensores:** `camera`, `google_mlkit_pose_detection`.
- **Datos y Visualización:** `hive_flutter`, `fl_chart`.
- **Multimedia:** `youtube_player_iframe`, `video_player`.
- **UI:** `google_fonts`, Material Design 3.

---

## 5. Arquitectura del Sistema

### 5.1. Flujo Cinemático y Algorítmico
El núcleo inteligente funciona de la siguiente manera, a una tasa de 30 veces por segundo:
1. **Captura:** El plugin `camera` extrae el `InputImage` en formato nativo.
2. **Inferencia Tensorial:** `PoseDetector` procesa la matriz y extrae coordenadas (X, Y).
3. **Filtrado:** El algoritmo descarta todo el cuerpo excepto el `leftAnkle` / `rightAnkle` validando su Likelihood.
4. **Almacenamiento:** El vector angular resultante se almacena en memoria RAM y, al terminar, el máximo ángulo obtenido se guarda en la base de datos local para renderizar la curva.

---

## 6. Implementación

### 6.1. Estructura de Directorios
```
lib/
 ├── models/        # Estructuras de datos (Session, Exercise, User)
 ├── screens/       # Interfaces (Dashboard, Cámara Inteligente, Catálogo)
 ├── services/      # Servicios Singleton (AuthService, DBService, ThemeService)
 ├── widgets/       # Componentes reusables (GlassContainer, Graficos)
 └── main.dart      # Inicialización general
```

---

## 7. Resultados Esperados

### 7.1. Cumplimiento
- **Alta precisión:** Obtención de ángulos trigonométricos fieles a los movimientos reales de los pacientes, emulando la precisión de un goniómetro manual.
- **Persistencia estable:** Los historiales clínicos locales logran sobrevivir a reinicios y actúan instantáneamente, logrando una experiencia offline fluida.

---

## 8. Conclusiones y Recomendaciones

### 8.1. Conclusiones
El desarrollo de **PhysioVision** demuestra de forma categórica que es altamente viable, eficiente y económico implementar biometría y visión artificial en teléfonos celulares comunes (Edge Computing). Al emplear metodologías de renderizado nativo con Flutter, no es necesario construir aplicaciones hospitalarias que dependan siempre del internet, sino que podemos otorgarle el poder terapéutico al usuario final de manera privada.

### 8.2. Recomendaciones y Trabajo Futuro
- **Validación Médica Continua:** Calibrar los umbrales algorítmicos en estudios conjuntos con licenciados en fisioterapia.
- **Asistente de Voz (Text-to-Speech):** Implementar comandos de voz donde la app instruya auditivamente al paciente (ej. "Excelente movimiento, dobla un poco más").
- **Conectividad Cloud (Opcional):** Explorar la posibilidad de que el fisioterapeuta, desde una consola web, pueda descargar u observar de forma remota y autorizada los gráficos generados en el dispositivo del paciente.

---

## Anexos

### Anexo A: Modelos de Datos Locales (Hive)
- **Exercise (Ejercicio):** `(id, name, description, videoUrl, userId)`
- **Session (Sesión Clínica):** `(id, exerciseId, date, maxAngle, anglesHistory)`
- **User (Usuario/Paciente):** `(id, name, age, gender, role)`

### Anexo B: Repositorio Oficial
El código fuente completo del proyecto, la documentación de la inteligencia artificial y su frontend se encuentran alojados y documentados en:
🔗 [https://github.com/raulpadillaok-glitch/traumantologia-app.git](https://github.com/raulpadillaok-glitch/traumantologia-app.git)

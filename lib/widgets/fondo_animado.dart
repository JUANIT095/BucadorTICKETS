import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Fondo negro con dos brillos rojos difuminados que se desplazan despacio.
///
/// Si Windows tiene desactivadas las animaciones, el fondo queda fijo; si la
/// ventana no está en primer plano, se pausa.
///
/// Se redibuja a ~10 cuadros por segundo y no a 60: el brillo se mueve muy
/// despacio (unos pocos píxeles por segundo) y cada cuadro obliga a
/// recalcular el desenfoque de los paneles de vidrio. Medido en la Fase 16:
/// a 60 cuadros/s usaba un 33–50 % de un núcleo con la app en reposo.
class FondoAnimado extends StatefulWidget {
  const FondoAnimado({super.key, required this.child});

  final Widget child;

  @override
  State<FondoAnimado> createState() => _FondoAnimadoState();
}

class _FondoAnimadoState extends State<FondoAnimado>
    with WidgetsBindingObserver {
  static const _cuadro = Duration(milliseconds: 100);
  static const _ida = Duration(seconds: 20);

  /// 0 → 1 → 0 con suavizado, cada 2 × [_ida].
  final _progreso = ValueNotifier<double>(0);
  /// Tiempo animado acumulado (solo avanza mientras el fondo se mueve).
  var _transcurrido = Duration.zero;
  Timer? _temporizador;

  /// Pausa el fondo cuando la ventana pierde el foco (p. ej. tras abrir una
  /// carpeta en el Explorador): no tiene sentido redibujarlo sin que se vea.
  /// Arranca animando aunque Windows todavía no informe que la ventana está
  /// activa: si se detenía antes del primer cuadro, la ventana no llegaba a
  /// mostrarse y la app se cerraba sola (comprobado en la Fase 16).
  var _enPrimerPlano = true;
  var _sinAnimaciones = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    _enPrimerPlano = estado == AppLifecycleState.resumed;
    _actualizar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sinAnimaciones = MediaQuery.disableAnimationsOf(context);
    if (_sinAnimaciones) _progreso.value = 0.5;
    _actualizar();
  }

  void _actualizar() {
    if (_sinAnimaciones || !_enPrimerPlano) {
      _temporizador?.cancel();
      _temporizador = null;
    } else {
      _temporizador ??= Timer.periodic(_cuadro, (_) => _avanzar());
    }
  }

  void _avanzar() {
    final ida = _ida.inMilliseconds;
    _transcurrido += _cuadro;
    final fase = (_transcurrido.inMilliseconds % (2 * ida)) / ida; // 0..2
    _progreso.value = Curves.easeInOutSine.transform(
      fase <= 1 ? fase : 2 - fase,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _temporizador?.cancel();
    _progreso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PintorBrillos(_progreso), child: widget.child);
  }
}

class _PintorBrillos extends CustomPainter {
  _PintorBrillos(this.progreso) : super(repaint: progreso);

  final ValueListenable<double> progreso;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppTheme.negro);

    final t = progreso.value;
    final radio = size.longestSide * 0.55;

    _brillo(
      canvas,
      centro: Offset(
        size.width * (0.05 + 0.20 * t),
        size.height * (0.05 + 0.15 * t),
      ),
      radio: radio,
      intensidad: 0.38,
    );
    _brillo(
      canvas,
      centro: Offset(
        size.width * (0.95 - 0.20 * t),
        size.height * (1.0 - 0.15 * t),
      ),
      radio: radio * 0.9,
      intensidad: 0.28,
    );
  }

  /// El propio degradado radial hace el difuminado (más barato que un blur).
  void _brillo(
    Canvas canvas, {
    required Offset centro,
    required double radio,
    required double intensidad,
  }) {
    final zona = Rect.fromCircle(center: centro, radius: radio);
    final pintura = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.rojo.withValues(alpha: intensidad),
          AppTheme.rojoProfundo.withValues(alpha: intensidad * 0.45),
          AppTheme.negro.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(zona);
    canvas.drawCircle(centro, radio, pintura);
  }

  @override
  bool shouldRepaint(_PintorBrillos anterior) => anterior.progreso != progreso;
}

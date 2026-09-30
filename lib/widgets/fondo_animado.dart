import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Fondo negro con dos brillos rojos difuminados que se desplazan despacio.
///
/// Si Windows tiene desactivadas las animaciones, el fondo queda fijo.
class FondoAnimado extends StatefulWidget {
  const FondoAnimado({super.key, required this.child});

  final Widget child;

  @override
  State<FondoAnimado> createState() => _FondoAnimadoState();
}

class _FondoAnimadoState extends State<FondoAnimado>
    with SingleTickerProviderStateMixin {
  late final _animacion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animacion.value = 0.5;
    } else if (!_animacion.isAnimating) {
      _animacion.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PintorBrillos(
        CurvedAnimation(parent: _animacion, curve: Curves.easeInOutSine),
      ),
      child: widget.child,
    );
  }
}

class _PintorBrillos extends CustomPainter {
  _PintorBrillos(this.progreso) : super(repaint: progreso);

  final Animation<double> progreso;

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

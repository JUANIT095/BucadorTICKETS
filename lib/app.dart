import 'package:flutter/material.dart';

import 'core/constants/textos.dart';
import 'core/theme/app_theme.dart';
import 'features/search/presentation/buscador_controller.dart';
import 'features/search/presentation/datos_demo.dart';
import 'features/search/presentation/pantalla_busqueda.dart';
import 'features/search/presentation/raiz_controller.dart';

class BuscadorTicketsApp extends StatefulWidget {
  const BuscadorTicketsApp({super.key, required this.raiz});

  /// Se crea en `main` con los servicios reales; las pruebas inyectan el suyo.
  final RaizController raiz;

  @override
  State<BuscadorTicketsApp> createState() => _BuscadorTicketsAppState();
}

class _BuscadorTicketsAppState extends State<BuscadorTicketsApp> {
  // TEMPORAL (Fase 12): datos de demostración en lugar del índice real.
  final _controller = BuscadorController(
    fechaIndice: DatosDemo.fechaIndice,
    tickets: DatosDemo.tickets,
  );

  /// Última raíz para la que se lanzó la detección de años.
  String? _raizDetectada;

  @override
  void initState() {
    super.initState();
    widget.raiz.addListener(_alCambiarRaiz);
    _alCambiarRaiz();
  }

  /// Cada vez que cambia la raíz activa (al arrancar o al elegir otra), se
  /// vuelven a detectar los años y los meses.
  void _alCambiarRaiz() {
    final ruta = widget.raiz.rutaActiva;
    if (ruta == _raizDetectada) return;
    _raizDetectada = ruta;
    _controller.detectarEstructura(ruta);
  }

  @override
  void dispose() {
    widget.raiz.removeListener(_alCambiarRaiz);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Textos.tituloApp,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.oscuro,
      home: PantallaBusqueda(controller: _controller, raiz: widget.raiz),
    );
  }
}

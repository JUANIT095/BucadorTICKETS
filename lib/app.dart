import 'package:flutter/material.dart';

import 'core/constants/textos.dart';
import 'core/theme/app_theme.dart';
import 'features/search/data/repositorio_indice.dart';
import 'features/search/presentation/buscador_controller.dart';
import 'features/search/presentation/pantalla_busqueda.dart';
import 'features/search/presentation/raiz_controller.dart';

class BuscadorTicketsApp extends StatefulWidget {
  const BuscadorTicketsApp({super.key, required this.raiz, this.repositorio});

  /// Se crea en `main` con los servicios reales; las pruebas inyectan el suyo.
  final RaizController raiz;

  /// Persistencia del índice; null = siempre se indexa (pruebas).
  final RepositorioIndice? repositorio;

  @override
  State<BuscadorTicketsApp> createState() => _BuscadorTicketsAppState();
}

class _BuscadorTicketsAppState extends State<BuscadorTicketsApp> {
  late final _controller = BuscadorController(repositorio: widget.repositorio);

  /// Última situación de la raíz atendida, para no repetir trabajo.
  String? _ultimaRaiz;

  @override
  void initState() {
    super.initState();
    widget.raiz.addListener(_alCambiarRaiz);
    _alCambiarRaiz();
  }

  /// Sigue a la raíz: activa → índice guardado o indexación; no encontrada →
  /// último índice sin conexión; sin raíz → índice vacío.
  void _alCambiarRaiz() {
    final estado = widget.raiz.estado;
    final clave = switch (estado) {
      RaizVerificando() => null, // transitorio: se espera al resultado
      RaizActiva(:final ruta) => 'activa:$ruta',
      RaizNoEncontrada(:final ultimaRuta) => 'sin conexión:$ultimaRuta',
      _ => 'ninguna',
    };
    if (clave == null || clave == _ultimaRaiz) return;
    _ultimaRaiz = clave;
    switch (estado) {
      case RaizActiva(:final ruta):
        _controller.activarRaiz(ruta);
      case RaizNoEncontrada(:final ultimaRuta):
        _controller.cargarSinConexion(ultimaRuta);
      default:
        _controller.desactivar();
    }
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

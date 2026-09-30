import 'package:flutter/material.dart';

import 'core/constants/textos.dart';
import 'core/theme/app_theme.dart';
import 'features/search/presentation/buscador_controller.dart';
import 'features/search/presentation/datos_demo.dart';
import 'features/search/presentation/pantalla_busqueda.dart';

class BuscadorTicketsApp extends StatefulWidget {
  const BuscadorTicketsApp({super.key});

  @override
  State<BuscadorTicketsApp> createState() => _BuscadorTicketsAppState();
}

class _BuscadorTicketsAppState extends State<BuscadorTicketsApp> {
  // TEMPORAL (Fase 12): datos de demostración en lugar del índice real.
  final _controller = BuscadorController(
    raiz: DatosDemo.raiz,
    fechaIndice: DatosDemo.fechaIndice,
    tickets: DatosDemo.tickets,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Textos.tituloApp,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.oscuro,
      home: PantallaBusqueda(controller: _controller),
    );
  }
}

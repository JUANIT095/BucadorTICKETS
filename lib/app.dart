import 'package:flutter/material.dart';

import 'core/constants/textos.dart';

class BuscadorTicketsApp extends StatelessWidget {
  const BuscadorTicketsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Textos.tituloApp,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      // Provisional: la pantalla de búsqueda llega en la Fase 4.
      home: const Scaffold(
        body: Center(child: Text(Textos.tituloApp)),
      ),
    );
  }
}

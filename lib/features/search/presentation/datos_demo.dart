// ============================================================================
// TEMPORAL — Datos y controles de demostración de la Fase 4.
// Se elimina en la Fase 12, cuando la pantalla use el índice real.
// Los textos de este archivo son solo para desarrollo (no llegan al usuario),
// por eso no están en textos.dart.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/constants/textos.dart';
import '../../../models/ticket.dart';
import 'buscador_controller.dart';

abstract final class DatosDemo {
  static const raiz = r'D:\DISCO';

  static final fechaIndice = DateTime(2026, 9, 30, 10, 15);

  static const tickets = <Ticket>[
    Ticket(
      numero: '100219',
      nombre: 'Curación2 ABC - Proyecto IA',
      nombreCarpeta: '100219_Curación2 ABC - Proyecto IA',
      anio: 2024,
      mes: 5,
      carpetaMes: 'Mayo',
      rutaRelativa: r'METADA 2024\Mayo\100219_Curación2 ABC - Proyecto IA',
    ),
    Ticket(
      numero: '100287',
      nombre: 'Informe trimestral de ventas',
      nombreCarpeta: '100287_Informe trimestral de ventas',
      anio: 2024,
      mes: 6,
      carpetaMes: 'Junio',
      rutaRelativa: r'METADA 2024\Junio\100287_Informe trimestral de ventas',
    ),
    Ticket(
      numero: '101045',
      nombre: 'Rediseño portal de clientes',
      nombreCarpeta: '101045 - Rediseño portal de clientes',
      anio: 2025,
      mes: 9,
      carpetaMes: 'Setiembre',
      rutaRelativa:
          r'METADA 2025\Setiembre\101045 - Rediseño portal de clientes',
    ),
    Ticket(
      nombre: 'Varios',
      nombreCarpeta: 'Varios',
      anio: 2025,
      carpetaMes: 'Pendientes',
      rutaRelativa: r'METADA 2025\Pendientes\Varios',
    ),
    Ticket(
      numero: '102310',
      nombre:
          'Campaña de lanzamiento del nuevo producto con un nombre de carpeta '
          'muy largo para probar el recorte',
      nombreCarpeta:
          '102310_Campaña de lanzamiento del nuevo producto con un nombre de '
          'carpeta muy largo para probar el recorte',
      anio: 2026,
      mes: 1,
      carpetaMes: 'Enero',
      rutaRelativa:
          r'METADA 2026\Enero\102310_Campaña de lanzamiento del nuevo producto '
          r'con un nombre de carpeta muy largo para probar el recorte',
    ),
  ];

  static const _elementos = {
    '100219': 12,
    '100287': 1,
    '101045': 0,
    // "102310" sin valor: muestra "Calculando…".
  };

  static int? elementosDe(Ticket ticket) =>
      ticket.numero == null ? 3 : _elementos[ticket.numero];
}

/// Botón flotante (solo en modo debug) para alternar estados y avisos.
class SelectorEstadoDemo extends StatelessWidget {
  const SelectorEstadoDemo({super.key, required this.controller});

  final BuscadorController controller;

  @override
  Widget build(BuildContext context) {
    final opciones = <String, EstadoBusqueda>{
      'Inicial': const EstadoInicial(),
      'Buscando': const EstadoBuscando(),
      'Indexando': const EstadoIndexando(),
      'Sin resultados': const EstadoSinResultados(),
      'Error': const EstadoError(Textos.errorLeerIndice),
      'Con resultados': const EstadoConResultados(DatosDemo.tickets),
    };

    return MenuAnchor(
      menuChildren: [
        for (final MapEntry(key: nombre, value: estado) in opciones.entries)
          MenuItemButton(
            onPressed: () => controller.mostrarEstado(estado),
            child: Text(nombre),
          ),
        const Divider(),
        MenuItemButton(
          onPressed: () {
            const aviso = Textos.avisoRaizNoDisponible;
            controller.avisos.contains(aviso)
                ? controller.descartarAviso(aviso)
                : controller.mostrarAviso(aviso);
          },
          child: const Text('Mostrar / ocultar aviso'),
        ),
      ],
      builder: (context, menu, _) => FloatingActionButton.small(
        tooltip: 'Estados de demostración (solo debug)',
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
        child: const Icon(Icons.bug_report_outlined),
      ),
    );
  }
}

import 'package:buscador_tickets/models/ticket.dart';

/// Tickets de ejemplo para las pruebas de widget (antes eran los datos de
/// demostración de la app). Variedad: sin número, sin mes reconocido, nombre
/// y ruta muy largos.
abstract final class TicketsPrueba {
  static final fechaIndice = DateTime(2026, 9, 30, 10, 15);

  static final tickets = <Ticket>[
    Ticket(
      numero: '100219',
      nombre: 'Curación2 ABC - Proyecto IA',
      nombreCarpeta: '100219_Curación2 ABC - Proyecto IA',
      anio: 2024,
      mes: 5,
      carpetaMes: 'Mayo',
      rutaRelativa: r'2024\Mayo\100219_Curación2 ABC - Proyecto IA',
    ),
    Ticket(
      numero: '100287',
      nombre: 'Informe trimestral de ventas',
      nombreCarpeta: '100287_Informe trimestral de ventas',
      anio: 2024,
      mes: 6,
      carpetaMes: 'Junio',
      rutaRelativa: r'2024\Junio\100287_Informe trimestral de ventas',
    ),
    Ticket(
      numero: '101045',
      nombre: 'Rediseño portal de clientes',
      nombreCarpeta: '101045 - Rediseño portal de clientes',
      anio: 2025,
      mes: 9,
      carpetaMes: 'Setiembre',
      rutaRelativa: r'2025\Setiembre\101045 - Rediseño portal de clientes',
    ),
    Ticket(
      nombre: 'Varios',
      nombreCarpeta: 'Varios',
      anio: 2025,
      carpetaMes: 'Pendientes',
      rutaRelativa: r'2025\Pendientes\Varios',
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
          r'2026\Enero\102310_Campaña de lanzamiento del nuevo producto '
          r'con un nombre de carpeta muy largo para probar el recorte',
    ),
  ];
}

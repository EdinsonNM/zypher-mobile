import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  // Lista de eventos de ejemplo (en un caso real vendrían de la base de datos)
  final List<Evento> _eventos = [
    Evento(
      titulo: 'Excursión al museo',
      fecha: DateTime(2024, 8, 25),
      horario: '10:00 AM - 2:00 PM',
      descripcion: 'Visita guiada al Museo de Historia Natural. Los estudiantes deberán llevar almuerzo y ropa cómoda.',
    ),
    Evento(
      titulo: 'Día deportivo',
      fecha: DateTime(2024, 9, 2),
      horario: '8:00 AM - 1:00 PM',
      descripcion: 'Jornada de competencias deportivas en el campo del colegio. Se recomienda usar el uniforme deportivo.',
    ),
    Evento(
      titulo: 'Feria de ciencias',
      fecha: DateTime(2024, 9, 15),
      horario: 'Todo el día',
      descripcion: 'Presentación de proyectos científicos de los alumnos en el patio principal. Abierto a todos los padres de familia.',
    ),
    Evento(
      titulo: 'Entrega de notas',
      fecha: DateTime(2024, 9, 30),
      horario: '5:00 PM - 7:00 PM',
      descripcion: 'Reunión de padres y maestros para la entrega de libretas de calificaciones del segundo trimestre.',
    ),
    Evento(
      titulo: 'Día de la Raza',
      fecha: DateTime(2024, 10, 12),
      horario: 'Feriado',
      descripcion: 'No hay clases por feriado nacional. Las actividades se reanudan el 13 de octubre.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827), // bg-gray-900
      body: Column(
        children: [
          // Contenido principal
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Lista de eventos
                  Expanded(
                    child: _buildEventosList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 48), // Espacio para centrar el título
        const Text(
          'Próximos Eventos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 48), // Espacio para centrar el título
      ],
    );
  }

  Widget _buildEventosList() {
    return ListView.separated(
      itemCount: _eventos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final evento = _eventos[index];
        return _buildEventoCard(evento);
      },
    );
  }

  Widget _buildEventoCard(Evento evento) {
    final mes = _getMesAbreviado(evento.fecha.month);
    final dia = evento.fecha.day;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937), // bg-gray-800
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha
          Container(
            width: 64,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF374151), // bg-gray-700
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  mes,
                  style: const TextStyle(
                    color: Color(0xFFF87171), // text-red-400
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dia.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Información del evento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  evento.horario,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF), // text-gray-400
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  evento.descripcion,
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB), // text-gray-300
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMesAbreviado(int month) {
    switch (month) {
      case 1:
        return 'ENE';
      case 2:
        return 'FEB';
      case 3:
        return 'MAR';
      case 4:
        return 'ABR';
      case 5:
        return 'MAY';
      case 6:
        return 'JUN';
      case 7:
        return 'JUL';
      case 8:
        return 'AGO';
      case 9:
        return 'SEP';
      case 10:
        return 'OCT';
      case 11:
        return 'NOV';
      case 12:
        return 'DIC';
      default:
        return '';
    }
  }
}

// Modelo de datos para los eventos
class Evento {
  final String titulo;
  final DateTime fecha;
  final String horario;
  final String descripcion;

  Evento({
    required this.titulo,
    required this.fecha,
    required this.horario,
    required this.descripcion,
  });
}

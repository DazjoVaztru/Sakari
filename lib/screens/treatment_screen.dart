import 'package:flutter/material.dart';
import '../models/tratamiento_model.dart';
import '../services/tratamientos_service.dart';
import '../services/citas_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  List<String> _diasBloqueados = [];
  List<int> _diasSemanaCerrados = [];
  List<TratamientoModel> listaTratamientos = [];
  List<Map<String, dynamic>> listaActivos = [];
  bool isLoading = true;

  // Ponemos el token aquí arriba para que TODA la pantalla lo pueda usar
  // (Puse el que te devolvió tu consola en la prueba exitosa)
  String miToken = "";

  @override
  void initState() {
    super.initState();
    _inicializarPantalla(); // <- Cambiamos esto
  }

  // NUEVA FUNCIÓN QUE LEE LA MEMORIA PRIMERO
  Future<void> _inicializarPantalla() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Leemos el token de la memoria. Si no hay, dejamos un string vacío
      miToken = prefs.getString('token') ?? "";
    });

    if (miToken.isNotEmpty) {
      _cargarTratamientos();
      _cargarDiasBloqueados();
    }
  }

  Future<void> _cargarTratamientos() async {
    // Aquí ya NO pegamos el token a mano, usamos la variable miToken que ya se llenó
    final tratamientos = await TratamientosService.obtenerCatalogo(miToken);
    final activos = await TratamientosService.obtenerTratamientosActivos(
      miToken,
    );

    if (mounted) {
      setState(() {
        listaTratamientos = tratamientos;
        listaActivos = activos;
        isLoading = false;
      });
    }
  }

  void _cargarDiasBloqueados() async {
    final data = await CitasService.obtenerDiasBloqueados(miToken);
    if (mounted) {
      setState(() {
        // 👇 AÑADIMOS List<String>.from y List<int>.from PARA EVITAR EL ERROR 👇
        _diasBloqueados = List<String>.from(data['fechas'] ?? []);
        _diasSemanaCerrados = List<int>.from(data['dias_semana'] ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0277BD),
        title: const Text(
          "Mis Tratamientos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0277BD)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN 1: EN CURSO (AHORA ES DINÁMICA) ---
                  const Text(
                    "En curso",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF014F7E),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (listaActivos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        "No tienes tratamientos activos en este momento.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  else
                    // Dibujamos una tarjeta por cada tratamiento activo real
                    ...listaActivos
                        .map((activo) => _buildActivoCard(activo))
                        .toList(),

                  const SizedBox(height: 15),

                  // --- SECCIÓN 2: SERVICIOS DISPONIBLES ---
                  const Text(
                    "Servicios Disponibles",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF014F7E),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Agenda un nuevo servicio hoy mismo.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 15),

                  if (listaTratamientos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No hay tratamientos en el catálogo.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listaTratamientos.length,
                      itemBuilder: (context, index) {
                        final tratamiento = listaTratamientos[index];
                        return _buildServicioCard(
                          tratamiento.id,
                          tratamiento.nombre,
                          _obtenerDescripcion(tratamiento.categoria),
                          tratamiento.precio,
                          _obtenerIcono(tratamiento.categoria),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  // --- WIDGET PARA TRATAMIENTO ACTIVO REAL ---
  Widget _buildActivoCard(Map<String, dynamic> activo) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0277BD), Color(0xFF4FC3F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0277BD).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activo['nombre'] ?? 'Tratamiento',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Builder(
                builder: (context) {
                  // 1. Recibimos el estado y le quitamos espacios extra (.trim)
                  String estadoBackend = (activo['estado'] ?? 'Activo')
                      .toString()
                      .toLowerCase()
                      .trim();

                  // 2. Definimos textos por defecto (Pendiente/Activo)
                  String estadoMostrar = "Activo";
                  Color colorFondo = Colors.white.withOpacity(0.3);

                  // 3. ✅ VALIDACIÓN MÚLTIPLE (Atrapamos todas las palabras posibles)
                  if (estadoBackend == 'atendido' ||
                      estadoBackend == 'atendida' ||
                      estadoBackend == 'completado' ||
                      estadoBackend == 'completada' ||
                      estadoBackend == 'finalizado' ||
                      estadoBackend == 'concluido') {
                    estadoMostrar = "Atendido";
                    colorFondo = Colors.green.withOpacity(
                      0.8,
                    ); // Lo pintamos verde 🟢
                  } else if (estadoBackend == 'cancelado' ||
                      estadoBackend == 'cancelada') {
                    estadoMostrar = "Cancelado";
                    colorFondo = Colors.red.withOpacity(
                      0.8,
                    ); // Lo pintamos rojo 🔴
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorFondo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estadoMostrar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Progreso del tratamiento",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.2, // Podrías hacerlo dinámico después desde el backend
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Inicio: ${activo['fecha_inicio'] ?? ''}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tarjeta de Servicio actualizada con el modal
  Widget _buildServicioCard(
    int idServicio,
    String titulo,
    String subtitulo,
    double precio,
    IconData icono,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icono, color: const Color(0xFF0277BD), size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  "\$${precio.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Color(0xFF0277BD),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _mostrarModalAgendar(idServicio, titulo),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0277BD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Agendar"),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DEL MODAL DE AGENDAR ---
  void _mostrarModalAgendar(int idServicio, String nombreServicio) {
    final BuildContext contextoPrincipal = context;

    final DateTime hoy = DateTime.now();
    final DateTime diaActual = DateTime(hoy.year, hoy.month, hoy.day);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        DateTime fechaTemp = diaActual;
        int pasoActual = 1;
        String? horaSeleccionada;
        bool isLoadingHorarios = false;
        List<String> horariosDisponibles = [];

        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            Future<void> cargarHorarios(DateTime nuevaFecha) async {
              setModalState(() {
                fechaTemp = nuevaFecha;
                pasoActual = 2;
                isLoadingHorarios = true;
                horaSeleccionada = null;
              });

              // AHORA MANDAMOS EL TOKEN AL SERVICIO PARA VER LOS HORARIOS REALES
              final horarios = await CitasService.obtenerHorariosDisponibles(
                miToken,
                nuevaFecha,
              );

              if (mounted) {
                setModalState(() {
                  horariosDisponibles = horarios;
                  isLoadingHorarios = false;
                });
              }
            }

            return Container(
              height: 650,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Agendar: $nombreServicio",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF014F7E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pasoActual == 1
                        ? "Selecciona el Día"
                        : "Selecciona la Hora",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PASO 1: CALENDARIO
                  if (pasoActual == 1) ...[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: CalendarDatePicker(
                          initialDate: fechaTemp,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          // 👇 REPETIMOS LA MAGIA AQUÍ 👇
                          selectableDayPredicate: (DateTime day) {
                            String fechaStr =
                                "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

                            // 1. Bloquea vacaciones o días feriados
                            if (_diasBloqueados.contains(fechaStr)) {
                              return false;
                            }

                            // 2. ✅ Bloquea los días de la semana que el SaaS configuró como cerrados (Ej: 5, 6, 7)
                            if (_diasSemanaCerrados.contains(day.weekday)) {
                              return false;
                            }

                            return true; // Día libre
                          },
                          // ☝️ FIN DE LA MAGIA ☝️
                          onDateChanged: (newDate) {
                            cargarHorarios(newDate);
                          },
                        ),
                      ),
                    ),
                  ],

                  // PASO 2: HORARIOS
                  if (pasoActual == 2) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F5FE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0277BD).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Día seleccionado",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "${fechaTemp.day} de ${_obtenerMes(fechaTemp.month)}, ${fechaTemp.year}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0277BD),
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                setModalState(() => pasoActual = 1),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text("Cambiar"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isLoadingHorarios)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF0277BD),
                          ),
                        ),
                      )
                    else if (horariosDisponibles.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "No hay horarios disponibles.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: horariosDisponibles.map((hora) {
                          return _buildTimeOption(
                            hora,
                            horaSeleccionada,
                            (val) =>
                                setModalState(() => horaSeleccionada = val),
                          );
                        }).toList(),
                      ),

                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancelar"),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: horaSeleccionada == null
                                ? null
                                : () async {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(
                                      contextoPrincipal,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text("Agendando cita..."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );

                                    // Usamos el token global para agendar
                                    bool exito =
                                        await CitasService.agendarNuevaCita(
                                          miToken,
                                          idServicio,
                                          fechaTemp,
                                          horaSeleccionada!,
                                        );

                                    if (exito && mounted) {
                                      ScaffoldMessenger.of(
                                        contextoPrincipal,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "¡Cita agendada con éxito!",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      // Recargamos la pantalla para mostrar el nuevo tratamiento en curso
                                      _cargarTratamientos();
                                    } else if (mounted) {
                                      ScaffoldMessenger.of(
                                        contextoPrincipal,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Error al agendar."),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0277BD),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Confirmar"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- HELPERS (Funciones de apoyo) ---
  Widget _buildTimeOption(
    String time,
    String? selected,
    Function(String) onSelect,
  ) {
    bool isSelected = time == selected;
    return GestureDetector(
      onTap: () => onSelect(time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0277BD) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF0277BD) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _obtenerMes(int mes) {
    const meses = [
      "Ene",
      "Feb",
      "Mar",
      "Abr",
      "May",
      "Jun",
      "Jul",
      "Ago",
      "Sep",
      "Oct",
      "Nov",
      "Dic",
    ];
    return meses[mes - 1];
  }

  IconData _obtenerIcono(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'limpieza':
        return Icons.clean_hands;
      case 'estética':
        return Icons.auto_awesome;
      default:
        return Icons.medical_services_outlined;
    }
  }

  String _obtenerDescripcion(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'limpieza':
        return 'Elimina sarro y manchas.';
      case 'estética':
        return 'Mejora tu sonrisa.';
      case 'general':
        return 'Cuidado preventivo y valoración.';
      default:
        return 'Procedimiento seguro y profesional.';
    }
  }
}

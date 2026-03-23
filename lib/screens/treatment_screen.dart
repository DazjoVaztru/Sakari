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

  String miToken = "";

  @override
  void initState() {
    super.initState();
    _inicializarPantalla();
  }

  Future<void> _inicializarPantalla() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      miToken = prefs.getString('token') ?? "";
    });

    if (miToken.isNotEmpty) {
      _cargarTratamientos();
      _cargarDiasBloqueados();
    }
  }

  void _cargarDiasBloqueados() async {
    final data = await CitasService.obtenerDiasBloqueados(miToken);
    if (mounted) {
      setState(() {
        _diasBloqueados = List<String>.from(data['fechas'] ?? []);
        _diasSemanaCerrados = List<int>.from(data['dias_semana'] ?? []);
      });
    }
  }

  Future<void> _cargarTratamientos() async {
    try {
      // ✅ CORRECCIÓN 1: Cambiado a obtenerCatalogo
      final tratamientosApi = await TratamientosService.obtenerCatalogo(
        miToken,
      );
      final activosApi = await TratamientosService.obtenerTratamientosActivos(
        miToken,
      );

      if (mounted) {
        setState(() {
          listaTratamientos = tratamientosApi;
          listaActivos = activosApi;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tratamientos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0277BD),
        elevation: 0,
        title: const Text(
          "Tratamientos",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0277BD)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "En curso",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF014F7E),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (listaActivos.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Text(
                        "No tienes tratamientos activos en este momento.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: listaActivos.length,
                        itemBuilder: (context, index) {
                          return _buildActivoCard(listaActivos[index]);
                        },
                      ),
                    ),

                  const SizedBox(height: 30),
                  const Text(
                    "Catálogo de Servicios",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF014F7E),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (listaTratamientos.isEmpty)
                    const Center(
                      child: Text(
                        "No hay servicios disponibles",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...listaTratamientos.map(
                      (tratamiento) => _buildTratamientoCard(tratamiento),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildActivoCard(Map<String, dynamic> activo) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0277BD), Color(0xFF014F7E)],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.health_and_safety,
                color: Colors.white,
                size: 30,
              ),
              Builder(
                builder: (context) {
                  String estadoBackend = (activo['estado'] ?? 'Activo')
                      .toString()
                      .toLowerCase()
                      .trim();

                  String estadoMostrar = "Activo";
                  Color colorFondo = Colors.white.withOpacity(0.3);

                  if (estadoBackend == 'atendido' ||
                      estadoBackend == 'atendida' ||
                      estadoBackend == 'completado' ||
                      estadoBackend == 'completada' ||
                      estadoBackend == 'finalizado' ||
                      estadoBackend == 'concluido') {
                    estadoMostrar = "Atendido";
                    colorFondo = Colors.green.withOpacity(0.8);
                  } else if (estadoBackend == 'cancelado' ||
                      estadoBackend == 'cancelada') {
                    estadoMostrar = "Cancelado";
                    colorFondo = Colors.red.withOpacity(0.8);
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activo['nombre'] ?? 'Sin nombre',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                "Iniciado: ${activo['fecha_inicio'] ?? 'N/A'}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTratamientoCard(TratamientoModel tratamiento) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              // ✅ CORRECCIÓN 2: Acceder a categoria
              _obtenerIcono(tratamiento.categoria),
              color: const Color(0xFF0277BD),
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // ✅ CORRECCIÓN 3: Cambiado a nombre
                  tratamiento.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF014F7E),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  // ✅ CORRECCIÓN 4: Cambiado a categoria en lugar de descripcion
                  tratamiento.categoria,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${tratamiento.precio.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0277BD),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _mostrarModalAgendar(
                          // ✅ CORRECCIÓN 5: Cambiado a id y nombre
                          tratamiento.id,
                          tratamiento.nombre,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0277BD),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        "Agendar",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarModalAgendar(int idServicio, String nombreServicio) {
    final BuildContext contextoPrincipal = context;

    // 🔥 MAGIA: Función inteligente que busca el primer día disponible
    DateTime buscarPrimerDiaLibre() {
      DateTime diaPrueba = DateTime.now().add(
        const Duration(days: 1),
      ); // Empezamos desde mañana

      for (int i = 0; i < 60; i++) {
        // Buscamos un día libre en los próximos 2 meses
        String fechaStr =
            "${diaPrueba.year}-${diaPrueba.month.toString().padLeft(2, '0')}-${diaPrueba.day.toString().padLeft(2, '0')}";

        // Si el día NO está bloqueado en fechas y NO es un día de la semana cerrado, ¡lo encontramos!
        if (!_diasBloqueados.contains(fechaStr) &&
            !_diasSemanaCerrados.contains(diaPrueba.weekday)) {
          return diaPrueba;
        }
        diaPrueba = diaPrueba.add(
          const Duration(days: 1),
        ); // Si está cerrado, checamos el día siguiente
      }
      return DateTime.now().add(
        const Duration(days: 1),
      ); // Respaldo de emergencia
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        // ✅ CORRECCIÓN: Le damos a Flutter un día de inicio que es 100% seguro que está abierto
        DateTime fechaTemp = buscarPrimerDiaLibre();

        int pasoActual = 1;
        String? horaSeleccionada;
        bool isLoadingHorarios = false;
        List<String> horariosDisponibles = [];
        bool isCargandoBoton = false;

        return StatefulBuilder(
          // ... EL RESTO DE TU CÓDIGO HACIA ABAJO SE QUEDA EXACTAMENTE IGUAL ...
          builder: (BuildContext modalContext, StateSetter setModalState) {
            Future<void> cargarHorarios(DateTime nuevaFecha) async {
              setModalState(() {
                fechaTemp = nuevaFecha;
                pasoActual = 2;
                isLoadingHorarios = true;
                horaSeleccionada = null;
              });

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
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 10),
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F5FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event_available,
                            color: Color(0xFF0277BD),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Agendar Cita",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF014F7E),
                                ),
                              ),
                              Text(
                                nombreServicio,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (pasoActual == 2)
                          IconButton(
                            icon: const Icon(
                              Icons.edit_calendar,
                              color: Color(0xFF0277BD),
                            ),
                            onPressed: () {
                              setModalState(() {
                                pasoActual = 1;
                                horaSeleccionada = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 30),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pasoActual == 1) ...[
                            const Text(
                              "1. Selecciona el día",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: CalendarDatePicker(
                                initialDate: fechaTemp,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                                selectableDayPredicate: (DateTime day) {
                                  String fechaStr =
                                      "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

                                  if (_diasBloqueados.contains(fechaStr)) {
                                    return false;
                                  }
                                  if (_diasSemanaCerrados.contains(
                                    day.weekday,
                                  )) {
                                    return false;
                                  }
                                  return true;
                                },
                                onDateChanged: (newDate) {
                                  cargarHorarios(newDate);
                                },
                              ),
                            ),
                          ] else ...[
                            const Text(
                              "2. Selecciona la hora",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${fechaTemp.day} de ${_obtenerMes(fechaTemp.month)} ${fechaTemp.year}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF0277BD),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (isLoadingHorarios)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0277BD),
                                  ),
                                ),
                              )
                            else if (horariosDisponibles.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(30),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 50,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 15),
                                    const Text(
                                      "No hay horarios disponibles\npara este día.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: horariosDisponibles.map((hora) {
                                  bool isSelected = hora == horaSeleccionada;
                                  return InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        horaSeleccionada = hora;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF0277BD)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF0277BD)
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        hora,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  if (pasoActual == 2 && horaSeleccionada != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isCargandoBoton
                                ? null
                                : () async {
                                    setModalState(() => isCargandoBoton = true);

                                    final Map<String, dynamic> resultado =
                                        await CitasService.agendarNuevaCita(
                                          miToken,
                                          idServicio,
                                          fechaTemp,
                                          horaSeleccionada!,
                                        );

                                    if (mounted) {
                                      if (resultado['success'] == true) {
                                        ScaffoldMessenger.of(
                                          contextoPrincipal,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              resultado['message']
                                                      ?.toString() ??
                                                  "¡Cita agendada con éxito!",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        _cargarTratamientos();
                                        Navigator.of(contextoPrincipal).pop();
                                      } else {
                                        setModalState(
                                          () => isCargandoBoton = false,
                                        );
                                        ScaffoldMessenger.of(
                                          contextoPrincipal,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              resultado['message']
                                                      ?.toString() ??
                                                  "Error al agendar.",
                                            ),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(
                                              seconds: 4,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0277BD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: isCargandoBoton
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Confirmar Cita",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
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
}

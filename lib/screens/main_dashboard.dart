import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importamos el Login para poder cerrar sesión
import 'clinic_screen.dart';
import 'dentist_screen.dart';
import 'treatment_screen.dart';
import 'payments_screen.dart';
import 'settings_screen.dart';
import '../models/cita_model.dart';
import '../services/citas_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/publicidad_model.dart';
import '../services/publicidad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  // Variables de Estado
  bool tratamientoRealizado = true;

  // Nuevas variables para cargar la base de datos
  CitaModel? citaActual;
  bool isLoadingCita = true;
  DateTime fechaCita = DateTime.now();
  String estadoCita = "Cargando...";
  Color colorEstado = Colors.grey;
  PublicidadModel? promoActiva;
  bool isLoadingPromo = true;
  List<String> _diasBloqueados = [];
  List<int> _diasSemanaCerrados = [];

  // Ponemos el token aquí para poder pasárselo a los servicios
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
      // Una vez que tenemos el token de la memoria, ahora sí cargamos la base de datos
      _cargarCitaDesdeBD();
      _cargarPromocion();
      _cargarDiasBloqueados();
    }
  }

  void _cargarDiasBloqueados() async {
    final data = await CitasService.obtenerDiasBloqueados(miToken);
    if (mounted) {
      setState(() {
        _diasBloqueados = data['fechas'];
        _diasSemanaCerrados =
            data['dias_semana']; // Guardamos los días de la semana
      });
    }
  }

  Future<void> _cargarCitaDesdeBD() async {
    // Ahora enviamos el token real
    final cita = await CitasService.obtenerProximaCita(
      1,
    ); // Mantenemos el simulador por ahora en citas_service

    if (mounted) {
      setState(() {
        citaActual = cita;
        isLoadingCita = false;

        if (cita != null) {
          fechaCita = cita.fechaHoraInicio;
          estadoCita = cita.estadoCita;
          colorEstado = cita.estadoCita == 'pendiente'
              ? Colors.orange
              : Colors.green;
        }
      });
    }
  }

  Future<void> _cargarPromocion() async {
    final promo = await PublicidadService.obtenerPromocionActiva();
    if (mounted) {
      setState(() {
        promoActiva = promo;
        isLoadingPromo = false;
      });
    }
  }

  Future<void> _abrirGoogleMaps() async {
    // Aquí ponemos la dirección de Tehuacán
    const String direccion = 'Centro, Tehuacán, Puebla';
    final String urlCodificada = Uri.encodeFull(
      'https://www.google.com/maps/search/?api=1&query=$direccion',
    );
    final Uri url = Uri.parse(urlCodificada);

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('No se pudo abrir el mapa');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ocurrió un error al intentar abrir Google Maps."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF0277BD),
              radius: 18,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0277BD)),
              accountName: Text(
                "Josue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text("paciente@sakary.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Color(0xFF0277BD)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildClassicMenuItem(
                    Icons.home,
                    "Inicio",
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildClassicMenuItem(
                    Icons.local_hospital,
                    "Clínica",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClinicScreen(),
                        ),
                      );
                    },
                  ),
                  _buildClassicMenuItem(
                    Icons.person,
                    "Dentista",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DentistScreen(),
                        ),
                      );
                    },
                  ),
                  _buildClassicMenuItem(
                    Icons.folder_shared,
                    "Tratamiento",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TreatmentScreen(),
                        ),
                      );
                    },
                  ),
                  _buildClassicMenuItem(
                    Icons.attach_money,
                    "Pagos",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildClassicMenuItem(
                    Icons.settings,
                    "Configuración",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildClassicMenuItem(
                Icons.logout,
                "Cerrar Sesión",
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hola, Josue 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF014F7E),
              ),
            ),
            const Text(
              "¿Cómo está tu sonrisa hoy?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // --- BANNER DE PROMOCIONES (DINÁMICO) ---
            if (isLoadingPromo)
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0277BD)),
                ),
              )
            else if (promoActiva != null)
              Container(
                width: double.infinity,
                height: 140,
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
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: 20,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promoActiva!.titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            promoActiva!.descripcion,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // --- TARJETA DE CITA (DINÁMICA) ---
            const Text(
              "Tu Próxima Cita",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Si está cargando, mostramos el circulito azul
            if (isLoadingCita)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Color(0xFF0277BD)),
                ),
              )
            // Si cargó pero no hay citas en la BD
            else if (citaActual == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "No tienes citas próximas agendadas.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            // Si cargó y SI hay cita, mostramos la tarjeta
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F5FE),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF0277BD),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${fechaCita.day} de ${_obtenerMes(fechaCita.month)}, ${fechaCita.year}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${fechaCita.hour}:${fechaCita.minute.toString().padLeft(2, '0')} ${fechaCita.hour < 12 ? 'AM' : 'PM'}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Usamos los datos reales del modelo
                            Text(
                              citaActual!.nombreDoctor,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              citaActual!.nombreServicio,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Chip(
                          label: Text(
                            estadoCita.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: colorEstado,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ... (Tus botones de confirmar y reagendar se quedan exactamente igual)
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            "Confirmar",
                            const Color(0xFF0277BD),
                            true,
                            onTap: _accionConfirmar,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildActionButton(
                            "Reagendar",
                            Colors.grey,
                            false,
                            onTap: _accionReagendar,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            // Accesos Rápidos
            const Text(
              "¿Qué necesitas hoy?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickActionItem(
                  icon: Icons.cleaning_services,
                  label: "Higiene",
                  onTap: () => _mostrarRecomendacionesHigiene(context),
                ),
                _buildQuickActionItem(
                  icon: Icons.location_on,
                  label: "Ubicación",
                  onTap: _abrirGoogleMaps, // Conectamos la función aquí
                ),
                _buildQuickActionItem(
                  icon: Icons.healing,
                  label: "Cuidados",
                  isEnabled: tratamientoRealizado,
                  onTap: () => _mostrarCuidadosPostTratamiento(context),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _accionConfirmar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF8E1E7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text("✅", style: TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            const Text(
              "¡Gracias por confirmar!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF880E4F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Lo esperamos el día ${fechaCita.day} a las ${fechaCita.hour}:${fechaCita.minute}0.",
              style: const TextStyle(fontSize: 14, color: Color(0xFF880E4F)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                estadoCita = "Confirmada";
                colorEstado = Colors.green;
              });
              Navigator.pop(ctx);
            },
            child: const Text(
              "Aceptar",
              style: TextStyle(
                color: Color(0xFF880E4F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _accionReagendar() {
    final BuildContext contextoPrincipal = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        DateTime fechaTemp = fechaCita;
        int pasoActual = 1;
        String? horaSeleccionada;

        // Nuevas variables dinámicas para los horarios
        bool isLoadingHorarios = false;
        List<String> horariosDisponibles = [];

        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            // Función interna para pedir los horarios a la BD
            Future<void> cargarHorarios(DateTime nuevaFecha) async {
              setModalState(() {
                fechaTemp = nuevaFecha;
                pasoActual = 2;
                isLoadingHorarios = true;
                horaSeleccionada = null; // Reiniciamos la hora si cambia de día
              });

              // Agregamos miToken como primer parámetro
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
                    pasoActual == 1
                        ? "Selecciona el Día"
                        : "Selecciona la Hora",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF014F7E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- PASO 1: CALENDARIO ---
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
                          // 👇 ESTA ES LA MAGIA QUE BLOQUEA LOS DÍAS 👇
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
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "Toca un día para ver horarios",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],

                  // --- PASO 2: HORARIOS ---
                  if (pasoActual == 2) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F5FE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0277BD).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Nueva Fecha Seleccionada",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${fechaTemp.day} de ${_obtenerMes(fechaTemp.month)}, ${fechaTemp.year}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0277BD),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                setModalState(() => pasoActual = 1),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text("Cambiar día"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Horarios Disponibles:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // --- MOSTRAR HORARIOS O CÍRCULO DE CARGA ---
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
                            "No hay horarios disponibles este día.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        // Dibujamos la lista de horarios directamente desde la Base de Datos
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
                                        content: Text(
                                          "Reagendando cita en el sistema...",
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );

                                    // Aseguramos que tenemos una cita cargada para sacar su ID
                                    // Asumiendo que tu CitaModel tiene una propiedad llamada 'id'
                                    int idCita =
                                        1; // Cambiar por 'citaActual?.id ?? 0' si tienes la propiedad 'id' en tu modelo

                                    bool
                                    exito = await CitasService.reagendarCita(
                                      idCita, // <- Pasamos el ID real de la cita
                                      fechaTemp,
                                    );

                                    if (exito && mounted) {
                                      setState(() {
                                        fechaCita = fechaTemp;
                                        estadoCita = "Reagendada";
                                        colorEstado = Colors.blue;
                                      });
                                      ScaffoldMessenger.of(
                                        contextoPrincipal,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "¡Cita reagendada con éxito!",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else if (mounted) {
                                      ScaffoldMessenger.of(
                                        contextoPrincipal,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Error al conectar con la clínica.",
                                          ),
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

  void _mostrarRecomendacionesHigiene(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "🦷 Tips de Higiene",
          style: TextStyle(color: Color(0xFF0277BD)),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• Cepíllate 3 veces al día."),
            SizedBox(height: 8),
            Text("• Usa hilo dental."),
            SizedBox(height: 8),
            Text("• Cambia cepillo cada 3 meses."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  void _mostrarCuidadosPostTratamiento(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🩺 Cuidados", style: TextStyle(color: Colors.teal)),
        content: const Text("No ingerir alimentos sólidos por 4 horas."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled
          ? onTap
          : () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sin acciones pendientes.")),
            ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : Colors.grey[300],
              shape: BoxShape.circle,
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isEnabled ? const Color(0xFF0277BD) : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isEnabled ? Colors.grey : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassicMenuItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
    Color color = const Color(0xFF0277BD),
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 26),
      title: Text(
        title,
        style: TextStyle(
          color: color == Colors.redAccent ? Colors.redAccent : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
    );
  }

  Widget _buildActionButton(
    String text,
    Color color,
    bool filled, {
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? color : Colors.white,
        foregroundColor: filled ? Colors.white : color,
        elevation: filled ? 2 : 0,
        side: filled ? null : BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      ),
      child: Text(text),
    );
  }
}

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'clinic_screen.dart';
import 'dentist_screen.dart';
import 'treatment_screen.dart';
import 'payments_screen.dart';
import 'settings_screen.dart';
import '../models/cita_model.dart';
import '../services/citas_service.dart';
import '../services/clinica_service.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/publicidad_model.dart';
import '../services/publicidad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

// 1. Agregamos WidgetsBindingObserver para escuchar cuando la app va a segundo plano y regresa
class _MainDashboardState extends State<MainDashboard>
    with WidgetsBindingObserver {
  bool tratamientoRealizado = true;

  List<CitaModel> citasProximas = [];
  bool isLoadingCita = true;
  List<PublicidadModel> listaPromociones = [];
  bool isLoadingPromo = true;
  List<String> _diasBloqueados = [];
  List<int> _diasSemanaCerrados = [];
  String miToken = "";
  String nombrePaciente = "Cargando...";
  String correoPaciente = "Cargando...";
  String fotoPerfilUrl = "";
  String direccionClinica = 'Centro, Tehuacán, Puebla';

  @override
  void initState() {
    super.initState();
    // Registramos el observador del ciclo de vida
    WidgetsBinding.instance.addObserver(this);
    _inicializarPantalla();
  }

  // 2. Limpiamos el observador cuando la pantalla se destruye
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 3. Detectamos cuando la app regresa del segundo plano para recargar
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _inicializarPantalla();
    }
  }

  Future<void> _inicializarPantalla() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    setState(() {
      miToken = token;
    });

    if (miToken.isNotEmpty) {
      final response = await AuthService.getProfile();
      if (mounted && response['success'] == true) {
        final paciente = response['paciente'];
        setState(() {
          nombrePaciente = paciente['nombre_completo'] ?? "Paciente";
          correoPaciente = paciente['email'] ?? "paciente@sakary.com";
          fotoPerfilUrl = paciente['foto_perfil'] ?? "";
        });
      }

      _cargarCitaDesdeBD();
      _cargarPromociones();
      _cargarDiasBloqueados();
      _cargarDatosClinica();
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

  Future<void> _cargarCitaDesdeBD() async {
    final citas = await CitasService.obtenerProximasCitas(miToken);
    if (mounted) {
      setState(() {
        final ahora = DateTime.now();
        var citasFiltradas = citas.where((cita) {
          return cita.fechaHoraInicio.isAfter(ahora);
        }).toList();

        citasFiltradas.sort(
          (a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio),
        );

        if (citasFiltradas.isNotEmpty) {
          citasProximas = [citasFiltradas.first];
        } else {
          citasProximas = [];
        }

        isLoadingCita = false;
      });
    }
  }

  Future<void> _cargarPromociones() async {
    final promos = await PublicidadService.obtenerPromocionesActivas(miToken);
    if (mounted) {
      setState(() {
        listaPromociones = promos;
        isLoadingPromo = false;
      });
    }
  }

  Future<void> _cargarDatosClinica() async {
    final clinica = await ClinicaService.obtenerDatosClinica(miToken);

    if (mounted) {
      setState(() {
        direccionClinica = clinica?.direccion ?? 'Centro, Tehuacán, Puebla';
      });
    }
  }

  Future<void> _abrirGoogleMaps() async {
    final String urlCodificada = Uri.encodeFull(
      'https://www.google.com/maps/search/?api=1&query=$direccionClinica',
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
    final citaPrimera = citasProximas.isNotEmpty ? citasProximas.first : null;
    final bool tieneHigiene =
        citaPrimera != null &&
        citaPrimera.tipsHigiene.isNotEmpty &&
        citaPrimera.tipsHigiene.startsWith('http');
    final bool tieneCuidados =
        citaPrimera != null &&
        citaPrimera.cuidados.isNotEmpty &&
        citaPrimera.cuidados.startsWith('http');

    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ACCESIBILIDAD: Etiqueta semántica para el botón de menú lateral
        iconTheme: const IconThemeData(color: Color(0xFF0277BD)),
        actions: [
          // ACCESIBILIDAD: Se envuelve el GestureDetector en Semantics para lectores de pantalla
          Semantics(
            button: true,
            label: 'Abrir configuración y perfil',
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ).then((_) => _inicializarPantalla());
              },
              // ACCESIBILIDAD: Área táctil expandida con padding
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF0277BD),
                  radius: 18,
                  backgroundImage: fotoPerfilUrl.isNotEmpty
                      ? NetworkImage(fotoPerfilUrl)
                      : null,
                  child: fotoPerfilUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // ACCESIBILIDAD: MergeSemantics para leer los datos del paciente juntos
            MergeSemantics(
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF0277BD)),
                accountName: Text(
                  nombrePaciente,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(correoPaciente),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: fotoPerfilUrl.isNotEmpty
                      ? NetworkImage(fotoPerfilUrl)
                      : null,
                  child: fotoPerfilUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF0277BD),
                        )
                      : null,
                ),
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
                      ).then(
                        (_) => _inicializarPantalla(),
                      ); // 4. Recargar al volver
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
                      ).then(
                        (_) => _inicializarPantalla(),
                      ); // 4. Recargar al volver
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
                      ).then(
                        (_) => _inicializarPantalla(),
                      ); // 4. Recargar al volver
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
                      ).then(
                        (_) => _inicializarPantalla(),
                      ); // 4. Recargar al volver
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
                      ).then((_) => _inicializarPantalla());
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
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('token');

                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // 5. Agregamos RefreshIndicator y AlwaysScrollableScrollPhysics
      body: RefreshIndicator(
        onRefresh: _inicializarPantalla,
        color: const Color(0xFF0277BD),
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Importante para que siempre se pueda hacer Pull-to-Refresh
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ACCESIBILIDAD: El saludo se lee como encabezado
              Semantics(
                header: true,
                child: Text(
                  "Hola, ${nombrePaciente.split(' ')[0]} 👋",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF014F7E),
                  ),
                ),
              ),
              const Text(
                "¿Cómo está tu sonrisa hoy?",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              if (isLoadingPromo)
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0277BD)),
                  ),
                )
              else if (listaPromociones.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listaPromociones.length,
                    itemBuilder: (context, index) {
                      final promo = listaPromociones[index];
                      // ACCESIBILIDAD: Agrupa toda la info de la promo en una sola lectura
                      return MergeSemantics(
                        child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          margin: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            image: promo.imagenUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(promo.imagenUrl),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.5),
                                      BlendMode.darken,
                                    ),
                                  )
                                : null,
                            gradient: promo.imagenUrl.isEmpty
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF0277BD),
                                      Color(0xFF4FC3F7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
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
                              // ACCESIBILIDAD: Ocultar gráficos decorativos al lector
                              ExcludeSemantics(
                                child: Positioned(
                                  right: -20,
                                  top: -20,
                                  child: CircleAvatar(
                                    radius: 80,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.1,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      promo.titulo,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      promo.descripcion,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 35),

              Semantics(
                header: true,
                child: const Text(
                  "Tu Próxima Cita",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (isLoadingCita)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF0277BD)),
                  ),
                )
              else if (citasProximas.isEmpty)
                MergeSemantics(
                  child: Container(
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
                        ExcludeSemantics(
                          child: const Icon(
                            Icons.event_busy,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No tienes citas próximas",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Comunícate con la clínica para agendar tu próxima visita.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...citasProximas.map((cita) {
                  final DateTime fechaCita = cita.fechaHoraInicio;
                  final String estadoCita = cita.estadoCita;

                  // ACCESIBILIDAD: Todo el contenedor de la cita es un solo bloque semántico
                  return MergeSemantics(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 15),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    ExcludeSemantics(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE1F5FE),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month,
                                          color: Color(0xFF0277BD),
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      estadoCita.toLowerCase() == 'confirmada'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        estadoCita.toLowerCase() == 'confirmada'
                                        ? Colors.green
                                        : Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Semantics(
                                  label: "Estado de la cita: ",
                                  child: Text(
                                    estadoCita.toUpperCase(),
                                    style: TextStyle(
                                      color:
                                          estadoCita.toLowerCase() ==
                                              'confirmada'
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Divider(
                              color: Color(0xFFEEEEEE),
                              thickness: 1,
                            ),
                          ),
                          Row(
                            children: [
                              ExcludeSemantics(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.medical_information,
                                    color: Color(0xFF0277BD),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Tratamiento a realizar:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      cita.nombreServicio,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (cita.estadoCita.toLowerCase() !=
                              'confirmada') ...[
                            const SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    "Confirmar",
                                    const Color(0xFF0277BD),
                                    true,
                                    onTap: () => _accionConfirmar(cita.id),
                                    semanticHint:
                                        "Confirmar cita del ${fechaCita.day} de ${_obtenerMes(fechaCita.month)}",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildActionButton(
                                    "Reagendar",
                                    cita.haSidoReagendada
                                        ? Colors.grey.shade400
                                        : Colors.grey,
                                    false,
                                    onTap: () {
                                      if (cita.haSidoReagendada) {
                                        _mostrarAlertaLimiteReagendos();
                                      } else {
                                        _accionReagendar(cita);
                                      }
                                    },
                                    semanticHint: cita.haSidoReagendada
                                        ? "Reagendar no disponible. Límite de reagendos alcanzado"
                                        : "Abrir calendario para reagendar cita",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 35),

              Semantics(
                header: true,
                child: const Text(
                  "Acciones Rápidas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tieneHigiene) ...[
                    _buildQuickActionItem(
                      icon: Icons.clean_hands,
                      label: "Higiene",
                      onTap: () => _mostrarRecomendacionesHigiene(context),
                      semanticLabel: "Ver PDF de recomendaciones de Higiene",
                    ),
                    const SizedBox(width: 30),
                  ],
                  if (tieneCuidados) ...[
                    _buildQuickActionItem(
                      icon: Icons.health_and_safety,
                      label: "Cuidados",
                      onTap: () => _mostrarCuidadosPostTratamiento(context),
                      semanticLabel: "Ver PDF de Cuidados post tratamiento",
                    ),
                    const SizedBox(width: 30),
                  ],
                  _buildQuickActionItem(
                    icon: Icons.map,
                    label: "Ubicación",
                    onTap: _abrirGoogleMaps,
                    semanticLabel:
                        "Abrir Google Maps con la ubicación de la clínica",
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _accionConfirmar(int idCita) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Confirmando cita en el sistema..."),
        duration: Duration(seconds: 1),
      ),
    );

    final resultado = await CitasService.confirmarCita(miToken, idCita);

    if (mounted) {
      if (resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Cita confirmada exitosamente!"),
            backgroundColor: Colors.green,
          ),
        );
        _cargarCitaDesdeBD();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _accionReagendar(CitaModel citaAReagendar) {
    final BuildContext contextoPrincipal = context;

    DateTime fechaCitaActual = DateTime(
      citaAReagendar.fechaHoraInicio.year,
      citaAReagendar.fechaHoraInicio.month,
      citaAReagendar.fechaHoraInicio.day,
    );

    DateTime buscarPrimerDiaLibre() {
      DateTime diaPrueba = fechaCitaActual.add(const Duration(days: 1));
      for (int i = 0; i < 60; i++) {
        String fechaStr =
            "${diaPrueba.year}-${diaPrueba.month.toString().padLeft(2, '0')}-${diaPrueba.day.toString().padLeft(2, '0')}";
        if (!_diasBloqueados.contains(fechaStr) &&
            !_diasSemanaCerrados.contains(diaPrueba.weekday)) {
          return diaPrueba;
        }
        diaPrueba = diaPrueba.add(const Duration(days: 1));
      }
      return fechaCitaActual.add(const Duration(days: 1));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        DateTime fechaTemp = buscarPrimerDiaLibre();
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
                  Semantics(
                    header: true,
                    child: Text(
                      pasoActual == 1
                          ? "Selecciona el Día"
                          : "Selecciona la Hora",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF014F7E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                          firstDate: DateTime.now().isAfter(fechaCitaActual)
                              ? DateTime.now()
                              : fechaCitaActual.add(const Duration(days: 1)),
                          lastDate: DateTime(2030),
                          selectableDayPredicate: (DateTime day) {
                            DateTime fechaEvaluar = DateTime(
                              day.year,
                              day.month,
                              day.day,
                            );

                            if (!fechaEvaluar.isAfter(fechaCitaActual)) {
                              return false;
                            }

                            String fechaStr =
                                "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

                            if (_diasBloqueados.contains(fechaStr)) {
                              return false;
                            }

                            if (_diasSemanaCerrados.contains(day.weekday)) {
                              return false;
                            }

                            return true;
                          },
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

                  if (pasoActual == 2) ...[
                    MergeSemantics(
                      child: Container(
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Horarios Disponibles:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: horariosDisponibles.map((hora) {
                                return _buildTimeOption(
                                  hora,
                                  horaSeleccionada,
                                  (val) => setModalState(
                                    () => horaSeleccionada = val,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
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
                                    setModalState(
                                      () => isLoadingHorarios = true,
                                    );

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

                                    final Map<String, dynamic> resultado =
                                        await CitasService.reagendarCita(
                                          miToken,
                                          citaAReagendar.id,
                                          fechaTemp,
                                          horaSeleccionada!,
                                        );

                                    if (mounted) {
                                      Navigator.pop(ctx);

                                      if (resultado['success'] == true) {
                                        ScaffoldMessenger.of(
                                          contextoPrincipal,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              resultado['message']
                                                      ?.toString() ??
                                                  "¡Cita reagendada con éxito!",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        _cargarCitaDesdeBD();
                                      } else {
                                        ScaffoldMessenger.of(
                                          contextoPrincipal,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              resultado['message']
                                                      ?.toString() ??
                                                  "Error al reagendar.",
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

  void _mostrarAlertaLimiteReagendos() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Por políticas de asistencia, solo puedes reagendar tu cita una vez.',
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Widget _buildTimeOption(
    String time,
    String? selected,
    Function(String) onSelect,
  ) {
    bool isSelected = time == selected;
    // ACCESIBILIDAD: Decirle al usuario qué hora es y si está seleccionada
    return Semantics(
      button: true,
      label: 'Horario $time',
      selected: isSelected,
      child: GestureDetector(
        onTap: () => onSelect(time),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0277BD) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0277BD)
                  : Colors.grey.shade300,
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
      ),
    );
  }

  String _obtenerMes(int mes) {
    const meses = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre",
    ];
    return meses[mes - 1];
  }

  void _mostrarRecomendacionesHigiene(BuildContext context) async {
    final citaPrimera = citasProximas.isNotEmpty ? citasProximas.first : null;
    if (citaPrimera != null &&
        citaPrimera.tipsHigiene.isNotEmpty &&
        citaPrimera.tipsHigiene.startsWith('http')) {
      final Uri urlPdf = Uri.parse(citaPrimera.tipsHigiene);
      try {
        if (!await launchUrl(urlPdf, mode: LaunchMode.externalApplication)) {
          throw Exception('No se pudo abrir el PDF');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ocurrió un error al intentar abrir el documento."),
            ),
          );
        }
      }
    }
  }

  void _mostrarCuidadosPostTratamiento(BuildContext context) async {
    final citaPrimera = citasProximas.isNotEmpty ? citasProximas.first : null;
    if (citaPrimera != null &&
        citaPrimera.cuidados.isNotEmpty &&
        citaPrimera.cuidados.startsWith('http')) {
      final Uri urlPdf = Uri.parse(citaPrimera.cuidados);
      try {
        if (!await launchUrl(urlPdf, mode: LaunchMode.externalApplication)) {
          throw Exception('No se pudo abrir el PDF');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ocurrió un error al intentar abrir el documento."),
            ),
          );
        }
      }
    }
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required String semanticLabel,
    bool isEnabled = true,
  }) {
    // ACCESIBILIDAD: Se envuelve la acción rápida en Semantics
    return Semantics(
      button: true,
      label: isEnabled
          ? "Acción rápida: $semanticLabel"
          : "$label, no disponible en este momento",
      child: GestureDetector(
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
              // Excluimos la semántica del icono puro porque ya tenemos el label principal
              child: ExcludeSemantics(
                child: Icon(
                  icon,
                  color: isEnabled ? const Color(0xFF0277BD) : Colors.grey,
                  size: 28,
                ),
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
      ),
    );
  }

  Widget _buildClassicMenuItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
    Color color = const Color(0xFF0277BD),
  }) {
    // ACCESIBILIDAD: El ListTile maneja muy bien el área táctil y la semántica nativa
    return ListTile(
      leading: ExcludeSemantics(child: Icon(icon, color: color, size: 26)),
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
    String? semanticHint,
  }) {
    return Semantics(
      button: true,
      hint: semanticHint,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? color : Colors.white,
          foregroundColor: filled ? Colors.white : color,
          elevation: filled ? 2 : 0,
          side: filled ? null : BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          // ACCESIBILIDAD: Garantizamos el tamaño mínimo de interacción
          minimumSize: const Size(88, 48),
        ),
        child: Text(text),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clinica_model.dart';
import '../services/clinica_service.dart';

class ClinicScreen extends StatefulWidget {
  const ClinicScreen({super.key});

  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
  ClinicaModel? clinica;
  bool isLoading = true;
  String miToken = "";

  @override
  void initState() {
    super.initState();
    _cargarDatosClinica();
  }

  Future<void> _cargarDatosClinica() async {
    final prefs = await SharedPreferences.getInstance();
    miToken = prefs.getString('token') ?? "";

    final datos = await ClinicaService.obtenerDatosClinica(miToken);
    if (mounted) {
      setState(() {
        clinica = datos;
        isLoading = false;
      });
    }
  }

  Future<void> _abrirMapa(BuildContext context) async {
    final String direccion = clinica?.direccion ?? 'Centro, Tehuacán, Puebla';

    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(direccion)}',
    );

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

  Future<void> _llamarClinica(BuildContext context, String telefono) async {
    final Uri url = Uri.parse('tel:$telefono');
    try {
      if (!await launchUrl(url)) throw Exception();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al abrir la app de teléfono."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        // ACCESIBILIDAD: El título principal de la pantalla
        title: Semantics(
          header: true,
          child: const Text(
            "Nuestra Clínica",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0xFF29B6F6),
        elevation: 0,
        centerTitle: true,
        // ACCESIBILIDAD: Asegurar que el botón de regreso tenga etiqueta
        leading: Semantics(
          button: true,
          label: 'Regresar a la pantalla anterior',
          child: IconButton(
            icon: const ExcludeSemantics(
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: isLoading
          ? Semantics(
              label: 'Cargando información de la clínica',
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF0277BD)),
              ),
            )
          : clinica == null
          ? Semantics(
              label: 'Error al cargar la información',
              child: const Center(
                child: Text(
                  "Error al cargar la información de la clínica.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ENCABEZADO ESTILO PERFIL ---
                  // ACCESIBILIDAD: Agrupamos el nombre y subtítulo para que se lea fluido
                  MergeSemantics(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 30,
                        left: 20,
                        right: 20,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF29B6F6), Color(0xFF0277BD)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        children: [
                          // ACCESIBILIDAD: Ocultamos el ícono decorativo
                          ExcludeSemantics(
                            child: Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_hospital_rounded,
                                color: Color(0xFF0277BD),
                                size: 45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            clinica!.nombre,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Atención Dental Especializada",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  // --- BOTONES DE ACCIÓN ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          // ACCESIBILIDAD: Semántica explícita para botón de ubicación
                          child: Semantics(
                            button: true,
                            hint: 'Abre el mapa para ver la ruta a la clínica',
                            child: ElevatedButton.icon(
                              onPressed: () => _abrirMapa(context),
                              icon: const ExcludeSemantics(
                                child: Icon(Icons.directions),
                              ),
                              label: const Text("Cómo llegar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0277BD),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                // Garantizar área táctil mínima
                                minimumSize: const Size(88, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          // ACCESIBILIDAD: Semántica explícita para botón de llamada
                          child: Semantics(
                            button: true,
                            hint: 'Llama por teléfono a la clínica',
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _llamarClinica(context, clinica!.telefono),
                              icon: const ExcludeSemantics(
                                child: Icon(Icons.phone),
                              ),
                              label: const Text("Llamar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0277BD),
                                side: const BorderSide(
                                  color: Color(0xFF0277BD),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                // Garantizar área táctil mínima
                                minimumSize: const Size(88, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- INFORMACIÓN DETALLADA ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ACCESIBILIDAD: Título de sección marcado como header
                        Semantics(
                          header: true,
                          child: const Text(
                            "Contacto",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF014F7E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildInfoTile(
                          Icons.location_on,
                          "Dirección",
                          clinica!.direccion,
                        ),
                        _buildInfoTile(
                          Icons.phone_android,
                          "Teléfono",
                          clinica!.telefono,
                        ),

                        const SizedBox(height: 25),

                        // ACCESIBILIDAD: Título de sección marcado como header
                        Semantics(
                          header: true,
                          child: const Text(
                            "Horarios de Atención",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF014F7E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        if (clinica!.horariosLista.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: clinica!.horariosLista.asMap().entries.map((
                                entry,
                              ) {
                                int index = entry.key;
                                var horario = entry.value;

                                return Column(
                                  children: [
                                    // ACCESIBILIDAD: Fusionamos la fila del día para que se lea como una sola oración
                                    MergeSemantics(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              // ACCESIBILIDAD: Ocultar icono decorativo
                                              ExcludeSemantics(
                                                child: Icon(
                                                  Icons.access_time,
                                                  color: horario['esCerrado']
                                                      ? Colors.grey.shade400
                                                      : const Color(0xFF29B6F6),
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                horario['dia'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: horario['esCerrado']
                                                      ? Colors.grey.shade500
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            horario['horas'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: horario['esCerrado']
                                                  ? Colors.redAccent
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index <
                                        clinica!.horariosLista.length - 1)
                                      const Divider(
                                        height: 24,
                                        color: Color(0xFFEEEEEE),
                                        thickness: 1,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        if (clinica!.horariosLista.isEmpty)
                          Semantics(
                            label: "No hay horarios configurados en el sistema",
                            child: const Text(
                              "Horarios no configurados",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String subtitle, {
    bool esCerrado = false,
  }) {
    // ACCESIBILIDAD: Unir título y contenido para que se lea "Dirección: Centro, Tehuacán..."
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: esCerrado
                      ? Colors.grey.shade200
                      : const Color(0xFFE1F5FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: esCerrado
                      ? Colors.grey.shade600
                      : const Color(0xFF29B6F6),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: esCerrado ? Colors.grey.shade600 : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    // Dejamos que el texto crezca si el paciente hace la letra muy grande en su teléfono
                    style: TextStyle(
                      color: esCerrado ? Colors.redAccent : Colors.grey,
                      height: 1.4,
                      fontWeight: esCerrado
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

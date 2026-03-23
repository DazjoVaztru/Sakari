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

  // Función para abrir Google Maps REAL
  Future<void> _abrirMapa(BuildContext context) async {
    // Tomamos la dirección real que trajo Laravel
    final String direccion = clinica?.direccion ?? 'Centro, Tehuacán, Puebla';

    // Esta es la URL universal (Query) que entiende tanto Android como iOS para abrir su app de mapas
    // Nota: Agregué el signo de dólar ($) que faltaba en tu variable Uri.encodeComponent para que funcione correctamente.
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(direccion)}',
    );

    try {
      // mode: LaunchMode.externalApplication fuerza a que se abra en la App de Google Maps y no en el navegador de la app
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

  // Función para llamar
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
        title: const Text(
          "Nuestra Clínica",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(
          0xFF29B6F6,
        ), // <-- AQUÍ ESTÁ TU COLOR CELESTE ORIGINAL
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0277BD)),
            )
          : clinica == null
          ? const Center(
              child: Text(
                "Error al cargar la información de la clínica.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TÍTULO DE LA CLÍNICA (En lugar de la imagen que quitamos) ---
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 25,
                      left: 20,
                      right: 20,
                      bottom: 10,
                    ),
                    child: Center(
                      child: Text(
                        clinica!.nombre,
                        style: const TextStyle(
                          color: Color(0xFF0277BD), // Azul fuerte para resaltar
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- BOTONES DE ACCIÓN ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _abrirMapa(context),
                            icon: const Icon(Icons.directions),
                            label: const Text("Cómo llegar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0277BD),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _llamarClinica(context, clinica!.telefono),
                            icon: const Icon(Icons.phone),
                            label: const Text("Llamar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0277BD),
                              side: const BorderSide(color: Color(0xFF0277BD)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
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
                        const Text(
                          "Contacto",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF014F7E),
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

                        const Text(
                          "Horarios de Atención",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF014F7E),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 🔥 DIBUJA LOS 7 DÍAS AUTOMÁTICAMENTE EN 2 COLUMNAS 🔥
                        // 🔥 DIBUJA LOS 7 DÍAS AUTOMÁTICAMENTE EN LISTA (NUEVO DISEÑO) 🔥
                        if (clinica!.horariosLista.isNotEmpty)
                          ...clinica!.horariosLista.map(
                            (horario) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Empuja el día a la izq y la hora a la der
                                children: [
                                  // Lado Izquierdo: Ícono y Día
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: horario['esCerrado']
                                            ? Colors.grey.shade400
                                            : const Color(0xFF29B6F6),
                                        size: 20,
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

                                  // Lado Derecho: Horas
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
                          ),
                        if (clinica!.horariosLista.isEmpty)
                          const Text(
                            "Horarios no configurados",
                            style: TextStyle(color: Colors.grey),
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

  // Solo agrégale el parámetro esCerrado al final
  Widget _buildInfoTile(
    IconData icon,
    String title,
    String subtitle, {
    bool esCerrado = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Si está cerrado, fondo gris clarito
              color: esCerrado ? Colors.grey.shade200 : const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(10),
            ),
            // Si está cerrado, ícono gris oscuro
            child: Icon(
              icon,
              color: esCerrado ? Colors.grey.shade600 : const Color(0xFF29B6F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start, // Deja que el texto suba
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: esCerrado ? Colors.grey.shade600 : Colors.black87,
                  ),
                  // 🔥 NUEVO: Forzamos a que si el día es largo, se corte
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  // 🔥 NUEVO: Forzamos a que si la hora es larga, se corte
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: esCerrado ? Colors.redAccent : Colors.grey,
                    height: 1.4,
                    fontWeight: esCerrado ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

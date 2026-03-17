import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarDatosClinica();
  }

  Future<void> _cargarDatosClinica() async {
    final datos = await ClinicaService.obtenerDatosClinica();
    if (mounted) {
      setState(() {
        clinica = datos;
        isLoading = false;
      });
    }
  }

  // Función para abrir Google Maps
  Future<void> _abrirMapa(BuildContext context) async {
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
                  // --- IMAGEN PRINCIPAL ---
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(clinica!.imagenUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        clinica!.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                        _buildInfoTile(Icons.email, "Correo", clinica!.email),

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
                        _buildInfoTile(
                          Icons.access_time,
                          "Lunes a Viernes",
                          clinica!.horarioSemana,
                        ),
                        _buildInfoTile(
                          Icons.weekend,
                          "Fines de Semana",
                          clinica!.horarioFinSemana,
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

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE), // Fondo suave
              borderRadius: BorderRadius.circular(10),
            ),
            // <-- Color celeste en el icono para que combine
            child: Icon(icon, color: const Color(0xFF29B6F6), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

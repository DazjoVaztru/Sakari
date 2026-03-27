import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doctor_model.dart';
import '../services/doctor_service.dart';

class DentistScreen extends StatefulWidget {
  const DentistScreen({super.key});

  @override
  State<DentistScreen> createState() => _DentistScreenState();
}

class _DentistScreenState extends State<DentistScreen> {
  DoctorModel? doctor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDoctor();
  }

  Future<void> _cargarDoctor() async {
    // Simulamos que el paciente tiene asignado al doctor con ID 1
    final doc = await DoctorService.obtenerPerfilDoctor(1);
    if (mounted) {
      setState(() {
        doctor = doc;
        isLoading = false;
      });
    }
  }

  Future<void> _abrirWhatsApp(BuildContext context, String telefono) async {
    const String mensaje =
        'Hola, me comunico desde la app SAKARI para una consulta.';
    final Uri url = Uri.parse(
      'whatsapp://send?phone=$telefono&text=${Uri.encodeComponent(mensaje)}',
    );
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se pudo abrir WhatsApp."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _hacerLlamada(BuildContext context, String telefono) async {
    final Uri url = Uri.parse('tel:$telefono');
    try {
      if (!await launchUrl(url)) throw Exception();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se pudo abrir la aplicación de teléfono."),
            backgroundColor: Colors.red,
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
        title: const Text(
          "Mi Dentista",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0277BD),
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
          : doctor == null
          ? const Center(
              child: Text(
                "Error al cargar la información del doctor.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0277BD),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -60,
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: NetworkImage(doctor!.imagenUrl),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),
                  Text(
                    doctor!.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF014F7E),
                    ),
                  ),
                  Text(
                    doctor!.especialidad,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Cédula Prof: ${doctor!.cedula}",
                      style: const TextStyle(
                        color: Color(0xFF0277BD),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _abrirWhatsApp(context, doctor!.telefono),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text("WhatsApp"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
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
                                _hacerLlamada(context, doctor!.telefono),
                            icon: const Icon(Icons.call),
                            label: const Text("Llamar"),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(doctor!.anosExperiencia, "Años Exp."),
                      _buildStatItem(doctor!.calificacion, "Calificación"),
                      _buildStatItem(doctor!.pacientesAtendidos, "Pacientes"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sobre mí",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          doctor!.sobreMi,
                          style: const TextStyle(
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0277BD),
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

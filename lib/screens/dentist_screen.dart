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
  // Utilizamos nuestra clase Doctor
  Doctor? doctor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDoctor();
  }

  Future<void> _cargarDoctor() async {
    // Traemos la lista de doctores de la clínica desde la SaaS
    final doctores = await DoctorService.getDoctores();

    if (mounted) {
      setState(() {
        // Tomamos el primer doctor de la lista (o null si la clínica no tiene doctores)
        doctor = doctores.isNotEmpty ? doctores.first : null;
        isLoading = false;
      });
    }
  }

  Future<void> _abrirWhatsApp(BuildContext context, String telefono) async {
    // Limpiamos espacios en blanco del número
    String celLimpio = telefono.replaceAll(' ', '');
    const String mensaje =
        'Hola, me comunico desde la app DentalConnect para una consulta.';

    // Formato universal de WhatsApp
    final Uri url = Uri.parse(
      'https://wa.me/$celLimpio?text=${Uri.encodeComponent(mensaje)}',
    );

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  Future<void> _llamarDoctor(BuildContext context, String telefono) async {
    String celLimpio = telefono.replaceAll(' ', '');
    final Uri url = Uri.parse('tel:$celLimpio');

    try {
      if (!await launchUrl(url)) throw Exception();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la app de llamadas')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Perfil del Dentista",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0277BD),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text("Aún no hay dentistas asignados a tu clínica."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fondo claro
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección superior con la foto e info principal
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0277BD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Foto del doctor
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        (doctor!.fotoPerfilUrl != null &&
                            doctor!.fotoPerfilUrl!.isNotEmpty)
                        ? NetworkImage(doctor!.fotoPerfilUrl!)
                        : null,
                    child:
                        (doctor!.fotoPerfilUrl == null ||
                            doctor!.fotoPerfilUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  // Nombre del doctor
                  Text(
                    doctor!.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Especialidad
                  Text(
                    doctor!.especialidad,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[100],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- SECCIÓN DE STATS REMOVIDA A PETICIÓN DEL EQUIPO ---
                  const SizedBox(height: 30),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sección de Botones de Contacto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _abrirWhatsApp(context, doctor!.telefono),
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text(
                        "Mensaje",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF25D366,
                        ), // Color WhatsApp
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
                      onPressed: () => _llamarDoctor(context, doctor!.telefono),
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text(
                        "Llamar",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0277BD),
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

            // Sección "Sobre mí"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
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
                      style: const TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

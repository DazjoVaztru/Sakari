import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEditing = false;
  bool _isLoading = true;

  // Controladores de campos NO editables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // NUEVO: Un solo controlador para la dirección completa
  final TextEditingController _direccionController = TextEditingController();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Variable temporal para guardar la URL de la foto (cuando la traigamos de la base de datos)
  String? _fotoPerfilUrl;

  @override
  void initState() {
    super.initState();
    _cargarDatosPaciente();
  }

  // --- CARGAR DATOS REALES ---
  Future<void> _cargarDatosPaciente() async {
    final response = await AuthService.getProfile();

    if (response['success'] == true) {
      final paciente = response['paciente'];
      setState(() {
        _nameController.text = paciente['nombre_completo'] ?? '';
        _emailController.text = paciente['email'] ?? '';
        _phoneController.text = paciente['telefono'] ?? '';

        // Asumiendo que ahora tu backend envía todo junto en 'direccion'
        // Si tu backend envía la dirección guardada en el campo 'calle', cámbialo aquí.
        _direccionController.text =
            paciente['direccion'] ?? paciente['calle'] ?? '';

        // Guardamos la URL de la foto si tu SaaS ya la envía
        _fotoPerfilUrl = paciente['foto_perfil'];

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: ${response['message']}')),
        );
      }
    }
  }

  // --- GUARDAR DATOS PERSONALES ---
  Future<void> _guardarDatosPersonales() async {
    setState(() => _isLoading = true);

    // Ahora enviamos un solo campo para la dirección
    final data = {
      'direccion': _direccionController
          .text, // Asegúrate de que Laravel reciba este mismo nombre
    };

    final response = await AuthService.updateProfile(data);

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Datos actualizados')),
      );
    }
  }

  // --- FUNCION PARA CAMBIAR FOTO (A FUTURO) ---
  void _cambiarFotoPerfil() {
    // Aquí pondremos la lógica del ImagePicker para subir la foto a Laravel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Abrir galería para cambiar foto 📷'),
      ),
    );
  }

  // --- CAMBIAR CONTRASEÑA ---
  Future<void> _cambiarPassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Llena ambos campos de contraseña')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await AuthService.updatePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Proceso finalizado')),
      );
    }

    if (response['success'] == true) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
    }
  }

  void _mostrarDialogoPassword() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña Actual',
                ),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _cambiarPassword();
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text(
          "Configuración",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0277BD),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isEditing) {
                _guardarDatosPersonales();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // --- DISEÑO DE FOTO DE PERFIL CON BOTÓN ---
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFF0277BD),
                        backgroundImage:
                            _fotoPerfilUrl != null && _fotoPerfilUrl!.isNotEmpty
                            ? NetworkImage(
                                _fotoPerfilUrl!,
                              ) // Muestra la foto de la BD
                            : null,
                        child: _fotoPerfilUrl == null || _fotoPerfilUrl!.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ) // Icono por defecto
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _cambiarFotoPerfil,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF0277BD),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle("Datos Personales"),
                  const SizedBox(height: 10),
                  _buildTextField(
                    "Nombre Completo",
                    _nameController,
                    Icons.person,
                    false,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Correo Electrónico",
                    _emailController,
                    Icons.email,
                    false,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Teléfono",
                    _phoneController,
                    Icons.phone,
                    false,
                  ),

                  const SizedBox(height: 25),

                  _buildSectionTitle("Dirección"),
                  const SizedBox(height: 10),
                  // Cambiamos por un solo TextField que se puede hacer grande (maxLines)
                  _buildTextField(
                    "Dirección Completa",
                    _direccionController,
                    Icons.location_on,
                    _isEditing,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 35),

                  _buildSectionTitle("Seguridad"),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _mostrarDialogoPassword,
                    icon: const Icon(Icons.lock_reset, color: Colors.white),
                    label: const Text(
                      "Cambiar Contraseña",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0277BD),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF014F7E),
        ),
      ),
    );
  }

  // Agregué el parámetro opcional 'maxLines' para que el campo de dirección sea más alto
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isFieldEnabled, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: isFieldEnabled,
      maxLines: maxLines,
      style: TextStyle(
        color: isFieldEnabled ? Colors.black87 : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint:
            maxLines > 1, // Alinea el texto arriba si el campo es alto
        prefixIcon: Icon(
          icon,
          color: isFieldEnabled ? const Color(0xFF0277BD) : Colors.grey[400],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isFieldEnabled ? Colors.white : Colors.grey[300],
      ),
    );
  }
}

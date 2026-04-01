import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEditing = false;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String? _fotoPerfilUrl;
  File? _imagenLocalSeleccionada;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarDatosPaciente();
  }

  Future<void> _cargarDatosPaciente() async {
    final response = await AuthService.getProfile();

    if (response['success'] == true) {
      final paciente = response['paciente'];
      setState(() {
        _nameController.text = paciente['nombre_completo'] ?? '';
        _emailController.text = paciente['email'] ?? '';
        _phoneController.text = paciente['telefono'] ?? '';
        _direccionController.text = paciente['direccion'] ?? '';
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

  Future<void> _guardarDatosPersonales() async {
    setState(() => _isLoading = true);

    final data = {'direccion': _direccionController.text};
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

  void _mostrarOpcionesDeFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Actualizar Foto de Perfil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0277BD)),
              title: const Text('Tomar Foto con la Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? foto = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (foto != null) {
                  setState(() => _imagenLocalSeleccionada = File(foto.path));
                  _subirFotoPerfil(File(foto.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF0277BD),
              ),
              title: const Text('Elegir de la Galería'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? foto = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
                if (foto != null) {
                  setState(() => _imagenLocalSeleccionada = File(foto.path));
                  _subirFotoPerfil(File(foto.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _subirFotoPerfil(File imagen) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Subiendo nueva foto... ⏳')));

    final response = await AuthService.uploadProfileImage(imagen);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Foto actualizada ✅')),
      );
    }
  }

  Future<void> _cambiarPassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Llena ambos campos de contraseña')),
      );
      return;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La nueva contraseña no puede ser igual a la actual ⚠️',
          ),
          backgroundColor: Colors.orange,
        ),
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
    bool isCurrentPasswordVisible = false;
    bool isNewPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Cambiar Contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo: Contraseña Actual
                  TextField(
                    controller: _currentPasswordController,
                    obscureText:
                        !isCurrentPasswordVisible, // Controla si se oculta o no
                    decoration: InputDecoration(
                      labelText: 'Contraseña Actual',
                      // Icono de visibilidad (ojito)
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCurrentPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF0277BD),
                        ),
                        onPressed: () {
                          // Actualizamos el estado local del diálogo
                          setStateDialog(() {
                            isCurrentPasswordVisible =
                                !isCurrentPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Pequeño espacio
                  // Campo: Nueva Contraseña
                  TextField(
                    controller: _newPasswordController,
                    obscureText:
                        !isNewPasswordVisible, // Controla si se oculta o no
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      // Icono de visibilidad (ojito)
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF0277BD),
                        ),
                        onPressed: () {
                          // Actualizamos el estado local del diálogo
                          setStateDialog(() {
                            isNewPasswordVisible = !isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Limpiamos los controladores al cancelar
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    Navigator.pop(context);
                  },
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

                  // --- FOTO DE PERFIL ---
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFF0277BD),
                        backgroundImage: _imagenLocalSeleccionada != null
                            ? FileImage(_imagenLocalSeleccionada!)
                                  as ImageProvider
                            : (_fotoPerfilUrl != null &&
                                      _fotoPerfilUrl!.isNotEmpty
                                  ? NetworkImage(_fotoPerfilUrl!)
                                  : null),
                        child:
                            (_imagenLocalSeleccionada == null &&
                                (_fotoPerfilUrl == null ||
                                    _fotoPerfilUrl!.isEmpty))
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _mostrarOpcionesDeFoto,
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
                  // Le quitamos el maxLines para que vuelva a su tamaño normal
                  _buildTextField(
                    "Dirección Completa",
                    _direccionController,
                    Icons.location_on,
                    _isEditing,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isFieldEnabled,
  ) {
    return TextField(
      controller: controller,
      enabled: isFieldEnabled,
      style: TextStyle(
        color: isFieldEnabled ? Colors.black87 : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
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

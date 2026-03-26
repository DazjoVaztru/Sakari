import 'package:flutter/material.dart';
// IMPORTANTE: Asegúrate de importar la ruta correcta donde tienes tus servicios
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEditing = false;
  bool _isLoading = true; // Iniciamos cargando

  // Dejamos los controladores vacíos inicialmente
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosPaciente(); // Llamamos a la función al iniciar la pantalla
  }

  // --- FUNCIÓN PARA CARGAR LOS DATOS REALES ---
  Future<void> _cargarDatosPaciente() async {
    final response = await AuthService.getProfile();

    if (response['success'] == true) {
      final paciente = response['paciente'];
      setState(() {
        _nameController.text = paciente['nombre_completo'] ?? '';
        _emailController.text = paciente['email'] ?? '';
        _phoneController.text = paciente['telefono'] ?? '';
        _calleController.text = paciente['calle'] ?? '';
        _coloniaController.text = paciente['colonia'] ?? '';
        _ciudadController.text = paciente['ciudad'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${response['message']}'),
          ),
        );
      }
    }
  }

  // --- FUNCIÓN 1: Guardar Datos ---
  Future<void> _guardarDatosPersonales() async {
    setState(() => _isLoading = true);

    final data = {
      'calle': _calleController.text,
      'colonia': _coloniaController.text,
      'ciudad': _ciudadController.text,
    };

    final response = await AuthService.updateProfile(data);

    setState(() {
      _isLoading = false;
      _isEditing = false; // Bloqueamos los campos al terminar
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Datos actualizados')),
      );
    }
  }

  // --- FUNCIÓN 2: Cambiar Contraseña ---
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

  // DIÁLOGO PARA PEDIR LAS CONTRASEÑAS
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
                Navigator.pop(context); // Cierra el diálogo
                _cambiarPassword(); // Ejecuta la función
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
            // El icono cambia dependiendo de si estamos editando o no
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF0277BD),
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // --- SECCIÓN BLOQUEADA ---
                  _buildSectionTitle("Datos Personales"),
                  const SizedBox(height: 10),
                  // Observa el "false" al final, indica que NUNCA se pueden editar
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

                  // --- SECCIÓN EDITABLE ---
                  _buildSectionTitle("Dirección"),
                  const SizedBox(height: 10),
                  // Observa el "_isEditing", indica que se activan al darle al botón del AppBar
                  _buildTextField(
                    "Calle y Número",
                    _calleController,
                    Icons.location_on,
                    _isEditing,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Colonia",
                    _coloniaController,
                    Icons.holiday_village,
                    _isEditing,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Ciudad",
                    _ciudadController,
                    Icons.location_city,
                    _isEditing,
                  ),

                  const SizedBox(height: 35),

                  // --- SECCIÓN SEGURIDAD ---
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

  // Modifiqué esta función para que acepte un parámetro booleano de si está activo o no
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
        // Si está bloqueado, se pone en un gris muy sutil para que el paciente sepa que no se toca
        fillColor: isFieldEnabled ? Colors.white : Colors.grey[300],
      ),
    );
  }
}

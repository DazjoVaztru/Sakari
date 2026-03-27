import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEditing = false;
  bool _notificaciones = true;
  // Eliminamos la variable _biometria

  final TextEditingController _nameController = TextEditingController(
    text: "Josue David",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "paciente@sakary.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "238 123 4567",
  );

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
              _isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _isEditing = !_isEditing),
            tooltip: _isEditing ? "Cancelar" : "Editar Perfil",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0277BD),
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0277BD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (!_isEditing)
              const Text(
                "Toca el lápiz arriba para editar",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 30),
            _buildSectionTitle("Datos Personales"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    "Nombre Completo",
                    _nameController,
                    Icons.person,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Correo Electrónico",
                    _emailController,
                    Icons.email,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField("Teléfono", _phoneController, Icons.phone),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Preferencias"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      "Recibir Notificaciones",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text("Recordatorios de citas y ofertas"),
                    activeThumbColor: const Color(0xFF0277BD),
                    value: _notificaciones,
                    onChanged: (val) => setState(() => _notificaciones = val),
                  ),
                  // Eliminamos el Divider y el SwitchListTile de biometría aquí
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isEditing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Cambios guardados correctamente!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Guardar Cambios",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock_reset, color: Colors.grey),
              label: const Text(
                "Cambiar Contraseña",
                style: TextStyle(color: Colors.grey),
              ),
            ),
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
  ) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      style: TextStyle(
        color: _isEditing ? Colors.black87 : Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: _isEditing ? const Color(0xFF0277BD) : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: _isEditing ? const Color(0xFFE1F5FE) : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Añadido para los formatters de texto

// 1. La Tarjeta Blanca con Sombra
Widget buildFormCard(
  BuildContext context, {
  required String title,
  required List<Widget> children,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.blueGrey.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 30),
        ...children,
      ],
    ),
  );
}

// 2. Campo de Texto Estilizado (MODIFICADO)
Widget buildInput(
  IconData icon,
  String hint, {
  bool isPassword = false,
  TextEditingController? controller,
  Widget? suffixIcon, // <-- Nuevo: Para poner el ojito
  TextInputType?
  keyboardType, // <-- Nuevo: Para cambiar el tipo de teclado (números)
  List<TextInputFormatter>?
  inputFormatters, // <-- Nuevo: Para forzar solo dígitos
  int? maxLength, // <-- Nuevo: Para limitar a 10 caracteres
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    maxLength: maxLength,
    decoration: InputDecoration(
      counterText: "", // Oculta el contador de texto "0/10" debajo del input
      prefixIcon: Icon(icon, color: const Color(0xFF0277BD)),
      suffixIcon: suffixIcon, // Agregamos el ojito aquí
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF0277BD), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}

// 3. Botón Principal Azul
Widget buildPrimaryButton(
  BuildContext context,
  String text,
  VoidCallback onPressed,
) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

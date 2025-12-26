import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool readOnly; // <--- NUEVO CAMPO

  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.controller,
    this.readOnly = false, // <--- Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly, // <--- Conectamos la propiedad
      style: TextStyle(
        fontSize: 15,
        color: readOnly ? Colors.grey[700] : null, // Visualmente indicamos que está bloqueado
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: readOnly ? Colors.grey : colors.primary)
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        filled: readOnly, // Fondo gris si es solo lectura
        fillColor: readOnly ? Colors.grey[200] : null,
      ),
    );
  }
}
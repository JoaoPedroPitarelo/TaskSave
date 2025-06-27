import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CustomDropdownMenu({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Transparente para não cobrir o resto da tela com cor sólida
      child: Container(
        width: 250, // Largura do menu
        decoration: BoxDecoration(
          color: const Color(0xFF2800FF), // Cor de fundo do menu
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem('Estágio', Colors.blue, () => onCategorySelected('Estágio')),
            const Divider(color: Colors.white54, height: 1, indent: 20, endIndent: 20), // Separador
            _buildMenuItem('Pessoal', Colors.yellow, () => onCategorySelected('Pessoal')),
            const Divider(color: Colors.white54, height: 1, indent: 20, endIndent: 20), // Separador
            _buildMenuItem('Faculdade', Colors.cyan, () => onCategorySelected('Faculdade')),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
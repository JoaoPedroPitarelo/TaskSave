import 'package:flutter/material.dart';

Widget buildDrawerItem({
  required BuildContext context,
  required IconData icon,
  required String text,
  int? count,
  bool showPlusIcon = false,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);

  return ListTile(
    leading: Icon(icon, color: Colors.white, size: 28),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: theme.textTheme.bodySmall,
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
        if (showPlusIcon) ...[
          const Spacer(),
          const Icon(Icons.add, color: Colors.white, size: 24),
        ],
      ],
    ),
    onTap: onTap,
  );
}
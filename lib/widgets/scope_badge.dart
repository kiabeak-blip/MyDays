import 'package:flutter/material.dart';
import '../models/task.dart';

class ScopeBadge extends StatelessWidget {
  final TaskScope scope;

  const ScopeBadge({super.key, required this.scope});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color color;
    final String label;

    switch (scope) {
      case TaskScope.day:
        color = cs.tertiary;
        label = 'DAY';
      case TaskScope.week:
        color = cs.secondary;
        label = 'WEEK';
      case TaskScope.month:
        color = cs.primary;
        label = 'MONTH';
      case TaskScope.custom:
        color = const Color(0xFF009688);
        label = 'CUSTOM';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';

/// The filled blue tick / empty ring the design uses to mark the chosen
/// option in a list of single-choice cards. Shared so every tool screen
/// marks selection the same way.
class SelectionMark extends StatelessWidget {
  const SelectionMark({required this.isSelected, super.key, this.size = 22});

  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    if (!isSelected) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outline, width: 1.5),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
      child: Icon(Icons.check_rounded, size: size * 0.64, color: scheme.onPrimary),
    );
  }
}

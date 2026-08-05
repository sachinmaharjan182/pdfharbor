import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';

/// Full-width drawing pad. Pops the drawn signature as transparent PNG
/// bytes, or null if cancelled.
class DrawSignatureSheet extends StatefulWidget {
  const DrawSignatureSheet({super.key});

  @override
  State<DrawSignatureSheet> createState() => _DrawSignatureSheetState();
}

class _DrawSignatureSheetState extends State<DrawSignatureSheet> {
  late SignatureController _controller;
  Color _penColor = Colors.black;

  static const List<Color> _penColors = [Colors.black, Color(0xFF1E3A8A), Color(0xFF7F1D1D)];

  @override
  void initState() {
    super.initState();
    _controller = _createController(_penColor);
  }

  /// The pen colour is fixed at construction, so changing it means
  /// rebuilding the controller and replaying the existing strokes.
  SignatureController _createController(Color color, {List<Point>? points}) {
    return SignatureController(
      points: points,
      penColor: color,
      penStrokeWidth: 3,
      exportPenColor: color,
      // Left transparent so the signature composites cleanly over page content.
      exportBackgroundColor: Colors.transparent,
    );
  }

  void _changePenColor(Color color) {
    final points = _controller.value;
    final previous = _controller;
    setState(() {
      _penColor = color;
      _controller = _createController(color, points: points);
    });
    previous.dispose();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.sm,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Draw your signature', style: context.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Signature(
                controller: _controller,
                height: 220,
                backgroundColor: context.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                for (final color in _penColors)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: InkWell(
                      onTap: () => _changePenColor(color),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _penColor == color
                                ? context.colorScheme.primary
                                : context.colorScheme.outlineVariant,
                            width: _penColor == color ? 3 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(_controller.clear),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_controller.isEmpty) {
      context.showSnackBar('Draw a signature first');
      return;
    }
    final Uint8List? bytes = await _controller.toPngBytes();
    if (!mounted) return;
    Navigator.of(context).pop(bytes);
  }
}

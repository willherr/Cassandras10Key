import 'package:flutter/material.dart';

class MaterialTextButton extends StatelessWidget {
  const MaterialTextButton(
    this.text, {
    super.key,
    required this.onPressed,
    this.primary = true,
    this.accent = false,
    this.warn = false,
  });

  final bool primary;
  final bool accent;
  final bool warn;

  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = warn
        ? theme.colorScheme.error
        : accent
            ? theme.colorScheme.secondary
            : theme.colorScheme.primary;

    return TextButton(
      style: ButtonStyle(
        overlayColor: MaterialStatePropertyAll(color.withOpacity(.2)),
      ),
      onPressed: () => onPressed(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(color: color, fontSize: 18)),
      ),
    );
  }
}

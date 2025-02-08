import 'package:flutter/material.dart';

class MaterialTextButton extends StatelessWidget {
  const MaterialTextButton(this.text,
      {super.key,
      required this.onPressed,
      this.primary = true,
      this.accent = false,
      this.warn = false,
      this.fontSize = 26});

  final bool primary;
  final bool accent;
  final bool warn;

  final String text;
  final Function? onPressed;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    final theme = Theme.of(context);
    final color = isDisabled
        ? Colors.grey
        : warn
            ? theme.colorScheme.error
            : accent
                ? theme.colorScheme.secondary
                : theme.colorScheme.primary;

    return TextButton(
      style: ButtonStyle(
        overlayColor: WidgetStatePropertyAll(color.withOpacity(.2)),
      ),
      onPressed: onPressed == null ? null : () => onPressed!(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(color: color, fontSize: fontSize)),
      ),
    );
  }
}

import 'package:adding_machine/ui/material_text_button.dart';
import 'package:flutter/material.dart';

class EditHistoryDialog extends StatefulWidget {
  EditHistoryDialog({super.key, required double initialValue}) {
    var display = initialValue.toString();
    if (display.endsWith(".0")) {
      display = display.substring(0, display.length - 2);
    }
    myController.value = TextEditingValue(text: display);
  }

  final myController = TextEditingController();

  @override
  State<EditHistoryDialog> createState() => _EditHistoryDialogState();
}

class _EditHistoryDialogState extends State<EditHistoryDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Edit Tape"),
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: TextField(
            controller: widget.myController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(label: Text("New Value")),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MaterialTextButton(
              "Cancel",
              accent: true,
              fontSize: 12,
              onPressed: () => Navigator.pop(context),
            ),
            MaterialTextButton(
              "OK",
              primary: true,
              fontSize: 12,
              onPressed: widget.myController.text.isEmpty
                  ? null
                  : () => Navigator.pop(
                        context,
                        double.parse(widget.myController.text),
                      ),
            )
          ],
        )
      ],
    );
  }
}

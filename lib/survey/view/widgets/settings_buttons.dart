import 'package:flutter/material.dart';

class ModalActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ModalActionButtons({
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onCancel,
          child: Text("Скасувати"),
        ),
        SizedBox(width: 10),
        FilledButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(elevation: 4),
          child: Text("Зберегти"),
        ),
      ],
    );
  }
}

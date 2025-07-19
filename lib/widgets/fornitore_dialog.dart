import 'package:flutter/material.dart';

class FornitoreDialog extends StatelessWidget {
  final void Function(String nome, String numero) onSave;

  const FornitoreDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nomeController = TextEditingController();
    final numeroController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.store, color: Colors.teal),
          SizedBox(width: 8),
          Text("Aggiungi Fornitore"),
        ],
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: "Nome fornitore",
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Inserisci un nome valido";
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: numeroController,
              decoration: InputDecoration(
                labelText: "Numero WhatsApp",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty || value.length < 9) {
                  return "Numero non valido";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Annulla", style: TextStyle(color: Colors.grey[700])),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            final nome = nomeController.text.trim();
            final numero = numeroController.text.trim();
            onSave(nome, numero);
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.save),
          label: Text("Salva"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

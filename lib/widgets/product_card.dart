import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String nome;
  final int quantita;
  final int soglia;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    Key? key,
    required this.nome,
    required this.quantita,
    required this.soglia,
    this.onIncrement,
    this.onDecrement,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Icon leadingIcon;
    if (quantita == 0) {
      leadingIcon = Icon(Icons.error, color: Colors.red);
    } else if (quantita < soglia) {
      leadingIcon = Icon(Icons.warning, color: Colors.orange);
    } else {
      leadingIcon = Icon(Icons.check_circle, color: Colors.green);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: ListTile(
        leading: leadingIcon,
        title: Text(
          nome,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Quantità: $quantita  Soglia: $soglia',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDecrement != null)
              IconButton(
                icon: Icon(Icons.remove),
                color: Colors.red,
                onPressed: onDecrement,
              ),
            if (onIncrement != null)
              IconButton(
                icon: Icon(Icons.add),
                color: Colors.green,
                onPressed: onIncrement,
              ),
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

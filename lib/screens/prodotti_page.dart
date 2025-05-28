import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'addproductform.dart';

class ProdottiPage extends StatefulWidget {
  @override
  State<ProdottiPage> createState() => _ProdottiPageState();
}

class _ProdottiPageState extends State<ProdottiPage> {
  final CollectionReference prodottiCollection =
  FirebaseFirestore.instance.collection('prodotti');

  void _modificaProdotto(BuildContext context, String docId, Map<String, dynamic> prodotto) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Modifica Prodotto'),
      content: SingleChildScrollView(
        child: AddProductForm(
          prodottoDaModificare: prodotto,
          onSave: (modifiche) async {
            if (modifiche != null) {
              await FirebaseFirestore.instance
                  .collection('prodotti')
                  .doc(docId)
                  .update(modifiche);
              Navigator.of(context).pop(); // chiude il dialog dopo il salvataggio
            }
          },
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prodotti')),
      body: StreamBuilder<QuerySnapshot>(
        stream: prodottiCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('Nessun prodotto presente'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final prodotto = doc.data()! as Map<String, dynamic>;

              Icon leadingIcon;
              if (prodotto['quantita'] == 0) {
                leadingIcon = Icon(Icons.warning, color: Colors.red);
              } else if (prodotto['quantita'] < prodotto['soglia']) {
                leadingIcon = Icon(Icons.error, color: Colors.orange);
              } else {
                leadingIcon = Icon(Icons.check_circle, color: Colors.green);
              }

              return ListTile(
                leading: leadingIcon,
                title: Text(prodotto['nome']),
                subtitle:
                Text('Quantità: ${prodotto['quantita']}  Soglia: ${prodotto['soglia']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _modificaProdotto(context, doc.id, prodotto),
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () async {
                        await prodottiCollection.doc(doc.id).delete();
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

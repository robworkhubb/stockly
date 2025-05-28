import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plaza_storage/screens/addproductform.dart' as form;
import 'package:plaza_storage/screens/prodotti_page.dart' as prodotti;


// Il tuo AddProductForm lo puoi lasciare identico a quello che hai.

class AddProductForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? prodottoDaModificare;
  const AddProductForm({Key? key, this.prodottoDaModificare, required this.onSave}) : super(key: key);

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantitaController = TextEditingController();
  final TextEditingController _sogliaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prodottoDaModificare != null) {
      _nomeController.text = widget.prodottoDaModificare!['nome'];
      _quantitaController.text = widget.prodottoDaModificare!['quantita'].toString();
      _sogliaController.text = widget.prodottoDaModificare!['soglia'].toString();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantitaController.dispose();
    _sogliaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome Prodotto'),
              validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
            ),
            TextFormField(
              controller: _quantitaController,
              decoration: InputDecoration(labelText: 'Quantità'),
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value ?? '') == null ? 'Inserisci un numero' : null,
            ),
            TextFormField(
              controller: _sogliaController,
              decoration: InputDecoration(labelText: 'Soglia minima di avviso'),
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value ?? '') == null ? 'Inserisci un numero' : null,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newProduct = {
                    'nome': _nomeController.text.trim(),
                    'quantita': int.parse(_quantitaController.text),
                    'soglia': int.parse(_sogliaController.text),
                  };
                  widget.onSave(newProduct); // richiama la callback passando il prodotto
                }
              },
              child: Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pagina principale per gestire i prodotti e aprire il form

class ProdottiPage extends StatefulWidget {
  const ProdottiPage({Key? key}) : super(key: key);

  @override
  State<ProdottiPage> createState() => _ProdottiPageState();
}

class _ProdottiPageState extends State<ProdottiPage> {
  final CollectionReference prodottiRef = FirebaseFirestore.instance.collection('prodotti');

  Future<void> _aggiungiProdotto() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aggiungi prodotto'),
        content: AddProductForm(onSave: (newProduct) {  },),
    ),
    );

    if (result != null) {
      await prodottiRef.add(result);
      setState(() {}); // Ricarica la pagina per aggiornare la lista
    }
  }

  Future<void> _modificaProdotto(String id, Map<String, dynamic> prodotto) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifica prodotto'),
        content: AddProductForm(prodottoDaModificare: prodotto, onSave: (newProduct){ }),
      ),
    );

    if (result != null) {
      await prodottiRef.doc(id).update(result);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestione Prodotti'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: prodottiRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final prodotti = snapshot.data!.docs;

          if (prodotti.isEmpty) {
            return Center(child: Text('Nessun prodotto disponibile'));
          }

          return ListView.builder(
            itemCount: prodotti.length,
            itemBuilder: (context, index) {
              final prodotto = prodotti[index];
              final data = prodotto.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(data['nome'] ?? ''),
                subtitle: Text('Quantità: ${data['quantita']}, Soglia: ${data['soglia']}'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _modificaProdotto(prodotto.id, data),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _aggiungiProdotto,
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: ProdottiPage()));
}

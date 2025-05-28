import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';
import 'addproductform.dart';
import 'ordinerapido.dart'; // Assicurati di avere questo import se usi OrdineRapidoPage

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> prodotti = [];
  bool loading = true;

  String dataOggi = DateFormat('d MMMM', 'it_IT').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchProdotti();
  }

  Future<void> fetchProdotti() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('prodotti').get();
      final List<Map<String, dynamic>> loadedProdotti = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'nome': data['nome'] ?? 'Sconosciuto',
          'quantita': data['quantita'] ?? 0,
          'soglia': data['soglia'] ?? 0,
          'fornitore': data['fornitore'] ?? "",
        };
      }).where((prodotto) =>
      prodotto['nome'] != 'Sconosciuto' &&
          prodotto['nome'].toString().trim().isNotEmpty
      ).toList();

      setState(() {
        prodotti = loadedProdotti;
        loading = false;
      });

      checkAndShowNotifications();
    } catch (e) {
      print("Errore nel recupero prodotti: $e");
      setState(() {
        loading = false;
      });
    }
  }

  void checkAndShowNotifications() {
    for (var prodotto in prodotti) {
      if (prodotto['quantita'] == 0) {
        showNotification(
          'Prodotto esaurito',
          '${prodotto['nome']} è esaurito!',
          'prodotto_esaurito_${prodotto['nome']}',
        );
      } else if (prodotto['quantita'] < prodotto['soglia']) {
        showNotification(
          'Prodotto sotto soglia',
          '${prodotto['nome']} è sotto la soglia minima.',
          'prodotto_sottosoglia_${prodotto['nome']}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prodottiFiltrati = prodotti
        .where((p) => p['quantita'] == 0 || p['quantita'] < p['soglia'])
        .toList();
    final esauriti = prodotti.where((p) => p['quantita'] == 0).toList();

    int _sottosoglia = 0;
    for (var prodotto in prodotti) {
      if (prodotto['quantita'] < prodotto['soglia']) {
        _sottosoglia++;
      }
    }

    if (loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white70,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plaza Storage', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Row(children: [Text(dataOggi), Spacer(), Text('Benvenuto')]),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isLarge = constraints.maxWidth > 600;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: isLarge ? constraints.maxWidth * 0.45 : double.infinity,
                      height: 100,
                      child: _buildCardSottoSoglia(_sottosoglia),
                    ),
                    SizedBox(
                      width: isLarge ? constraints.maxWidth * 0.45 : double.infinity,
                      height: 100,
                      child: _buildCardEsauriti(esauriti.length),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            Text("Prodotti da ordinare", style: TextStyle(fontSize: 25)),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: prodottiFiltrati.length,
                itemBuilder: (context, index) {
                  final prodotto = prodottiFiltrati[index];
                  return ListTile(
                    title: Text(prodotto['nome']),
                    subtitle: Row(
                      children: [
                        if (prodotto['quantita'] == 0) ...[
                          Icon(Icons.error, color: Colors.red, size: 18),
                          SizedBox(width: 4),
                          Text("Esaurito"),
                        ] else if (prodotto['quantita'] < prodotto['soglia']) ...[
                          Icon(Icons.warning, color: Colors.orange, size: 18),
                          SizedBox(width: 4),
                          Text("Da tenere d'occhio"),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrdineRapidoPage(),
                      ),
                    );
                  },
                  child: Row(
                    children: [Icon(Icons.note), Text(' Genera ordine')],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Aggiungi Prodotto'),
                        content: SingleChildScrollView(
                          child: AddProductForm(onSave: (newProduct) {
                            Navigator.of(context).pop(newProduct);
                          }),
                        ),
                      ),
                    ).then((newProduct) async {
                      if (newProduct != null) {
                        // Salva su Firestore
                        await FirebaseFirestore.instance.collection('prodotti').add(newProduct);
                        // Ricarica la lista prodotti da Firestore
                        await fetchProdotti();
                      }
                    });
                  },
                  child: Row(
                    children: [Icon(Icons.warehouse), Text(' Nuovo Prodotto')],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSottoSoglia(int sottoSoglia) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xF6FFC861),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 5),
            spreadRadius: 3.0,
            blurRadius: 4.5,
          ),
        ],
        border: Border.all(color: Colors.grey, width: 1),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⬇ Prodotti sotto la soglia:',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            '$sottoSoglia',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildCardEsauriti(int count) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xF6FF6161),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 5),
            spreadRadius: 3.0,
            blurRadius: 4.5,
          ),
        ],
        border: Border.all(color: Colors.grey, width: 1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 3),
              Text('Prodotti esauriti:', style: TextStyle(color: Colors.white70)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "$count",
            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

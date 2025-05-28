import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdineRapidoPage extends StatefulWidget {
  const OrdineRapidoPage({Key? key}) : super(key: key);

  @override
  State<OrdineRapidoPage> createState() => _OrdineRapidoPageState();
}

class _OrdineRapidoPageState extends State<OrdineRapidoPage> {
  final Map<String, String> fornitori = {
    "Fornitore A": "393911278922",
    "Fornitore B": "393760956101",
  };

  String fornitoreSelezionato = "Fornitore A";

  // Funzione per inviare ordine WhatsApp dato un elenco di prodotti
  void _inviaOrdineWhatsapp(List<Map<String, dynamic>> prodottiDaOrdinare) async {
    if (prodottiDaOrdinare.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nessun prodotto da ordinare")),
      );
      return;
    }

    String numero = fornitori[fornitoreSelezionato]!;

    String messaggio = Uri.encodeComponent(
      "📦 Ordine rapido da Plaza Storage\n" +
          prodottiDaOrdinare
              .map((p) {
            int suggerita = (p['soglia'] as int) * 2;
            return "- ${p['nome']} x $suggerita";
          })
              .join("\n") +
          "\n📅 Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
    );

    final url = Uri.parse("https://wa.me/$numero?text=$messaggio");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore nell'apertura di WhatsApp")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ordine Rapido")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: fornitoreSelezionato,
              isExpanded: true,
              items: fornitori.keys.map((nomeFornitore) {
                return DropdownMenuItem<String>(
                  value: nomeFornitore,
                  child: Text(nomeFornitore),
                );
              }).toList(),
              onChanged: (nuovo) {
                if (nuovo != null) {
                  setState(() {
                    fornitoreSelezionato = nuovo;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('prodotti').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Errore nel caricamento dati'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Estrai lista prodotti da snapshot e filtra
                  final allProdotti = snapshot.data!.docs.map((doc) {
                    final data = doc.data()! as Map<String, dynamic>;
                    data['id'] = doc.id; // se vuoi id per update/delete
                    return data;
                  }).toList();

                  final prodottiDaOrdinare = allProdotti.where((p) {
                    return (p['quantita'] == 0 || p['quantita'] < p['soglia']);
                  }).toList();

                  if (prodottiDaOrdinare.isEmpty) {
                    return Center(child: Text('Nessun prodotto da ordinare'));
                  }

                  return ListView.builder(
                    itemCount: prodottiDaOrdinare.length,
                    itemBuilder: (context, index) {
                      final prodotto = prodottiDaOrdinare[index];
                      final nome = prodotto['nome'] ?? 'Nome mancante';
                      final quantitaSuggerita = (prodotto['soglia'] as int) * 2;

                      return ListTile(
                        leading: Icon(Icons.shopping_cart_outlined),
                        title: Text(nome),
                        subtitle: Text("Suggerito: $quantitaSuggerita unità"),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text("Genera ordine WhatsApp"),
              onPressed: () async {
                final snapshot = await FirebaseFirestore.instance.collection('prodotti').get();
                final prodottiDaOrdinare = snapshot.docs.map((doc) {
                  final data = doc.data();
                  data['id'] = doc.id;
                  return data;
                }).where((p) => p['quantita'] == 0 || p['quantita'] < p['soglia']).toList();

                _inviaOrdineWhatsapp(List<Map<String, dynamic>>.from(prodottiDaOrdinare));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.green,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

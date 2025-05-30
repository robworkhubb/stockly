import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdineRapidoPage extends StatefulWidget {
  const OrdineRapidoPage({Key? key}) : super(key: key);

  @override
  State<OrdineRapidoPage> createState() => _OrdineRapidoPageState();
}

class _OrdineRapidoPageState extends State<OrdineRapidoPage> {
  Map<String, String> fornitori = {};
  String? fornitoreSelezionato;

  void _inviaOrdineWhatsapp(
      List<Map<String, dynamic>> prodottiDaOrdinare) async {
    if (prodottiDaOrdinare.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nessun prodotto da ordinare")),
      );
      return;
    }

    if (fornitoreSelezionato == null ||
        !fornitori.containsKey(fornitoreSelezionato)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Seleziona un fornitore valido")),
      );
      return;
    }
    String numero = fornitori[fornitoreSelezionato]!;

    final prefisso = '+39';
    if(!numero.startsWith(prefisso)){
      numero = prefisso + numero;
    }


    String messaggio = Uri.encodeComponent(
      "📦 Ordine rapido da Plaza Storage\n" +
          prodottiDaOrdinare
              .map((p) {
            int suggerita = (p['soglia'] as int) * 2;
            return "- ${p['nome']} x $suggerita";
          })
              .join("\n") +
          "\n📅 Data: ${DateTime
              .now()
              .day}/${DateTime
              .now()
              .month}/${DateTime
              .now()
              .year}",
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

  Future<void> _aggiungiFornitore(String nome, String numero) async{
    await FirebaseFirestore.instance.collection('fornitori').add({
      'nome': nome,
      'numero': numero,
    });
  }

  void _caricaFornitori() {
    FirebaseFirestore.instance.collection('fornitori').snapshots().listen((
        snapshot) {
      Map<String, String> mappaFornitori = {};
      for (var doc in snapshot.docs) {
        final dati = doc.data();
        final nome = dati['nome'] ?? '';
        final numero = dati['numero'] ?? '';
        if (nome.isNotEmpty && numero.isNotEmpty) {
          mappaFornitori[nome] = numero;
        }
      }
      setState(() {
        fornitori = mappaFornitori;
        if (fornitoreSelezionato == null && fornitori.isNotEmpty) {
          fornitoreSelezionato = fornitori.keys.first;
        }
      });
    });
  }

  void _mostraDialogAggiungiFornitore() {
    final nomeController = TextEditingController();
    final numeroController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Aggiungi nuovo fornitore"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: "Nome fornitore"),
              ),
              TextField(
                controller: numeroController,
                decoration: InputDecoration(labelText: "Numero WhatsApp"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () async {
                final nome = nomeController.text.trim();
                final numero = numeroController.text.trim();

                if (nome.isEmpty || numero.isEmpty) return;

                await FirebaseFirestore.instance.collection('fornitori').add({
                  'nome': nome,
                  'numero': numero,
                });
                Navigator.of(context).pop();
              },
              child: Text("Aggiungi"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _caricaFornitori();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ordine Rapido", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal),
                    color: Colors.teal.shade50,
                  ),
                  child: DropdownButton<String>(
                    value: fornitoreSelezionato,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: fornitori.keys.map((nomeFornitore) {
                      return DropdownMenuItem<String>(
                        value: nomeFornitore,
                        child: Text(nomeFornitore, style: TextStyle(fontWeight: FontWeight.w600)),
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
                ),
                SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _mostraDialogAggiungiFornitore,
                  icon: Icon(Icons.add, color: Colors.teal),
                  label: Text("Aggiungi nuovo fornitore", style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Mostra numero fornitore selezionato
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                fornitoreSelezionato != null
                    ? "Numero: ${fornitori[fornitoreSelezionato!]}"
                    : "Seleziona un fornitore",
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700]),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('prodotti')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Errore nel caricamento dati'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final allProdotti = snapshot.data!.docs.map((doc) {
                    final data = doc.data()! as Map<String, dynamic>;
                    data['id'] = doc.id;
                    return data;
                  }).toList();

                  final prodottiDaOrdinare = allProdotti.where((p) =>
                  p['quantita'] == 0 || p['quantita'] < p['soglia']).toList();

                  if (prodottiDaOrdinare.isEmpty) {
                    return Center(child: Text('Nessun prodotto da ordinare'));
                  }

                  return ListView.builder(
                    itemCount: prodottiDaOrdinare.length,
                    itemBuilder: (context, index) {
                      final prodotto = prodottiDaOrdinare[index];
                      final nome = prodotto['nome'] ?? 'Nome mancante';
                      final quantitaSuggerita = (prodotto['soglia'] as int) * 2;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: Icon(
                              Icons.shopping_cart_outlined, color: Colors.teal),
                          title: Text(nome,
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("Suggerito: $quantitaSuggerita unità"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.send, color: Colors.white),
                  label: Text("Genera ordine WhatsApp",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    backgroundColor: Colors.green,
                    textStyle: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 6,
                  ),
                  onPressed: () async {
                    final snapshot = await FirebaseFirestore.instance
                        .collection('prodotti').get();
                    final prodottiDaOrdinare = snapshot.docs.map((doc) {
                      final data = doc.data();
                      data['id'] = doc.id;
                      return data;
                    }).where((p) =>
                    p['quantita'] == 0 || p['quantita'] < p['soglia']).toList();

                    _inviaOrdineWhatsapp(
                        List<Map<String, dynamic>>.from(prodottiDaOrdinare));

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ordine WhatsApp generato!'))
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


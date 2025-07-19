// ignore_for_file: unused_import, unused_element, unused_local_variable

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/product_card.dart';
import '../widgets/main_button.dart';
import '../widgets/fornitore_dialog.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';

class OrdineRapidoPage extends StatefulWidget {
  const OrdineRapidoPage({Key? key}) : super(key: key);

  @override
  State<OrdineRapidoPage> createState() => _OrdineRapidoPageState();
}

class _OrdineRapidoPageState extends State<OrdineRapidoPage> {
  Map<String, String> fornitori = {};
  String? fornitoreSelezionato;

  void _inviaOrdineWhatsapp(
    List<Map<String, dynamic>> prodottiDaOrdinare,
  ) async {
    if (prodottiDaOrdinare.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Nessun prodotto da ordinare")));
      return;
    }

    if (fornitoreSelezionato == null ||
        !fornitori.containsKey(fornitoreSelezionato)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Seleziona un fornitore valido")));
      return;
    }
    String numero = fornitori[fornitoreSelezionato]!;

    final prefisso = '+39';
    if (!numero.startsWith(prefisso)) {
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

  Future<void> _aggiungiFornitore(String nome, String numero) async {
    await FirebaseFirestore.instance.collection('fornitori').add({
      'nome': nome,
      'numero': numero,
    });
  }

  void _modificaFornitore(String nome, String numero, String docId) {
    final nomeController = TextEditingController(text: nome);
    final numeroController = TextEditingController(text: numero);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Modifica Fornitore"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(labelText: "Nome fornitore"),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "Inserisci un nome valido"
                              : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: numeroController,
                  decoration: InputDecoration(labelText: "Numero WhatsApp"),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          value == null ||
                                  value.trim().isEmpty ||
                                  value.length < 9
                              ? "Numero non valido"
                              : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final nuovoNome = nomeController.text.trim();
                await FirebaseFirestore.instance
                    .collection('fornitori')
                    .doc(docId)
                    .update({
                      'nome': nuovoNome,
                      'numero': numeroController.text.trim(),
                    });
                Navigator.of(context).pop();
                if (fornitoreSelezionato == nome) {
                  setState(() {
                    fornitoreSelezionato = nuovoNome;
                  });
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Fornitore aggiornato!")),
                );
              },
              child: Text("Salva"),
            ),
          ],
        );
      },
    );
  }

  void _rimuoviFornitore(String docId) async {
    String? nomeEliminato;
    fornitori.forEach((nome, id) {
      if (_fornitoriId[nome] == docId) nomeEliminato = nome;
    });
    final conferma = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Conferma eliminazione"),
            content: Text("Vuoi davvero eliminare questo fornitore?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Annulla"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Elimina"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
    );
    if (conferma == true) {
      await FirebaseFirestore.instance
          .collection('fornitori')
          .doc(docId)
          .delete();
      setState(() {
        if (fornitoreSelezionato == nomeEliminato) {
          fornitoreSelezionato =
              fornitori.keys.where((n) => n != nomeEliminato).isNotEmpty
                  ? fornitori.keys.where((n) => n != nomeEliminato).first
                  : null;
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fornitore eliminato!")));
    }
  }

  void _caricaFornitori() {
    FirebaseFirestore.instance.collection('fornitori').snapshots().listen((
      snapshot,
    ) {
      Map<String, String> mappaFornitori = {};
      Map<String, String> mappaId = {};
      for (var doc in snapshot.docs) {
        final dati = doc.data();
        final nome = dati['nome'] ?? '';
        final numero = dati['numero'] ?? '';
        if (nome.isNotEmpty && numero.isNotEmpty) {
          mappaFornitori[nome] = numero;
          mappaId[nome] = doc.id;
        }
      }
      setState(() {
        fornitori = mappaFornitori;
        _fornitoriId = mappaId;
        if (fornitoreSelezionato == null && fornitori.isNotEmpty) {
          fornitoreSelezionato = fornitori.keys.first;
        }
      });
    });
  }

  Map<String, String> _fornitoriId = {};

  void _mostraDialogAggiungiFornitore() {
    final nomeController = TextEditingController();
    final numeroController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                    if (value == null ||
                        value.trim().isEmpty ||
                        value.length < 9) {
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
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final nome = nomeController.text.trim();
                final numero = numeroController.text.trim();

                await FirebaseFirestore.instance.collection('fornitori').add({
                  'nome': nome,
                  'numero': numero,
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Fornitore aggiunto con successo")),
                );
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
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: fornitoreSelezionato,
                          isExpanded: true,
                          underline: SizedBox(),
                          items:
                              fornitori.keys.map((nomeFornitore) {
                                return DropdownMenuItem<String>(
                                  value: nomeFornitore,
                                  child: Row(
                                    children: [
                                      Text(
                                        nomeFornitore,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          final docId =
                                              _fornitoriId[nomeFornitore]!;
                                          _modificaFornitore(
                                            nomeFornitore,
                                            fornitori[nomeFornitore]!,
                                            docId,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          final docId =
                                              _fornitoriId[nomeFornitore]!;
                                          _rimuoviFornitore(docId);
                                        },
                                      ),
                                    ],
                                  ),
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
                    ],
                  ),
                ),
                SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => FornitoreDialog(
                            onSave: (nome, numero) async {
                              await FirebaseFirestore.instance
                                  .collection('fornitori')
                                  .add({'nome': nome, 'numero': numero});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Fornitore aggiunto con successo",
                                  ),
                                ),
                              );
                            },
                          ),
                    );
                  },
                  icon: Icon(Icons.add, color: Colors.teal),
                  label: Text(
                    "Aggiungi nuovo fornitore",
                    style: TextStyle(color: Colors.teal),
                  ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  final prodottiDaOrdinare =
                      provider.prodotti
                          .where(
                            (p) => p.quantita == 0 || p.quantita < p.soglia,
                          )
                          .toList();
                  if (provider.loading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (prodottiDaOrdinare.isEmpty) {
                    return Center(child: Text('Nessun prodotto da ordinare'));
                  }
                  return ListView.builder(
                    itemCount: prodottiDaOrdinare.length,
                    itemBuilder: (context, index) {
                      final prodotto = prodottiDaOrdinare[index];
                      return ProductCard(
                        nome: prodotto.nome,
                        quantita: prodotto.quantita,
                        soglia: prodotto.soglia,
                        onEdit: null,
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: MainButton(
                  label: "Genera ordine WhatsApp",
                  icon: Icons.send,
                  color: Colors.green,
                  onPressed: () async {
                    final provider = Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    );
                    final prodottiDaOrdinare =
                        provider.prodotti
                            .where(
                              (p) => p.quantita == 0 || p.quantita < p.soglia,
                            )
                            .toList();
                    _inviaOrdineWhatsapp(
                      prodottiDaOrdinare.map((p) => p.toJson()).toList(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ordine WhatsApp generato!')),
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

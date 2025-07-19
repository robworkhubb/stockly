// ignore_for_file: unused_import, unused_element, unused_local_variable, deprecated_member_use

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
  Map<String, String> _fornitoriId = {};
  String? fornitoreSelezionato;

  @override
  void initState() {
    super.initState();
    _caricaFornitori();
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

  void _inviaOrdineWhatsapp(
    List<Map<String, dynamic>> prodottiDaOrdinare,
  ) async {
    if (prodottiDaOrdinare.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nessun prodotto da ordinare")),
      );
      return;
    }
    if (fornitoreSelezionato == null ||
        !fornitori.containsKey(fornitoreSelezionato)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleziona un fornitore valido")),
      );
      return;
    }
    String numero = fornitori[fornitoreSelezionato!]!;
    final prefisso = '+39';
    if (!numero.startsWith(prefisso)) {
      numero = prefisso + numero;
    }
    String messaggio = Uri.encodeComponent(
      "📦 Ordine:" +
          prodottiDaOrdinare
              .map((p) {
                int suggerita = (p['soglia'] as int) * 2;
                return "- ${p['nome']} x $suggerita";
              })
              .join("\n") +
          "\n📅 Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}\nOrdine fatto con l'app Stockely ✅.",
    );
    final url = Uri.parse("https://wa.me/$numero?text=$messaggio");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore nell'apertura di WhatsApp")),
      );
    }
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
          title: const Text("Modifica Fornitore"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: "Nome fornitore",
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "Inserisci un nome valido"
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: numeroController,
                  decoration: const InputDecoration(
                    labelText: "Numero WhatsApp",
                  ),
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
              child: const Text("Annulla"),
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
                  const SnackBar(content: Text("Fornitore aggiornato!")),
                );
              },
              child: const Text("Salva"),
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
            title: const Text("Conferma eliminazione"),
            content: const Text("Vuoi davvero eliminare questo fornitore?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annulla"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Elimina"),
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
      ).showSnackBar(const SnackBar(content: Text("Fornitore eliminato!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    String dataOggi = DateTime.now().toLocal().toString().substring(0, 10);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            const Icon(Icons.send_outlined, color: Color(0xFF009688), size: 28),
            const SizedBox(width: 10),
            const Text(
              'Ordine Rapido',
              style: TextStyle(
                color: Color(0xFF009688),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              dataOggi,
              style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: fornitoreSelezionato,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(24),
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF009688),
                              fontSize: 16,
                            ),
                            items:
                                fornitori.keys.map((nomeFornitore) {
                                  return DropdownMenuItem<String>(
                                    value: nomeFornitore,
                                    child: Row(
                                      children: [
                                        Text(nomeFornitore),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(
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
                                          icon: const Icon(
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
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF009688),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                      const SnackBar(
                                        content: Text(
                                          "Fornitore aggiunto con successo",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.teal),
                        label: const Text(
                          "Aggiungi fornitore",
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
              ),
              const SizedBox(height: 16),
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
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (prodottiDaOrdinare.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 64,
                              color: Colors.teal.shade100,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Nessun prodotto da ordinare',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: prodottiDaOrdinare.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final prodotto = prodottiDaOrdinare[index];
                        return ProductCard(
                          nome: prodotto.nome,
                          quantita: prodotto.quantita,
                          soglia: prodotto.soglia,
                          suggerita: prodotto.soglia * 2,
                          onEdit: null,
                          onDelete: null,
                          onIncrement: null,
                          onDecrement: null,
                          showEditDelete: false,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 100,
            child: SafeArea(
              bottom: true,
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
                    prodottiDaOrdinare
                        .map(
                          (p) => {
                            'nome': p.nome,
                            'quantita': p.quantita,
                            'soglia': p.soglia,
                          },
                        )
                        .toList(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ordine WhatsApp generato!')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

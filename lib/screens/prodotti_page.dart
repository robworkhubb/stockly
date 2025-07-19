// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, unused_import, unused_element

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:plazastorage/models/product_model.dart';
import 'addproductform.dart';
import '../widgets/product_card.dart';
import '../widgets/main_button.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';

class ProdottiPage extends StatefulWidget {
  @override
  State<ProdottiPage> createState() => _ProdottiPageState();
}

class _ProdottiPageState extends State<ProdottiPage> {
  String dataOggi = DateFormat('d MMMM', 'it_IT').format(DateTime.now());
  final CollectionReference prodottiCollection = FirebaseFirestore.instance
      .collection('prodotti');
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ProductProvider>(context, listen: false).fetchProdotti();
      });
    }
  }

  void _modificaProdotto(BuildContext context, String id, Product prodotto) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Modifica Prodotto'),
            content: AddProductForm(
              prodottoDaModificare: {
                'nome': prodotto.nome,
                'quantita': prodotto.quantita,
                'soglia': prodotto.soglia,
                'fornitore': prodotto.fornitore,
              },
              onSave: (modifiche) async {
                if (modifiche != null) {
                  final updated = Product(
                    id: prodotto.id,
                    nome: modifiche['nome'],
                    quantita: modifiche['quantita'],
                    soglia: modifiche['soglia'],
                    fornitore: modifiche['fornitore'] ?? '',
                  );
                  await Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).updateProdotto(id, updated);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
    );
  }

  void _aggiungiProdotto() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Aggiungi Prodotto'),
            content: AddProductForm(
              onSave: (prodotto) async {
                if (prodotto != null) {
                  await Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).addProdotto(
                    Product(
                      id: '', // id vuoto, Firestore lo genera
                      nome: prodotto['nome'],
                      quantita: prodotto['quantita'],
                      soglia: prodotto['soglia'],
                      fornitore: prodotto['fornitore'] ?? '',
                    ),
                  );
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flatware, size: 28, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Plaza Storage',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          dataOggi,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          // Mostra loader solo se loading è true
          if (provider.loading) {
            return Center(child: CircularProgressIndicator());
          }
          final prodotti = provider.prodotti;
          // Se la lista prodotti è vuota, mostra un messaggio
          if (prodotti.isEmpty) {
            return Center(child: Text('Nessun prodotto presente'));
          }
          // Nessuno scroll: mostro tutto in una colonna
          return Column(
            children: [
              for (final prodotto in prodotti)
                ProductCard(
                  nome: prodotto.nome,
                  quantita: prodotto.quantita,
                  soglia: prodotto.soglia,
                  onDecrement: () async {
                    if (prodotto.quantita > 0) {
                      await provider.updateQuantita(
                        prodotto.id,
                        prodotto.quantita - 1,
                      );
                    }
                  },
                  onIncrement: () async {
                    await provider.updateQuantita(
                      prodotto.id,
                      prodotto.quantita + 1,
                    );
                  },
                  onEdit:
                      () => _modificaProdotto(context, prodotto.id, prodotto),
                  onDelete: () async {
                    await provider.deleteProdotto(prodotto.id);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, unused_import, unused_element

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:stockely/models/product_model.dart';
import 'addproductform.dart';
import '../widgets/product_card.dart';
import '../widgets/main_button.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';

class ProdottiPage extends StatefulWidget {
  const ProdottiPage({Key? key}) : super(key: key);

  @override
  State<ProdottiPage> createState() => _ProdottiPageState();
}

class _ProdottiPageState extends State<ProdottiPage> {
  String get dataOggi => DateFormat('d MMMM', 'it_IT').format(DateTime.now());
  bool _initialized = false;
  String _search = '';
  String _filter = 'Tutti';
  final List<String> _filtri = ['Tutti', 'Sotto soglia', 'Esauriti'];

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

  void _showProductDialog({Map<String, dynamic>? prodotto, String? id}) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              prodotto == null ? 'Aggiungi Prodotto' : 'Modifica Prodotto',
            ),
            content: AddProductForm(
              prodottoDaModificare: prodotto,
              onSave: (modifiche) async {
                if (modifiche != null) {
                  final provider = Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  );
                  if (id == null) {
                    await provider.addProdotto(
                      Product(
                        id: '',
                        nome: modifiche['nome'],
                        categoria: modifiche['categoria'] ?? '',
                        quantita: modifiche['quantita'],
                        soglia: modifiche['soglia'],
                        prezzoUnitario: modifiche['prezzoUnitario'] ?? 0.0,
                        consumati: modifiche['consumati'] ?? 0,
                        ultimaModifica: DateTime.now(),
                      ),
                    );
                  } else {
                    await provider.updateProdotto(
                      id,
                      Product(
                        id: id,
                        nome: modifiche['nome'],
                        categoria: modifiche['categoria'] ?? '',
                        quantita: modifiche['quantita'],
                        soglia: modifiche['soglia'],
                        prezzoUnitario: modifiche['prezzoUnitario'] ?? 0.0,
                        consumati: modifiche['consumati'] ?? 0,
                        ultimaModifica: DateTime.now(),
                      ),
                    );
                  }
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
    );
  }

  List<Product> _filtraProdotti(List<Product> prodotti) {
    List<Product> filtrati = prodotti;
    if (_filter == 'Sotto soglia') {
      filtrati =
          prodotti
              .where((p) => p.quantita < p.soglia && p.quantita > 0)
              .toList();
    } else if (_filter == 'Esauriti') {
      filtrati = prodotti.where((p) => p.quantita == 0).toList();
    }
    if (_search.isNotEmpty) {
      filtrati =
          filtrati
              .where(
                (p) => p.nome.toLowerCase().contains(_search.toLowerCase()),
              )
              .toList();
    }
    return filtrati;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            const Icon(
              Icons.warehouse_outlined,
              color: Color(0xFF009688),
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'Gestione Prodotti',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FA), // teal chiaro
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Cerca prodotto...',
                        hintStyle: TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF009688),
                          size: 24,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filter,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      style: const TextStyle(
                        color: Color(0xFF009688),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      items:
                          _filtri
                              .map(
                                (f) => DropdownMenuItem<String>(
                                  value: f,
                                  child: Text(f),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _filter = v!),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF009688),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final prodotti = _filtraProdotti(provider.prodotti);
                if (prodotti.isEmpty) {
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
                          'Nessun prodotto trovato',
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
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 100, // spazio per bottom nav e FAB
                  ),
                  itemCount: prodotti.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final prodotto = prodotti[index];
                    return ProductCard(
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
                          () => _showProductDialog(
                            prodotto: {
                              'nome': prodotto.nome,
                              'quantita': prodotto.quantita,
                              'soglia': prodotto.soglia,
                              'categoria': prodotto.categoria,
                              'prezzo unitario': prodotto.prezzoUnitario,
                            },
                            id: prodotto.id,
                          ),
                      onDelete: () async {
                        await provider.deleteProdotto(prodotto.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _showProductDialog(),
          backgroundColor: Colors.teal,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
          tooltip: 'Aggiungi prodotto',
        ),
      ),
    );
  }
}

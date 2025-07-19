// ignore_for_file: unused_catch_stack

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Product> _prodotti = [];
  bool _loading = false;

  List<Product> get prodotti =>
      _prodotti; // Suggerimento: valuta UnmodifiableListView per sola lettura
  bool get loading => _loading;

  Future<void> fetchProdotti() async {
    _loading = true;
    notifyListeners();
    final snapshot =
        await FirebaseFirestore.instance.collection('prodotti').get();
    _prodotti =
        snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList();
    _loading = false;
    notifyListeners();
  }

  // Top 5 prodotti consumati
  List<Product> topConsumati({int top = 5}) {
    final sorted = List<Product>.from(_prodotti)
      ..sort((a, b) => b.consumati.compareTo(a.consumati));
    return sorted.take(top).toList();
  }

  // Distribuzione per categoria (per quantità consumata)
  Map<String, int> distribuzionePerCategoria() {
    final Map<String, int> dist = {};
    for (var p in _prodotti) {
      dist[p.categoria] = (dist[p.categoria] ?? 0) + p.consumati;
    }
    return dist;
  }

  // Spesa mensile totale (ipotizzando che ogni prodotto abbia ultimaModifica e prezzoUnitario)
  Map<String, double> spesaMensile() {
    final Map<String, double> monthly = {};
    for (var p in _prodotti) {
      if (p.ultimaModifica != null) {
        final key =
            "${p.ultimaModifica!.year}-${p.ultimaModifica!.month.toString().padLeft(2, '0')}";
        monthly[key] = (monthly[key] ?? 0) + (p.consumati * p.prezzoUnitario);
      }
    }
    return monthly;
  }

  Future<void> addProdotto(Product prodotto) async {
    final doc = await FirebaseFirestore.instance
        .collection('prodotti')
        .add(prodotto.toFirestore());
    _prodotti.add(
      Product(
        id: doc.id,
        nome: prodotto.nome,
        categoria: prodotto.categoria,
        quantita: prodotto.quantita,
        soglia: prodotto.soglia,
        prezzoUnitario: prodotto.prezzoUnitario,
        consumati: prodotto.consumati,
        ultimaModifica: prodotto.ultimaModifica ?? DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> updateProdotto(String id, Product prodotto) async {
    await FirebaseFirestore.instance
        .collection('prodotti')
        .doc(id)
        .update(prodotto.toFirestore());
    final index = _prodotti.indexWhere((p) => p.id == id);
    if (index != -1) {
      _prodotti[index] = Product(
        id: id,
        nome: prodotto.nome,
        categoria: prodotto.categoria,
        quantita: prodotto.quantita,
        soglia: prodotto.soglia,
        prezzoUnitario: prodotto.prezzoUnitario,
        consumati: prodotto.consumati,
        ultimaModifica: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> deleteProdotto(String id) async {
    await _firebaseService.deleteProdotto(id);
    await fetchProdotti();
  }

  Future<void> updateQuantita(String id, int nuovaQuantita) async {
    final index = _prodotti.indexWhere((p) => p.id == id);
    if (index != -1) {
      final prodotto = _prodotti[index];
      // Se decremento, aggiorno anche consumati
      int nuovoConsumati = prodotto.consumati;
      if (nuovaQuantita < prodotto.quantita) {
        nuovoConsumati += (prodotto.quantita - nuovaQuantita);
      }
      final updated = Product(
        id: prodotto.id,
        nome: prodotto.nome,
        categoria: prodotto.categoria,
        quantita: nuovaQuantita,
        soglia: prodotto.soglia,
        prezzoUnitario: prodotto.prezzoUnitario,
        consumati: nuovoConsumati,
        ultimaModifica: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('prodotti')
          .doc(id)
          .update(updated.toFirestore());
      _prodotti[index] = updated;
      notifyListeners();
    }
  }
}

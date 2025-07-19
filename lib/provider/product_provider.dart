import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Product> _prodotti = [];
  bool _loading = false;

  List<Product> get prodotti => _prodotti;
  bool get loading => _loading;

  Future<void> fetchProdotti() async {
    print('fetchProdotti chiamato');
    _loading = true;
    notifyListeners();
    try {
      _prodotti = await _firebaseService.fetchProdotti();
      print('Prodotti caricati: ${_prodotti.length}');
      for (var p in _prodotti) {
        print(
          'Prodotto: nome=${p.nome}, quantita=${p.quantita}, soglia=${p.soglia}, fornitore=${p.fornitore}, id=${p.id}',
        );
      }
    } catch (e, st) {
      print('Errore in fetchProdotti: ${e.toString()}');
      print('Stacktrace: ${st.toString()}');
    } finally {
      _loading = false;
      notifyListeners();
      print('fetchProdotti: loading impostato a false');
    }
  }

  Future<void> addProdotto(Product prodotto) async {
    await _firebaseService.addProdotto(prodotto);
    await fetchProdotti();
  }

  Future<void> updateProdotto(String id, Product prodotto) async {
    await _firebaseService.updateProdotto(id, prodotto);
    await fetchProdotti();
  }

  Future<void> deleteProdotto(String id) async {
    await _firebaseService.deleteProdotto(id);
    await fetchProdotti();
  }

  Future<void> updateQuantita(String id, int nuovaQuantita) async {
    final index = _prodotti.indexWhere((p) => p.id == id);
    if (index != -1) {
      final prodotto = _prodotti[index];
      final updated = Product(
        id: prodotto.id,
        nome: prodotto.nome,
        fornitore: prodotto.fornitore,
        quantita: nuovaQuantita,
        soglia: prodotto.soglia,
      );
      _prodotti[index] = updated;
      notifyListeners(); // Aggiorna subito la UI
      await _firebaseService.updateProdotto(id, updated);
      // Non ricaricare tutta la lista!
    }
  }
}

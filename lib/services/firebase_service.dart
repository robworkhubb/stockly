import 'package:stockely/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Future<List<Product>> fetchProdotti() async {
    final snap = await _db.collection('prodotti').get();
    return snap.docs
        .map((doc) => Product.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> addProdotto(Product prodotto) async {
    await _db.collection('prodotti').add(prodotto.toFirestore());
  }

  Future<void> updateProdotto(String id, Product prodotto) async {
    await _db.collection('prodotti').doc(id).update(prodotto.toFirestore());
  }

  Future<void> deleteProdotto(String id) async {
    await _db.collection('prodotti').doc(id).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/fornitore_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Servizi per i Prodotti
  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addProduct(Product product) {
    return _db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) {
    return _db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) {
    return _db.collection('products').doc(productId).delete();
  }

  // Servizi per i Fornitori
  Stream<List<Fornitore>> getFornitori() {
    return _db
        .collection('fornitori')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Fornitore.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addFornitore(Fornitore fornitore) {
    return _db.collection('fornitori').add(fornitore.toMap());
  }

  Future<void> updateFornitore(Fornitore fornitore) {
    return _db
        .collection('fornitori')
        .doc(fornitore.id)
        .update(fornitore.toMap());
  }

  Future<void> deleteFornitore(String fornitoreId) {
    return _db.collection('fornitori').doc(fornitoreId).delete();
  }
}

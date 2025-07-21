import '../../../domain/repositories/product_repository.dart';
import '../../../models/product_model.dart';
import '../../../services/firestore_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirestoreService _firestoreService;

  ProductRepositoryImpl(this._firestoreService);

  @override
  Stream<List<Product>> getProducts() {
    return _firestoreService.getProducts();
  }

  @override
  Future<void> addProduct(Product product) {
    return _firestoreService.addProduct(product);
  }

  @override
  Future<void> updateProduct(Product product) {
    return _firestoreService.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String productId) {
    return _firestoreService.deleteProduct(productId);
  }
}

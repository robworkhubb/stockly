import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../domain/repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _productRepository;
  List<Product> _prodotti = [];
  bool _loading = true;
  String _searchTerm = '';
  String? _filterCategory;

  ProductProvider(this._productRepository) {
    _loadProducts();
  }

  List<Product> get prodotti {
    List<Product> filteredProducts = _prodotti;

    if (_filterCategory != null && _filterCategory!.isNotEmpty) {
      filteredProducts =
          filteredProducts
              .where((p) => p.categoria == _filterCategory)
              .toList();
    }

    if (_searchTerm.isNotEmpty) {
      filteredProducts =
          filteredProducts
              .where(
                (p) =>
                    p.nome.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                    p.categoria.toLowerCase().contains(
                      _searchTerm.toLowerCase(),
                    ),
              )
              .toList();
    }
    return filteredProducts;
  }

  bool get loading => _loading;
  String? get activeCategory => _filterCategory;
  List<String> get uniqueCategories =>
      _prodotti.map((p) => p.categoria).toSet().toList();

  void _loadProducts() {
    _productRepository.getProducts().listen((prodotti) {
      _prodotti = prodotti;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> addProduct(Product product) async {
    await _productRepository.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _productRepository.updateProduct(product);
  }

  Future<void> deleteProduct(String productId) async {
    await _productRepository.deleteProduct(productId);
  }

  Future<void> updateQuantity(Product product, int newQuantity) async {
    int consumatiDelta = product.quantita - newQuantity;
    if (consumatiDelta < 0) consumatiDelta = 0;

    final updatedProduct = Product(
      id: product.id,
      nome: product.nome,
      categoria: product.categoria,
      quantita: newQuantity,
      soglia: product.soglia,
      prezzoUnitario: product.prezzoUnitario,
      consumati: product.consumati + consumatiDelta,
      ultimaModifica: DateTime.now(),
    );
    await updateProduct(updatedProduct);
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchTerm = '';
    _filterCategory = null;
    notifyListeners();
  }

  // Metodi di analisi per la dashboard
  List<Product> topConsumati({int count = 5}) {
    final sorted = List<Product>.from(_prodotti)
      ..sort((a, b) => b.consumati.compareTo(a.consumati));
    return sorted.take(count).toList();
  }

  Map<String, int> distribuzionePerCategoria() {
    final Map<String, int> dist = {};
    for (var p in _prodotti) {
      dist[p.categoria] = (dist[p.categoria] ?? 0) + p.consumati;
    }
    return dist;
  }

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
}

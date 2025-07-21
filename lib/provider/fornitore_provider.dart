import 'package:flutter/material.dart';
import '../models/fornitore_model.dart';
import '../domain/repositories/fornitore_repository.dart';

class FornitoreProvider with ChangeNotifier {
  final FornitoreRepository _fornitoreRepository;
  List<Fornitore> _fornitori = [];
  bool _loading = true;

  FornitoreProvider(this._fornitoreRepository) {
    _loadFornitori();
  }

  List<Fornitore> get fornitori => _fornitori;
  bool get loading => _loading;

  void _loadFornitori() {
    _fornitoreRepository.getFornitori().listen((fornitori) {
      _fornitori = fornitori;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> addFornitore(String nome, String numero) async {
    final nuovoFornitore = Fornitore(id: '', nome: nome, numero: numero);
    await _fornitoreRepository.addFornitore(nuovoFornitore);
  }

  Future<void> updateFornitore(Fornitore fornitore) async {
    await _fornitoreRepository.updateFornitore(fornitore);
  }

  Future<void> deleteFornitore(String fornitoreId) async {
    await _fornitoreRepository.deleteFornitore(fornitoreId);
  }
}

import '../../models/fornitore_model.dart';

abstract class FornitoreRepository {
  Stream<List<Fornitore>> getFornitori();
  Future<void> addFornitore(Fornitore fornitore);
  Future<void> updateFornitore(Fornitore fornitore);
  Future<void> deleteFornitore(String fornitoreId);
}

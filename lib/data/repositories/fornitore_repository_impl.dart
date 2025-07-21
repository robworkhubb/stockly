import '../../../domain/repositories/fornitore_repository.dart';
import '../../../models/fornitore_model.dart';
import '../../../services/firestore_service.dart';

class FornitoreRepositoryImpl implements FornitoreRepository {
  final FirestoreService _firestoreService;

  FornitoreRepositoryImpl(this._firestoreService);

  @override
  Stream<List<Fornitore>> getFornitori() {
    return _firestoreService.getFornitori();
  }

  @override
  Future<void> addFornitore(Fornitore fornitore) {
    return _firestoreService.addFornitore(fornitore);
  }

  @override
  Future<void> updateFornitore(Fornitore fornitore) {
    return _firestoreService.updateFornitore(fornitore);
  }

  @override
  Future<void> deleteFornitore(String fornitoreId) {
    return _firestoreService.deleteFornitore(fornitoreId);
  }
}

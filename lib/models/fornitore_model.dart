import 'package:cloud_firestore/cloud_firestore.dart';

class Fornitore {
  final String id;
  final String nome;
  final String numero;

  Fornitore({required this.id, required this.nome, required this.numero});

  factory Fornitore.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Fornitore(
      id: doc.id,
      nome: data['nome'] ?? '',
      numero: data['numero'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'numero': numero};
  }
}

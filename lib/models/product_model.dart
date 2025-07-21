import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nome;
  final String categoria;
  final int quantita;
  final int soglia;
  final double prezzoUnitario;
  final int consumati;
  final DateTime? ultimaModifica;

  Product({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.quantita,
    required this.soglia,
    required this.prezzoUnitario,
    required this.consumati,
    this.ultimaModifica,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      nome: data['nome'],
      categoria: data['categoria'] ?? '',
      quantita: data['quantita'],
      soglia: data['soglia'],
      prezzoUnitario: (data['prezzoUnitario'] ?? 0).toDouble(),
      consumati: data['consumati'] ?? 0,
      ultimaModifica:
          data['ultimaModifica'] != null
              ? (data['ultimaModifica'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'nome': nome,
    'categoria': categoria,
    'quantita': quantita,
    'soglia': soglia,
    'prezzoUnitario': prezzoUnitario,
    'consumati': consumati,
    'ultimaModifica':
        ultimaModifica != null ? Timestamp.fromDate(ultimaModifica!) : null,
  };
}

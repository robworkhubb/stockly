class Product {
  String id;
  String nome;
  String fornitore;
  int quantita;
  int soglia;

  Product({
    required this.id,
    required this.nome,
    required this.fornitore,
    required this.quantita,
    required this.soglia,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      nome: json['nome'] ?? '',
      fornitore: json['fornitore'] ?? '',
      quantita: json['quantita'] ?? 0,
      soglia: json['soglia'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'fornitore': fornitore,
      'quantita': quantita,
      'soglia': soglia,
    };
  }
}

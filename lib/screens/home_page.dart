// ignore_for_file: unused_import, unused_local_variable, unnecessary_cast, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';
import '../widgets/info_box.dart';
import '../widgets/product_card.dart';
import '../widgets/main_button.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String get dataOggi =>
      DateFormat('d MMMM yyyy', 'it_IT').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            const Icon(Icons.inventory_2, color: Color(0xFF009688), size: 28),
            const SizedBox(width: 10),
            const Text(
              'Stockly',
              style: TextStyle(
                color: Color(0xFF009688),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              dataOggi,
              style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final prodotti = provider.prodotti;
          final sottoSoglia =
              prodotti
                  .where((p) => p.quantita < p.soglia && p.quantita > 0)
                  .toList();
          final esauriti = prodotti.where((p) => p.quantita == 0).toList();
          final critici =
              prodotti
                  .where((p) => p.quantita == 0 || p.quantita < p.soglia)
                  .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InfoBox(
                        title: 'Sotto soglia',
                        value: sottoSoglia.length,
                        gradientColors: const [
                          Color(0xFFFFE16D),
                          Color(0xFFFFD54F),
                        ],
                        icon: Icons.warning_amber_rounded,
                        iconColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InfoBox(
                        title: 'Esauriti',
                        value: esauriti.length,
                        gradientColors: const [
                          Color(0xFFFF8A80),
                          Color(0xFFFF5252),
                        ],
                        icon: Icons.error,
                        iconColor: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Prodotti da ordinare',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),
                critici.isEmpty
                    ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Nessun prodotto critico',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: critici.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final prodotto = critici[index];
                        return ProductCard(
                          nome: prodotto.nome,
                          quantita: prodotto.quantita,
                          soglia: prodotto.soglia,
                          suggerita: -1, // visualizza solo nome e stato
                          onEdit: null,
                          onDelete: null,
                          showEditDelete: false,
                        );
                      },
                    ),
                const SizedBox(height: 80), // Spazio per la bottom nav
              ],
            ),
          );
        },
      ),
    );
  }
}

// ignore_for_file: unused_import, unused_local_variable, unnecessary_cast, deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../main.dart';
import 'addproductform.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'ordinerapido.dart';
import '../widgets/info_box.dart';
import '../widgets/product_card.dart';
import '../widgets/main_button.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dataOggi = DateFormat('d MMMM', 'it_IT').format(DateTime.now());
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ProductProvider>(context, listen: false).fetchProdotti();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flatware, size: 28, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Plaza Storage',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.teal),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          dataOggi,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Spacer(),
                        Text(
                          'Benvenuto',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          try {
            if (provider.loading) {
              return Center(child: CircularProgressIndicator());
            }
            final prodotti = provider.prodotti;
            if (prodotti.isEmpty) {
              return Center(child: Text('Nessun prodotto presente'));
            }
            final sottoSoglia =
                prodotti.where((p) => p.quantita < p.soglia).length;
            final esauriti = prodotti.where((p) => p.quantita == 0).length;
            final prodottiFiltrati =
                prodotti
                    .where((p) => p.quantita == 0 || p.quantita < p.soglia)
                    .toList();
            // Nessuno scroll: mostro tutto in una colonna
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isLarge = constraints.maxWidth > 600;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width:
                              isLarge
                                  ? constraints.maxWidth * 0.45
                                  : double.infinity,
                          height: 133,
                          child: InfoBox(
                            title: 'Sotto soglia',
                            value: sottoSoglia,
                            gradientColors: [
                              Color(0xFFFFE16D),
                              Color(0xFFFFD54F),
                            ],
                            icon: Icons.warning_amber_rounded,
                            iconColor: Colors.orange,
                          ),
                        ),
                        SizedBox(
                          width:
                              isLarge
                                  ? constraints.maxWidth * 0.45
                                  : double.infinity,
                          height: 133,
                          child: InfoBox(
                            title: 'Esauriti',
                            value: esauriti,
                            gradientColors: [
                              Color(0xFFFF8A80),
                              Color(0xFFFF5252),
                            ],
                            icon: Icons.error,
                            iconColor: Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.teal),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prodotti da ordinare',
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(height: 8),
                      prodottiFiltrati.isEmpty
                          ? Center(child: Text('Nessun prodotto da ordinare'))
                          : Column(
                            children: [
                              for (final prodotto in prodottiFiltrati)
                                ProductCard(
                                  nome: prodotto.nome,
                                  quantita: prodotto.quantita,
                                  soglia: prodotto.soglia,
                                ),
                            ],
                          ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  child: MainButton(
                    label: 'Genera ordine',
                    icon: Icons.note_add,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrdineRapidoPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } catch (e, st) {
            print('ERRORE UI HOME:  $e\n$st');
            return Center(
              child: Text('Errore nella visualizzazione della home.'),
            );
          }
        },
      ),
    );
  }

  Stream<Map<String, int>> prodottiStatsStream() {
    return FirebaseFirestore.instance.collection('prodotti').snapshots().map((
      snapshot,
    ) {
      int sottoSogliaCount = 0;
      int esauritiCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final quantita = data['quantita'] ?? 0;
        final soglia = data['soglia'] ?? 0;

        if (quantita == 0) {
          esauritiCount++;
        } else if (quantita < soglia) {
          sottoSogliaCount++;
        }
      }

      return {'sottoSoglia': sottoSogliaCount, 'esauriti': esauritiCount};
    });
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../main.dart';
import 'addproductform.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'ordinerapido.dart'; // Assicurati di avere questo import se usi OrdineRapidoPage

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> prodotti = [];
  bool loading = true;
  String dataOggi = DateFormat('d MMMM', 'it_IT').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchProdotti();
  }

  Future<void> fetchProdotti() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('prodotti').get();
      final List<Map<String, dynamic>> loadedProdotti =
          snapshot.docs
              .map((doc) {
                final data = doc.data();
                return {
                  'nome': data['nome'] ?? 'Sconosciuto',
                  'quantita': data['quantita'] ?? 0,
                  'soglia': data['soglia'] ?? 0,
                  'fornitore': data['fornitore'] ?? "",
                };
              })
              .where(
                (prodotto) =>
                    prodotto['nome'] != 'Sconosciuto' &&
                    prodotto['nome'].toString().trim().isNotEmpty,
              )
              .toList();

      setState(() {
        prodotti = loadedProdotti;
        loading = false;
      });
    } catch (e) {
      print("Errore nel recupero prodotti: $e");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prodottiFiltrati =
        prodotti
            .where((p) => p['quantita'] == 0 || p['quantita'] < p['soglia'])
            .toList();
    final esauriti = prodotti.where((p) => p['quantita'] == 0).toList();

    int _sottosoglia = 0;
    for (var prodotto in prodotti) {
      if (prodotto['quantita'] < prodotto['soglia']) {
        _sottosoglia++;
      }
    }

    if (loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Il primo LayoutBuilder e le cards vanno bene così
              LayoutBuilder(
                builder: (context, constraints) {
                  final isLarge = constraints.maxWidth > 600;
                  return StreamBuilder<Map<String, int>>(
                    stream: prodottiStatsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Errore: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: Text('Nessun dato'));
                      }
                      final stats = snapshot.data!;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isLarge = constraints.maxWidth > 600;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              SizedBox(
                                width: isLarge ? constraints.maxWidth * 0.45 : double.infinity,
                                height: 133,
                                child: _buildCardSottoSoglia(stats['sottoSoglia'] ?? 0),
                              ),
                              SizedBox(
                                width: isLarge ? constraints.maxWidth * 0.45 : double.infinity,
                                height: 133,
                                child: _buildCardEsauriti(stats['esauriti'] ?? 0),
                              ),
                            ],
                          );
                        },
                      );
                    },
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
                    // Qui assegni un’altezza fissa per la lista
                    SizedBox(
                      height: 300, // adatta l'altezza a seconda della tua UI
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('prodotti').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final prodottiFiltrati = snapshot.data!.docs.where((doc) {
                            final data = doc.data()! as Map<String, dynamic>;
                            return data['quantita'] < data['soglia'];
                          }).toList();

                          if (prodottiFiltrati.isEmpty) {
                            return Center(child: Text('Nessun prodotto da ordinare'));
                          }

                          return AnimationLimiter(
                            child: ListView.builder(
                              itemCount: prodottiFiltrati.length,
                              itemBuilder: (context, index) {
                                final prodotto = prodottiFiltrati[index];
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 3,
                                        margin: EdgeInsets.symmetric(vertical: 6),
                                        child: ListTile(
                                          title: Text(prodotto['nome']),
                                          subtitle: Row(
                                            children: [
                                              if (prodotto['quantita'] == 0) ...[
                                                Icon(Icons.error, color: Colors.red, size: 18),
                                                SizedBox(width: 4),
                                                Text("Esaurito"),
                                              ] else if (prodotto['quantita'] < prodotto['soglia']) ...[
                                                Icon(Icons.warning, color: Colors.orange, size: 18),
                                                SizedBox(width: 4),
                                                Text("Da tenere d'occhio"),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80), // distanza da bottom nav bar
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.note_add, size: 24, color: Colors.white),
                    label: Text(
                      'Genera ordine',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                      shadowColor: Colors.tealAccent,
                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<Map<String, int>> prodottiStatsStream() {
    return FirebaseFirestore.instance
        .collection('prodotti')
        .snapshots()
        .map((snapshot) {
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

      return {
        'sottoSoglia': sottoSogliaCount,
        'esauriti': esauritiCount,
      };
    });
  }

  Widget _buildCardSottoSoglia(int sottoSoglia) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE16D), Color(0xFFFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(Icons.trending_down, color: Colors.white),
              ),
              SizedBox(width: 8),
              Text(
                'Sotto soglia',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '$sottoSoglia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardEsauriti(int count) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A80), Color(0xFFFF5252)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(Icons.warning_amber_rounded, color: Colors.white),
              ),
              SizedBox(width: 8),
              Text(
                'Esauriti',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'addproductform.dart';

class ProdottiPage extends StatefulWidget {
  @override
  State<ProdottiPage> createState() => _ProdottiPageState();
}

class _ProdottiPageState extends State<ProdottiPage> {
  String dataOggi = DateFormat('d MMMM', 'it_IT').format(DateTime.now());
  final CollectionReference prodottiCollection =
  FirebaseFirestore.instance.collection('prodotti');

  void _modificaProdotto(BuildContext context, String docId, Map<String, dynamic> prodotto) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Modifica Prodotto'),
        content: SingleChildScrollView(
          child: AddProductForm(
            prodottoDaModificare: prodotto,
            onSave: (modifiche) async {
              try {
                if (modifiche != null) {
                  await FirebaseFirestore.instance
                      .collection('prodotti')
                      .doc(docId)
                      .update(modifiche);
                }
                Navigator.of(dialogContext).pop(); // ✅ Questo è il contesto corretto
              } catch (e) {
                print("Errore nel salvataggio: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Errore durante la modifica")),
                );
              }
            },
          ),
        ),
      ),
    );
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
                      ],
                    ),
                    SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          dataOggi,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: prodottiCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('Nessun prodotto presente'));
          }

          return AnimationLimiter(
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final prodotto = doc.data()! as Map<String, dynamic>;
            
                Icon leadingIcon;
                if (prodotto['quantita'] == 0) {
                  leadingIcon = Icon(Icons.warning, color: Colors.red);
                } else if (prodotto['quantita'] < prodotto['soglia']) {
                  leadingIcon = Icon(Icons.error, color: Colors.orange);
                } else {
                  leadingIcon = Icon(Icons.check_circle, color: Colors.green);
                }
            
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: leadingIcon,
                            title: Text(prodotto['nome'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                            subtitle:
                            Text('Quantità: ${prodotto['quantita']}  Soglia: ${prodotto['soglia']}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(onPressed: () async {
                                  int quantitaCorrente = prodotto['quantita'] ?? 0;
                                  if (quantitaCorrente > 0) {
                                    await prodottiCollection.doc(doc.id).update({'quantita': quantitaCorrente - 1});
                                  }
                                }, icon: Icon(Icons.remove), color: Colors.red),
                                IconButton(onPressed: () async {
                                  int quantitaCorrente = prodotto['quantita'] ?? 0;
                                  await prodottiCollection.doc(doc.id).update({'quantita': quantitaCorrente + 1});
                                }, icon: Icon(Icons.add), color: Colors.green),
                                IconButton(
                                  onPressed: () => _modificaProdotto(context, doc.id, prodotto),
                                  icon: Icon(Icons.edit_outlined, color: Colors.blue,),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await prodottiCollection.doc(doc.id).delete();
                                  },
                                  icon: Icon(Icons.delete_outline, color: Colors.red,),
                                ),
                              ],
                            ),
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
    );
  }
}

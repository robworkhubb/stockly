import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plaza_storage/screens/addproductform.dart';
import 'package:plaza_storage/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:plaza_storage/screens/prodotti_page.dart' as prodotti;
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        fontFamily: 'Poppins',
      ),
      home: MainNavigation(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestione Magazzino',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  Timer? _timer;
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    HomePage(),
    Placeholder(),
    prodotti.ProdottiPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                title: Text('Aggiungi Prodotto'),
                content: SingleChildScrollView(
                  child: AddProductForm(
                    onSave: (newProduct) {
                      Navigator.of(context).pop(newProduct);
                    },
                  ),
                ),
              ),
            ).then((newProduct) async {
              if (newProduct != null) {
                await FirebaseFirestore.instance
                    .collection('prodotti')
                    .add(newProduct);
                setState(() {});
              }
            });
          });
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, size: 32, color: Colors.white,),
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0 ? Colors.teal : Colors.grey),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            SizedBox(width: 40), // spazio per il FAB centrale
            IconButton(
              icon: Icon(Icons.warehouse,
                  color: _selectedIndex == 2 ? Colors.teal : Colors.grey),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}

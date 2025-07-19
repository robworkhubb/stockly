// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stockely/screens/addproductform.dart';
import 'package:stockely/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stockely/widgets/floating_navbar.dart';
import 'services/firebase_options.dart';
import 'package:stockely/screens/prodotti_page.dart' as prodotti;
import 'dart:async';
import 'theme.dart';
import 'package:provider/provider.dart';
import 'provider/product_provider.dart';
import 'package:stockely/screens/ordinerapido.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: MainNavigation(),
      ),
    ),
  );
}

class MainNavigation extends StatefulWidget {
  MainNavigation({Key? key}) : super(key: key);
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController tabController;

  final List<Widget> _pages = [
    HomePage(),
    prodotti.ProdottiPage(),
    OrdineRapidoPage(),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: _pages.length, vsync: this);
    tabController.animation?.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != _selectedIndex && mounted) {
        setState(() {
          _selectedIndex = value;
        });
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingBottomNavBar();
  }
}

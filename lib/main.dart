import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:stockly/data/repositories/fornitore_repository_impl.dart';
import 'package:stockly/data/repositories/product_repository_impl.dart';
import 'package:stockly/provider/fornitore_provider.dart';
import 'package:stockly/provider/product_provider.dart';
import 'package:stockly/screens/splash_screen.dart';
import 'package:stockly/services/firestore_service.dart';
import 'package:stockly/firebase_options.dart';
import 'package:stockly/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Dependency Injection
  final firestoreService = FirestoreService();
  final productRepository = ProductRepositoryImpl(firestoreService);
  final fornitoreRepository = FornitoreRepositoryImpl(firestoreService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => FornitoreProvider(fornitoreRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    ),
  );
}

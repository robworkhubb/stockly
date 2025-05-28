import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plaza_storage/screens/addproductform.dart';
import 'package:plaza_storage/screens/home_page.dart';
import 'package:plaza_storage/screens/prodotti_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:plaza_storage/screens/addproductform.dart' as addform;
import 'package:plaza_storage/screens/prodotti_page.dart' as prodotti;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


Future<void> showNotification(String title, String body, String payload) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'storage_channel_id', // id del canale (unico)
    'Magazzino',          // nome canale
    channelDescription: 'Notifiche di magazzino',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,           // ID della notifica (puoi cambiare o incrementare)
    title,       // Titolo notifica
    body,        // Corpo testo notifica
    notificationDetails,
    payload: payload, // Dati per il tap
  );
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // NON mettere onSelectNotification qui
  );

  // Qui aggiungi un listener per il tap sulla notifica
  flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails()
      .then((details) {
    if (details != null && details.didNotificationLaunchApp) {
      // La app è stata aperta tappando su una notifica
      final payload = details.notificationResponse?.payload;
      // Gestisci il payload se vuoi
      print('App aperta da notifica con payload: $payload');
    }
  });
  runApp(MyApp());
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
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    HomePage(),
    Placeholder(), // Placeholder per il pulsante centrale "+"
    prodotti.ProdottiPage(),
  ];

  void _onItemTapped(int index) {
    if (index != 1) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // Azione per il pulsante centrale (aggiungi prodotto)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Aggiungi Prodotto'),
          content: SingleChildScrollView(
            child: AddProductForm(onSave: (newProduct) {  },),
          ),
        ),
      ).then((newProduct) async {
        if (newProduct != null && newProduct is Map<String, dynamic>) {
          await FirebaseFirestore.instance.collection('prodotti').add(newProduct);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Prodotti',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


  Widget _buildCardSottoSoglia(int sottoSoglia) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xF6FFC861),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 5),
            spreadRadius: 3.0,
            blurRadius: 4.5,
          ),
        ],
        border: Border.all(color: Colors.grey, width: 1),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '⬇ Prodotti sotto la soglia:',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '$sottoSoglia',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }

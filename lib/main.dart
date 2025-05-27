import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';

final List<Map<String, dynamic>> prodotti = [
  {'nome': 'Acqua Naturale', 'quantita': 7, 'soglia': 2},
  {'nome': 'Coca-Cola', 'quantita': 3, 'soglia': 5},
  {'nome': 'Fanta', 'quantita': 7, 'soglia': 3},
  {'nome': 'EstaThe Limone', 'quantita': 2, 'soglia': 1},
  {'nome': 'Gin Mare', 'quantita': 2, 'soglia': 1},
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // assicurati che Flutter sia inizializzato
  await initializeDateFormatting('it_IT', null); // inizializza per l’italiano
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    ProdottiPage(),
  ];

  void _onItemTapped(int index) {
    if (index != 1) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // Azione per il pulsante centrale (es. aggiunta prodotto)
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Aggiungi Prodotto'),
              content: SingleChildScrollView(child: AddProductForm()),
            ),
      ).then((newProduct) {
        if (newProduct != null) {
          setState(() {
            prodotti.add(newProduct);
          });
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

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dataOggi = DateFormat('d MMMM', 'it_IT').format(DateTime.now());

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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white70,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plaza Storage', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(dataOggi),
                      Spacer(),
                      Text('Benvenuto'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                      width: isLarge ? constraints.maxWidth * 0.45 : double.infinity,
                      height: 100,
                      child: _buildCardSottoSoglia(_sottosoglia),
                    ),
                    SizedBox(
                      width: isLarge ? constraints.maxWidth * 0.45 : double.infinity,
                      height: 100,
                      child: _buildCardEsauriti(esauriti.length),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            Text("Prodotti da ordinare", style: TextStyle(fontSize: 25)),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: prodottiFiltrati.length,
                itemBuilder: (context, index) {
                  final prodotto = prodottiFiltrati[index];
                  return ListTile(
                    title: Text(prodotto['nome']),
                    subtitle: Row(
                      children: [
                        if (prodotto['quantita'] == 0) ...[
                          Icon(Icons.error, color: Colors.red, size: 18),
                          SizedBox(width: 4),
                          Text("Esaurito"),
                        ] else if (prodotto['quantita'] <
                            prodotto['soglia']) ...[
                          Icon(Icons.warning, color: Colors.orange, size: 18),
                          SizedBox(width: 4),
                          Text("Da tenere d'occhio"),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OrdineRapidoPage(prodotti: prodottiFiltrati),
                      ),
                      );
                    }, child: Row(children: [Icon(Icons.note), Text(' Genera ordine')],)),
                    ElevatedButton(onPressed: (){
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                          title: Text('Aggiungi Prodotto'),
                          content: SingleChildScrollView(child: AddProductForm()),
                        ),
                      ).then((newProduct) {
                        if (newProduct != null) {
                          setState(() {
                            prodotti.add(newProduct);
                          });
                        }
                      });
                    }, child: Row(children: [Icon(Icons.warehouse), Text(' Nuovo Prodotto')],))
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  Widget _buildCardEsauriti(int count) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xF6FF6161),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 3),
              Text(
                'Prodotti esauriti:',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "$count",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}

class ProdottiPage extends StatefulWidget {
  @override
  State<ProdottiPage> createState() => _ProdottiPageState();
}

class _ProdottiPageState extends State<ProdottiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prodotti')),
      body: ListView.builder(
        itemCount: prodotti.length,
        itemBuilder: (context, index) {
          final prodotto = prodotti[index];
          return ListTile(
            leading: Icon(
              prodotto['quantita'] == 0
                  ? Icons.warning
                  : prodotto['quantita'] < prodotto['soglia']
                  ? Icons.error
                  : Icons.check_circle,
              color:
                  prodotto['quantita'] == 0
                      ? Colors.red
                      : prodotto['quantita'] < prodotto['soglia']
                      ? Colors.orange
                      : Colors.green,
            ),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  prodotti.removeAt(index);
                });
              },
              icon: Icon(Icons.delete),
            ),
            title: Text(prodotto['nome']),
            subtitle: Text(
              'Quantità: ${prodotto['quantita']} Soglia: ${prodotto['soglia']}',
            ),
          );
        },
      ),
    );
  }
}

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantitaController = TextEditingController();
  final TextEditingController _sogliaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _quantitaController.dispose();
    _sogliaController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(labelText: 'Nome Prodotto'),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Campo obbligatorio'
                        : null,
          ),
          TextFormField(
            controller: _quantitaController,
            decoration: InputDecoration(labelText: 'Quantità'),
            keyboardType: TextInputType.number,
            validator:
                (value) =>
                    int.tryParse(value ?? '') == null
                        ? 'Inserisci un numero'
                        : null,
          ),
          TextFormField(
            controller: _sogliaController,
            decoration: InputDecoration(labelText: 'Soglia minima di avviso'),
            validator:
                (value) =>
                    int.tryParse(value ?? '') == null
                        ? 'Inserisci un numero'
                        : null,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newProduct = {
                  'nome': _nomeController.text,
                  'quantita': int.parse(_quantitaController.text),
                  'soglia': int.parse(_sogliaController.text),
                };
                Navigator.pop(context, newProduct);
              }
            },
            child: Text('Aggiungi'),
          ),
        ],
      ),
    );
  }
}

class OrdineRapidoPage extends StatefulWidget {
  final List<Map<String, dynamic>> prodotti;
  const OrdineRapidoPage({Key? key, required this.prodotti}) : super(key: key);

  @override
  State<OrdineRapidoPage> createState() => _OrdineRapidoPageState();
}

class _OrdineRapidoPageState extends State<OrdineRapidoPage> {
  final Map<String, String> fornitori = {
    "Fornitore Bibite": "393760956101",
    "Fornitore Zucchero": "393881941520",
  };

  String fornitoreSelezionato = "Fornitore Bibite";

  late List<Map<String, dynamic>> prodottiDaOrdinare;

  @override
  void initState() {
    super.initState();
    prodottiDaOrdinare = widget.prodotti.where((prodotto) =>
    prodotto['quantita'] == 0 || prodotto['quantita'] < prodotto['soglia']).toList();
  }

  void _inviaOrdineWhatsapp() async {
    String numero = fornitori[fornitoreSelezionato]!;

    String messaggio = Uri.encodeComponent(
        "📦 Ordine rapido da Plaza Storage\n" +
            prodottiDaOrdinare.map((p) {
              int suggerita = (p['soglia'] as int) * 2;
              return "- ${p['nome']} x $suggerita";
            }).join("\n") +
            "\n📅 Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
    );

    final url = Uri.parse("https://wa.me/$numero?text=$messaggio");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore nell'apertura di WhatsApp"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ordine Rapido")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: fornitoreSelezionato,
              isExpanded: true,
              items: fornitori.keys.map((String nomeFornitore) {
                return DropdownMenuItem<String>(
                  value: nomeFornitore,
                  child: Text(nomeFornitore),
                );
              }).toList(),
              onChanged: (String? nuovo) {
                if (nuovo != null) {
                  setState(() {
                    fornitoreSelezionato = nuovo;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: prodottiDaOrdinare.length,
                itemBuilder: (context, index) {
                  final prodotto = prodottiDaOrdinare[index];
                  final nome = prodotto['nome'];
                  final quantitaSuggerita = (prodotto['soglia'] as int) * 2;

                  return ListTile(
                    leading: Icon(Icons.shopping_cart_outlined),
                    title: Text(nome),
                    subtitle: Text("Suggerito: $quantitaSuggerita unità"),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text("Genera ordine WhatsApp"),
              onPressed: _inviaOrdineWhatsapp,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.green,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 40,),
          ],
        ),
      ),
    );
  }
}


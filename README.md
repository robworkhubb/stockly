# 📦 Plaza Storage

**Plaza Storage** è un'app mobile Flutter progettata per la gestione di un piccolo magazzino. Permette di aggiungere, monitorare e ricevere notifiche sui prodotti in stock. L'app è pensata per essere semplice, veloce ed efficace, ideale per negozi, laboratori o piccole attività.

## 🚀 Funzionalità principali

- ✅ Aggiunta rapida dei prodotti con nome, quantità, soglia minima, descrizione.
- 📉 Visualizzazione prodotti esauriti o sotto soglia.
- 🔔 Notifiche locali automatiche sui prodotti critici.
- 🏠 Interfaccia divisa in 3 schermate principali: Home, Aggiungi, Prodotti.
- 📆 Data corrente mostrata nella home.
- 📱 UI moderna e intuitiva.
- 🔄 Aggiornamento in tempo reale dopo l'aggiunta o modifica dei prodotti.

## 📸 Screenshot

*(Inserisci qui gli screenshot delle tre schermate principali: Home, Aggiungi prodotto, Lista prodotti)*

## 📁 Struttura del progetto

lib/
├── main.dart
├── models/
│ └── product.dart
├── services/
│ └── notification_service.dart
├── screens/
│ ├── home_page.dart
│ ├── add_product_page.dart
│ └── product_list_page.dart
├── widgets/
│ └── product_card.dart
└── providers/
└── product_provider.dart

markdown
Copia
Modifica

## 🔔 Notifiche

Le notifiche push **locali** vengono attivate all'avvio dell'app (nel `initState` della `HomePage`) e avvisano l'utente in caso di:

- ❌ Prodotti esauriti (quantità = 0)
- ⚠️ Prodotti sotto soglia (quantità ≤ soglia minima)

Le notifiche usano la libreria [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications).


🛠️ Come avviare l'app
Clona il repository:

bash
Copia
Modifica
git clone https://github.com/tuo-username/plaza-storage.git
Installa le dipendenze:

bash
Copia
Modifica
flutter pub get
Avvia l'app:

bash
Copia
Modifica
flutter run
👨‍💻 Autore
Sviluppato con ❤️ da Roberto – Studente e sviluppatore Flutter junior.

Se ti piace il progetto, lascia una ⭐ su GitHub o contattami per collaborazioni!


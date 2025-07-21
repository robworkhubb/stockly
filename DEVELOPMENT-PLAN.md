# Stockly – Piano di sviluppo e Architettura

**Stockly** è un'app mobile realizzata in Flutter per la gestione semplificata del magazzino.  
Permette all'utente di aggiungere, modificare e monitorare prodotti, notificando automaticamente quando un prodotto è esaurito o sotto soglia.

## 🧱 Architettura a 3 Strati (Clean Architecture)

L'architettura di Stockly è basata sui principi della **Clean Architecture** per garantire una netta separazione delle responsabilità, alta testabilità e manutenibilità. Il progetto è suddiviso in 3 layer principali:

1.  **Presentation Layer**: La UI dell'applicazione. Include widget, schermate e la gestione dello stato della UI (tramite Provider). Questo strato non conosce i dettagli dell'implementazione del database o di altre fonti dati.
2.  **Domain Layer**: Il cuore della logica di business. Include i modelli dati (`Product`, `Fornitore`) e i "Repository" (contratti/interfacce) che definiscono le operazioni sui dati, senza specificare come vengono implementate. Questo strato è completamente indipendente dalla UI e dalla fonte dati.
3.  **Data Layer**: L'implementazione concreta delle fonti dati. Include le implementazioni dei Repository e i servizi che comunicano con API esterne (come `FirestoreService`). Questo strato è responsabile di recuperare e salvare i dati.

### Flusso dei Dati

Il flusso dei dati segue una regola di dipendenza unidirezionale: `Presentation -> Domain -> Data`.

```mermaid
graph TD
    A[Presentation Layer <br> (UI, Provider)] --> B[Domain Layer <br> (Repository, Models)];
    B --> C[Data Layer <br> (FirestoreService, API)];
```

Questo disaccoppiamento permette di:
-   **Sostituire facilmente la fonte dati**: Possiamo passare da Firestore a un altro database modificando solo il Data Layer, senza toccare la UI o la logica di business.
-   **Testare la logica di business in isolamento**: È possibile testare i repository e i provider usando dati finti ("mock"), senza dipendere da Firebase.
-   **Mantenere il codice organizzato e leggibile**.

### 🎯 Obiettivi principali
- Gestire piccoli magazzini o dispense in modo veloce.
- Ricevere **notifiche push locali** per prodotti esauriti o sotto soglia.
- Aggiungere prodotti tramite una UI semplice e rapida.
- Visualizzare lo stato dei prodotti critici nella schermata principale.

### 🧱 Architettura
- **Flutter + Provider** per la gestione dello stato.
- **Modularizzato** in cartelle: `models/`, `providers/`, `services/`, `screens/`, `widgets/`.
- **flutter_local_notifications** per la gestione delle notifiche push locali.

### ✏️ MVP Funzionalità implementate
- Aggiunta prodotto con quantità minima e quantità attuale.
- Home con **info-box** su prodotti esauriti o sotto soglia.
- Lista prodotti con stato, quantità e soglia.
- Navigazione a schede (Home, Aggiunta, Prodotti).
- Trigger notifiche alla partenza dell’app (`initState`).

## 🚀 OTTIMIZZAZIONE

### 1. Logica principale (main.dart, provider)
- Rimosso l’uso di const dove non supportato dai costruttori delle pagine per evitare errori linter.
- Aggiunti commenti per suggerire l’uso di const e IndexedStack dove possibile per migliorare performance e mantenimento stato tra tab.
- In `ProductProvider`:
  - Rimossi i print di debug in produzione.
  - Notifica i listener solo se la lista prodotti cambia davvero.
  - Suggerito l’uso di UnmodifiableListView per esporre la lista prodotti in sola lettura.
  - Aggiornamento ottimizzato della quantità senza ricaricare tutta la lista.

### 2. Schermate
- In `home_page.dart`:
  - Uso di const per widget statici dove possibile.
  - Calcoli dei filtri (prodotti sotto soglia, esauriti, ecc.) spostati fuori dai widget per evitare calcoli ripetuti.
  - Suggerito l’uso di ListView.builder se la lista dei prodotti cresce molto.
  - Nota su stream non utilizzato: valutare se integrarlo o rimuoverlo.
  - Suggerito l’uso di un logger invece di print per la gestione degli errori in produzione.

- In `prodotti_page.dart`:
  - Uso di const per widget statici dove possibile.
  - Se la lista prodotti supera 20 elementi, viene usato ListView.builder invece di Column per performance.
  - Suggerita la modularizzazione dei dialog in widget separati se crescono.
  - Commenti su best practice e ottimizzazione.

### 3. Widget
- Suggerito di rendere const i widget personalizzati dove possibile.
- Suddividere la UI in widget più piccoli e riutilizzabili per ridurre i rebuild.
- Se si usano immagini remote, suggerito l’uso di caching.

- In `ProductCard`:
  - Costruttore const, uso di const per le icone, getter helper per leadingIcon.
- In `InfoBox`:
  - Costruttore const, uso di const per widget statici, suggerimento di passare valori const dal chiamante.
- In `MainButton`:
  - Costruttore const, uso di const per widget statici, suggerimento di passare valori const dal chiamante.
- In `FornitoreDialog`:
  - Costruttore const, uso di const per widget statici, nota su modularizzazione campi e gestione controller per evitare memory leak.

### Best practice generali
- Profiling con Flutter DevTools per individuare colli di bottiglia.
- Chiudere sempre controller/stream nei widget stateful.
- Mantenere il file pubspec.yaml pulito da dipendenze inutilizzate.
- Aggiornare Flutter e i pacchetti per beneficiare delle ultime ottimizzazioni.

# Aggiornamento 2025: Analitiche e Refactoring Modello

## Refactoring Modello Product
- Il modello Product ora include: categoria, prezzoUnitario, consumati, ultimaModifica.
- Rimosso il campo fornitore da tutte le istanze e riferimenti.

## Provider
- I metodi del provider ora espongono aggregazioni per dashboard: top consumati, distribuzione per categoria, spesa mensile.
- Tutte le creazioni/aggiornamenti di Product ora richiedono i nuovi parametri obbligatori.

## Form e UI
- Il form di aggiunta/modifica prodotto ora include categoria e prezzo unitario.
- Tutte le schermate sono state aggiornate per usare il nuovo modello.

## Dashboard Analitica
- Aggiunta una pagina dashboard che mostra:
  - Top 5 prodotti consumati (bar chart)
  - Distribuzione per categoria (pie chart)
  - Spesa mensile totale (line chart)
- I dati sono aggregati dal provider e visualizzati con fl_chart.

## Firestore
- Tutte le query e i salvataggi sono ora coerenti con il nuovo modello.
- I metodi toJson/fromJson sono stati sostituiti da toFirestore/fromFirestore.

## Migrazione
- Tutti i riferimenti a fornitore sono stati rimossi.
- I dati esistenti devono essere migrati per includere i nuovi campi obbligatori.

# Changelog 2025

- Refactoring modello Product: aggiunti categoria, prezzoUnitario, consumati, ultimaModifica.
- Dashboard analitica: top 5 prodotti consumati, distribuzione per categoria, spesa mensile totale.
- Provider aggiornato per aggregazioni e performance.
- UI e form modernizzati e coerenti.
- Query Firestore ottimizzate e coerenti con il nuovo modello.
- Rimozione campo fornitore e metodi toJson/fromJson.
- Best practice di sviluppo e manutenzione documentate.

# Aggiornamenti 2025

- L'app si chiama ora **Stockly**.
- Refactoring completo del modello Product: aggiunti categoria, prezzoUnitario, consumati, ultimaModifica.
- Dashboard analitica con grafici moderni (fl_chart): top 5 prodotti consumati, distribuzione per categoria, spesa mensile totale.
- Provider aggiornato per aggregazioni e performance.
- UI e form modernizzati e coerenti.
- Query Firestore ottimizzate e coerenti con il nuovo modello.
- Tutti gli import ora sono `package:stockly/...`.

# Esempi di utilizzo funzioni

## Ottenere metriche dal provider

```dart
final provider = Provider.of<ProductProvider>(context);

// Top 5 prodotti consumati
final topProducts = provider.topConsumati();

// Distribuzione per categoria
final categoryDist = provider.distribuzionePerCategoria();

// Spesa mensile totale
final monthlyExpense = provider.spesaMensile();
```

## Modificare/estendere le funzioni

- Per cambiare la logica di aggregazione, modifica i metodi in `product_provider.dart`.
- Per aggiungere nuove metriche, crea nuovi metodi che aggregano i dati della lista `prodotti`.
- Per visualizzare nuove metriche nella dashboard, aggiungi una nuova Card e il relativo grafico in `dashboard_page.dart`.

Esempio: aggiungere una metrica "prodotti mai consumati":
```dart
List<Product> maiConsumati() {
  return prodotti.where((p) => p.consumati == 0).toList();
}
```

Integra la funzione nella dashboard come vuoi!


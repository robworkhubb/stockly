# Plaza Storage

**Plaza Storage** è un'app mobile realizzata in Flutter per la gestione semplificata del magazzino.  
Permette all'utente di aggiungere, modificare e monitorare prodotti, notificando automaticamente quando un prodotto è esaurito o sotto soglia.

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

### 📦 Da fare / refactoring in corso
- Miglioramento UI/UX con componenti riutilizzabili e tema coerente.
- Pulizia codice, rimozione logiche duplicate.
- Modularizzazione e separazione di responsabilità nei widget.

# Guide d'activation finale — Deadpool IA

A faire **une seule fois** pour rendre l'app 100% operationnelle en production.

---

## 1. Migration SQL Supabase

Ouvre **Supabase → SQL Editor** et execute :

```
sql/migration_h1_reminder.sql
```

Cela ajoute :
- `appointments.h1_reminder_sent` (BOOLEAN) → utilise par le workflow SMS H-1
- `appointments.google_event_id` (TEXT) → stocke l'ID d'event retourne par Google Calendar
- 2 index pour optimiser les queries cron

Aucun impact sur les donnees existantes.

---

## 2. Expediteur Brevo

Tous les emails automatises utilisent `noreply@visitandsmile.fr`. Cet expediteur doit etre verifie dans Brevo sinon les envois echouent.

### Option A — Utiliser le domaine visitandsmile.fr
1. Brevo → **Senders, Domains & Dedicated IPs** → **Domains** → Ajouter `visitandsmile.fr`
2. Ajouter les enregistrements DNS (SPF, DKIM) fournis par Brevo chez le registrar du domaine
3. Attendre la validation (quelques minutes a 24h)

### Option B — Utiliser directement l'email d'Alison
1. Brevo → **Senders** → Ajouter un nouvel expediteur avec l'email personnel/pro d'Alison
2. Valider via le mail de confirmation recu
3. Remplacer dans chaque workflow n8n :
   ```
   "email": "noreply@visitandsmile.fr"
   ```
   par l'email valide.

Les 7 workflows email a mettre a jour :
- Email Confirmation RDV (`4sXKFLUiEoR48Q71`)
- Email Anniversaire clients (`raroE26supQB8HEs`)
- Email Fallback (dans SMS J-1 `jMwMr5SG9fadIbpk`)
- Relances Clients (`2ACxIzKRd1ju95Ge`)
- Email Resume Hebdo (`AXIuA0XgdjCNpUSU`)
- Email Rappel URSSAF (`2hLl7R1WNVjXUpJD`)

---

## 3. Google Calendar OAuth (workflow Sync GCal)

Le workflow `lMzRfBzdwnSldRwE` est cree mais **non active** car il necessite une credential OAuth2.

1. n8n → **Credentials** → **Create New** → **Google Calendar OAuth2 API**
2. Suivre le flux OAuth (autoriser l'acces au Google Calendar d'Alison)
3. Ouvrir le workflow `Deadpool IA - Sync Google Calendar`
4. Sur le node **Create GCal Event** → selectionner la credential creee
5. **Activer** le workflow (toggle en haut a droite)

Une fois active, chaque RDV cree dans l'app genere automatiquement un event Google Calendar.

---

## 4. Verification finale

Dans l'app (Parametres → Automatisations n8n), le compteur doit afficher **11/11** une fois GCal active.

Tests rapides depuis le panneau Automations :
- **Email confirmation RDV** → envoie une requete vide (simulation)
- **Chatbot** → reponse Claude
- **Nouvelle vente** → declenche le resume de vente
- **Sync GCal** → creation event

Sinon, test complet : creer un vrai RDV depuis la page Planning, verifier :
1. Toast "RDV planifie" + "Email envoye" + "Google Calendar sync"
2. Email recu a l'adresse du client test
3. Event visible dans Google Calendar
4. Apres 1h, SMS H-1 (si numero renseigne)
5. A 18h la veille, SMS J-1

---

## Cadence des automations deployees

| Workflow | Declencheur | Frequence |
|---|---|---|
| Email confirmation RDV | Webhook | A chaque creation RDV |
| Sync Google Calendar | Webhook | A chaque creation RDV |
| SMS Rappel J-1 | Cron | 18h quotidien |
| SMS Rappel H-1 | Cron | Chaque heure |
| Email Anniversaire | Cron | 9h quotidien |
| Relances J+1/J+3/J+7 | Cron | 10h quotidien |
| Email Resume Hebdo | Cron | Lundi 9h |
| Email Rappel URSSAF | Cron | 20 Jan/Avr/Jul/Oct 9h |
| Agent Social Autopost | Cron | Lun/Mer/Ven 10h |
| Chatbot Deadpool | Webhook | On-demand |
| Nouvelle vente | Webhook | A chaque creation vente |

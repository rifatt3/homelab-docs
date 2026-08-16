# Governance – Azure Policy & Initiative

**Ziel:** Governance-Kette von der Policy-Definition bis zur Compliance-Auswertung aufbauen

**Scope:** Resource Group `rg-lab-az900`

## Aufbau

| Ebene | Umsetzung |
|---|---|
| Policy Definition | `Allowed Locations Audit` – auditiert Ressourcen ausserhalb erlaubter Regionen |
| Initiative Definition | `Get Secure` – Bündel mit Built-in-Policy *Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost* |
| Assignment | Initiative auf `rg-lab-az900`, Enforcement: Default, mit Non-Compliance-Message |

## Design-Entscheidungen

- **Effekt `audit` statt `deny`:** erst Bestandsaufnahme, dann Durchsetzung – vermeidet, dass
  laufende Deployments blockiert werden, bevor der Bestand bereinigt ist
- **Parametrisierte `allowedLocations`:** Regionsliste wird beim Assignment übergeben, nicht in der
  Definition hinterlegt – dieselbe Definition ist damit für mehrere Scopes wiederverwendbar
- **Initiative statt Einzel-Policy:** ergibt einen konsolidierten Compliance-Wert und eine
  Zuweisung statt mehrerer
- **Scope bewusst eng gefasst:** höhere Scopes (Subscription, Management Group) wären möglich
- **Non-Compliance-Message gesetzt:** verständliche Begründung statt generischer Fehlermeldung

## Test-Deployment (nicht durchführbar)

Zur Verifikation war eine Windows-VM im Scope vorgesehen. Deployment über mehrere Regionen
hinweg nicht möglich (siehe Stolpersteine); Compliance-Auswertung daher ohne Ressourcen im Scope.

## Stolpersteine & Lösungen

| Problem | Ursache | Lösung / Erkenntnis |
|---|---|---|
| Gängige VM-Grössen durchgehend „Size not available" | Resource Provider `Microsoft.Compute` nicht registriert | Registrierung unter Subscription → Resource providers; Symptom lässt keinen Rückschluss auf die Ursache zu |
| Nach Registrierung weiterhin keine Grössen wählbar | „Insufficient quota – family limit": Free-Trial-Subscription ohne vCPU-Kontingent | Für Compute-Szenarien Umstellung auf Pay-as-you-go erforderlich |
| Teil der Grössen als „Incompatible with Trusted launch" markiert | Security Type schränkt verfügbare SKUs ein | Security Type `Standard` erweitert die Auswahl |

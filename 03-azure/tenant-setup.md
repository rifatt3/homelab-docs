# Azure Tenant – Grundkonfiguration

**Ziel:** Cloud-Seite des Hybrid-Labs; Basis für Governance-, Identity- und Infrastruktur-Szenarien

**Subscription:** Azure Free Account · **Tenant:** *.onmicrosoft.com

## Kontenmodell

| Ebene | Konto | Berechtigung |
|---|---|---|
| Billing | persönliches Microsoft-Konto | Billing Account Owner |
| Ressourcen (Azure RBAC) | Entra-User | Owner auf Subscription |
| Verzeichnis (Entra-Rollen) | derselbe Entra-User | Global Administrator |

**Begründung:** Persönliche Microsoft-Konten sind keine Entra-Objekte und damit von
identitätsbezogenen Funktionen (MFA-Registrierung, Conditional Access) ausgeschlossen.
Verwaltung erfolgt deshalb über einen dedizierten Entra-User; das persönliche Konto
bleibt reiner Billing-Inhaber.

## Umsetzung

1. Entra-User angelegt, RBAC-Rolle `Owner` auf Subscription-Ebene zugewiesen
2. Entra-Rolle `Global Administrator` für Verzeichnisverwaltung
3. Authentication Method `Microsoft Authenticator` tenantweit aktiviert,
   anschliessend benutzerseitige Registrierung (aka.ms/mysecurityinfo)
4. Kostenkontrolle: Budget mit Alerts bei 50 % / 80 % Actual Cost

## Design-Entscheidungen

- **RBAC ≠ Entra-Rollen:** zwei unabhängige Berechtigungssysteme; keine Rolle impliziert die andere
- **`Owner` mit uneingeschränkter Rollenvergabe** im Lab bewusst gewählt – produktiv wäre
  `Contributor` bzw. die eingeschränkte Condition angemessen
- **MFA ist zweistufig:** Tenant-Policy legt zulässige Methoden fest, Registrierung erfolgt
  pro Benutzer; Erzwingung später über Conditional Access
- Namenskonvention `rg-`, `vm-`, `vnet-`

## Stolpersteine & Lösungen

| Problem | Ursache | Lösung |
|---|---|---|
| Security-Info-Portal verweigert Anmeldung | persönliches MS-Konto ist keine Entra-Identität | Registrierung über dedizierten Entra-User |
| Kostenanzeige initial nicht verfügbar | Rollenzuweisung noch nicht propagiert | nach kurzer Wartezeit verfügbar; Billing-Ebene bleibt dem Billing Owner vorbehalten |

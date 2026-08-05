# DC01 – Domain Controller Deployment

**Ziel:** Erster Domain Controller der Lab-Domäne `lab.local` als Hyper-V-Gast auf HV01
**VM-Specs:** Generation 2 · 4 GB RAM (Dynamic Memory) · 60 GB VHDX (dynamically expanding) · vSwitch: LabSwitch (Internal)
**OS:** Windows Server 2025 Standard Evaluation (Desktop Experience)

## Umsetzung

1. VM über New-VM-Wizard erstellt (Ablage unter C:\Lab\VMs, ISO aus C:\Lab\ISOs als Bootmedium)
2. Windows Server in der VM installiert (Desktop Experience)
3. Grundkonfiguration per PowerShell:

```powershell
# Statische IP im isolierten Lab-Netz (kein Gateway – LabSwitch ist Internal)
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.0.10 -PrefixLength 24

# DNS auf sich selbst (DC01 wird eigener DNS-Server)
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.0.10

Rename-Computer -NewName "DC01" -Restart
```

4. AD DS installiert und Forest erstellt:

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName "lab.local" -DomainNetbiosName "LAB" -InstallDns
```

5. Verifikation nach automatischem Neustart: Login als LAB\Administrator, `Get-ADDomain` liefert lab.local

## Design-Entscheidungen

- **Statische IP für den DC:** Server werden gefunden, Clients finden – DC/DNS braucht eine feste Adresse, auf die alle Domänenmitglieder zeigen
- **DNS auf dem DC mitinstalliert:** AD ist ohne funktionierendes DNS nicht betriebsfähig (Service-Location via SRV-Records)
- **SafeMode-Administrator-Passwort** (DSRM) gesetzt und separat abgelegt – Recovery-Zugang am Verzeichnisdienst vorbei
- **Checkpoint `frische-domaene`** nach sauberem Shutdown erstellt – Wiederherstellungspunkt für Übungsszenarien (Hinweis: Checkpoints auf produktiven DCs problematisch, im Lab bewusst eingesetzt)

## Stolpersteine & Lösungen

| Problem | Ursache | Lösung |
|---|---|---|
| Sonderzeichen falsch (- ergibt /) | VM mit US-Tastaturlayout installiert | `Set-WinUserLanguageList -LanguageList de-CH -Force`, ab-/anmelden; Learning: Layout VOR dem Setzen von Passwörtern prüfen |
| Diverse gelbe Warnungen bei Prerequisite Checks | Standardhinweise (DNS-Delegation, Kompatibilität) | Erwartbar; entscheidend ist "All prerequisite checks passed successfully" |

## Learnings

- Rollentrennung: HV01 virtualisiert nur, DC01 authentifiziert nur – ein System, eine Aufgabe
- Isoliertes Lab-Netz (10.0.0.0/24 am Internal Switch) reicht für AD vollständig; Internet folgt später via External Switch
- Ab dieser Phase: jede GUI-Aufgabe einmal in PowerShell nachvollziehen (Befehle oben = Beginn der Script-Sammlung)

## Nächste Schritte

- [ ] OU-Struktur für fiktives KMU (Treuhandbüro)
- [ ] Testuser und Sicherheitsgruppen nach AGDLP
- [ ] Erste GPOs (Passwort-Policy, Desktop-Standards)
- [ ] CL01 (Windows 11) erstellen und in Domäne joinen

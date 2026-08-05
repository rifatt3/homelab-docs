# HV01 – Hypervisor-Host Setup

**Ziel:** Hyper-V-Host für ein Hybrid-Lab auf Consumer-Hardware
**Hardware:** HP EliteBook 840 G7 · 16 GB RAM · 477 GB NVMe (Kioxia)
**OS:** Windows Server 2025 Standard Evaluation (Desktop Experience), EN / Keyboard CH

## Umsetzung

1. Boot-Stick am Zweitgerät erstellt (Rufus, GPT/UEFI, Server-2025-Eval-ISO)
2. Boot via F9-Menü, Custom Install, bestehende Linux-Partitionen entfernt
3. Grundkonfiguration: Rename zu HV01, Windows Update
4. Remote-Verwaltung: RDP aktiviert, Betrieb mit geschlossenem Deckel
   (Power Options: "When I close the lid → Do nothing", Plan: High Performance)
5. Verwaltung ausschliesslich remote vom Arbeitsgerät (mstsc) – Server läuft headless

## Besonderheit: Consumer-Hardware als Server

Das EliteBook 840 G7 hat keinen RJ45-Port. Netzanbindung vorerst via WLAN;
External vSwitch damit nicht sauber möglich (WLAN-Bridging-Limitierung) →
Plan: Internal vSwitch für die AD-Phase, USB-Gigabit-NIC bestellt für
External Switch ab Phase 2/3.

## Stolpersteine & Lösungen

| Problem | Ursache | Lösung |
|---|---|---|
| Kein WLAN nach Installation | Server-OS: WLAN-Feature inaktiv, kein Treiber | Feature "Wireless LAN Service" + WLAN AutoConfig-Dienst; Intel AX201-Treiber (Win11-Paket, kompatibel) |
| Touchpad ohne Funktion | Fehlende Serial-IO-Treiber im Server-OS | Übergangsweise USB-Maus; obsolet seit RDP-Betrieb |
| Display fix auf 100 % Helligkeit | Microsoft Basic Display Adapter | Intel Graphics Driver nachinstalliert |
| Setup: "Windows can't be installed on partition" | Alt-Partitionen (Linux/EFI) | Alle Partitionen gelöscht, Install auf Unallocated Space |

## Learnings

- Windows Server hat keinen Bluetooth-Stack – BT-Peripherie am Server ist keine Option
- Win11-Treiber laufen i.d.R. auf Server 2025 (gleiche Codebasis) – nützlich für Nicht-Server-Hardware
- Evaluation: 180 Tage, via `slmgr /rearm` bis 5× verlängerbar (`slmgr /dlv` zeigt Reststand)

## Nächste Schritte

- [x] Hyper-V-Rolle installieren
- [x] Internal vSwitch `LabSwitch`
- [x] Ordnerstruktur C:\Lab\ISOs, C:\Lab\VMs
- [x] VM DC01 (Domain Controller, Domäne lab.local)

# VNet-Segmentierung – Web- und Datenbank-Tier

**Ziel:** Zwei-Tier-Architektur mit segmentiertem Netzwerkzugriff; Web-Tier aus dem Internet
erreichbar, Datenbank-Tier ausschliesslich aus dem Web-Subnetz

## Aufbau

| Ressource | Wert |
|---|---|
| VNet | `vnet-lab`, 10.0.0.0/16 |
| Subnetz Web | `snet-web`, 10.0.1.0/24 |
| Subnetz DB | `snet-db`, 10.0.2.0/24 |
| NSGs | `nsg-web`, `nsg-db` – jeweils am Subnetz assoziiert |

### nsg-web

| Prio | Regel | Quelle | Ziel | Port | Aktion |
|---|---|---|---|---|---|
| 100 | Allow-HTTP-HTTPS | Any | Any | 80, 443 TCP | Allow |

### nsg-db

| Prio | Regel | Quelle | Ziel | Port | Aktion |
|---|---|---|---|---|---|
| 100 | Allow-SQL-from-Web | 10.0.1.0/24 | 10.0.2.0/24 | 1433 TCP | Allow |
| 150 | Allow-AzureLoadBalancer | Service Tag AzureLoadBalancer | Any | Any | Allow |
| 200 | Deny-VNet-Inbound | Service Tag VirtualNetwork | Any | Any | Deny |

## Design-Entscheidungen

- **Explizite Deny-Regel gegen VNet-Verkehr:** Die Standardregel `AllowVnetInBound` (Prio 65000)
  erlaubt sämtlichen Verkehr innerhalb des VNets. Ohne Regel 200 wäre das DB-Subnetz zwar vom
  Internet getrennt, aber aus jedem Subnetz auf jedem Port erreichbar – Abschottung nach aussen
  ist nicht dasselbe wie Segmentierung nach innen.
- **AzureLoadBalancer separat freigegeben:** Das Service Tag `VirtualNetwork` umfasst auch
  Plattformverkehr. Ohne Ausnahme bei Prio 150 würden Health Probes eines späteren Load Balancers
  blockiert und VMs als unhealthy gemeldet.
- **Prioritätenreihenfolge:** Auswertung von niedrig nach hoch, erste passende Regel gewinnt –
  Allow-Regeln müssen deshalb vor der Deny-Regel liegen.
- **NSG am Subnetz statt an der NIC:** gilt automatisch für alle künftigen Ressourcen im Subnetz.

## Hinweis

Azure meldet bei der Deny-Regel eine Warnung zum blockierten VNet-Zugriff. In diesem Fall
beabsichtigt – die Warnung unterscheidet nicht zwischen versehentlichem Aushebeln der
Standardregel und gewollter Segmentierung.

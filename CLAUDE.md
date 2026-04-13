# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

luci-app-syncdial is an OpenWrt LuCI application for multi-WAN PPPoE concurrent dialing (多线多拨). It uses macvlan to create virtual WAN interfaces from physical interfaces, enabling multiple simultaneous PPPoE connections for load balancing via mwan3.

**Dependencies:** `kmod-macvlan`, `luci-app-mwan3`

## Build

This is an OpenWrt package. Build within the OpenWrt buildroot:

```
make package/luci-app-syncdial/compile V=s
```

There are no tests or linting tools configured.

## Architecture

### LuCI Frontend (Lua)
- `luasrc/controller/syncdial.lua` — Route registration. Mounts the CBI model at `admin/network/syncdial` and provides a redial endpoint (`macvlan_redial`) that kills all pppd processes.
- `luasrc/model/cbi/syncdial.lua` — CBI form definition. All user-facing config options (enable, dial type, WAN count, IPv6, disconnect detection, etc.) map to UCI config `syncdial.config`.
- `luasrc/view/syncdial/redial_button.htm` — XHR-based "redial" button template.

### Shell Scripts (Backend)
- `root/bin/genwancfg` — Core script. On UCI commit, removes old vwan/macvlan configs, then regenerates macvlan devices, PPPoE interfaces, firewall zone entries, and mwan3 load-balancing config. Triggered via ucitrack (`/etc/uci-defaults/luci-syncdial`).
- `root/bin/pppconnectcheck` — Disconnect detection daemon. Checks online interface count against configured minimum; if too few are online, tears down all vwan interfaces and redials after a configurable wait.

### Hotplug Scripts
- `root/etc/hotplug.d/iface/01-dialcheck` — Triggers `pppconnectcheck` on interface down events; also recreates macvlan devices on ifup when using old_frame mode. Supports dual-WAN.
- `root/etc/hotplug.d/iface/01-mvifcreate` — Legacy single-WAN macvlan recreation on ifup (superseded by 01-dialcheck for dual-WAN).

### UCI Config
- `root/etc/config/syncdial` — Default config structure. Key options: `enabled`, `syncon` (concurrent dial), `dial_type` (1=single-line, 2=dual-line), `wannum`/`wannum2` (virtual WAN count per line), `old_frame` (legacy macvlan creation mode), `dialchk` (disconnect detection).

## Key Concepts

- **Two macvlan modes:** `old_frame=1` creates macvlan interfaces via `ip link add` at runtime; `old_frame=0` uses UCI device config (`network.macvlandev_*`).
- **Dual-WAN:** `dial_type=2` enables a second physical WAN with its own set of virtual interfaces (vwan numbering continues from first line's count).
- **vwan naming:** Virtual interfaces are named `vwan1`, `vwan2`, etc. Macvlan devices are `macvlan1`, `macvlan2`, etc.
- **mwan3 integration:** Unless `nomwan=1`, genwancfg auto-generates mwan3 interface/member/policy configs for load balancing.
- **Firewall backup:** The script backs up original firewall zone networks in `syncdial.config.devbackup` before modification.

## Language

UI strings are in Chinese (Simplified). Config keys and log tags are in English.

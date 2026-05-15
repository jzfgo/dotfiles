# Power Management — MacBook Air 2019 (CachyOS / Hyprland)

## What's running

| Tool | Purpose | Config |
|------|---------|--------|
| **TLP** | Main battery manager (CPU, WiFi, USB, PCIe, audio) | `/etc/tlp.d/01-macbook-air.conf` |
| **hypridle** | Idle → dim → lock → display off → suspend | `~/.config/hypr/hypridle.conf` |
| **power-profiles-daemon** | **Masked** — conflicts with TLP | — |

## Quick reference

```sh
sudo tlp start              # re-apply settings after a config change
sudo tlp-stat               # full status dump
sudo tlp-stat -p            # CPU / turbo / EPP
sudo tlp-stat -r            # WiFi / Bluetooth
sudo tlp-stat -e            # PCIe ASPM + runtime PM
sudo tlp-stat -u            # USB autosuspend
```

## Known trade-offs and how to fix them

### Turbo boost disabled on battery
CPU is capped at 1.6 GHz base clock. Saves ~1-2W.

**Symptom:** Sustained tasks (compiling, video calls) feel sluggish on battery.

**Fix:** In `/etc/tlp.d/01-macbook-air.conf`:
```
CPU_BOOST_ON_BAT=1
```
Then: `sudo tlp start`

---

### WiFi drops or high latency on battery
brcmfmac (Broadcom T2 WiFi) power management is known to cause intermittent
disconnects on some T2 MacBooks.

**Symptom:** WiFi cuts out or pings spike when on battery.

**Fix:** In `/etc/tlp.d/01-macbook-air.conf`:
```
WIFI_PWR_ON_BAT=off
```
Then: `sudo tlp start`

---

### Audio click/pop when sound starts
The audio codec powers down after 1s of silence on battery (saves ~0.5W).
The click when it wakes up is normal — not a hardware fault.

**Fix (if unbearable):** In `/etc/tlp.d/01-macbook-air.conf`:
```
SOUND_POWER_SAVE_ON_BAT=0
```
Then: `sudo tlp start`

---

### USB peripheral misbehaves on battery
USB autosuspend puts idle USB devices to sleep after 2s.
T2 internal devices (keyboard, trackpad, FaceTime camera) are not affected.

**Fix:** Find the device ID with `lsusb`, then in `/etc/tlp.d/01-macbook-air.conf`:
```
USB_DENYLIST="1234:5678"
```
Then: `sudo tlp start`

---

### TLP stops applying settings after an update
power-profiles-daemon (ppd) can get re-installed by package upgrades and
re-activate itself, silently blocking TLP's CPU settings.

**Symptom:** `sudo tlp start` prints warnings about ppd, CPU_BOOST or EPP
settings are not applied.

**Fix:**
```sh
sudo systemctl mask --now power-profiles-daemon
sudo tlp start
```

---

## Display / idle (hypridle)

Config: `~/.config/hypr/hypridle.conf`

| Timeout | Action |
|---------|--------|
| 2.5 min | Dim screen to 10%, turn off keyboard backlight |
| 5 min   | Lock screen (hyprlock) |
| 5.5 min | Display DPMS off |
| 30 min  | Suspend (`systemctl suspend`) |

hypridle is launched via Hyprland autostart (`~/.config/hypr/modules/autostart.conf`).
If the screen never dims, check: `pgrep hypridle` — if empty, it crashed; restart with `hypridle &`.

# Sling 🚀📱💻
**Zero-App QR File Sharing Between Phone & PC for [Omarchy](https://omarchy.org) / Quickshell**

Sling files between your smartphone (iPhone or Android) and your Linux PC with **zero apps to install on your mobile device**. Scan the QR code in the bar and the transfer portal opens in your phone's browser.

![Sling Preview](./preview.png)

---

## ✨ Features

* **📷 Zero Mobile Installation:** Point your regular phone camera at the QR code in the top bar and the transfer portal opens on your local Wi-Fi.
* **📱 Send from Phone to PC:** Tap to pick photos, videos or documents — files land in `~/Downloads/Sling/Received/`.
* **💻 Send from PC to Phone:** Put files in `~/Downloads/Sling/Send/`, or press **📤 Send file…** in the panel (file picker), and download them on the phone with one tap. Queued files are symlinked, not copied, so a 2 GB video costs no extra disk.
* **📊 Live Progress:** Large transfers show a progress bar — in the phone's page *and* in the bar panel (file, percent, MB/s), with the percentage in the bare bar label itself while it runs.
* **🔔 Native Desktop Notifications:** A desktop notification with the file count arrives as soon as transfers complete.
* **🔐 Token-gated:** Every request must carry a random token in the URL (`/t/<token>/`), created at start and carried by the QR code. Without it the server answers 403 and reveals nothing.
* **💤 Disarms itself:** The server exits after 15 minutes without traffic (`SLING_IDLE_TIMEOUT`), so leaving it started does not leave a permanent door open.
* **🏠 A name to remember:** `http://sling.local:5380` is published over mDNS (Avahi) and shown in the panel, so the address survives the router handing out a new IP. The QR code still carries the IP, because Android does not resolve `.local` reliably.
* **🌐 Automatic System & Browser Language (i18n):** English, Svenska, Nederlands, 日本語, Deutsch, Français, Español, 中文 — on both the PC and the phone.
* **🔒 100% Local & Private:** Direct peer-to-peer over your local Wi-Fi network. No cloud, no external servers, no tracking.

---

## 📦 Requirements

| Dependency | Needed for | Install (Arch/Omarchy) |
|---|---|---|
| `qrencode` | the QR code (**required**) | `sudo pacman -S qrencode` |
| `avahi` | the `sling.local` name (optional) | `sudo pacman -S avahi && sudo systemctl enable --now avahi-daemon` |
| `zenity` | the **Send file…** picker (optional) | `sudo pacman -S zenity` |
| `libnotify` | desktop notifications (optional) | usually already installed |
| `wl-clipboard` | the copy-link button (optional) | usually already installed |

Only `qrencode` is required; the rest degrade gracefully — the panel reports what is missing (`omarchy-sling status` → `"qr_ok": false`) instead of showing a blank square.

Verify a build at any time — it starts its own server on a spare port, uploads test files and checks them byte for byte, then probes the token gate, the size cap and the progress reporting:

```bash
omarchy-sling selftest
```

---

## 🛠️ Installation

```bash
omarchy plugin add https://github.com/alexwest1981/sling.git --enable
```

The CLI lives in `bin/omarchy-sling`; put it on your `PATH`:

```bash
ln -s ~/.config/omarchy/plugins/io.github.alexwest1981.sling/bin/omarchy-sling ~/.local/bin/omarchy-sling
```

### Allow Sling in your Firewall (Port 5380)

Linux firewalls block incoming connections from the local network by default. Allow incoming traffic on port `5380/tcp`:

* **If you use UFW (Omarchy default):**
  ```bash
  sudo ufw allow 5380/tcp
  ```

* **If you use firewalld:**
  ```bash
  sudo firewall-cmd --add-port=5380/tcp --permanent
  sudo firewall-cmd --reload
  ```

* **If you use nftables:**
  ```bash
  sudo nft add rule inet filter input tcp dport 5380 accept
  ```

### Restart Omarchy Shell

```bash
omarchy-restart-shell
```

---

## 🕹️ Usage

**From the panel:** click the bar icon — the server starts, the QR code appears inside the neon reticle, and the panel shows the URL, the `sling.local` address, a live progress bar while a large file is moving, the send queue and the last received files. Buttons: **📁 Open folder**, **📤 Send file…**, **▶ Start / 🛑 Stop**.

**From the terminal:**

```bash
omarchy-sling start                  # start the server, print the token URL
omarchy-sling status                 # JSON: running, url, mdns_url, qr_ok, active, queues
omarchy-sling send ~/Pictures/a.jpg  # queue files for the phone (symlinked)
omarchy-sling send-pick              # queue files via a file picker
omarchy-sling open                   # open the Received folder
omarchy-sling stop                   # stop now (SIGTERM, then SIGKILL)
omarchy-sling selftest               # verify parser, token gate, size cap and progress
```

Environment overrides: `SLING_PORT` (5380), `SLING_IDLE_TIMEOUT` (900 s), `SLING_MAX_UPLOAD` (2 GiB per request), `SLING_BASE_DIR` (`~/Downloads/Sling`), `SLING_MDNS_NAME` (`sling`).

---

## 🔐 Security model

The server has to listen on `0.0.0.0:5380` — the phone must reach it — so the protection is not the bind address but three gates:

1. **A token in the path.** Everything lives under `/t/<token>/`; a request without it gets 403 and learns nothing. The token is regenerated on every start and only appears in the panel, the QR code and `status`.
2. **Auto-disarm.** No traffic for `SLING_IDLE_TIMEOUT` (15 min by default) and the process exits, deleting its token.
3. **A hard size cap.** `SLING_MAX_UPLOAD` is checked before the body is read, so a hostile client cannot fill the disk.

Traffic is plain HTTP (no TLS) — anyone able to sniff your Wi-Fi can see file contents in transit. On your own home network that is the tradeoff; on an open network, transfer only between devices you trust.

Uploads are streamed straight to disk with a bounded buffer (a 150 MB file costs about 0.6 MB of resident memory, measured), filenames are HTML-escaped so a crafted name cannot inject script into the phone's page, and downloads are sent with an RFC 5987 encoded `Content-Disposition` so a filename cannot inject headers.

---

## 🗑️ Removal

```bash
omarchy plugin remove io.github.alexwest1981.sling
rm -f ~/.local/bin/omarchy-sling
rm -rf ~/Downloads/Sling ~/.local/state/sling    # received files, send queue and the log
```

Nothing else is written outside those paths, so removing them removes the plugin.

---

## 🎨 Design

The phone's page uses the neon palette: electric cyan `#00f0ff` for the reticle, the progress bar and control accents, hot magenta `#ff007f` for the wordmark, on an obsidian `#0d1117` canvas. The bar panel keeps your bar's own surface colours and uses the neon tones as accents, so it does not fight a light theme.

---

## 🛠️ Troubleshooting & Checklist

* **Same Wi-Fi Network:** Make sure your smartphone and your PC are connected to the same local Wi-Fi router (not mobile data 4G/5G).
* **AP/Client Isolation:** Some guest Wi-Fi networks have "Client Isolation" enabled, which prevents local devices from talking to each other. Use your standard home/office Wi-Fi.
* **Nothing happens when the QR is scanned:** read the log — `~/.local/state/sling/server.log`. It records the bind, the QR result and every rejected upload.
* **Missing QR code:** `qrencode` is not installed; `omarchy-sling status` reports `"qr_ok": false`.
* **Port already in use:** another instance is running (`omarchy-sling stop`, then start again). Starting when one already runs is a no-op, not an error.
* **Storage Location:** Received files are saved in `~/Downloads/Sling/Received/`, files waiting for the phone in `~/Downloads/Sling/Send/`.

---

## 📄 License

MIT License © 2026 [Alex Weström](https://github.com/alexwest1981)

# OmaDrop 🚀📱💻
**Zero-App QR File Sharing Between Phone & PC for [Omarchy](https://omarchy.org) / Quickshell**

Transfer photos, videos and files between your smartphone (iPhone or Android) and your Linux PC with **zero apps to install on your mobile device**.

![OmaDrop Preview Screenshot](./screenshot.png)

---

## ✨ Features

* **📷 Zero Mobile Installation:** Point your regular phone camera at the QR code in the top bar and the transfer portal opens on your local Wi-Fi.
* **📱 Send from Phone to PC:** Tap to pick photos, videos or documents — files land in `~/Downloads/OmaDrop/Received/`.
* **💻 Send from PC to Phone:** Put files in `~/Downloads/OmaDrop/Send/`, or press **📤 Send file…** in the panel (file picker), and download them on the phone with one tap. Queued files are symlinked, not copied, so a 2 GB video costs no extra disk.
* **🔔 Native Desktop Notifications:** A desktop notification with the file count arrives as soon as transfers complete.
* **🔐 Token-gated:** Every request must carry a random token in the URL (`/t/<token>/`), created at start and carried by the QR code. Without it the server answers 403 and reveals nothing.
* **💤 Disarms itself:** The server exits after 15 minutes without traffic (`OMADROP_IDLE_TIMEOUT`), so leaving it started does not leave a permanent door open.
* **🏠 A name to remember:** `http://omadrop.local:5380` is published over mDNS (Avahi) and shown in the panel, so the address survives the router handing out a new IP. The QR code still carries the IP, because Android does not resolve `.local` reliably.
* **📊 Progress & Streaming:** Real-time upload percentage, transfer speed and the last received files in the bar popup.
* **🌐 Automatic System & Browser Language (i18n):** English, Svenska, Nederlands, 日本語, Deutsch, Français, Español, 中文 — on both the PC and the phone.
* **🔒 100% Local & Private:** Direct peer-to-peer over your local Wi-Fi network. No cloud, no external servers, no tracking.

---

## 📦 Requirements

| Dependency | Needed for | Install (Arch/Omarchy) |
|---|---|---|
| `qrencode` | the QR code (**required**) | `sudo pacman -S qrencode` |
| `avahi` | the `omadrop.local` name (optional) | `sudo pacman -S avahi && sudo systemctl enable --now avahi-daemon` |
| `zenity` | the **Send file…** picker (optional) | `sudo pacman -S zenity` |
| `libnotify` | desktop notifications (optional) | usually already installed |
| `wl-clipboard` | the copy-link button (optional) | usually already installed |

Only `qrencode` is required; the rest degrade gracefully — the panel reports what is missing (`omarchy-omadrop status` → `"qr_ok": false`) instead of showing a blank square.

Verify a build at any time — it starts its own server on a spare port, uploads test files and checks them byte for byte, then probes the token gate and the size cap:

```bash
omarchy-omadrop selftest
```

---

##  Installation

### 1. Install the plugin

```bash
omarchy plugin add https://github.com/alexwest1981/OmaDrop.git --enable
```

Or by hand into the plugin directory:

```bash
git clone https://github.com/alexwest1981/OmaDrop.git ~/.config/omarchy/plugins/custom.omadrop
```

Add `custom.omadrop` to `bar.layout.right` in `~/.config/omarchy/shell.json` (the CLI does this for you if you prefer):

```json
{
  "bar": {
    "layout": {
      "right": [
        { "id": "custom.displays" },
        { "id": "custom.omadrop" },
        { "id": "omarchy.tray" }
      ]
    }
  }
}
```

The CLI lives in `bin/omarchy-omadrop`; put it on your `PATH`:

```bash
ln -s ~/.config/omarchy/plugins/custom.omadrop/bin/omarchy-omadrop ~/.local/bin/omarchy-omadrop
```

### 2. Allow OmaDrop in your Firewall (Port 5380)

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

### 3. Restart Omarchy Shell

```bash
omarchy-restart-shell
```

---

## 🕹️ Usage

**From the panel:** click the bar icon — the server starts, the QR code appears, and the panel shows the URL, the `omadrop.local` address, the send queue and the last received files. Buttons: **📁 Open folder**, **📤 Send file…**, **▶ Start / 🛑 Stop**.

**From the terminal:**

```bash
omarchy-omadrop start                  # start the server, print the token URL
omarchy-omadrop status                 # JSON: running, url, mdns_url, qr_ok, queues
omarchy-omadrop send ~/Pictures/a.jpg  # queue files for the phone (symlinked)
omarchy-omadrop send-pick              # queue files via a file picker
omarchy-omadrop open                   # open the Received folder
omarchy-omadrop stop                   # stop now (SIGTERM, then SIGKILL)
omarchy-omadrop selftest               # verify parser, token gate and size cap
```

Environment overrides: `OMADROP_PORT` (5380), `OMADROP_IDLE_TIMEOUT` (900 s), `OMADROP_MAX_UPLOAD` (2 GiB per request), `OMADROP_BASE_DIR` (`~/Downloads/OmaDrop`), `OMADROP_MDNS_NAME` (`omadrop`).

---

## 🔐 Security model

The server has to listen on `0.0.0.0:5380` — the phone must reach it — so the protection is not the bind address but three gates:

1. **A token in the path.** Everything lives under `/t/<token>/`; a request without it gets 403 and learns nothing. The token is regenerated on every start and only appears in the panel, the QR code and `status`.
2. **Auto-disarm.** No traffic for `OMADROP_IDLE_TIMEOUT` (15 min by default) and the process exits, deleting its token.
3. **A hard size cap.** `OMADROP_MAX_UPLOAD` is checked before the body is read, so a hostile client cannot fill the disk.

Traffic is plain HTTP (no TLS) — anyone able to sniff your Wi-Fi can see file contents in transit. On your own home network that is the tradeoff; on an open network, transfer only between devices you trust.

Uploads are streamed straight to disk with a bounded buffer (a 150 MB file costs about 0.6 MB of resident memory, measured), filenames are HTML-escaped so a crafted name cannot inject script into the phone's page, and downloads are sent with an RFC 5987 encoded `Content-Disposition` so a filename cannot inject headers.

---

## 🛠️ Troubleshooting & Checklist

* **Same Wi-Fi Network:** Make sure your smartphone and your PC are connected to the same local Wi-Fi router (not mobile data 4G/5G).
* **AP/Client Isolation:** Some guest Wi-Fi networks have "Client Isolation" enabled, which prevents local devices from talking to each other. Use your standard home/office Wi-Fi.
* **Nothing happens when the QR is scanned:** read the log — `~/.local/state/omadrop/server.log`. It records the bind, the QR result and every rejected upload.
* **Missing QR code:** `qrencode` is not installed; `omarchy-omadrop status` reports `"qr_ok": false`.
* **Port already in use:** another instance is running (`omarchy-omadrop stop`, then start again). Starting when one already runs is a no-op, not an error.
* **Storage Location:** Received files are saved in `~/Downloads/OmaDrop/Received/`, files waiting for the phone in `~/Downloads/OmaDrop/Send/`.

---

## 📄 License

MIT License © 2026 [Alex Weström](https://github.com/alexwest1981)

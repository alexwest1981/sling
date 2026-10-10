import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.alexwest1981.sling"

  // Neonpaletten från Sling-mockupen. Accenter — panelens yta följer barens tema,
  // så widgeten inte krockar med en ljus bar.
  readonly property color neonCyan: "#00f0ff"
  readonly property color neonMagenta: "#ff007f"

  // CLI:n hittas på sin plats i pluginmappen — ingen PATH-symlänk behövs, och
  // token hamnar aldrig i argv (den går på stdin till wl-copy/qrencode).
  readonly property string cliPath: String(Qt.resolvedUrl("./bin/omarchy-sling")).replace("file://", "")

  property bool serverRunning: false
  property bool qrOk: false
  property string serverUrl: "http://127.0.0.1:5380"
  property string mdnsUrl: ""
  property string localIp: "127.0.0.1"
  property var recentFiles: []
  property var sendFiles: []
  property var transfer: null
  property bool popupOpen: false
  property string qrPath: ""
  property int refreshTrigger: 0

  // ---------------------------------------------------------------------------
  // i18n System Language Localization Dictionary
  // ---------------------------------------------------------------------------
  readonly property var i18nDict: ({
    en: {
      tooltip: "Sling (File Transfer Phone ↔ PC)\nClick to show QR code",
      title: "Sling File Sharing",
      subtitle: "Scan with your regular phone camera",
      copied: "Link copied to clipboard!",
      recent_title: "📥 Recently received files:",
      send_title: "📤 Files waiting to be sent",
      remove: "Remove",
      clear_all: "Clear all",
      btn_open_send: "Open Send folder",
      more: "more",
      btn_open: "📁 Open folder",
      btn_stop: "🛑 Stop",
      btn_start: "▶ Start",
      btn_send: "📤 Send file…",
      btn_clip: "📋 Send clipboard to phone",
      waiting: "waiting to be fetched",
      hint_start: "Press Start to show the QR code",
      same_wifi: "Same Wi-Fi required",
      idle: "Ready — waiting for a file"
    },
    sv: {
      tooltip: "Sling (Fildelning mobil ↔ dator)\nKlicka för att visa QR-kod",
      title: "Sling Fildelning",
      subtitle: "Scanna med mobilens vanliga kamera",
      copied: "Länk kopierad till urklipp!",
      recent_title: "📥 Senast mottagna filer:",
      send_title: "📤 Filer som väntar att skickas",
      remove: "Ta bort",
      clear_all: "Rensa alla",
      btn_open_send: "Öppna skickamappen",
      more: "fler",
      btn_open: "📁 Öppna mapp",
      btn_stop: "🛑 Stäng av",
      btn_start: "▶ Starta",
      btn_send: "📤 Skicka fil…",
      btn_clip: "📋 Skicka urklipp till telefonen",
      waiting: "väntar att hämtas",
      hint_start: "Tryck Starta för att visa QR-koden",
      same_wifi: "Kräver samma Wi-Fi",
      idle: "Redo — väntar på en fil"
    },
    nl: {
      tooltip: "Sling (Bestandsoverdracht Telefoon ↔ PC)\nKlik voor QR-code",
      title: "Sling Bestandsoverdracht",
      subtitle: "Scan met de camera van je telefoon",
      copied: "Link gekopieerd naar klembord!",
      recent_title: "📥 Recent ontvangen bestanden:",
      send_title: "📤 Te verzenden bestanden",
      remove: "Verwijderen",
      clear_all: "Alles wissen",
      btn_open_send: "Map Verzenden openen",
      more: "meer",
      btn_open: "📁 Map openen",
      btn_stop: "🛑 Stoppen",
      btn_start: "▶ Starten",
      btn_send: "📤 Bestand sturen…",
      btn_clip: "📋 Klembord naar telefoon",
      waiting: "wacht om opgehaald te worden",
      hint_start: "Druk op Starten voor de QR-code",
      same_wifi: "Vereist dezelfde Wi-Fi",
      idle: "Gereed — wacht op een bestand"
    },
    ja: {
      tooltip: "Sling (スマホ ↔ PC ファイル転送)\nクリックしてQRコードを表示",
      title: "Sling ファイル共有",
      subtitle: "スマホの標準カメラでスキャン",
      copied: "リンクをクリップボードにコピーしました！",
      recent_title: "📥 最近受信したファイル:",
      send_title: "📤 送信待ちのファイル",
      remove: "削除",
      clear_all: "すべてクリア",
      btn_open_send: "送信フォルダを開く",
      more: "件以上",
      btn_open: "📁 フォルダを開く",
      btn_stop: "🛑 停止",
      btn_start: "▶ 開始",
      btn_send: "📤 ファイルを送信…",
      btn_clip: "📋 クリップボードをスマホへ",
      waiting: "取得待ち",
      hint_start: "開始を押すとQRコードを表示します",
      same_wifi: "同じWi-Fi接続が必要です",
      idle: "待機中 — ファイルを待っています"
    },
    de: {
      tooltip: "Sling (Dateiübertragung Handy ↔ PC)\nKlicken für QR-Code",
      title: "Sling Dateifreigabe",
      subtitle: "Mit der Handykamera scannen",
      copied: "Link in Zwischenablage kopiert!",
      recent_title: "📥 Zuletzt empfangene Dateien:",
      send_title: "📤 Zu sendende Dateien",
      remove: "Entfernen",
      clear_all: "Alle löschen",
      btn_open_send: "Sendeordner öffnen",
      more: "weitere",
      btn_open: "📁 Ordner öffnen",
      btn_stop: "🛑 Beenden",
      btn_start: "▶ Starten",
      btn_send: "📤 Datei senden…",
      btn_clip: "📋 Zwischenablage ans Handy",
      waiting: "warten auf Abruf",
      hint_start: "Start drücken, um den QR-Code zu zeigen",
      same_wifi: "Gleiches WLAN erforderlich",
      idle: "Bereit — wartet auf eine Datei"
    },
    fr: {
      tooltip: "Sling (Transfert Téléphone ↔ PC)\nCliquer pour le code QR",
      title: "Sling Partage de fichiers",
      subtitle: "Scannez avec l'appareil photo du téléphone",
      copied: "Lien copié dans le presse-papiers !",
      recent_title: "📥 Fichiers récemment reçus :",
      send_title: "📤 Fichiers en attente d'envoi",
      remove: "Supprimer",
      clear_all: "Tout effacer",
      btn_open_send: "Ouvrir le dossier d'envoi",
      more: "de plus",
      btn_open: "📁 Ouvrir le dossier",
      btn_stop: "🛑 Arrêter",
      btn_start: "▶ Démarrer",
      btn_send: "📤 Envoyer un fichier…",
      btn_clip: "📋 Envoyer le presse-papiers au téléphone",
      waiting: "en attente de téléchargement",
      hint_start: "Appuyez sur Démarrer pour afficher le QR",
      same_wifi: "Même Wi-Fi requis",
      idle: "Prêt — en attente d'un fichier"
    },
    es: {
      tooltip: "Sling (Transferencia Móvil ↔ PC)\nHaz clic para código QR",
      title: "Sling Compartir archivos",
      subtitle: "Escanea con la cámara de tu móvil",
      copied: "¡Enlace copiado al portapapeles!",
      recent_title: "📥 Archivos recibidos recientemente:",
      send_title: "📤 Archivos en espera de envío",
      remove: "Eliminar",
      clear_all: "Borrar todo",
      btn_open_send: "Abrir carpeta de envío",
      more: "más",
      btn_open: "📁 Abrir carpeta",
      btn_stop: "🛑 Detener",
      btn_start: "▶ Iniciar",
      btn_send: "📤 Enviar archivo…",
      btn_clip: "📋 Enviar el portapapeles al teléfono",
      waiting: "esperando descarga",
      hint_start: "Pulsa Iniciar para ver el código QR",
      same_wifi: "Misma red Wi-Fi requerida",
      idle: "Listo — esperando un archivo"
    },
    zh: {
      tooltip: "Sling (手机 ↔ 电脑 文件传输)\n点击显示二维码",
      title: "Sling 文件传输",
      subtitle: "使用手机相机扫码",
      copied: "链接已复制到剪贴板！",
      recent_title: "📥 最近接收的文件:",
      send_title: "📤 等待发送的文件",
      remove: "移除",
      clear_all: "清空全部",
      btn_open_send: "打开发送文件夹",
      more: "件",
      btn_open: "📁 打开文件夹",
      btn_stop: "🛑 停止",
      btn_start: "▶ 启动",
      btn_send: "📤 发送文件…",
      btn_clip: "📋 发送剪贴板到手机",
      waiting: "等待获取",
      hint_start: "点击启动显示二维码",
      same_wifi: "需要连接到同一 Wi-Fi",
      idle: "就绪 — 等待文件"
    }
  })

  readonly property var langKey: {
    var loc = Qt.locale().name.toLowerCase()
    var shortCode = loc.split("_")[0].split("-")[0]
    return i18nDict[shortCode] ? shortCode : "en"
  }

  readonly property var str: i18nDict[langKey] || i18nDict.en

  function close() { popupOpen = false }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // ---------------------------------------------------------------------------
  // 1. Status Poller — tät bara medan panelen är öppen. Mätt: en körning kostar
  //    ~47 ms och startar en python-process; 1,5 s dygnet runt blev 0,8 CPU-
  //    timmar per dygn i onödan.
  // ---------------------------------------------------------------------------
  Process {
    id: statusProc
    command: [root.cliPath, "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var data = JSON.parse(text.trim())
          root.serverRunning = (data.running === true)
          root.qrOk = (data.qr_ok === true)
          root.serverUrl = data.url || ""
          root.mdnsUrl = data.mdns_url || ""
          root.localIp = data.ip || ""
          root.recentFiles = data.recent_files || []
          root.sendFiles = data.send_files || []
          root.transfer = data.active || null
          root.qrPath = data.qr_path || ""
          root.refreshTrigger += 1
        } catch (e) {
          console.warn("Sling: status JSON not readable: " + e)
        }
      }
    }
  }

  Timer {
    id: statusTimer
    interval: (root.popupOpen || root.transfer !== null) ? 1500 : 10000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!statusProc.running) statusProc.running = true
    }
  }

  function runSling() {
    var cmd = [root.cliPath].concat(Array.prototype.slice.call(arguments))
    Quickshell.execDetached(cmd)
    statusTimer.restart()
  }

  // Kopieringen görs av CLI:t: URL:en (med token) går på stdin till wl-copy, så den
  // syns varken i argv eller hänger på att en QML-process stänger sin pipe (mätt).
  // Filen som släpps på bar-ikonen går rakt in i skicka-kön — samma väg som
  // "Skicka fil…", men utan fönsterval. drop.urls är file://-URL:er.
  function queueDrop(urls) {
    var paths = []
    for (var i = 0; i < urls.length; i++) {
      var u = String(urls[i])
      if (u.indexOf("file://") === 0)
        paths.push(decodeURIComponent(u.slice(7)))
    }
    if (paths.length === 0) return
    root.runSling.apply(null, ["send"].concat(paths))
    root.popupOpen = true          // kvitto: kön syns direkt i panelen
  }

  function copyUrl(which) {
    root.runSling("copy", which)
    if (root.bar) root.bar.showTooltip(root, root.str.copied)
  }

  // Kön hanteras av CLI:t (länken tas bort, aldrig originalfilen). Listan ritas om
  // direkt så panelen inte står kvar med en rad som redan är borta.
  function removeSendFile(name) {
    root.sendFiles = root.sendFiles.filter(function(item) { return item.name !== name })
    root.runSling("remove", name)
  }

  function clearSendFiles() {
    root.sendFiles = []
    root.runSling("clear")
  }

  // ---------------------------------------------------------------------------
  // 2. Bar Button
  // ---------------------------------------------------------------------------
  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.transfer ? "󰄡 " + root.transfer.pct + "%" : "󰄡 Sling"
    active: root.popupOpen || root.serverRunning
    tooltipText: root.str.tooltip
    onPressed: function(btn) {
      if (!root.serverRunning) {
        runSling("start")
      }
      root.popupOpen = !root.popupOpen
    }

    DropArea {
      anchors.fill: parent
      onDropped: function(drop) {
        root.queueDrop(drop.urls)
        drop.accept()
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Interactive Graphical Popup Card
  // ---------------------------------------------------------------------------
  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    borderColor: root.neonCyan
    borderSpec: Border.controlSpec("normal", root.neonCyan, root.neonCyan)
    contentWidth: popup.fittedContentWidth(Style.space(340))
    contentHeight: popup.fittedContentHeight(popCol.implicitHeight)

    // Mockupens yta: obsidian #0d1117 innanför kortets egen ram (plattan ligger
    // innanför kanten så ramen syns kvar). Temats popupfärg var grå.
    Rectangle {
      anchors.fill: parent
      anchors.margins: -(popup.padding - Math.max(1, Style.space(2)))
      radius: Style.cornerRadius - Math.max(1, Style.space(2))
      color: "#0d1117"
    }

    Column {
      id: popCol
      anchors.fill: parent
      spacing: Style.space(12)

      // Header
      Row {
        spacing: Style.space(10)
        width: parent.width

        BorderSurface {
          width: Style.space(46)
          height: Style.space(46)
          radius: Style.spacing.labelGap
          color: Qt.rgba(0, 0.94, 1, 0.10)
          borderSpec: Border.controlSpec("normal", root.neonCyan, root.neonCyan)

          Text {
            anchors.centerIn: parent
            text: "󰄡"
            color: root.neonMagenta
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
          }
        }

        Column {
          spacing: Style.space(2)
          width: parent.width - Style.space(58)

          Text {
            id: wordmark
            text: "SLING"
            color: "#ffffff"
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.heading
            font.bold: true
            font.letterSpacing: Style.space(3)
            // Neon-glöden från mockupen (magenta halo, ingen förskjutning).
            layer.enabled: true
            layer.effect: MultiEffect {
              shadowEnabled: true
              shadowColor: root.neonMagenta
              shadowBlur: 1.0
              blurMax: 24
              shadowVerticalOffset: 0
              shadowHorizontalOffset: 0
            }
          }

          Text {
            text: root.str.subtitle
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
        }
      }

      // Avdelarlinjen under rubriken (mockupen: tunt cyan streck)
      Rectangle {
        width: parent.width
        height: 1
        color: root.neonCyan
        opacity: 0.35
      }

      // QR Code Container Card — QR bara när den finns, annars en ledtråd
      BorderSurface {
        width: parent.width
        height: Style.space(246)
        radius: Style.spacing.labelGap
        color: Qt.darker(root.bar.background || "#0d1117", 1.3)
        borderSpec: Border.controlSpec("normal", root.neonCyan, root.neonCyan)

        Column {
          anchors.centerIn: parent
          spacing: Style.space(8)

          // QR-koden med retikeln från mockupen: vit yta med neon-cyan hörnparenteser
          Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Style.space(176)
            height: Style.space(176)
            visible: root.serverRunning && root.qrOk

            // Crisp White Canvas for QR Code
            Rectangle {
              anchors.fill: parent
              anchors.margins: Style.space(8)
              radius: Style.space(10)
              color: "#ffffff"

              Image {
                id: qrImg
                anchors.centerIn: parent
                width: Style.space(146)
                height: Style.space(146)
                fillMode: Image.PreserveAspectFit
                cache: false
                source: (root.serverRunning && root.qrOk && root.qrPath !== "")
                        ? "file://" + root.qrPath + "?v=" + root.refreshTrigger : ""
                smooth: false
              }
            }

            // Fyra hörn, två streck var: [x-höger, y-neder, x-riktning, y-riktning]
            Repeater {
              model: [[0, 0, 1, 1], [1, 0, -1, 1], [0, 1, 1, -1], [1, 1, -1, -1]]

              Item {
                width: Style.space(18)
                height: Style.space(18)
                x: modelData[0] ? parent.width - width : 0
                y: modelData[1] ? parent.height - height : 0

                Rectangle {
                  width: parent.width
                  height: Style.space(2)
                  radius: Style.space(1)
                  color: root.neonCyan
                  x: 0
                  y: modelData[3] > 0 ? 0 : parent.height - height
                }

                Rectangle {
                  width: Style.space(2)
                  height: parent.height
                  radius: Style.space(1)
                  color: root.neonCyan
                  y: 0
                  x: modelData[2] > 0 ? 0 : parent.width - width
                }
              }
            }
          }

          Text {
            visible: !(root.serverRunning && root.qrOk)
            text: root.str.hint_start
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
          }

          // URL Text Pill (Click to copy)
          Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.serverRunning
            width: Math.min(urlRow.implicitWidth + Style.space(16), parent.width)
            height: Style.space(24)
            radius: Style.space(12)
            color: copyMouse.containsMouse ? Style.normalFillFor(root.bar.foreground, Color.accent) : Qt.rgba(1, 1, 1, 0.06)

            Row {
              id: urlRow
              anchors.centerIn: parent
              spacing: Style.space(5)

              Text {
                text: "🔗 " + root.serverUrl
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                elide: Text.ElideMiddle
                // Token-URL:en är lång — håll pillret innanför panelens bredd
                width: Math.min(implicitWidth, parent.parent.width - Style.space(16))
              }
            }

            MouseArea {
              id: copyMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.copyUrl("")
              }
            }
          }

          // Adressen att minnas — samma sida, namn i stället för IP
          Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.serverRunning && root.mdnsUrl !== ""
            width: Math.min(mdnsRow.implicitWidth + Style.space(16), parent.width)
            height: Style.space(22)
            radius: Style.space(11)
            color: mdnsMouse.containsMouse ? Style.normalFillFor(root.bar.foreground, Color.accent) : Qt.rgba(1, 1, 1, 0.04)

            Row {
              id: mdnsRow
              anchors.centerIn: parent
              spacing: Style.space(5)

              Text {
                text: "🏠 " + root.mdnsUrl
                color: Qt.darker(root.bar.foreground, 1.2)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                elide: Text.ElideMiddle
                width: Math.min(implicitWidth, parent.parent.width - Style.space(16))
              }
            }

            MouseArea {
              id: mdnsMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.copyUrl("mdns")
              }
            }
          }
        }
      }

      // Transfer-dock (mockupen): alltid synlig. Visar riktning, fil, procent och
      // fart medan en fil rullar; annars en dämpad rad och tom stapel.
      BorderSurface {
        width: parent.width
        height: Style.space(74)
        radius: Style.space(6)
        color: Qt.rgba(0, 0.94, 1, root.transfer ? 0.07 : 0.03)
        borderSpec: Border.controlSpec("normal", root.neonCyan, root.neonCyan)

        Column {
          anchors.fill: parent
          anchors.margins: Style.space(9)
          spacing: Style.space(6)

          Item {
            width: parent.width
            height: Style.space(20)

            Text {
              text: root.transfer
                    ? (root.transfer.dir === "up" ? "📥 " : "📤 ") + root.transfer.name
                    : root.str.idle
              // Filnamn är data, inte uppmärkning: AutoText skulle tolka "<img …>" i
              // ett uppladdat namn som rik text och låta skalet hämta bilden (HANCORE).
              textFormat: Text.PlainText
              color: root.transfer ? root.bar.foreground : Qt.darker(root.bar.foreground, 1.5)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              elide: Text.ElideMiddle
              width: parent.width - pctText.width - Style.space(6)
            }

            Text {
              id: pctText
              anchors.right: parent.right
              text: root.transfer ? root.transfer.pct + " %" : "—"
              color: root.transfer ? root.neonCyan : Qt.darker(root.bar.foreground, 1.6)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
            }
          }

          Rectangle {
            width: parent.width
            height: Style.space(8)
            radius: Style.space(4)
            color: Qt.rgba(1, 1, 1, 0.08)

            Rectangle {
              height: parent.height
              radius: parent.radius
              color: root.neonCyan
              width: parent.width * (root.transfer ? Math.max(0.02, Math.min(1, root.transfer.pct / 100)) : 0)

              Behavior on width {
                NumberAnimation { duration: 180 }
              }
            }
          }

          Text {
            width: parent.width
            text: root.transfer
                  ? root.transfer.human_done + " / " + root.transfer.human_total + "  ·  "
                    + (root.transfer.speed / 1048576).toFixed(1) + " MB/s"
                  : ""
            color: Qt.darker(root.bar.foreground, 1.4)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
          }
        }
      }

      // Skicka-kön: filer i Send/ som väntar på telefonen. De fem senaste ritas,
      // + N fler öppnar mappen. ✕/🗑 tar bort länken — originalet rörs aldrig.
      Column {
        width: parent.width
        spacing: Style.space(6)
        visible: root.sendFiles.length > 0

        Item {
          width: parent.width
          height: Math.max(sendTitleText.implicitHeight, Style.space(22))

          Text {
            id: sendTitleText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.str.send_title + " (" + root.sendFiles.length + "):"
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(4)

            PanelActionButton {
              iconText: "📁"
              tooltipText: root.str.btn_open_send
              foreground: Qt.darker(root.bar.foreground, 1.3)
              hoverColor: root.neonCyan
              size: Style.space(20)
              fontSize: Style.font.caption
              onClicked: root.runSling("open", "send")
            }

            PanelActionButton {
              iconText: "🗑"
              tooltipText: root.str.clear_all
              foreground: Qt.darker(root.bar.foreground, 1.3)
              hoverColor: "#f7768e"
              size: Style.space(20)
              fontSize: Style.font.caption
              onClicked: root.clearSendFiles()
            }
          }
        }

        Repeater {
          model: root.sendFiles.slice(0, 5)

          BorderSurface {
            width: parent.width
            height: Style.space(34)
            radius: Style.space(6)
            color: Qt.rgba(1, 1, 1, 0.04)
            borderSpec: Border.controlSpec("normal", root.bar.foreground, Color.accent)

            Row {
              anchors.fill: parent
              anchors.leftMargin: Style.space(10)
              anchors.rightMargin: Style.space(6)
              spacing: Style.space(6)

              Text {
                text: "📤"
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Style.font.bodySmall
              }

              Text {
                text: modelData.name
                textFormat: Text.PlainText          // namn är data, aldrig uppmärkning
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.bold: true
                elide: Text.ElideMiddle
                width: parent.width - Style.space(120)
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: modelData.size
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                anchors.verticalCenter: parent.verticalCenter
              }

              PanelActionButton {
                iconText: "✕"
                tooltipText: root.str.remove
                foreground: Qt.darker(root.bar.foreground, 1.4)
                hoverColor: "#f7768e"
                size: Style.space(20)
                fontSize: Style.font.caption
                anchors.verticalCenter: parent.verticalCenter
                onClicked: root.removeSendFile(modelData.name)
              }
            }
          }
        }

        Item {
          width: parent.width
          height: Style.space(20)
          visible: root.sendFiles.length > 5

          Text {
            anchors.centerIn: parent
            text: "+ " + (root.sendFiles.length - 5) + " " + root.str.more + "…"
            color: root.neonCyan
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.runSling("open", "send")
          }
        }
      }

      // Recent Files Section
      Column {
        width: parent.width
        spacing: Style.space(6)
        visible: root.recentFiles.length > 0

        Text {
          text: root.str.recent_title
          color: Qt.darker(root.bar.foreground, 1.3)
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
        }

        Repeater {
          model: root.recentFiles

          BorderSurface {
            width: parent.width
            height: Style.space(34)
            radius: Style.space(6)
            color: Qt.rgba(1, 1, 1, 0.04)
            borderSpec: Border.controlSpec("normal", root.bar.foreground, Color.accent)

            Row {
              anchors.fill: parent
              anchors.leftMargin: Style.space(10)
              anchors.rightMargin: Style.space(10)
              spacing: Style.space(8)

              Text {
                text: "📄"
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Style.font.bodySmall
              }

              Text {
                text: modelData.name
                textFormat: Text.PlainText          // namn från telefonen, aldrig uppmärkning
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.bold: true
                elide: Text.ElideMiddle
                width: parent.width - Style.space(90)
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: modelData.size
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                anchors.verticalCenter: parent.verticalCenter
              }
            }
          }
        }
      }

      // Action Buttons: mapp + skicka, sedan start/stopp över hela bredden
      Row {
        width: parent.width
        spacing: Style.space(8)

        Button {
          width: (parent.width - Style.space(8)) / 2
          text: root.str.btn_open
          foreground: root.bar.foreground
          horizontalPadding: Style.spacing.controlPaddingX
          verticalPadding: Style.spacing.controlPaddingY
          onClicked: root.runSling("open")
        }

        Button {
          width: (parent.width - Style.space(8)) / 2
          text: root.str.btn_send
          foreground: root.bar.foreground
          horizontalPadding: Style.spacing.controlPaddingX
          verticalPadding: Style.spacing.controlPaddingY
          onClicked: root.runSling("send-pick")
        }
      }

      Button {
        width: parent.width
        text: root.str.btn_clip
        foreground: root.bar.foreground
        horizontalPadding: Style.spacing.controlPaddingX
        verticalPadding: Style.spacing.controlPaddingY
        onClicked: root.runSling("clip")
      }

      Button {
        width: parent.width
        text: root.serverRunning ? root.str.btn_stop : root.str.btn_start
        foreground: root.serverRunning ? "#f7768e" : root.neonCyan
        horizontalPadding: Style.spacing.controlPaddingX
        verticalPadding: Style.spacing.controlPaddingY
        onClicked: {
          if (root.serverRunning) {
            root.runSling("stop")
          } else {
            root.runSling("start")
          }
        }
      }
    }
  }
}

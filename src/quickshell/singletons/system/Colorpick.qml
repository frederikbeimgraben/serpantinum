pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

// The color picker of the colorpick module of the bar. With colorpick.lens
// (default true), pick() takes a screenshot of each screen with grim and
// shows it in popouts/ColorpickOverlay.qml, with a magnifier of
// colorpick.zoom (default 8) around the pointer. A click picks the pixel
// from the screenshot, and Esc cancels. Without the lens, the color picker of
// niri (`niri msg --json pick-color`) picks the color.
// The color goes to the clipboard in the format of colorpick.format: "hex"
// (default), "rgb" or "hsl". When colorpick.notify is not false, a
// notification shows the value and a swatch of the color. The pill keeps the
// color for colorpick.resetAfter seconds (default 5, 0 keeps it). A key
// binding reaches pick() through the command socket with the line
// "pick colorpick", and "cancel colorpick" closes the picker.
Item {
    id: root

    readonly property var settings: Config.getSetting("colorpick", {}) || {}
    readonly property string format: ["hex", "rgb", "hsl"].indexOf(settings.format) !== -1 ? settings.format : "hex"
    readonly property bool notify: settings.notify !== false
    readonly property bool lens: settings.lens !== false
    readonly property int zoom: Math.max(2, Math.min(24, Number(settings.zoom) || 8))
    readonly property int resetAfter: settings.resetAfter === undefined ? 5 : Math.max(0, Number(settings.resetAfter) || 0)

    // The screenshots of the lens picker: screen name to file path.
    property bool picking: false
    property var shots: ({})
    property int shotRevision: 0

    property color lastColor: "transparent"
    property bool hasColor: false

    function hex2(v) {
        let h = Math.round(Math.max(0, Math.min(1, v)) * 255).toString(16);
        return h.length < 2 ? "0" + h : h;
    }

    function formatColor(r, g, b) {
        if (root.format === "rgb") return "rgb(" + Math.round(r * 255) + ", " + Math.round(g * 255) + ", " + Math.round(b * 255) + ")";
        if (root.format === "hsl") {
            let c = Qt.rgba(r, g, b, 1);
            let h = Math.max(0, c.hslHue);
            return "hsl(" + Math.round(h * 360) + ", " + Math.round(c.hslSaturation * 100) + "%, " + Math.round(c.hslLightness * 100) + "%)";
        }
        return "#" + hex2(r) + hex2(g) + hex2(b);
    }

    function pick() {
        if (root.picking || pickProc.running || shotProc.running) return;
        if (!root.lens) {
            pickProc.running = true;
            return;
        }
        let dir = Caching.getRunDir("colorpick");
        let map = {};
        let script = "set -e\n";
        let args = [];
        for (let i = 0; i < Quickshell.screens.length; i++) {
            let n = Quickshell.screens[i].name;
            map[n] = dir + "/shot-" + n + ".png";
            args.push(n, map[n]);
        }
        script += 'while [ $# -gt 0 ]; do grim -o "$1" "$2"; shift 2; done';
        root.shots = map;
        shotProc.command = ["bash", "-c", script, "_"].concat(args);
        shotProc.running = true;
    }

    function cancel() {
        root.picking = false;
    }

    // Reads the pixel x, y of the screenshot of a screen and delivers it.
    function finish(screenName, x, y) {
        root.picking = false;
        let path = root.shots[screenName];
        if (!path) return;
        pixelProc.command = ["magick", path, "-alpha", "off", "-format", "%[hex:p{" + Math.round(x) + "," + Math.round(y) + "}]", "info:"];
        pixelProc.running = true;
    }

    function deliver(r, g, b) {
        let value = root.formatColor(r, g, b);
        let hex = "#" + root.hex2(r) + root.hex2(g) + root.hex2(b);
        root.lastColor = Qt.rgba(r, g, b, 1);
        root.hasColor = true;
        if (root.resetAfter > 0) resetTimer.restart();
        Quickshell.execDetached(["wl-copy", value]);
        if (root.notify) {
            let swatch = Caching.getRunDir("colorpick") + "/swatch.png";
            Quickshell.execDetached(["bash", "-c",
                "magick -size 96x96 xc:\"$1\" \"$2\" && notify-send -a Serpantinum -i \"$2\" \"$3\" \"$4\"",
                "_", hex, swatch, value, I18n.t("colorpick.copied", "Copied to the clipboard")]);
        }
    }

    Timer {
        id: resetTimer
        interval: root.resetAfter * 1000
        onTriggered: root.hasColor = false
    }

    Process {
        id: shotProc
        onExited: exitCode => {
            if (exitCode !== 0) return;
            root.shotRevision++;
            root.picking = true;
        }
    }

    Process {
        id: pixelProc
        stdout: StdioCollector {
            onStreamFinished: {
                let h = this.text.trim().replace(/^#/, "");
                if (!/^[0-9a-fA-F]{6}/.test(h)) return;
                root.deliver(parseInt(h.substr(0, 2), 16) / 255, parseInt(h.substr(2, 2), 16) / 255, parseInt(h.substr(4, 2), 16) / 255);
            }
        }
    }

    Process {
        id: pickProc
        command: ["niri", "msg", "--json", "pick-color"]
        stdout: StdioCollector {
            onStreamFinished: {
                let rgb = null;
                try {
                    let r = JSON.parse(this.text);
                    rgb = Array.isArray(r) ? r : (r && Array.isArray(r.rgb) ? r.rgb : null);
                } catch (e) {}
                if (!rgb || rgb.length < 3) return;
                root.deliver(rgb[0], rgb[1], rgb[2]);
            }
        }
    }

    Connections {
        target: ShellBus
        function onCommand(action, target, arg) {
            if (target !== "colorpick") return;
            if (action === "pick") root.pick();
            else if (action === "cancel") root.cancel();
        }
    }
}

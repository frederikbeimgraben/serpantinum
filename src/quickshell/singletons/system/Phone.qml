pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

// Phones and other devices of Valent, the KDE Connect app, as GSConnect shows
// them in GNOME. scripts/valent.sh reads the devices over D-Bus. A busctl
// monitor watches the signals of Valent, and each signal reads the devices
// again after a short delay. A slow timer also reads them, in case Valent
// starts after the shell.
//
// Device actions (ring, ping, clipboard, files) go to org.gtk.Actions on the
// device path. App actions (share dialog, messages, main window) go to the
// path of the app.
Item {
    id: root

    readonly property string dest: "ca.andyholmes.Valent"
    readonly property string appPath: "/ca/andyholmes/Valent"

    property var devices: []
    readonly property var paired: devices.filter(d => (d.state & 2) !== 0)
    readonly property bool available: paired.length > 0
    // The device that the bar shows: the first connected paired device, else
    // the first paired device.
    readonly property var primary: {
        let c = paired.filter(d => (d.state & 1) !== 0);
        if (c.length > 0) return c[0];
        return paired.length > 0 ? paired[0] : null;
    }

    function isConnected(dev) {
        return dev ? (dev.state & 1) !== 0 : false;
    }

    function hasAction(dev, name) {
        return dev && dev.actions ? dev.actions.indexOf(name) !== -1 : false;
    }

    function deviceAction(dev, name) {
        if (!dev || !hasAction(dev, name)) return;
        Quickshell.execDetached(["busctl", "--user", "call", root.dest, dev.path,
            "org.gtk.Actions", "Activate", "sava{sv}", name, "0", "0"]);
    }

    function appAction(name) {
        Quickshell.execDetached(["busctl", "--user", "call", root.dest, root.appPath,
            "org.gtk.Actions", "Activate", "sava{sv}", name, "0", "0"]);
    }

    // The window action of Valent takes "main" or the id of a device, which
    // opens the page of that device.
    function openWindow(dev) {
        Quickshell.execDetached(["busctl", "--user", "call", root.dest, root.appPath,
            "org.gtk.Actions", "Activate", "sava{sv}", "window", "1", "s", dev ? dev.id : "main", "0"]);
    }

    property bool refreshPending: false

    function refresh() {
        if (readProc.running) {
            root.refreshPending = true;
            return;
        }
        readProc.running = true;
    }

    Process {
        id: readProc
        command: ["bash", Caching.serpantinumDir + "/scripts/valent.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(this.text);
                    root.devices = Array.isArray(list) ? list : [];
                } catch (e) {
                    root.devices = [];
                }
            }
        }
        onExited: {
            if (root.refreshPending) {
                root.refreshPending = false;
                root.refresh();
            }
        }
    }

    Timer {
        id: debounce
        interval: 300
        onTriggered: root.refresh()
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: monitorProc
        running: true
        command: ["busctl", "--user", "monitor", "--json=short",
            "--match", "type='signal',sender='" + root.dest + "',path_namespace='" + root.appPath + "'"]
        stdout: SplitParser {
            onRead: line => {
                if (line.indexOf('"type":"signal"') !== -1) debounce.restart();
            }
        }
        onExited: restartMonitor.start()
    }

    Timer {
        id: restartMonitor
        interval: 5000
        onTriggered: monitorProc.running = true
    }

    Component.onCompleted: refresh()
}

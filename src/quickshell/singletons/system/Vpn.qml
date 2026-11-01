pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

// WireGuard connections of NetworkManager for the vpn module of the bar.
// nmcli lists the connections, and `nmcli monitor` reports each change, so
// nothing polls. The settings give the connection that the bar shows in
// vpn.connection (empty: the first WireGuard connection) and an optional host
// in vpn.checkHost. While the connection is up, the host is pinged every
// vpn.interval seconds (default 60), so the module shows whether the tunnel
// carries traffic, not only whether it is up.
Item {
    id: root

    readonly property var settings: Config.getSetting("vpn", {}) || {}
    readonly property string connectionSetting: typeof settings.connection === "string" ? settings.connection : ""
    readonly property string checkHost: typeof settings.checkHost === "string" ? settings.checkHost.trim() : ""
    readonly property int intervalSec: Math.max(15, Number(settings.interval) || 60)

    // Each entry: { name, uuid, active }.
    property var connections: []
    readonly property var names: connections.map(c => c.name)
    readonly property bool available: connections.length > 0
    readonly property var current: {
        if (connections.length === 0) return null;
        let byName = connections.filter(c => c.name === root.connectionSetting);
        return byName.length > 0 ? byName[0] : connections[0];
    }
    readonly property bool connected: current !== null && current.active
    // True, false, or null while no check ran.
    property var reachable: null
    property bool busy: false

    function refresh() {
        if (!listProc.running) listProc.running = true;
    }

    function toggle(conn) {
        let c = conn || root.current;
        if (!c || root.busy) return;
        root.busy = true;
        toggleProc.command = ["nmcli", "connection", c.active ? "down" : "up", "uuid", c.uuid];
        toggleProc.running = true;
    }

    function check() {
        if (root.checkHost === "" || !root.connected || pingProc.running) {
            if (!root.connected || root.checkHost === "") root.reachable = null;
            return;
        }
        pingProc.command = ["ping", "-c", "1", "-W", "3", root.checkHost];
        pingProc.running = true;
    }

    onConnectedChanged: {
        root.reachable = null;
        if (root.connected) checkDelay.restart();
    }
    onCheckHostChanged: check()

    Process {
        id: listProc
        command: ["nmcli", "-t", "--escape", "no", "-f", "NAME,UUID,TYPE,DEVICE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = [];
                let lines = this.text.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    let f = lines[i].split(":");
                    if (f.length < 4 || f[f.length - 2] !== "wireguard") continue;
                    let dev = f[f.length - 1];
                    out.push({ name: f.slice(0, f.length - 3).join(":"), uuid: f[f.length - 3], active: dev !== "" && dev !== "--" });
                }
                root.connections = out;
            }
        }
    }

    Process {
        id: toggleProc
        onExited: {
            root.busy = false;
            root.refresh();
        }
    }

    Process {
        id: pingProc
        onExited: exitCode => root.reachable = (exitCode === 0)
    }

    Process {
        id: monitorProc
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: line => debounce.restart()
        }
        onExited: restartMonitor.start()
    }

    Timer {
        id: restartMonitor
        interval: 5000
        onTriggered: monitorProc.running = true
    }

    Timer {
        id: debounce
        interval: 400
        onTriggered: root.refresh()
    }

    Timer {
        id: checkDelay
        interval: 2000
        onTriggered: root.check()
    }

    Timer {
        interval: root.intervalSec * 1000
        running: root.connected && root.checkHost !== ""
        repeat: true
        onTriggered: root.check()
    }

    Component.onCompleted: refresh()
}

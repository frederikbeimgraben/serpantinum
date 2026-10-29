pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

// Fast command path into the shell. A click on the bar ran bash with
// qs_manager.sh, which started a quickshell ipc process; that took 150 to
// 600 ms before a panel began to open. Bar buttons now call send(), which
// reaches Main.qml in the same process. Shortcuts write one line to the
// socket $XDG_RUNTIME_DIR/serpantinum/cmd.sock, for example with
// `socat - UNIX-CONNECT:...`, which also skips the quickshell process.
//
// A line is "<action> <target> [arg]", the same as `serpantinum msg`.
Item {
    id: root

    signal command(string action, string target, string arg)

    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/serpantinum/cmd.sock"

    function send(action, target, arg) {
        action = action || "";
        target = target || "";
        arg = arg || "";
        // The focus face asks for "applauncher", which no handler knows; the
        // launcher target is "launcher".
        if (target === "applauncher") target = "launcher";
        // The network panel reads its mode (wifi, bt, eth) from a file when
        // it becomes visible, as qs_manager.sh writes it.
        if (target === "network" && arg !== "") networkMode.setText(arg);
        root.command(action, target, arg);
    }

    function dispatchLine(line) {
        let parts = String(line).trim().split(/\s+/);
        if (parts.length === 0 || parts[0] === "") return;
        root.send(parts[0], parts[1] || "", parts.slice(2).join(" "));
    }

    FileView {
        id: networkMode
        path: Caching.getCacheDir("network") + "/mode"
        blockWrites: true
        atomicWrites: false
    }

    Process {
        id: socketDir
        running: true
        command: ["mkdir", "-p", root.socketPath.substring(0, root.socketPath.lastIndexOf("/"))]
        onExited: server.active = true
    }

    SocketServer {
        id: server
        active: false
        path: root.socketPath
        handler: Socket {
            parser: SplitParser {
                onRead: (line) => root.dispatchLine(line)
            }
        }
    }
}

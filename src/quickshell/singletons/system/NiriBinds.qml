pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

// Key bindings of shell modules for niri. The shell writes them to
// $XDG_CONFIG_HOME/niri/serpantinum-binds.kdl, and the niri configuration
// includes that file, so a shortcut set in the settings works at once: niri
// reads an included file again when it changes. Each binding runs
// `serpantinum cmd <command>`, which writes the command to the command socket
// of the shell. The file is written only on niri and only when its content
// changes. A shortcut is a niri key name such as "Mod+Shift+C". An empty or
// invalid shortcut gives no binding.
Item {
    id: root

    readonly property bool isNiri: Boolean(Quickshell.env("NIRI_SOCKET"))
    readonly property string path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/niri/serpantinum-binds.kdl"

    // The bindings of the modules: shortcut, command and the title in the
    // hotkey overlay of niri.
    readonly property var binds: {
        let cp = Config.getSetting("colorpick", {}) || {};
        return [
            { key: typeof cp.shortcut === "string" ? cp.shortcut.trim() : "", command: "pick colorpick", title: "Pick a color" }
        ];
    }

    function valid(key) {
        return /^([A-Za-z]+\+)*[A-Za-z0-9_]+$/.test(key);
    }

    readonly property string content: {
        let lines = [
            "// Written by the Serpantinum shell from its settings. The shell writes",
            "// this file again when a shortcut changes, so edits here do not last.",
            "binds {"
        ];
        for (let i = 0; i < binds.length; i++) {
            let b = binds[i];
            if (!valid(b.key)) continue;
            let args = ["serpantinum", "cmd"].concat(b.command.split(" ")).map(a => "\"" + a + "\"").join(" ");
            lines.push("    " + b.key + " hotkey-overlay-title=\"" + b.title + "\" { spawn " + args + "; }");
        }
        lines.push("}");
        return lines.join("\n") + "\n";
    }

    property string written: ""

    function write() {
        if (!root.isNiri || root.content === root.written) return;
        root.written = root.content;
        bindsFile.setText(root.content);
    }

    onContentChanged: Qt.callLater(write)

    FileView {
        id: bindsFile
        path: root.path
        blockWrites: true
        atomicWrites: true
        onLoaded: root.written = text()
        onLoadFailed: Qt.callLater(root.write)
    }

    Component.onCompleted: Qt.callLater(write)
}

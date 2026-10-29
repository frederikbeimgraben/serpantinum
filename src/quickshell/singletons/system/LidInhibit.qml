pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

// Blocks suspend while active, also on a lid close. A transient systemd user
// unit holds a block inhibitor on handle-lid-switch, sleep and idle, so a lid
// close does nothing, the idle timer cannot suspend, and logind refuses a
// suspend request. The state does not persist: a logout or a reboot ends the
// unit. The state is read at start and after each toggle; nothing polls.
Item {
    id: root

    readonly property string unitName: "serpantinum-lid-block"
    property bool active: false
    property bool busy: false
    property bool showOsdOnRefresh: false

    function refresh() {
        statusProc.running = true;
    }

    function toggle() {
        if (root.busy) return;
        root.busy = true;
        root.showOsdOnRefresh = true;
        toggleProc.command = root.active
            ? ["systemctl", "--user", "stop", root.unitName]
            : ["systemd-run", "--user", "--quiet", "--collect", "--unit=" + root.unitName,
               "systemd-inhibit", "--what=handle-lid-switch:sleep:idle",
               "--who=Serpantinum", "--why=Suspend blocked from the bar", "--mode=block",
               "sleep", "infinity"];
        toggleProc.running = true;
    }

    Process {
        id: toggleProc
        onExited: {
            root.busy = false;
            root.refresh();
        }
    }

    Process {
        id: statusProc
        command: ["systemctl", "--user", "is-active", "--quiet", root.unitName]
        onExited: (exitCode) => {
            root.active = exitCode === 0;
            if (root.showOsdOnRefresh) {
                root.showOsdOnRefresh = false;
                OsdController.show("lid", root.active ? "on" : "off");
            }
        }
    }

    IpcHandler {
        target: "lid"
        function toggle(): void { root.toggle(); }
        function status(): string { return root.active ? "on" : "off"; }
    }

    Component.onCompleted: refresh()
}

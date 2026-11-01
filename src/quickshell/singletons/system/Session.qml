pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

// Session restore on niri. The shell saves which apps are open on which
// workspace and screen, after each change of the windows and every minute,
// to session.json in the state directory. A list without windows does not
// replace a saved one, so the last session of a shutdown stays.
// After a login, when session.enabled is true, the shell restores the saved
// session: with session.mode "ask" (default) a notification offers it, with
// "auto" it starts at once. Each app of the session starts once per window,
// and each new window of such an app moves to its saved screen and workspace.
// session.ignore lists app ids that are neither saved nor restored.
Item {
    id: root

    readonly property var settings: Config.getSetting("session", {}) || {}
    readonly property bool enabled: settings.enabled === true
    readonly property string mode: settings.mode === "auto" ? "auto" : "ask"
    readonly property var ignore: Array.isArray(settings.ignore) ? settings.ignore.map(n => String(n).toLowerCase()) : []
    readonly property bool isNiri: typeof NiriState !== "undefined" && Boolean(Quickshell.env("NIRI_SOCKET"))

    // The saving waits until the decision about the restore is made, so the
    // empty session of a fresh login does not replace the saved one.
    property bool ready: false
    property var saved: []
    property var pending: []
    property var knownIds: ({})

    function snapshot() {
        let wins = NiriState.windowsMap || {};
        let wss = NiriState.workspacesMap || {};
        let out = [];
        for (let id in wins) {
            let w = wins[id];
            if (!w || !w.app_id) continue;
            if (root.ignore.indexOf(String(w.app_id).toLowerCase()) !== -1) continue;
            let ws = wss[w.workspace_id];
            out.push({ appId: w.app_id, workspace: ws ? ws.idx : 1, output: ws ? (ws.output || "") : "" });
        }
        return out;
    }

    function save() {
        if (!root.ready || !root.enabled || !root.isNiri) return;
        let list = snapshot();
        if (list.length === 0) return;
        sessionFile.setText(JSON.stringify(list));
    }

    function restore() {
        let list = root.saved.filter(e => root.ignore.indexOf(String(e.appId).toLowerCase()) === -1);
        root.pending = list.slice();
        root.knownIds = Object.assign({}, NiriState.windowsMap || {});
        let started = {};
        for (let i = 0; i < list.length; i++) {
            let appId = list[i].appId;
            let open = Object.values(root.knownIds).filter(w => w && w.app_id === appId).length;
            let want = list.filter(e => e.appId === appId).length;
            if ((started[appId] || 0) + open >= want) continue;
            started[appId] = (started[appId] || 0) + 1;
            let did = typeof AppMatcher !== "undefined" ? AppMatcher.resolve(appId) : appId;
            let id = String(did || appId).replace(/\.desktop$/, "");
            let entry = DesktopEntries.byId(id) || DesktopEntries.heuristicLookup(appId);
            if (entry) AppLauncher.launch(entry);
        }
        pendingTimeout.restart();
        root.ready = true;
    }

    function placeNewWindows() {
        if (root.pending.length === 0) return;
        let wins = NiriState.windowsMap || {};
        for (let id in wins) {
            if (root.knownIds[id]) continue;
            let w = wins[id];
            root.knownIds[id] = w;
            let k = root.pending.findIndex(e => e.appId === w.app_id);
            if (k === -1) continue;
            let e = root.pending[k];
            root.pending.splice(k, 1);
            if (e.output) Quickshell.execDetached(["niri", "msg", "action", "move-window-to-monitor", "--id", String(w.id), e.output]);
            Quickshell.execDetached(["niri", "msg", "action", "move-window-to-workspace", "--window-id", String(w.id), "--focus", "false", String(e.workspace)]);
        }
    }

    FileView {
        id: sessionFile
        path: Caching.getStateDir("session") + "/session.json"
        blockWrites: true
        atomicWrites: true
    }

    Process {
        id: askProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() === "restore") root.restore();
                else root.ready = true;
            }
        }
    }

    Timer {
        id: startDelay
        interval: 8000
        running: root.isNiri
        onTriggered: {
            let list = [];
            try { list = JSON.parse(sessionFile.text() || "[]"); } catch (e) {}
            root.saved = Array.isArray(list) ? list : [];
            if (!root.enabled || root.saved.length === 0) {
                root.ready = true;
                return;
            }
            if (root.mode === "auto") {
                root.restore();
                return;
            }
            let apps = root.saved.map(e => e.appId).filter((a, i, all) => all.indexOf(a) === i);
            askProc.command = ["notify-send", "-a", "Serpantinum", "-i", "view-restore", "-w",
                "-A", "restore=" + I18n.t("session.restore", "Restore"),
                I18n.t("session.title", "Restore the last session?"),
                I18n.t("session.body", "{count} windows: {apps}").replace("{count}", root.saved.length).replace("{apps}", apps.join(", "))];
            askProc.running = true;
        }
    }

    Timer {
        id: pendingTimeout
        interval: 60000
        onTriggered: root.pending = []
    }

    Timer {
        id: saveDelay
        interval: 5000
        onTriggered: root.save()
    }

    Timer {
        interval: 60000
        running: root.ready && root.enabled
        repeat: true
        onTriggered: root.save()
    }

    Connections {
        target: (typeof NiriState !== "undefined") ? NiriState : null
        function onWindowsUpdated() {
            root.placeNewWindows();
            if (root.ready) saveDelay.restart();
        }
    }

    Component.onCompleted: {
        if (root.isNiri) NiriState.subscribe();
    }
}

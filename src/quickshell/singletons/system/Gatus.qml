pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

// The state of Gatus status pages for the gatus module of the bar. The
// settings give the base URLs in gatus.urls and the poll interval in seconds
// in gatus.interval (default 60, at least 15). scripts/gatus.sh reads the
// latest result of each endpoint from the API of each instance. Without URLs
// nothing polls, and the module has no size.
Item {
    id: root

    readonly property var settings: Config.getSetting("gatus", {}) || {}
    readonly property var urls: Array.isArray(settings.urls) ? settings.urls.filter(u => typeof u === "string" && u !== "") : []
    readonly property bool configured: urls.length > 0
    readonly property int intervalSec: Math.max(15, Number(settings.interval) || 60)

    property var instances: []
    property bool loaded: false
    readonly property int failingCount: instances.reduce((n, i) => n + (i.failing ? i.failing.length : 0), 0)
    readonly property int unreachableCount: instances.filter(i => !i.reachable).length

    function refresh() {
        if (root.urls.length === 0 || fetchProc.running) return;
        fetchProc.command = ["bash", Caching.serpantinumDir + "/scripts/gatus.sh"].concat(root.urls);
        fetchProc.running = true;
    }

    function open(url) {
        if (url) Quickshell.execDetached(["xdg-open", url]);
    }

    // getSetting returns a new copy after each change of any setting, so the
    // list is compared by its content.
    property string _urlsKey: ""

    onUrlsChanged: {
        let key = JSON.stringify(root.urls);
        if (key === root._urlsKey) return;
        root._urlsKey = key;
        root.instances = [];
        root.loaded = false;
        // onUrlsChanged runs before the bindings that read urls, such as
        // configured, so the refresh waits for the end of the event.
        Qt.callLater(refresh);
    }

    Process {
        id: fetchProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(this.text);
                    root.instances = Array.isArray(list) ? list : [];
                    root.loaded = true;
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: root.intervalSec * 1000
        running: root.configured
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}

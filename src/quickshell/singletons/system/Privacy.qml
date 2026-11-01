pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

// Apps that use the microphone or the camera, for the privacy module of the
// bar. `pw-dump --monitor` reports each change of PipeWire, and each change
// runs scripts/privacy.sh after a short delay, so nothing polls while no app
// records. While a stream is active, the script also looks every 5 s for
// processes that open the camera without PipeWire, such as Chromium.
// The settings are privacy.showMic and privacy.showCam (default true) and
// privacy.ignore, a list of app names that never count.
Item {
    id: root

    readonly property var settings: Config.getSetting("privacy", {}) || {}
    readonly property bool showMic: settings.showMic !== false
    readonly property bool showCam: settings.showCam !== false
    readonly property var ignore: Array.isArray(settings.ignore) ? settings.ignore.map(n => String(n).toLowerCase()) : []

    property var rawMic: []
    property var rawCam: []
    readonly property var mic: showMic ? rawMic.filter(n => root.ignore.indexOf(String(n).toLowerCase()) === -1) : []
    readonly property var cam: showCam ? rawCam.filter(n => root.ignore.indexOf(String(n).toLowerCase()) === -1) : []
    readonly property bool active: mic.length > 0 || cam.length > 0
    readonly property bool streaming: rawMic.length > 0 || rawCam.length > 0

    function refresh(scan) {
        if (checkProc.running) {
            root._pending = true;
            return;
        }
        checkProc.command = ["bash", Caching.serpantinumDir + "/scripts/privacy.sh"].concat(scan ? ["--scan"] : []);
        checkProc.running = true;
    }
    property bool _pending: false

    Process {
        id: checkProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let r = JSON.parse(this.text);
                    root.rawMic = Array.isArray(r.mic) ? r.mic : [];
                    root.rawCam = Array.isArray(r.cam) ? r.cam : [];
                } catch (e) {}
            }
        }
        onExited: {
            if (root._pending) {
                root._pending = false;
                root.refresh(root.streaming);
            }
        }
    }

    Process {
        id: monitorProc
        running: true
        command: ["pw-dump", "--monitor", "--no-colors"]
        stdout: SplitParser {
            onRead: line => {
                if (!debounce.running) debounce.start();
            }
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
        interval: 500
        onTriggered: root.refresh(root.streaming)
    }

    Timer {
        interval: 5000
        running: root.streaming
        repeat: true
        onTriggered: root.refresh(true)
    }
}

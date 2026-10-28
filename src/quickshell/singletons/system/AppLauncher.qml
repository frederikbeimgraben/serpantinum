pragma Singleton
import QtQuick
import Quickshell

// Launches desktop entries outside the cgroup of the shell.
//
// DesktopEntry.execute() starts the app as a child of quickshell. When the
// shell runs as a systemd user service (the Home Manager module does this),
// the app lands in serpantinum.service, and every restart of the service
// (a config switch, an update) kills the app with it. On systemd, the app
// therefore starts through `systemd-run --user --scope`, which gives it its
// own scope in app.slice. Without systemd, or for terminal apps, the plain
// execute() path stays.
QtObject {
    id: root

    readonly property string scopeWrapper:
        'if [ -d /run/systemd/system ] && command -v systemd-run >/dev/null 2>&1; then ' +
        'exec systemd-run --user --scope --collect --quiet --slice=app.slice -- "$@"; ' +
        'fi; exec "$@"'

    function launch(entry) {
        if (!entry) return;
        const cmd = entry.command;
        if (entry.runInTerminal || !cmd || cmd.length === 0) {
            entry.execute();
            return;
        }
        const ctx = { command: ["sh", "-c", root.scopeWrapper, "sh"].concat(cmd) };
        if (entry.workingDirectory) ctx.workingDirectory = entry.workingDirectory;
        Quickshell.execDetached(ctx);
    }
}

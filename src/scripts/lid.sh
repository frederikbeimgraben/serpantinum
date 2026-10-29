#!/usr/bin/env bash
# Toggles the lid suspend block of the shell. The shell owns the state and
# shows the OSD, see quickshell/singletons/system/LidInhibit.qml.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
exec quickshell -p "${SCRIPT_DIR%/scripts}/quickshell/Shell.qml" ipc call lid toggle

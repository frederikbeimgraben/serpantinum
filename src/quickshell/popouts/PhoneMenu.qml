import QtQuick
import Quickshell
import "../"

// The menu of the phone module of the bar, as GSConnect shows it in GNOME.
// Each paired device of Valent gets a header with its battery and a row of
// actions. The actions are disabled while the device is not connected. The
// share dialog and the messages window of Valent are below the devices. The
// look and the behavior come from BarListMenu.qml.
BarListMenu {
    id: phoneMenu

    controller: PhoneMenuController
    layerNamespace: "phonemenu"

    readonly property var deviceActions: [
        { action: "findmyphone.ring", icon: 0xF009E, key: "phone.menu.ring", text: "Ring" },
        { action: "ping.ping", icon: 0xF048A, key: "phone.menu.ping", text: "Ping" },
        { action: "clipboard.push", icon: 0xF0C57, key: "phone.menu.clipboard_push", text: "Send clipboard" },
        { action: "clipboard.pull", icon: 0xF014A, key: "phone.menu.clipboard_pull", text: "Get clipboard" },
        { action: "sftp.browse", icon: 0xF0870, key: "phone.menu.browse", text: "Browse files" }
    ]

    function batteryText(dev, on) {
        if (!on) return I18n.t("phone.menu.disconnected", "Disconnected");
        let b = dev.battery;
        if (!b) return "";
        return (b.charging ? String.fromCodePoint(0xF140B) + " " : "") + b.percentage + " %";
    }

    rows: {
        let out = [];
        let list = Phone.paired;
        for (let i = 0; i < list.length; i++) {
            let d = list[i];
            let on = Phone.isConnected(d);
            if (i > 0) out.push({ kind: "sep" });
            out.push({ kind: "header", icon: on ? 0xF011C : 0xF0950, text: d.name,
                status: batteryText(d, on), accent: on });
            for (let j = 0; j < deviceActions.length; j++) {
                let a = deviceActions[j];
                out.push({ kind: "item", type: "device", dev: d, action: a.action, icon: a.icon,
                    text: I18n.t(a.key, a.text), enabled: on && Phone.hasAction(d, a.action) });
            }
            out.push({ kind: "item", type: "settings", dev: d, icon: 0xF0493,
                text: I18n.t("phone.menu.settings", "Device settings"), enabled: true });
        }
        if (list.length === 0) {
            out.push({ kind: "empty", icon: 0xF0950, text: I18n.t("phone.menu.none", "No paired device") });
            out.push({ kind: "item", type: "app", action: "window", icon: 0xF011C,
                text: I18n.t("phone.menu.open", "Open Valent"), enabled: true });
            return out;
        }
        out.push({ kind: "sep" });
        out.push({ kind: "item", type: "app", action: "share-dialog", icon: 0xF022A,
            text: I18n.t("phone.menu.share", "Send files…"), enabled: Phone.primary !== null && Phone.isConnected(Phone.primary) });
        out.push({ kind: "item", type: "app", action: "messages-window", icon: 0xF0369,
            text: I18n.t("phone.menu.messages", "Messages"), enabled: true });
        return out;
    }

    onActivated: row => {
        if (row.type === "device") Phone.deviceAction(row.dev, row.action);
        else if (row.type === "settings") Phone.openWindow(row.dev);
        else if (row.action === "window") Phone.openWindow(null);
        else Phone.appAction(row.action);
    }
}

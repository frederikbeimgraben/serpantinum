import QtQuick
import Quickshell
import "../"

// The menu of the vpn module of the bar. Each WireGuard connection of
// NetworkManager is an item with its state, and a click connects or
// disconnects it. When a check host is set and the shown connection is up,
// the last row tells whether the host answers. The look and the behavior
// come from BarListMenu.qml.
BarListMenu {
    controller: VpnMenuController
    layerNamespace: "vpnmenu"

    rows: {
        let out = [{ kind: "header", icon: 0xF0582, text: I18n.t("vpn.menu.title", "WireGuard"),
            status: Vpn.connected ? I18n.t("vpn.menu.connected", "Connected") : I18n.t("vpn.menu.off", "Off"),
            accent: Vpn.connected, accentColor: ThemeBackend.green }];
        let list = Vpn.connections;
        for (let i = 0; i < list.length; i++) {
            let c = list[i];
            out.push({ kind: "item", icon: c.active ? 0xF0565 : 0xF099E, text: c.name,
                status: c.active ? I18n.t("vpn.menu.disconnect", "Disconnect") : I18n.t("vpn.menu.connect", "Connect"),
                accent: c.active, accentColor: ThemeBackend.green, conn: c, enabled: !Vpn.busy });
        }
        if (Vpn.connected && Vpn.checkHost !== "") {
            out.push({ kind: "sep" });
            let ok = Vpn.reachable;
            out.push({ kind: "empty", icon: ok === false ? 0xF0ECC : 0xF0565, text: Vpn.checkHost,
                status: ok === null ? I18n.t("vpn.menu.checking", "Checking…") : (ok ? I18n.t("vpn.menu.reachable", "Reachable") : I18n.t("vpn.menu.unreachable", "Unreachable")) });
        }
        return out;
    }

    onActivated: row => Vpn.toggle(row.conn)
}

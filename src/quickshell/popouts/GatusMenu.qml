import QtQuick
import Quickshell
import "../"

// The menu of the gatus module of the bar. Each Gatus instance gets a header
// with its host and its state: all endpoints up, the number of failing
// endpoints, or no answer from the API. The failing endpoints follow as items,
// and a click opens the page of that endpoint. The last item of an instance
// opens its status page. The look and the behavior come from BarListMenu.qml.
BarListMenu {
    id: gatusMenu

    controller: GatusMenuController
    layerNamespace: "gatusmenu"
    menuWidth: s(280)

    rows: {
        let out = [];
        let list = Gatus.instances;
        for (let i = 0; i < list.length; i++) {
            let inst = list[i];
            let failing = inst.failing || [];
            if (i > 0) out.push({ kind: "sep" });
            let status, icon, color;
            if (!inst.reachable) {
                status = I18n.t("gatus.menu.unreachable", "Unreachable");
                icon = 0xF0319;
                color = ThemeBackend.overlay1;
            } else if (failing.length > 0) {
                status = I18n.t("gatus.menu.failing", "{count} failing").replace("{count}", failing.length);
                icon = 0xF0028;
                color = ThemeBackend.red;
            } else {
                status = I18n.t("gatus.menu.ok", "All {count} up").replace("{count}", inst.total);
                icon = 0xF05E0;
                color = ThemeBackend.green;
            }
            out.push({ kind: "header", icon: icon, text: inst.host, status: status, accent: true, accentColor: color });
            for (let j = 0; j < failing.length; j++) {
                let e = failing[j];
                out.push({ kind: "item", icon: 0xF0028, text: e.group ? e.group + " / " + e.name : e.name,
                    url: inst.url + "/endpoints/" + e.key, enabled: true });
            }
            out.push({ kind: "item", icon: 0xF03CC, text: I18n.t("gatus.menu.open", "Open status page"),
                url: inst.url, enabled: true });
        }
        if (list.length === 0) {
            out.push({ kind: "empty", icon: 0xF05F6, text: I18n.t("gatus.menu.loading", "Checking…") });
        }
        return out;
    }

    onActivated: row => Gatus.open(row.url)
}

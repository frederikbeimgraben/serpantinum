import QtQuick
import Quickshell
import "../"

// The menu of the privacy module of the bar: the apps that use the
// microphone and the apps that use the camera. The look and the behavior
// come from BarListMenu.qml.
BarListMenu {
    controller: PrivacyMenuController
    layerNamespace: "privacymenu"

    rows: {
        let out = [];
        if (Privacy.mic.length > 0) {
            out.push({ kind: "header", icon: 0xF036C, text: I18n.t("privacy.menu.mic", "Microphone"), accent: true, accentColor: ThemeBackend.peach });
            for (let i = 0; i < Privacy.mic.length; i++) out.push({ kind: "empty", icon: 0xF08C6, text: Privacy.mic[i] });
        }
        if (Privacy.cam.length > 0) {
            if (out.length > 0) out.push({ kind: "sep" });
            out.push({ kind: "header", icon: 0xF05A0, text: I18n.t("privacy.menu.cam", "Camera"), accent: true, accentColor: ThemeBackend.peach });
            for (let j = 0; j < Privacy.cam.length; j++) out.push({ kind: "empty", icon: 0xF08C6, text: Privacy.cam[j] });
        }
        if (out.length === 0) out.push({ kind: "empty", icon: 0xF0565, text: I18n.t("privacy.menu.none", "No app records") });
        return out;
    }
}

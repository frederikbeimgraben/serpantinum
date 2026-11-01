import QtQuick
import QtQuick.Layouts
import "../../"
import "../../reusables"
import "../../reusables/guide"

// Session restore on niri, see singletons/system/Session.qml: whether the
// shell saves and restores the open apps, whether it asks first, and the apps
// that it leaves out. The settings are the session object: enabled, mode
// ("ask" or "auto") and ignore.
SettingsBlob {
    id: section
    required property var tab
    readonly property var rootObj: tab.rootObj

    readonly property var session: Config.getSetting("session", {}) || {}
    readonly property var ignoreList: Array.isArray(session.ignore) ? session.ignore : []

    function setSession(field, value) {
        let s = JSON.parse(JSON.stringify(section.session));
        s[field] = value;
        Config.setSetting("session", s);
    }

    SettingsRow {
        rootObj: section.rootObj
        settingId: "general_session_enabled"
        searchKeywords: "session restore reboot login windows apps workspace"
        icon: "󰦛"
        title: I18n.t("guide.general.session.enabled.title", "Restore the session")
        description: I18n.t("guide.general.session.enabled.desc", "Start the open apps again after a login, on their workspaces")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: section.session.enabled === true
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) { section.setSession("enabled", c); }
        }
    }

    SettingsRow {
        rootObj: section.rootObj
        settingId: "general_session_mode"
        searchKeywords: "session restore ask automatic"
        icon: "󰋗"
        title: I18n.t("guide.general.session.mode.title", "When to restore")
        description: I18n.t("guide.general.session.mode.desc", "Ask in a notification, or restore at once")

        Dropdown {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: section.rootObj.s(160)
            implicitHeight: section.rootObj.s(32)
            options: [I18n.t("guide.general.session.mode.ask", "Ask"), I18n.t("guide.general.session.mode.auto", "Automatic")]
            currentIndex: section.session.mode === "auto" ? 1 : 0
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface0
            hoverColor: ThemeBackend.surface1
            dropdownColor: ThemeBackend.surface0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            textColor: ThemeBackend.text
            activeTextColor: ThemeBackend.crust
            fontPixelSize: section.rootObj.s(11)
            onValueChanged: function(index, value) { section.setSession("mode", index === 1 ? "auto" : "ask"); }
        }
    }

    Repeater {
        model: section.ignoreList

        SettingsRow {
            id: ignoreRow
            required property var modelData
            required property int index
            rootObj: section.rootObj
            settingId: "general_session_ignore_" + index
            searchKeywords: "session restore ignore app"
            icon: "󰈉"
            title: I18n.t("guide.general.session.ignored.title", "Left out")
            description: ignoreRow.modelData

            ClickButton {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                height: section.rootObj.s(32)
                horizontalPadding: section.rootObj.s(10)
                cornerRadius: ThemeBackend.borderRadius
                buttonIcon: "󰆴"
                accentColor: ThemeBackend.surface0
                textColor: ThemeBackend.red
                onClicked: {
                    let list = section.ignoreList.slice();
                    list.splice(ignoreRow.index, 1);
                    section.setSession("ignore", list);
                }
            }
        }
    }

    SettingsRow {
        rootObj: section.rootObj
        settingId: "general_session_ignore_add"
        searchKeywords: "session restore ignore app add"
        icon: "󰐕"
        title: I18n.t("guide.general.session.ignore.title", "Leave an app out")
        description: I18n.t("guide.general.session.ignore.desc", "Enter the app id, such as org.gnome.Ptyxis, and press Enter")

        Input {
            id: ignoreInput
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: section.rootObj.s(220)
            implicitHeight: section.rootObj.s(32)
            placeholderText: "org.gnome.Ptyxis"
            baseColor: ThemeBackend.surface0
            accentColor: ThemeBackend.mauve
            textColor: ThemeBackend.text
            subTextColor: ThemeBackend.subtext0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            cornerRadius: ThemeBackend.borderRadius
            fontPixelSize: section.rootObj.s(11)
            onAccepted: function(finalText) {
                let id = finalText.trim();
                if (id === "" || section.ignoreList.indexOf(id) !== -1) return;
                section.setSession("ignore", section.ignoreList.concat([id]));
                ignoreInput.text = "";
            }
        }
    }
}

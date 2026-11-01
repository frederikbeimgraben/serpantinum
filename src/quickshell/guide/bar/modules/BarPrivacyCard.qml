import QtQuick
import QtQuick.Layouts
import "../../../"
import "../../../reusables"
import "../../../reusables/guide"

BarModuleCard {
    id: card
    title: I18n.t("guide.bar.modules.privacy", "Microphone and camera")
    moduleId: "privacy"
    styles: card.tab.privacyStyles
    currentStyle: card.tab.privacyStyle
    styleSettingId: "bar_privacy_style"
    styleKeywords: "gatus status page uptime monitoring style look button text layout"
    styleIcon: "󰍬"
    styleTitle: I18n.t("guide.bar.privacy.style.title", "Style")
    styleDescription: I18n.t("guide.bar.privacy.style.desc", "Choose the visual appearance of the microphone and camera module")
    onStyleSelected: id => card.tab.setPrivacyStyle(id)

    widgetComponent: Component {
        BarPreviewWidget {
            property string privacyStyle: variantId !== "" ? variantId : tab.privacyStyle
            property bool privacyShowIcon: tab.privacyShowIcon
            property bool privacyShowLabel: tab.privacyShowLabel
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_privacy_show_icon"
        searchKeywords: "privacy microphone camera recording webcam icon symbol indicator"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰍬"
        title: I18n.t("guide.bar.privacy.show_icon.title", "Show icon")
        description: I18n.t("guide.bar.privacy.show_icon.desc", "Display the microphone and camera icons")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.privacyShowIcon
            enabled: !checked || card.tab.privacyShowLabel
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setPrivacyShowIcon(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_privacy_show_label"
        searchKeywords: "privacy microphone camera recording webcam label text"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰀨"
        title: I18n.t("guide.bar.privacy.show_label.title", "Show apps")
        description: I18n.t("guide.bar.privacy.show_label.desc", "Display the names of the apps next to the icons")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.privacyShowLabel
            enabled: !checked || card.tab.privacyShowIcon
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setPrivacyShowLabel(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_privacy_show_mic"
        searchKeywords: "privacy microphone recording"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰍬"
        title: I18n.t("guide.bar.privacy.mic.title", "Microphone")
        description: I18n.t("guide.bar.privacy.mic.desc", "Show when an app uses the microphone")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.privacyShowMic
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.privacyShowMic = c;
                card.tab.setModuleConfig("privacy", "showMic", c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_privacy_show_cam"
        searchKeywords: "privacy camera webcam"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰖠"
        title: I18n.t("guide.bar.privacy.cam.title", "Camera")
        description: I18n.t("guide.bar.privacy.cam.desc", "Show when an app uses the camera")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.privacyShowCam
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.privacyShowCam = c;
                card.tab.setModuleConfig("privacy", "showCam", c);
            }
        }
    }

    Repeater {
        model: card.tab.privacyIgnore

        SettingsRow {
            id: ignoreRow
            required property var modelData
            required property int index
            rootObj: card.rootObj
            settingId: "bar_privacy_ignore_" + index
            searchKeywords: "privacy ignore app exclude"
            baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
            icon: "󰈉"
            title: I18n.t("guide.bar.privacy.ignored.title", "Ignored app")
            description: ignoreRow.modelData

            ClickButton {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                height: card.rootObj.s(32)
                horizontalPadding: card.rootObj.s(10)
                cornerRadius: ThemeBackend.borderRadius
                buttonIcon: "󰆴"
                accentColor: ThemeBackend.surface0
                textColor: ThemeBackend.red
                onClicked: {
                    let list = card.tab.privacyIgnore.slice();
                    list.splice(ignoreRow.index, 1);
                    card.tab.privacyIgnore = list;
                    card.tab.setModuleConfig("privacy", "ignore", list);
                }
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_privacy_ignore_add"
        searchKeywords: "privacy ignore app exclude add"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰐕"
        title: I18n.t("guide.bar.privacy.ignore.title", "Ignore an app")
        description: I18n.t("guide.bar.privacy.ignore.desc", "Enter the app name as the menu shows it and press Enter")

        Input {
            id: ignoreInput
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: card.rootObj.s(200)
            implicitHeight: card.rootObj.s(32)
            placeholderText: "cava"
            baseColor: ThemeBackend.surface0
            accentColor: ThemeBackend.mauve
            textColor: ThemeBackend.text
            subTextColor: ThemeBackend.subtext0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            cornerRadius: ThemeBackend.borderRadius
            fontPixelSize: card.rootObj.s(11)
            onAccepted: function(finalText) {
                let name = finalText.trim();
                if (name === "" || card.tab.privacyIgnore.indexOf(name) !== -1) return;
                let list = card.tab.privacyIgnore.concat([name]);
                card.tab.privacyIgnore = list;
                card.tab.setModuleConfig("privacy", "ignore", list);
                ignoreInput.text = "";
            }
        }
    }
}

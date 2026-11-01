import QtQuick
import QtQuick.Layouts
import "../../../"
import "../../../reusables"
import "../../../reusables/guide"

BarModuleCard {
    id: card
    title: I18n.t("guide.bar.modules.btbat", "Device batteries")
    moduleId: "btbat"
    styles: card.tab.btbatStyles
    currentStyle: card.tab.btbatStyle
    styleSettingId: "bar_btbat_style"
    styleKeywords: "gatus status page uptime monitoring style look button text layout"
    styleIcon: "󰂯"
    styleTitle: I18n.t("guide.bar.btbat.style.title", "Style")
    styleDescription: I18n.t("guide.bar.btbat.style.desc", "Choose the visual appearance of the device batteries module")
    onStyleSelected: id => card.tab.setBtbatStyle(id)

    widgetComponent: Component {
        BarPreviewWidget {
            property string btbatStyle: variantId !== "" ? variantId : tab.btbatStyle
            property bool btbatShowIcon: tab.btbatShowIcon
            property bool btbatShowPercent: tab.btbatShowPercent
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_btbat_show_icon"
        searchKeywords: "bluetooth battery device headphones mouse keyboard icon symbol indicator"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰂯"
        title: I18n.t("guide.bar.btbat.show_icon.title", "Show icon")
        description: I18n.t("guide.bar.btbat.show_icon.desc", "Display the device type icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.btbatShowIcon
            enabled: !checked || card.tab.btbatShowPercent
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setBtbatShowIcon(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_btbat_show_percent"
        searchKeywords: "bluetooth battery device headphones mouse keyboard label text"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰀨"
        title: I18n.t("guide.bar.btbat.show_percent.title", "Show percentage")
        description: I18n.t("guide.bar.btbat.show_percent.desc", "Display the charge percentage of each device")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.btbatShowPercent
            enabled: !checked || card.tab.btbatShowIcon
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setBtbatShowPercent(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_btbat_warn"
        searchKeywords: "bluetooth battery low warning notification"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰂃"
        title: I18n.t("guide.bar.btbat.warn.title", "Low battery warning")
        description: I18n.t("guide.bar.btbat.warn.desc", "Send a notification when a device falls below the threshold")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.btbatWarn
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.btbatWarn = c;
                card.tab.setModuleConfig("btbat", "warn", c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_btbat_threshold"
        searchKeywords: "bluetooth battery low threshold percent"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰁻"
        title: I18n.t("guide.bar.btbat.threshold.title", "Warning threshold")
        description: I18n.t("guide.bar.btbat.threshold.desc", "Charge level in percent that counts as low")

        Input {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: card.rootObj.s(80)
            implicitHeight: card.rootObj.s(32)
            text: String(card.tab.btbatLowThreshold)
            placeholderText: "20"
            baseColor: ThemeBackend.surface0
            accentColor: ThemeBackend.mauve
            textColor: ThemeBackend.text
            subTextColor: ThemeBackend.subtext0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            cornerRadius: ThemeBackend.borderRadius
            fontPixelSize: card.rootObj.s(11)
            onAccepted: function(finalText) {
                let v = Math.max(1, Math.min(99, parseInt(finalText) || 20));
                card.tab.btbatLowThreshold = v;
                card.tab.setModuleConfig("btbat", "lowThreshold", v);
            }
        }
    }
}

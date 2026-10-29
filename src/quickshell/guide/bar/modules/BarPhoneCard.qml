import QtQuick
import QtQuick.Layouts
import "../../../"
import "../../../reusables"
import "../../../reusables/guide"

BarModuleCard {
    id: card
    title: I18n.t("guide.bar.modules.phone", "Phone")
    moduleId: "phone"
    styles: card.tab.phoneStyles
    currentStyle: card.tab.phoneStyle
    styleSettingId: "bar_phone_style"
    styleKeywords: "phone kdeconnect valent gsconnect style look button text layout"
    styleIcon: "󰄜"
    styleTitle: I18n.t("guide.bar.phone.style.title", "Style")
    styleDescription: I18n.t("guide.bar.phone.style.desc", "Choose the visual appearance of the phone module")
    onStyleSelected: id => card.tab.setPhoneStyle(id)

    widgetComponent: Component {
        BarPreviewWidget {
            property string phoneStyle: variantId !== "" ? variantId : tab.phoneStyle
            property bool phoneShowIcon: tab.phoneShowIcon
            property bool phoneShowBattery: tab.phoneShowBattery
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_phone_show_icon"
        searchKeywords: "phone kdeconnect valent icon symbol indicator"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰄜"
        title: I18n.t("guide.bar.phone.show_icon.title", "Show icon")
        description: I18n.t("guide.bar.phone.show_icon.desc", "Display the phone icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.phoneShowIcon
            enabled: !checked || card.tab.phoneShowBattery
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setPhoneShowIcon(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_phone_show_battery"
        searchKeywords: "phone kdeconnect valent battery percent"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰁹"
        title: I18n.t("guide.bar.phone.show_battery.title", "Show battery")
        description: I18n.t("guide.bar.phone.show_battery.desc", "Display the battery level of the phone next to the icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.phoneShowBattery
            enabled: !checked || card.tab.phoneShowIcon
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setPhoneShowBattery(c);
            }
        }
    }
}

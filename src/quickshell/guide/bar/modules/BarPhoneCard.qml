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
            property bool phoneShowPercent: tab.phoneShowPercent
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
            enabled: !checked || card.tab.phoneShowPercent
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
        settingId: "bar_phone_show_percent"
        searchKeywords: "phone kdeconnect valent battery percent"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰁹"
        title: I18n.t("guide.bar.phone.show_percent.title", "Show percentage")
        description: I18n.t("guide.bar.phone.show_percent.desc", "Display the numeric phone charge percentage")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.phoneShowPercent
            enabled: !checked || card.tab.phoneShowIcon
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setPhoneShowPercent(c);
            }
        }
    }
}

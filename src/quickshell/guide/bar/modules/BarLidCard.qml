import QtQuick
import QtQuick.Layouts
import "../../../"
import "../../../reusables"
import "../../../reusables/guide"

BarModuleCard {
    id: card
    title: I18n.t("guide.bar.modules.lid", "Lid suspend")
    moduleId: "lid"
    styles: card.tab.lidStyles
    currentStyle: card.tab.lidStyle
    styleSettingId: "bar_lid_style"
    styleKeywords: "lid suspend sleep inhibit style look button text layout"
    styleIcon: "󰅶"
    styleTitle: I18n.t("guide.bar.lid.style.title", "Style")
    styleDescription: I18n.t("guide.bar.lid.style.desc", "Choose the visual appearance of the lid suspend module")
    onStyleSelected: id => card.tab.setLidStyle(id)

    widgetComponent: Component {
        BarPreviewWidget {
            property string lidStyle: variantId !== "" ? variantId : tab.lidStyle
            property bool lidShowIcon: tab.lidShowIcon
            property bool lidShowName: tab.lidShowName
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_lid_show_icon"
        searchKeywords: "lid suspend icon symbol indicator"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰅶"
        title: I18n.t("guide.bar.lid.show_icon.title", "Show icon")
        description: I18n.t("guide.bar.lid.show_icon.desc", "Display the suspend block icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.lidShowIcon
            enabled: !checked || card.tab.lidShowName
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setLidShowIcon(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_lid_show_name"
        searchKeywords: "lid suspend label awake auto"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰒲"
        title: I18n.t("guide.bar.lid.show_name.title", "Show name")
        description: I18n.t("guide.bar.lid.show_name.desc", "Display Awake or Auto next to the icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.lidShowName
            enabled: !checked || card.tab.lidShowIcon
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setLidShowName(c);
            }
        }
    }
}

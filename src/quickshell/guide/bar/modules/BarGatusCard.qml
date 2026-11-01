import QtQuick
import QtQuick.Layouts
import "../../../"
import "../../../reusables"
import "../../../reusables/guide"

BarModuleCard {
    id: card
    title: I18n.t("guide.bar.modules.gatus", "Status pages")
    moduleId: "gatus"
    styles: card.tab.gatusStyles
    currentStyle: card.tab.gatusStyle
    styleSettingId: "bar_gatus_style"
    styleKeywords: "gatus status page uptime monitoring style look button text layout"
    styleIcon: "󰗶"
    styleTitle: I18n.t("guide.bar.gatus.style.title", "Style")
    styleDescription: I18n.t("guide.bar.gatus.style.desc", "Choose the visual appearance of the status pages module")
    onStyleSelected: id => card.tab.setGatusStyle(id)

    widgetComponent: Component {
        BarPreviewWidget {
            property string gatusStyle: variantId !== "" ? variantId : tab.gatusStyle
            property bool gatusShowIcon: tab.gatusShowIcon
            property bool gatusShowCount: tab.gatusShowCount
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_gatus_show_icon"
        searchKeywords: "gatus status uptime icon symbol indicator"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰗶"
        title: I18n.t("guide.bar.gatus.show_icon.title", "Show icon")
        description: I18n.t("guide.bar.gatus.show_icon.desc", "Display the status icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.gatusShowIcon
            enabled: !checked || card.tab.gatusShowCount
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setGatusShowIcon(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_gatus_show_count"
        searchKeywords: "gatus status failing count number"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰀨"
        title: I18n.t("guide.bar.gatus.show_count.title", "Show count")
        description: I18n.t("guide.bar.gatus.show_count.desc", "Display the number of failing endpoints next to the icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.gatusShowCount
            enabled: !checked || card.tab.gatusShowIcon
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setGatusShowCount(c);
            }
        }
    }

    Repeater {
        model: card.tab.gatusUrls

        SettingsRow {
            id: urlRow
            required property var modelData
            required property int index
            rootObj: card.rootObj
            settingId: "bar_gatus_url_" + index
            searchKeywords: "gatus status page url address"
            baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
            icon: "󰖟"
            title: I18n.t("guide.bar.gatus.url.title", "Status page")
            description: I18n.t("guide.bar.gatus.url.desc", "Base URL of a Gatus instance")

            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: card.rootObj.s(6)

                Input {
                    implicitWidth: card.rootObj.s(240)
                    implicitHeight: card.rootObj.s(32)
                    text: urlRow.modelData
                    placeholderText: "https://status.example.org"
                    baseColor: ThemeBackend.surface0
                    accentColor: ThemeBackend.mauve
                    textColor: ThemeBackend.text
                    subTextColor: ThemeBackend.subtext0
                    borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
                    cornerRadius: ThemeBackend.borderRadius
                    fontPixelSize: card.rootObj.s(11)
                    onAccepted: function(finalText) {
                        card.tab.setGatusUrl(urlRow.index, finalText);
                    }
                }

                ClickButton {
                    height: card.rootObj.s(32)
                    horizontalPadding: card.rootObj.s(10)
                    cornerRadius: ThemeBackend.borderRadius
                    buttonIcon: "󰆴"
                    accentColor: ThemeBackend.surface0
                    textColor: ThemeBackend.red
                    onClicked: card.tab.removeGatusUrl(urlRow.index)
                }
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_gatus_url_add"
        searchKeywords: "gatus status page url add new"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰐕"
        title: I18n.t("guide.bar.gatus.add.title", "Add status page")
        description: I18n.t("guide.bar.gatus.add.desc", "Enter the URL and press Enter")

        Input {
            id: addInput
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: card.rootObj.s(240)
            implicitHeight: card.rootObj.s(32)
            placeholderText: "https://status.example.org"
            baseColor: ThemeBackend.surface0
            accentColor: ThemeBackend.mauve
            textColor: ThemeBackend.text
            subTextColor: ThemeBackend.subtext0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            cornerRadius: ThemeBackend.borderRadius
            fontPixelSize: card.rootObj.s(11)
            onAccepted: function(finalText) {
                card.tab.addGatusUrl(finalText);
                addInput.text = "";
            }
        }
    }
}

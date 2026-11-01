import QtQuick
import QtQuick.Layouts
import "../../../"
import "../../../reusables"
import "../../../reusables/guide"

BarModuleCard {
    id: card
    title: I18n.t("guide.bar.modules.vpn", "VPN")
    moduleId: "vpn"
    styles: card.tab.vpnStyles
    currentStyle: card.tab.vpnStyle
    styleSettingId: "bar_vpn_style"
    styleKeywords: "gatus status page uptime monitoring style look button text layout"
    styleIcon: "󰖂"
    styleTitle: I18n.t("guide.bar.vpn.style.title", "Style")
    styleDescription: I18n.t("guide.bar.vpn.style.desc", "Choose the visual appearance of the vpn module")
    onStyleSelected: id => card.tab.setVpnStyle(id)

    widgetComponent: Component {
        BarPreviewWidget {
            property string vpnStyle: variantId !== "" ? variantId : tab.vpnStyle
            property bool vpnShowIcon: tab.vpnShowIcon
            property bool vpnShowLabel: tab.vpnShowLabel
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_vpn_show_icon"
        searchKeywords: "vpn wireguard tunnel networkmanager icon symbol indicator"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰖂"
        title: I18n.t("guide.bar.vpn.show_icon.title", "Show icon")
        description: I18n.t("guide.bar.vpn.show_icon.desc", "Display the VPN icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.vpnShowIcon
            enabled: !checked || card.tab.vpnShowLabel
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setVpnShowIcon(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_vpn_show_label"
        searchKeywords: "vpn wireguard tunnel networkmanager label text"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰀨"
        title: I18n.t("guide.bar.vpn.show_label.title", "Show name")
        description: I18n.t("guide.bar.vpn.show_label.desc", "Display the name of the connection next to the icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.vpnShowLabel
            enabled: !checked || card.tab.vpnShowIcon
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setVpnShowLabel(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_vpn_connection"
        searchKeywords: "vpn wireguard connection tunnel"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰖂"
        title: I18n.t("guide.bar.vpn.connection.title", "Connection")
        description: I18n.t("guide.bar.vpn.connection.desc", "The WireGuard connection that the bar shows")

        Dropdown {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: card.rootObj.s(200)
            implicitHeight: card.rootObj.s(32)
            options: Vpn.names
            currentIndex: Math.max(0, Vpn.names.indexOf(Vpn.current ? Vpn.current.name : ""))
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface0
            hoverColor: ThemeBackend.surface1
            dropdownColor: ThemeBackend.surface0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            textColor: ThemeBackend.text
            activeTextColor: ThemeBackend.crust
            fontPixelSize: card.rootObj.s(11)
            onValueChanged: function(index, value) {
                card.tab.setModuleConfig("vpn", "connection", value);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_vpn_check_host"
        searchKeywords: "vpn wireguard check host ping reachable"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰖟"
        title: I18n.t("guide.bar.vpn.check.title", "Check host")
        description: I18n.t("guide.bar.vpn.check.desc", "A host behind the tunnel that answers ping. Empty: no check")

        Input {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: card.rootObj.s(200)
            implicitHeight: card.rootObj.s(32)
            text: card.tab.vpnCheckHost
            placeholderText: "10.0.0.1"
            baseColor: ThemeBackend.surface0
            accentColor: ThemeBackend.mauve
            textColor: ThemeBackend.text
            subTextColor: ThemeBackend.subtext0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            cornerRadius: ThemeBackend.borderRadius
            fontPixelSize: card.rootObj.s(11)
            onAccepted: function(finalText) {
                card.tab.vpnCheckHost = finalText.trim();
                card.tab.setModuleConfig("vpn", "checkHost", finalText.trim());
            }
        }
    }
}

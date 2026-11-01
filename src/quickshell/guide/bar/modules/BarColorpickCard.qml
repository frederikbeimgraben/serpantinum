import QtQuick
import QtQuick.Layouts
import "../../../"
import "../../../reusables"
import "../../../reusables/guide"

BarModuleCard {
    id: card
    title: I18n.t("guide.bar.modules.colorpick", "Color picker")
    moduleId: "colorpick"
    styles: card.tab.colorpickStyles
    currentStyle: card.tab.colorpickStyle
    styleSettingId: "bar_colorpick_style"
    styleKeywords: "gatus status page uptime monitoring style look button text layout"
    styleIcon: "󰈊"
    styleTitle: I18n.t("guide.bar.colorpick.style.title", "Style")
    styleDescription: I18n.t("guide.bar.colorpick.style.desc", "Choose the visual appearance of the color picker module")
    onStyleSelected: id => card.tab.setColorpickStyle(id)

    widgetComponent: Component {
        BarPreviewWidget {
            property string colorpickStyle: variantId !== "" ? variantId : tab.colorpickStyle
            property bool colorpickShowIcon: tab.colorpickShowIcon
            property bool colorpickShowLabel: tab.colorpickShowLabel
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_colorpick_show_icon"
        searchKeywords: "color picker pipette eyedropper hex icon symbol indicator"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰈊"
        title: I18n.t("guide.bar.colorpick.show_icon.title", "Show icon")
        description: I18n.t("guide.bar.colorpick.show_icon.desc", "Display the pipette icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.colorpickShowIcon
            enabled: !checked || card.tab.colorpickShowLabel
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setColorpickShowIcon(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_colorpick_show_label"
        searchKeywords: "color picker pipette eyedropper hex label text"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰀨"
        title: I18n.t("guide.bar.colorpick.show_label.title", "Show value")
        description: I18n.t("guide.bar.colorpick.show_label.desc", "Display the last picked color value next to the icon")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.colorpickShowLabel
            enabled: !checked || card.tab.colorpickShowIcon
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.setColorpickShowLabel(c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_colorpick_format"
        searchKeywords: "color picker format hex rgb hsl"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰏘"
        title: I18n.t("guide.bar.colorpick.format.title", "Format")
        description: I18n.t("guide.bar.colorpick.format.desc", "Format of the value in the clipboard")

        Dropdown {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: card.rootObj.s(140)
            implicitHeight: card.rootObj.s(32)
            options: ["HEX", "RGB", "HSL"]
            currentIndex: Math.max(0, ["hex", "rgb", "hsl"].indexOf(card.tab.colorpickFormat))
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface0
            hoverColor: ThemeBackend.surface1
            dropdownColor: ThemeBackend.surface0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            textColor: ThemeBackend.text
            activeTextColor: ThemeBackend.crust
            fontPixelSize: card.rootObj.s(11)
            onValueChanged: function(index, value) {
                let f = ["hex", "rgb", "hsl"][index];
                card.tab.colorpickFormat = f;
                card.tab.setModuleConfig("colorpick", "format", f);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_colorpick_notify"
        searchKeywords: "color picker notification swatch"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰂚"
        title: I18n.t("guide.bar.colorpick.notify.title", "Notification")
        description: I18n.t("guide.bar.colorpick.notify.desc", "Show the picked color in a notification")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.colorpickNotify
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.colorpickNotify = c;
                card.tab.setModuleConfig("colorpick", "notify", c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_colorpick_lens"
        searchKeywords: "color picker magnifier lens zoom"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰍉"
        title: I18n.t("guide.bar.colorpick.lens.title", "Magnifier")
        description: I18n.t("guide.bar.colorpick.lens.desc", "Show a zoomed lens around the pointer while picking")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: card.tab.colorpickLens
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                card.tab.colorpickLens = c;
                card.tab.setModuleConfig("colorpick", "lens", c);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_colorpick_zoom"
        searchKeywords: "color picker magnifier zoom factor"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰛭"
        title: I18n.t("guide.bar.colorpick.zoom.title", "Zoom")
        description: I18n.t("guide.bar.colorpick.zoom.desc", "Enlargement of the magnifier, 2 to 24")

        Input {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: card.rootObj.s(80)
            implicitHeight: card.rootObj.s(32)
            text: String(card.tab.colorpickZoom)
            placeholderText: "8"
            baseColor: ThemeBackend.surface0
            accentColor: ThemeBackend.mauve
            textColor: ThemeBackend.text
            subTextColor: ThemeBackend.subtext0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            cornerRadius: ThemeBackend.borderRadius
            fontPixelSize: card.rootObj.s(11)
            onAccepted: function(finalText) {
                let v = parseInt(finalText);
                if (isNaN(v)) v = 8;
                v = Math.max(2, Math.min(24, v));
                card.tab.colorpickZoom = v;
                card.tab.setModuleConfig("colorpick", "zoom", v);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_colorpick_reset"
        searchKeywords: "color picker reset idle delay seconds"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰔛"
        title: I18n.t("guide.bar.colorpick.reset.title", "Reset after")
        description: I18n.t("guide.bar.colorpick.reset.desc", "Seconds until the pill returns to its idle look. 0 keeps the color")

        Input {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: card.rootObj.s(80)
            implicitHeight: card.rootObj.s(32)
            text: String(card.tab.colorpickResetAfter)
            placeholderText: "5"
            baseColor: ThemeBackend.surface0
            accentColor: ThemeBackend.mauve
            textColor: ThemeBackend.text
            subTextColor: ThemeBackend.subtext0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            cornerRadius: ThemeBackend.borderRadius
            fontPixelSize: card.rootObj.s(11)
            onAccepted: function(finalText) {
                let v = parseInt(finalText);
                if (isNaN(v)) v = 5;
                v = Math.max(0, Math.min(3600, v));
                card.tab.colorpickResetAfter = v;
                card.tab.setModuleConfig("colorpick", "resetAfter", v);
            }
        }
    }

    SettingsRow {
        rootObj: card.rootObj
        settingId: "bar_colorpick_shortcut"
        searchKeywords: "color picker shortcut key binding hotkey niri"
        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
        icon: "󰌌"
        title: I18n.t("guide.bar.colorpick.shortcut.title", "Shortcut")
        description: I18n.t("guide.bar.colorpick.shortcut.desc", "niri key that starts the picker, such as Mod+Shift+C. Empty: none")

        Input {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: card.rootObj.s(160)
            implicitHeight: card.rootObj.s(32)
            text: card.tab.colorpickShortcut
            placeholderText: "Mod+Shift+C"
            baseColor: ThemeBackend.surface0
            accentColor: ThemeBackend.mauve
            textColor: ThemeBackend.text
            subTextColor: ThemeBackend.subtext0
            borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
            cornerRadius: ThemeBackend.borderRadius
            fontPixelSize: card.rootObj.s(11)
            onAccepted: function(finalText) {
                let key = finalText.trim();
                card.tab.colorpickShortcut = key;
                card.tab.setModuleConfig("colorpick", "shortcut", key);
            }
        }
    }
}

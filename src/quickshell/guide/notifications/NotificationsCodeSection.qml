import QtQuick
import QtQuick.Layouts
import "../../"
import "../../reusables"
import "../../reusables/guide"

// One-time codes in notifications: a notification that contains a code, such
// as a login code from the phone, gets a button that copies the code. The
// settings are notifications.otp: enabled, requireKeyword (a word such as
// "code" or "PIN" must also appear, so a year or a price does not count),
// minDigits and maxDigits. See notifications/Notification.qml.
SettingsBlob {
    id: section
    required property var tab
    readonly property var rootObj: tab.rootObj

    readonly property var otp: {
        let n = Config.getSetting("notifications", {}) || {};
        return (n.otp && typeof n.otp === "object") ? n.otp : {};
    }

    function setOtp(field, value) {
        let o = JSON.parse(JSON.stringify(section.otp));
        o[field] = value;
        section.tab.updateNotifSetting("otp", o);
    }

    SettingsRow {
        rootObj: section.tab.rootObj
        settingId: "notifications_otp_enabled"
        searchKeywords: "notification code otp pin copy login sms"
        icon: "󰆏"
        title: I18n.t("guide.notifications.otp.enabled.title", "Copy one-time codes")
        description: I18n.t("guide.notifications.otp.enabled.desc", "Add a button that copies a login code from a notification")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: section.otp.enabled !== false
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) { section.setOtp("enabled", c); }
        }
    }

    SettingsRow {
        rootObj: section.tab.rootObj
        settingId: "notifications_otp_keyword"
        searchKeywords: "notification code otp keyword"
        icon: "󰌆"
        title: I18n.t("guide.notifications.otp.keyword.title", "Only with a keyword")
        description: I18n.t("guide.notifications.otp.keyword.desc", "Count digits only when a word such as code, PIN, OTP or TAN appears")

        Toggle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: section.otp.requireKeyword !== false
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) { section.setOtp("requireKeyword", c); }
        }
    }

    SettingsRow {
        rootObj: section.tab.rootObj
        settingId: "notifications_otp_digits"
        searchKeywords: "notification code otp digits length"
        icon: "󰎠"
        title: I18n.t("guide.notifications.otp.digits.title", "Code length")
        description: I18n.t("guide.notifications.otp.digits.desc", "Smallest and largest number of digits of a code")

        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: section.rootObj.s(6)

            Repeater {
                model: [["minDigits", 4], ["maxDigits", 8]]

                Input {
                    required property var modelData
                    implicitWidth: section.rootObj.s(60)
                    implicitHeight: section.rootObj.s(32)
                    text: String(Number(section.otp[modelData[0]]) || modelData[1])
                    placeholderText: String(modelData[1])
                    baseColor: ThemeBackend.surface0
                    accentColor: ThemeBackend.mauve
                    textColor: ThemeBackend.text
                    subTextColor: ThemeBackend.subtext0
                    borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
                    cornerRadius: ThemeBackend.borderRadius
                    fontPixelSize: section.rootObj.s(11)
                    onAccepted: function(finalText) {
                        section.setOtp(modelData[0], Math.max(3, Math.min(12, parseInt(finalText) || modelData[1])));
                    }
                }
            }
        }
    }
}

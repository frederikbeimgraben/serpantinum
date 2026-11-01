pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../../"

// Batteries of devices such as Bluetooth headphones, mice and keyboards for
// the btbat module of the bar. UPower lists them, so nothing polls. The list
// leaves out the laptop battery and power supplies, and a device without a
// level. When btbat.warn is not false, a device that falls below
// btbat.lowThreshold percent (default 20) sends one notification, until it
// rises above the threshold again.
Item {
    id: root

    readonly property var settings: Config.getSetting("btbat", {}) || {}
    readonly property int lowThreshold: Math.max(1, Math.min(99, Number(settings.lowThreshold) || 20))
    readonly property bool warn: settings.warn !== false

    readonly property var devices: {
        let all = UPower.devices ? (UPower.devices.values || []) : [];
        return all.filter(d => d && !d.isLaptopBattery
            && d.type !== UPowerDeviceType.LinePower && d.type !== UPowerDeviceType.Battery
            && d.type !== UPowerDeviceType.Ups && d.percentage > 0);
    }

    function iconFor(type) {
        switch (type) {
        case UPowerDeviceType.Mouse: return 0xF037D;
        case UPowerDeviceType.Keyboard: return 0xF030C;
        case UPowerDeviceType.Headset: return 0xF02CE;
        case UPowerDeviceType.Headphones: return 0xF02CB;
        case UPowerDeviceType.GamingInput: return 0xF0297;
        case UPowerDeviceType.Speakers: return 0xF04C3;
        case UPowerDeviceType.Phone: return 0xF011C;
        case UPowerDeviceType.Tablet: return 0xF04F6;
        case UPowerDeviceType.Pen: return 0xF03EA;
        case UPowerDeviceType.Wearable: return 0xF0589;
        default: return 0xF00AF;
        }
    }

    function nameOf(d) {
        return (d && d.model) ? d.model : I18n.t("btbat.device", "Device");
    }

    Instantiator {
        model: UPower.devices
        delegate: QtObject {
            required property var modelData
            readonly property bool counted: root.devices.indexOf(modelData) !== -1
            readonly property int level: Math.round((modelData ? modelData.percentage : 0) * 100)
            property bool warned: false

            onLevelChanged: {
                if (!counted || !root.warn) return;
                if (level > root.lowThreshold) {
                    warned = false;
                } else if (!warned && level > 0) {
                    warned = true;
                    Quickshell.execDetached(["notify-send", "-a", "Serpantinum", "-i", "battery-caution",
                        I18n.t("btbat.low.title", "{name} battery low").replace("{name}", root.nameOf(modelData)),
                        I18n.t("btbat.low.body", "{level} % left").replace("{level}", level)]);
                }
            }
        }
    }
}

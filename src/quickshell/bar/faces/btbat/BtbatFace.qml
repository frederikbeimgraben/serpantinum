import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../bat"
import "../../../reusables"
import "../../../"

// Batteries of Bluetooth and other devices, see singletons/system/Btbat.qml.
// Each device is a battery pill with the same styles, fill and charge wave as
// the battery module, and an icon for its type: mouse, keyboard, headset,
// controller and others. The style settings are btbatStyle,
// btbatShowPercent and btbatShowIcon. A click opens the Bluetooth panel.
// Without a device the face has no size.
Item {
    id: root

    property var module: null
    property var widget: module

    readonly property var activeTarget: widget || module
    readonly property bool isPreview: activeTarget ? Boolean(activeTarget.isPreview) : false
    readonly property bool isVertical: (activeTarget && activeTarget.orientation === "vertical")
    readonly property var barWindow: activeTarget ? activeTarget.barWindow : null

    function s(val) {
        if (barWindow && typeof barWindow.cs === "function") return barWindow.cs(val);
        return val;
    }

    readonly property var items: isPreview
        ? [{ capacity: 64, charging: false, icon: 0xF02CB }]
        : Btbat.devices.map(d => ({ capacity: Math.round(d.percentage * 100), charging: d.state === UPowerDeviceState.Charging, icon: Btbat.iconFor(d.type) }))

    readonly property real spacing: s(4)
    property real targetLength: {
        if (module && !module.moduleActive) return 0;
        let sum = 0;
        let n = 0;
        for (let i = 0; i < pills.count; i++) {
            let it = pills.itemAt(i);
            if (it && it.targetLength > 0) {
                sum += it.targetLength;
                n++;
            }
        }
        return n > 0 ? sum + spacing * (n - 1) : 0;
    }
    property bool isFaceVisible: targetLength > 0

    implicitWidth: isVertical ? (parent ? parent.width : 0) : targetLength
    implicitHeight: isVertical ? targetLength : (parent ? parent.height : 0)

    AxisFlow {
        vertical: root.isVertical
        anchors.centerIn: parent
        spacing: root.spacing

        Repeater {
            id: pills
            model: root.items

            BatFace {
                required property var modelData
                module: root.module
                widget: root.widget
                settingPrefix: "btbat"
                source: ({
                    capacity: modelData.capacity,
                    charging: modelData.charging,
                    icon: String.fromCodePoint(modelData.icon),
                    chargingIcon: String.fromCodePoint(modelData.icon)
                })
                onActivated: ShellBus.send("toggle", "network", "bt")
            }
        }
    }
}

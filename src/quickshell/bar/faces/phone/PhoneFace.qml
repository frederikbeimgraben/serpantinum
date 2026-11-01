import QtQuick
import Quickshell
import "../bat"
import "../../../"

// Phone of Valent, the KDE Connect app, in the look of the battery module:
// the same styles, the same fill and the same wave while it charges. The face
// is the battery face with the first connected paired device as its source,
// see singletons/system/Phone.qml. The icon is a phone, with a bolt inside
// while the phone charges. The style settings are phoneStyle,
// phoneShowPercent and phoneShowIcon. A click opens the phone menu with the
// device actions. Without a connected phone the face has no size.
BatFace {
    id: phoneRoot

    settingPrefix: "phone"

    readonly property var device: isPreview ? ({ state: 3, battery: { percentage: 76, charging: false } }) : Phone.primary
    readonly property bool isConnected: device !== null && device !== undefined && (device.state & 1) !== 0

    hidden: !isConnected
    source: ({
        capacity: (isConnected && device.battery) ? device.battery.percentage : 0,
        charging: (isConnected && device.battery) ? device.battery.charging : false,
        icon: String.fromCodePoint(0xF011C),
        chargingIcon: String.fromCodePoint(0xF1397)
    })

    onActivated: item => {
        let target = item || phoneRoot;
        let pt = target.mapToItem(null, 0, 0);
        let scr = (barWindow && barWindow.screen) ? barWindow.screen : null;
        let isRightBar = barWindow ? barWindow.barPosition === "right" : false;
        let isBottomBar = barWindow ? barWindow.barPosition === "bottom" : false;
        let globX = isVertical ? (isRightBar ? pt.x : (pt.x + target.width)) : (pt.x + (target.width / 2));
        let globY = isVertical ? (pt.y + (target.height / 2)) : (isBottomBar ? pt.y : (pt.y + target.height));
        PhoneMenuController.toggle(scr, globX, globY, isVertical && isRightBar, !isVertical && isBottomBar, isVertical);
    }
}

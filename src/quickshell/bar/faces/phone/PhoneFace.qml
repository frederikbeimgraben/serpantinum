import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import "../../../reusables"
import "../../../"

// Phone of Valent, the KDE Connect app, as GSConnect shows it in the GNOME
// panel. The face shows the phone icon and the battery of the first
// connected paired device, see singletons/system/Phone.qml. A click opens the
// phone menu with the device actions. Without a paired device the face has
// no size. The face follows the build of the lid face: a button pill or text.
Item {
    id: root

    property var module: null
    property var widget: module

    property string orientation: (activeTarget && activeTarget.orientation !== undefined) ? activeTarget.orientation : "horizontal"
    readonly property bool isVertical: orientation === "vertical"

    readonly property var activeTarget: widget || module
    readonly property bool isCompact: activeTarget ? activeTarget.isCompact : false
    readonly property var barWindow: activeTarget ? activeTarget.barWindow : null
    readonly property bool isPreview: activeTarget ? Boolean(activeTarget.isPreview) : false
    readonly property bool isBottomBar: barWindow ? (barWindow.barPosition === "bottom") : false
    readonly property bool isRightBar: module && module.isRightBar !== undefined ? module.isRightBar : (barWindow ? (barWindow.barPosition === "right") : false)

    function s(val) {
        if (barWindow && typeof barWindow.s === "function") return barWindow.cs(val);
        if (activeTarget && typeof activeTarget.s === "function") return activeTarget.s(val);
        if (typeof Scaler !== "undefined" && typeof Scaler.s === "function") return Math.round(Scaler.s(val));
        return val;
    }

    property int configRevision: 0

    Connections {
        target: (typeof Config !== "undefined") ? Config : null
        function onSettingsLoaded() { root.configRevision++; }
        function onRawSettingsChanged() { root.configRevision++; }
    }

    function barSetting(key, fallback) {
        let dummy = configRevision;
        if (typeof Config !== "undefined" && Config.rawSettings && Config.rawSettings.bar) {
            let bs = Config.rawSettings.bar;
            if (bs[key] !== undefined) return bs[key];
        }
        return fallback;
    }

    property string phoneStyle: {
        if (widget && widget !== root && widget.phoneStyle !== undefined) return widget.phoneStyle;
        if (module && module.phoneStyle !== undefined) return module.phoneStyle;
        return barSetting("phoneStyle", "button");
    }

    property bool showIcon: {
        if (widget && widget !== root && widget.phoneShowIcon !== undefined) return widget.phoneShowIcon;
        if (module && module.phoneShowIcon !== undefined) return module.phoneShowIcon;
        return Boolean(barSetting("phoneShowIcon", true));
    }

    property bool showBattery: {
        if (widget && widget !== root && widget.phoneShowBattery !== undefined) return widget.phoneShowBattery;
        if (module && module.phoneShowBattery !== undefined) return module.phoneShowBattery;
        return Boolean(barSetting("phoneShowBattery", true));
    }

    property bool showLayout: (!barWindow || isPreview) ? true : ((!module || module.moduleActive) && barWindow.isStartupReady)

    readonly property var device: isPreview ? ({ name: "Phone", state: 3, battery: { percentage: 76, charging: false } }) : Phone.primary
    readonly property bool hasDevice: device !== null && device !== undefined
    readonly property bool isConnected: hasDevice && (device.state & 1) !== 0
    readonly property bool isActive: PhoneMenuController.isVisible
    readonly property string effectiveIcon: isConnected ? String.fromCodePoint(0xF011C) : String.fromCodePoint(0xF0950)
    readonly property string effectiveName: {
        if (!isConnected || !device.battery) return "";
        return (device.battery.charging ? String.fromCodePoint(0xF140B) : "") + device.battery.percentage + "%";
    }

    function toggle(item) {
        if (root.isPreview) return;
        let pt = item.mapToItem(null, 0, 0);
        let scr = (barWindow && barWindow.screen) ? barWindow.screen : null;
        let globX = root.isVertical ? (root.isRightBar ? pt.x : (pt.x + item.width)) : (pt.x + (item.width / 2));
        let globY = root.isVertical ? (pt.y + (item.height / 2)) : (root.isBottomBar ? pt.y : (pt.y + item.height));
        PhoneMenuController.toggle(scr, globX, globY, root.isVertical && root.isRightBar, !root.isVertical && root.isBottomBar, root.isVertical);
    }

    readonly property real pillLength: pillLoader.item ? (isVertical ? pillLoader.item.height : pillLoader.item.width) : 0
    readonly property real textLength: isVertical ? textLayout.implicitHeight : textLayout.implicitWidth

    property real targetLength: {
        if (module && !module.moduleActive) return 0;
        if (!root.hasDevice) return 0;
        if (root.phoneStyle === "text") {
            return (textLength > 0) ? (textLength + s(root.isCompact ? (isVertical ? 14 : 12) : 16)) : 0;
        }
        return (pillLength > 0) ? (pillLength + s(root.isCompact ? 8 : 10)) : 0;
    }

    function syncImplicitSize() {
        let cross = module ? module.thickness : (parent ? (isVertical ? parent.width : parent.height) : 0);
        implicitWidth = isVertical ? cross : targetLength;
        implicitHeight = isVertical ? targetLength : cross;
    }

    onTargetLengthChanged: syncImplicitSize()
    onIsVerticalChanged: syncImplicitSize()
    onModuleChanged: syncImplicitSize()
    onParentChanged: syncImplicitSize()

    Timer {
        running: true
        interval: 0
        onTriggered: root.syncImplicitSize()
    }

    MouseArea {
        id: textMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: root.phoneStyle === "text" && !root.isPreview
        onClicked: root.toggle(textMouseArea)
    }

    AxisFlow {
        id: textLayout
        vertical: root.isVertical
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        visible: root.phoneStyle === "text"
        anchors.centerIn: parent
        spacing: root.isVertical ? s(root.isCompact ? 2 : 3) : s(root.isCompact ? 5 : 6)
        opacity: root.showLayout ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

        Item {
            visible: root.showIcon
            width: root.isVertical ? textIcon.implicitWidth : s(root.isCompact ? 18 : 20)
            height: root.isVertical ? textIcon.implicitHeight : width

            Text {
                id: textIcon
                anchors.centerIn: parent
                text: root.effectiveIcon
                font.family: ThemeBackend.iconFont
                font.pixelSize: s(root.isCompact ? 14 : 15)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: textMouseArea.containsMouse ? Qt.lighter(ThemeBackend.peach, 1.15) : (root.isActive ? ThemeBackend.peach : ThemeBackend.subtext0)
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        Text {
            visible: root.showBattery
            text: root.effectiveName
            font.family: ThemeBackend.fontFamily
            font.pixelSize: root.isVertical ? s(root.isCompact ? 9 : 10) : s(root.isCompact ? 11 : 12)
            font.bold: true
            color: textMouseArea.containsMouse ? Qt.lighter(ThemeBackend.text, 1.15) : ThemeBackend.text
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    Loader {
        id: pillLoader
        visible: root.phoneStyle !== "text"
        anchors.centerIn: parent
        sourceComponent: root.isVertical ? sideButtonComponent : topButtonComponent
    }

    Component {
        id: topButtonComponent

        ClickButton {
            id: phonePill
            property bool initAnimTrigger: root.showLayout

            height: s(root.isCompact ? 28 : 30)
            maxWidth: s(root.isCompact ? 156 : 160)
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - s(2))
            horizontalPadding: s(root.isCompact ? 10 : 12)
            buttonIcon: root.showIcon ? root.effectiveIcon : ""
            iconFontSize: s(root.isCompact ? 14 : 15)
            buttonText: root.showBattery ? root.effectiveName : ""
            textFontSize: s(root.isCompact ? 11 : 12)
            accentColor: root.isActive ? (root.isCompact ? Qt.lighter(ThemeBackend.peach, 1.08) : ThemeBackend.peach) : (root.isCompact ? Qt.lighter(ThemeBackend.surface0, 1.18) : ThemeBackend.surface0)
            textColor: root.isActive ? ThemeBackend.base : (root.isCompact ? Qt.lighter(ThemeBackend.text, 1.05) : ThemeBackend.text)

            property real targetWidth: (root.showIcon || root.showBattery) ? implicitWidth : 0
            width: targetWidth
            Behavior on width { NumberAnimation { duration: 480; easing.type: Easing.OutQuint } }

            opacity: initAnimTrigger ? 1.0 : 0.0
            transform: Translate { y: phonePill.initAnimTrigger ? 0 : s(15); Behavior on y { NumberAnimation { duration: 620; easing.type: Easing.OutQuint } } }
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

            onClicked: root.toggle(phonePill)
        }
    }

    Component {
        id: sideButtonComponent

        ClickButton {
            id: sidePill
            width: s(root.isCompact ? 28 : 30)
            height: (root.showIcon || root.showBattery) ? s(root.isCompact ? 28 : 30) : 0
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - s(2))
            horizontalPadding: 0
            buttonIcon: root.showIcon ? root.effectiveIcon : ""
            iconFontSize: s(root.isCompact ? 14 : 15)
            buttonText: (!root.showIcon && root.showBattery) ? root.effectiveName.substring(0, 3) : ""
            textFontSize: s(root.isCompact ? 9 : 10)
            accentColor: root.isActive ? (root.isCompact ? Qt.lighter(ThemeBackend.peach, 1.08) : ThemeBackend.peach) : (root.isCompact ? Qt.lighter(ThemeBackend.surface0, 1.18) : ThemeBackend.surface0)
            textColor: root.isActive ? ThemeBackend.base : (root.isCompact ? Qt.lighter(ThemeBackend.text, 1.05) : ThemeBackend.text)
            onClicked: root.toggle(sidePill)
        }
    }
}

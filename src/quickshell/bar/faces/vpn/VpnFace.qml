import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import "../../../reusables"
import "../../../"

// A WireGuard connection of NetworkManager, see singletons/system/Vpn.qml.
// The pill is green while the connection is up and, when a check host is
// set, the host answers. It is red when the connection is up but the host
// does not answer, and plain while the connection is down. A click opens the
// vpn menu, which connects and disconnects. Without a WireGuard connection
// the face has no size. The face follows the build of the gatus face.
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

    property string vpnStyle: {
        if (widget && widget !== root && widget.vpnStyle !== undefined) return widget.vpnStyle;
        if (module && module.vpnStyle !== undefined) return module.vpnStyle;
        return barSetting("vpnStyle", "button");
    }

    property bool showIcon: {
        if (widget && widget !== root && widget.vpnShowIcon !== undefined) return widget.vpnShowIcon;
        if (module && module.vpnShowIcon !== undefined) return module.vpnShowIcon;
        return Boolean(barSetting("vpnShowIcon", true));
    }

    property bool showLabel: {
        if (widget && widget !== root && widget.vpnShowLabel !== undefined) return widget.vpnShowLabel;
        if (module && module.vpnShowLabel !== undefined) return module.vpnShowLabel;
        return Boolean(barSetting("vpnShowLabel", true));
    }

    property bool showLayout: (!barWindow || isPreview) ? true : ((!module || module.moduleActive) && barWindow.isStartupReady)

    readonly property bool hasDevice: isPreview || Vpn.available
    readonly property bool problem: !isPreview && Vpn.connected && Vpn.reachable === false
    readonly property bool isActive: isPreview || Vpn.connected
    readonly property color okColor: Qt.lighter(isVertical ? ThemeBackend.green : Qt.lighter(ThemeBackend.green, 1.15), 1.065)
    readonly property color statusColor: problem ? ThemeBackend.red : okColor
    readonly property string effectiveIcon: String.fromCodePoint(problem ? 0xF0ECC : (isActive ? 0xF0565 : 0xF099E))
    readonly property string effectiveName: isPreview ? "VPN" : (Vpn.current ? Vpn.current.name : "")

    function toggle(item) {
        if (root.isPreview) return;
        let pt = item.mapToItem(null, 0, 0);
        let scr = (barWindow && barWindow.screen) ? barWindow.screen : null;
        let globX = root.isVertical ? (root.isRightBar ? pt.x : (pt.x + item.width)) : (pt.x + (item.width / 2));
        let globY = root.isVertical ? (pt.y + (item.height / 2)) : (root.isBottomBar ? pt.y : (pt.y + item.height));
        VpnMenuController.toggle(scr, globX, globY, root.isVertical && root.isRightBar, !root.isVertical && root.isBottomBar, root.isVertical);
    }

    readonly property real pillLength: pillLoader.item ? (isVertical ? pillLoader.item.height : pillLoader.item.width) : 0
    readonly property real textLength: isVertical ? textLayout.implicitHeight : textLayout.implicitWidth

    property real targetLength: {
        if (module && !module.moduleActive) return 0;
        if (!root.hasDevice) return 0;
        if (root.vpnStyle === "text") {
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
        enabled: root.vpnStyle === "text" && !root.isPreview
        onClicked: root.toggle(textMouseArea)
    }

    AxisFlow {
        id: textLayout
        vertical: root.isVertical
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        visible: root.vpnStyle === "text"
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
                color: textMouseArea.containsMouse ? Qt.lighter(root.statusColor, 1.15) : (root.isActive ? root.statusColor : ThemeBackend.subtext0)
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        Text {
            visible: root.showLabel
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
        visible: root.vpnStyle !== "text"
        anchors.centerIn: parent
        sourceComponent: root.isVertical ? sideButtonComponent : topButtonComponent
    }

    Component {
        id: topButtonComponent

        ClickButton {
            id: vpnPill
            property bool initAnimTrigger: root.showLayout

            height: s(root.isCompact ? 28 : 30)
            maxWidth: s(root.isCompact ? 156 : 160)
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - s(2))
            horizontalPadding: s(root.isCompact ? 10 : 12)
            buttonIcon: root.showIcon ? root.effectiveIcon : ""
            iconFontSize: s(root.isCompact ? 14 : 15)
            buttonText: root.showLabel ? root.effectiveName : ""
            textFontSize: s(root.isCompact ? 11 : 12)
            accentColor: root.isActive ? (root.isCompact ? Qt.lighter(root.statusColor, 1.08) : root.statusColor) : (root.isCompact ? Qt.lighter(ThemeBackend.surface0, 1.18) : ThemeBackend.surface0)
            textColor: root.isActive ? ThemeBackend.base : (root.isCompact ? Qt.lighter(ThemeBackend.text, 1.05) : ThemeBackend.text)

            property real targetWidth: (root.showIcon || root.showLabel) ? implicitWidth : 0
            width: targetWidth
            // A pill that appears from width 0 takes its full width at once and
            // fades in. Grown from 0, it was narrower than high, so the corner
            // radius did not fit and it showed as a square first.
            Behavior on width {
                enabled: vpnPill.width > 1
                NumberAnimation { duration: 480; easing.type: Easing.OutQuint }
            }

            opacity: initAnimTrigger ? 1.0 : 0.0
            transform: Translate { y: vpnPill.initAnimTrigger ? 0 : s(15); Behavior on y { NumberAnimation { duration: 620; easing.type: Easing.OutQuint } } }
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

            onClicked: root.toggle(vpnPill)
        }
    }

    Component {
        id: sideButtonComponent

        ClickButton {
            id: sidePill
            width: s(root.isCompact ? 28 : 30)
            height: (root.showIcon || root.showLabel) ? s(root.isCompact ? 28 : 30) : 0
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - s(2))
            horizontalPadding: 0
            buttonIcon: root.showIcon ? root.effectiveIcon : ""
            iconFontSize: s(root.isCompact ? 14 : 15)
            buttonText: (!root.showIcon && root.showLabel) ? root.effectiveName.substring(0, 3) : ""
            textFontSize: s(root.isCompact ? 9 : 10)
            accentColor: root.isActive ? (root.isCompact ? Qt.lighter(root.statusColor, 1.08) : root.statusColor) : (root.isCompact ? Qt.lighter(ThemeBackend.surface0, 1.18) : ThemeBackend.surface0)
            textColor: root.isActive ? ThemeBackend.base : (root.isCompact ? Qt.lighter(ThemeBackend.text, 1.05) : ThemeBackend.text)
            onClicked: root.toggle(sidePill)
        }
    }
}

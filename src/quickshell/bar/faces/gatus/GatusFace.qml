import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import "../../../reusables"
import "../../../"

// The state of the Gatus status pages in gatus.urls, see
// singletons/system/Gatus.qml, which checks them every minute. The pill is
// green with a heartbeat icon when all endpoints are up. When an endpoint
// fails, it is red and shows the number of failing endpoints. When an
// instance does not answer, it is grey. A click
// opens the gatus menu with the instances and the failing endpoints. Without
// configured URLs the face has no size. The face follows the build of the
// phone face: a button pill or text.
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

    property string gatusStyle: {
        if (widget && widget !== root && widget.gatusStyle !== undefined) return widget.gatusStyle;
        if (module && module.gatusStyle !== undefined) return module.gatusStyle;
        return barSetting("gatusStyle", "button");
    }

    property bool showIcon: {
        if (widget && widget !== root && widget.gatusShowIcon !== undefined) return widget.gatusShowIcon;
        if (module && module.gatusShowIcon !== undefined) return module.gatusShowIcon;
        return Boolean(barSetting("gatusShowIcon", true));
    }

    property bool showCount: {
        if (widget && widget !== root && widget.gatusShowCount !== undefined) return widget.gatusShowCount;
        if (module && module.gatusShowCount !== undefined) return module.gatusShowCount;
        return Boolean(barSetting("gatusShowCount", true));
    }

    property bool showLayout: (!barWindow || isPreview) ? true : ((!module || module.moduleActive) && barWindow.isStartupReady)

    readonly property bool hasDevice: isPreview || Gatus.configured
    readonly property int failing: isPreview ? 0 : Gatus.failingCount
    readonly property bool hasProblem: failing > 0
    readonly property bool unreachable: !isPreview && Gatus.unreachableCount > 0
    // The pill shows the state in its color: green when every endpoint is up,
    // red when an endpoint fails, grey when an instance does not answer. Before
    // the first result it has the plain look of the other modules.
    readonly property bool isActive: isPreview || Gatus.loaded
    readonly property color statusColor: hasProblem ? ThemeBackend.red : (unreachable ? ThemeBackend.overlay1 : ThemeBackend.green)
    readonly property string effectiveIcon: String.fromCodePoint(hasProblem ? 0xF0028 : (unreachable ? 0xF0319 : 0xF05F6))
    readonly property string effectiveName: hasProblem ? String(failing) : ""

    function toggle(item) {
        if (root.isPreview) return;
        let pt = item.mapToItem(null, 0, 0);
        let scr = (barWindow && barWindow.screen) ? barWindow.screen : null;
        let globX = root.isVertical ? (root.isRightBar ? pt.x : (pt.x + item.width)) : (pt.x + (item.width / 2));
        let globY = root.isVertical ? (pt.y + (item.height / 2)) : (root.isBottomBar ? pt.y : (pt.y + item.height));
        GatusMenuController.toggle(scr, globX, globY, root.isVertical && root.isRightBar, !root.isVertical && root.isBottomBar, root.isVertical);
    }

    readonly property real pillLength: pillLoader.item ? (isVertical ? pillLoader.item.height : pillLoader.item.width) : 0
    readonly property real textLength: isVertical ? textLayout.implicitHeight : textLayout.implicitWidth

    property real targetLength: {
        if (module && !module.moduleActive) return 0;
        if (!root.hasDevice) return 0;
        if (root.gatusStyle === "text") {
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
        enabled: root.gatusStyle === "text" && !root.isPreview
        onClicked: root.toggle(textMouseArea)
    }

    AxisFlow {
        id: textLayout
        vertical: root.isVertical
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        visible: root.gatusStyle === "text"
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
            visible: root.showCount
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
        visible: root.gatusStyle !== "text"
        anchors.centerIn: parent
        sourceComponent: root.isVertical ? sideButtonComponent : topButtonComponent
    }

    Component {
        id: topButtonComponent

        ClickButton {
            id: gatusPill
            property bool initAnimTrigger: root.showLayout

            height: s(root.isCompact ? 28 : 30)
            maxWidth: s(root.isCompact ? 156 : 160)
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - s(2))
            horizontalPadding: s(root.isCompact ? 10 : 12)
            buttonIcon: root.showIcon ? root.effectiveIcon : ""
            iconFontSize: s(root.isCompact ? 14 : 15)
            buttonText: root.showCount ? root.effectiveName : ""
            textFontSize: s(root.isCompact ? 11 : 12)
            accentColor: root.isActive ? (root.isCompact ? Qt.lighter(root.statusColor, 1.08) : root.statusColor) : (root.isCompact ? Qt.lighter(ThemeBackend.surface0, 1.18) : ThemeBackend.surface0)
            textColor: root.isActive ? ThemeBackend.base : (root.isCompact ? Qt.lighter(ThemeBackend.text, 1.05) : ThemeBackend.text)

            property real targetWidth: (root.showIcon || root.showCount) ? implicitWidth : 0
            width: targetWidth
            Behavior on width { NumberAnimation { duration: 480; easing.type: Easing.OutQuint } }

            opacity: initAnimTrigger ? 1.0 : 0.0
            transform: Translate { y: gatusPill.initAnimTrigger ? 0 : s(15); Behavior on y { NumberAnimation { duration: 620; easing.type: Easing.OutQuint } } }
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

            onClicked: root.toggle(gatusPill)
        }
    }

    Component {
        id: sideButtonComponent

        ClickButton {
            id: sidePill
            width: s(root.isCompact ? 28 : 30)
            height: (root.showIcon || root.showCount) ? s(root.isCompact ? 28 : 30) : 0
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - s(2))
            horizontalPadding: 0
            buttonIcon: root.showIcon ? root.effectiveIcon : ""
            iconFontSize: s(root.isCompact ? 14 : 15)
            buttonText: (!root.showIcon && root.showCount) ? root.effectiveName.substring(0, 3) : ""
            textFontSize: s(root.isCompact ? 9 : 10)
            accentColor: root.isActive ? (root.isCompact ? Qt.lighter(root.statusColor, 1.08) : root.statusColor) : (root.isCompact ? Qt.lighter(ThemeBackend.surface0, 1.18) : ThemeBackend.surface0)
            textColor: root.isActive ? ThemeBackend.base : (root.isCompact ? Qt.lighter(ThemeBackend.text, 1.05) : ThemeBackend.text)
            onClicked: root.toggle(sidePill)
        }
    }
}

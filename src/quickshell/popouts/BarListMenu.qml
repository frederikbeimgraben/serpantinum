import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../reusables"
import "../"

// A list menu that a bar module opens, in the look of the tray menu, see
// TrayBase.qml. The module gives the rows and a controller singleton with
// isVisible, screen, targetX, targetY, alignRight, alignBottom, isSideBar and
// hide(). A row is an object with `kind` and display fields:
//   header: icon, text and status, in bold. `accent` colors the icon.
//   item:   icon, text and status. `enabled` false greys it out. A click
//           sends `activated(row)` and closes the menu.
//   empty:  icon and text, greyed out, without a click.
//   sep:    a separator line.
// `icon` is a code point of the icon font. The menu closes on Esc, after a
// click on an item, and a short time after the pointer leaves it.
PanelWindow {
    id: menuWindow

    screen: menuWindow.controller ? menuWindow.controller.screen : null

    WlrLayershell.namespace: menuWindow.layerNamespace
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: menuWindow.isVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        enabled: menuWindow.isVisible
        onActivated: menuWindow.controller.hide()
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    mask: Region {
        item: (menuWindow.isVisible || menuContainer.animProgress > 0.001) ? menuContainer : null
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function s(val) { return (typeof Scaler !== "undefined") ? Scaler.s(val) : val; }
    function glyph(code) { return code ? String.fromCodePoint(code) : ""; }

    required property var controller
    property string layerNamespace: "barmenu"
    property var rows: []
    signal activated(var row)

    property bool isVisible: menuWindow.controller.isVisible
    property real targetX: menuWindow.controller.targetX
    property real targetY: menuWindow.controller.targetY
    property bool alignRight: menuWindow.controller.alignRight
    property bool alignBottom: menuWindow.controller.alignBottom
    property bool isSideBar: menuWindow.controller.isSideBar

    property int configRevision: 0

    Connections {
        target: (typeof Config !== "undefined") ? Config : null
        function onSettingsLoaded() {
            menuWindow.controller.hide();
            menuWindow.configRevision++;
        }
    }

    property string barStyle: {
        let dummy = configRevision;
        if (typeof Config === "undefined" || !Config.rawSettings || !Config.rawSettings.bar) return "modular";
        let st = Config.rawSettings.bar.style;
        if (typeof st === "string") return st;
        if (st && typeof st === "object") {
            if (st.fill || st.mode === "fill") return "fill";
            if (st.solid || st.mode === "solid") return "solid";
        }
        return "modular";
    }

    onBarStyleChanged: menuWindow.controller.hide()

    property bool isSolid: barStyle === "solid" || barStyle === "fill"

    property real barHeight: {
        let dummy = configRevision;
        return (typeof Config !== "undefined" && Config.rawSettings && Config.rawSettings.bar && Config.rawSettings.bar.height) ? s(Config.rawSettings.bar.height) : s(40);
    }

    property real cornerRadius: {
        let dummy = configRevision;
        let raw = (typeof ThemeBackend !== "undefined" && ThemeBackend.borderRadius !== undefined && ThemeBackend.borderRadius !== null)
            ? ThemeBackend.borderRadius
            : s(12);
        let threshold = s(32);
        let maxLimit = s(44);
        if (raw <= threshold) return Math.max(0, raw);
        let excess = raw - threshold;
        let range = maxLimit - threshold;
        return threshold + range * (1.0 - Math.exp(-excess / range));
    }

    property real menuMargin: isSolid ? 0 : s(20)

    visible: isVisible || menuContainer.animProgress > 0.001

    function run(row) {
        if (!row || !row.enabled) return;
        menuWindow.activated(row);
        menuWindow.controller.hide();
    }

    property real menuWidth: s(240)
    property real itemHeight: s(32)
    property real headerHeight: s(40)
    property real sepHeight: s(9)

    function rowHeight(row) {
        if (row.kind === "header") return headerHeight;
        if (row.kind === "sep") return sepHeight;
        return itemHeight;
    }

    property real menuHeight: {
        let h = s(16);
        for (let i = 0; i < rows.length; i++) h += rowHeight(rows[i]);
        return Math.max(s(40), h);
    }

    property real clampedX: {
        let w = menuWidth;
        let x = 0;
        if (isSideBar) {
            if (alignRight) {
                let barEdge = (targetX > menuWindow.width / 2) ? targetX : (menuWindow.width - barHeight);
                x = isSolid ? (menuWindow.width - barHeight - w) : (barEdge - w - menuMargin);
            } else {
                let barEdge = (targetX > 0 && targetX < menuWindow.width / 2) ? targetX : barHeight;
                x = isSolid ? barHeight : (barEdge + menuMargin);
            }
        } else {
            x = targetX - (w / 2);
        }
        let edgeBound = (isSolid && !isSideBar) ? (cornerRadius + s(4)) : s(8);
        return Math.max(edgeBound, Math.min(menuWindow.width - w - edgeBound, x));
    }

    property real clampedY: {
        let h = menuHeight;
        let y = 0;
        if (isSideBar) {
            y = targetY - (h / 2);
        } else if (alignBottom) {
            let barEdge = (targetY > menuWindow.height / 2) ? targetY : (menuWindow.height - barHeight);
            y = isSolid ? (menuWindow.height - barHeight - h) : (barEdge - h - menuMargin);
        } else {
            let barEdge = (targetY > 0 && targetY < menuWindow.height / 2) ? targetY : barHeight;
            y = isSolid ? barHeight : (barEdge + menuMargin);
        }
        let edgeBound = (isSolid && isSideBar) ? (cornerRadius + s(4)) : s(8);
        return Math.max(edgeBound, Math.min(menuWindow.height - h - edgeBound, y));
    }

    Timer {
        id: autoCloseTimer
        interval: 2400
        onTriggered: {
            if (!menuHover.hovered) menuWindow.controller.hide();
        }
    }

    onIsVisibleChanged: {
        if (isVisible) {
            autoCloseTimer.interval = 2400;
            autoCloseTimer.restart();
        } else {
            autoCloseTimer.stop();
        }
    }

    Item {
        id: rootContainer
        anchors.fill: parent

        Item {
            id: menuContainer

            property real animProgress: menuWindow.isVisible ? 1.0 : 0.0
            Behavior on animProgress {
                NumberAnimation {
                    duration: menuWindow.isVisible ? 280 : 220
                    easing.type: Easing.OutCubic
                }
            }

            property real dynamicCornerRadius: menuWindow.isSolid ? Math.max(0, Math.min(menuWindow.cornerRadius, (menuWindow.isSideBar ? width : height))) : 0

            x: {
                if (menuWindow.isSolid) {
                    if (menuWindow.isSideBar && menuWindow.alignRight) {
                        return menuWindow.clampedX + (menuWindow.menuWidth - width);
                    }
                    return menuWindow.clampedX;
                }
                let slideOffset = menuWindow.s(16) * (1.0 - animProgress);
                if (menuWindow.isSideBar) {
                    return menuWindow.alignRight ? (menuWindow.clampedX + slideOffset) : (menuWindow.clampedX - slideOffset);
                }
                return menuWindow.clampedX;
            }

            y: {
                if (menuWindow.isSolid) {
                    if (!menuWindow.isSideBar && menuWindow.alignBottom) {
                        return menuWindow.clampedY + (menuWindow.menuHeight - height);
                    }
                    return menuWindow.clampedY;
                }
                let slideOffset = menuWindow.s(16) * (1.0 - animProgress);
                if (!menuWindow.isSideBar) {
                    return menuWindow.alignBottom ? (menuWindow.clampedY + slideOffset) : (menuWindow.clampedY - slideOffset);
                }
                return menuWindow.clampedY;
            }

            width: (menuWindow.isSolid && menuWindow.isSideBar) ? menuWindow.menuWidth * animProgress : menuWindow.menuWidth
            height: (menuWindow.isSolid && !menuWindow.isSideBar) ? menuWindow.menuHeight * animProgress : menuWindow.menuHeight

            opacity: animProgress
            scale: !menuWindow.isSolid ? (0.92 + (0.08 * animProgress)) : 1.0

            transformOrigin: {
                if (menuWindow.isSideBar) return menuWindow.alignRight ? Item.Right : Item.Left;
                return menuWindow.alignBottom ? Item.Bottom : Item.Top;
            }

            GlassFillets {
                id: rootFillets
                card: menuBox
                filletRadius: (menuWindow.isSolid && menuContainer.dynamicCornerRadius > 0.5) ? menuContainer.dynamicCornerRadius : 0
                filletDir: menuWindow.isSideBar
                    ? (menuWindow.alignRight ? Qt.vector2d(1, 0) : Qt.vector2d(-1, 0))
                    : (menuWindow.alignBottom ? Qt.vector2d(0, 1) : Qt.vector2d(0, -1))
            }

            ShaderEffect {
                visible: menuWindow.isSolid && menuContainer.dynamicCornerRadius > 0.5
                x: menuWindow.isSideBar ? (menuWindow.alignRight ? (parent.width - menuContainer.dynamicCornerRadius) : 0) : -menuContainer.dynamicCornerRadius
                y: menuWindow.isSideBar ? -menuContainer.dynamicCornerRadius : (menuWindow.alignBottom ? (parent.height - menuContainer.dynamicCornerRadius) : 0)
                width: menuContainer.dynamicCornerRadius
                height: menuContainer.dynamicCornerRadius
                property vector2d itemSize: Qt.vector2d(width, height)
                property real cornerIndex: menuWindow.isSideBar ? (menuWindow.alignRight ? 3.0 : 2.0) : (menuWindow.alignBottom ? 3.0 : 1.0)
                property color color: Qt.alpha(ThemeBackend.base, ThemeBackend.elementOpacity)
                fragmentShader: "file://" + Caching.serpantinumDir + "/assets/shaders/ui/corner_cutout.frag.qsb"
            }

            ShaderEffect {
                visible: menuWindow.isSolid && menuContainer.dynamicCornerRadius > 0.5
                x: menuWindow.isSideBar ? (menuWindow.alignRight ? (parent.width - menuContainer.dynamicCornerRadius) : 0) : parent.width
                y: menuWindow.isSideBar ? parent.height : (menuWindow.alignBottom ? (parent.height - menuContainer.dynamicCornerRadius) : 0)
                width: menuContainer.dynamicCornerRadius
                height: menuContainer.dynamicCornerRadius
                property vector2d itemSize: Qt.vector2d(width, height)
                property real cornerIndex: menuWindow.isSideBar ? (menuWindow.alignRight ? 1.0 : 0.0) : (menuWindow.alignBottom ? 2.0 : 0.0)
                property color color: Qt.alpha(ThemeBackend.base, ThemeBackend.elementOpacity)
                fragmentShader: "file://" + Caching.serpantinumDir + "/assets/shaders/ui/corner_cutout.frag.qsb"
            }

            Rectangle {
                id: menuBox
                anchors.fill: parent
                color: Qt.alpha(ThemeBackend.base, ThemeBackend.elementOpacity)
                radius: menuWindow.cornerRadius
                readonly property bool flatCorners: menuWindow.isSolid
                topLeftRadius: (flatCorners && (menuWindow.isSideBar ? !menuWindow.alignRight : !menuWindow.alignBottom)) ? 0 : menuWindow.cornerRadius
                topRightRadius: (flatCorners && (menuWindow.isSideBar ? menuWindow.alignRight : !menuWindow.alignBottom)) ? 0 : menuWindow.cornerRadius
                bottomLeftRadius: (flatCorners && (menuWindow.isSideBar ? !menuWindow.alignRight : menuWindow.alignBottom)) ? 0 : menuWindow.cornerRadius
                bottomRightRadius: (flatCorners && (menuWindow.isSideBar ? menuWindow.alignRight : menuWindow.alignBottom)) ? 0 : menuWindow.cornerRadius
                clip: true

                WallpaperBlur {
                    z: -1
                    anchors.fill: parent
                    topLeftRadius: parent.topLeftRadius
                    topRightRadius: parent.topRightRadius
                    bottomLeftRadius: parent.bottomLeftRadius
                    bottomRightRadius: parent.bottomRightRadius
                    filletRadius: rootFillets.filletRadius
                    filletDir: rootFillets.filletDir
                }

                HoverHandler {
                    id: menuHover
                    onHoveredChanged: {
                        if (hovered) {
                            autoCloseTimer.stop();
                        } else if (menuWindow.isVisible) {
                            autoCloseTimer.interval = 800;
                            autoCloseTimer.restart();
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                }

                Item {
                    anchors.fill: parent
                    anchors.margins: menuWindow.s(8)

                    GlassLens {
                        id: hoverLens
                        z: -1
                        targetX: menuList.hoverItem ? menuList.hoverItem.x : 0
                        targetY: menuList.hoverItem ? menuList.hoverItem.y : 0
                        targetWidth: menuList.hoverItem ? menuList.hoverItem.width : 0
                        targetHeight: menuList.hoverItem ? menuList.hoverItem.height : 0
                        radius: menuWindow.s(4)
                        tintColor: ThemeBackend.surface0
                        tintAmount: 0.3
                        shadow: 0
                        restPress: 0.2
                        magnify: menuWindow.s(3)
                        press: menuList.hoverItem && menuList.hoverItem.pressed ? 0.8 : 0
                    }

                    Column {
                        id: menuList
                        width: parent.width
                        property Item hoverItem: null

                        Repeater {
                            model: menuWindow.rows

                            delegate: Item {
                                id: rowItem
                                width: menuList.width
                                height: menuWindow.rowHeight(modelData)
                                readonly property bool isHeader: modelData.kind === "header"
                                readonly property bool isSep: modelData.kind === "sep"
                                readonly property bool clickable: modelData.kind === "item" && modelData.enabled === true
                                readonly property bool pressed: rowMouse.pressed
                                readonly property bool lensWanted: clickable && rowMouse.containsMouse

                                onLensWantedChanged: {
                                    if (lensWanted) menuList.hoverItem = rowItem;
                                    else if (menuList.hoverItem === rowItem) menuList.hoverItem = null;
                                }
                                Component.onDestruction: {
                                    if (menuList.hoverItem === rowItem) menuList.hoverItem = null;
                                }

                                Rectangle {
                                    width: parent.width - menuWindow.s(16)
                                    height: 1
                                    color: ThemeBackend.surface0
                                    anchors.centerIn: parent
                                    visible: rowItem.isSep
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    visible: !rowItem.isSep
                                    radius: menuWindow.s(4)
                                    color: (hoverGlass.active || hoverLens.glassActive) ? "transparent" : (rowItem.lensWanted ? ThemeBackend.surface0 : "transparent")
                                    opacity: (rowItem.isHeader || (modelData.kind === "item" && modelData.enabled)) ? 1.0 : 0.4

                                    GlassFill {
                                        id: hoverGlass
                                        anchors.fill: parent
                                        radius: parent.radius
                                        allowed: rowItem.lensWanted && !hoverLens.glassActive
                                        tintColor: ThemeBackend.surface0
                                        tintAmount: 0.3
                                        press: rowMouse.pressed ? 0.8 : 0.2
                                    }

                                    Text {
                                        id: rowIcon
                                        anchors.left: parent.left
                                        anchors.leftMargin: menuWindow.s(8)
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: menuWindow.s(18)
                                        horizontalAlignment: Text.AlignHCenter
                                        text: menuWindow.glyph(modelData.icon)
                                        color: modelData.accent ? (modelData.accentColor || ThemeBackend.peach) : ThemeBackend.text
                                        font.family: ThemeBackend.iconFont
                                        font.pixelSize: menuWindow.s(rowItem.isHeader ? 17 : 15)
                                    }

                                    Text {
                                        anchors.left: rowIcon.right
                                        anchors.leftMargin: menuWindow.s(8)
                                        anchors.right: statusText.visible ? statusText.left : parent.right
                                        anchors.rightMargin: menuWindow.s(8)
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.text || ""
                                        color: ThemeBackend.text
                                        font.family: ThemeBackend.fontFamily
                                        font.pixelSize: menuWindow.s(13)
                                        font.bold: rowItem.isHeader
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Text {
                                        id: statusText
                                        anchors.right: parent.right
                                        anchors.rightMargin: menuWindow.s(8)
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: text !== ""
                                        text: (rowItem.isSep ? "" : modelData.status) || ""
                                        color: ThemeBackend.subtext0
                                        font.family: ThemeBackend.fontFamily
                                        font.pixelSize: menuWindow.s(12)
                                    }

                                    MouseArea {
                                        id: rowMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled: rowItem.clickable
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: menuWindow.run(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../reusables"
import "../"

// The menu of the phone module of the bar, as GSConnect shows it in GNOME.
// Each paired device of Valent gets a header with its battery and a row of
// actions. The actions are disabled while the device is not connected. The
// share dialog and the messages window of Valent are below the devices.
//
// The position, size and glass look follow the tray menu, see TrayBase.qml.
// The menu closes on Esc, after a click on an action, and a short time after
// the pointer leaves it.
PanelWindow {
    id: phoneMenuWindow

    screen: PhoneMenuController.screen

    WlrLayershell.namespace: "phonemenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: phoneMenuWindow.isVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        enabled: phoneMenuWindow.isVisible
        onActivated: PhoneMenuController.hide()
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    mask: Region {
        item: (phoneMenuWindow.isVisible || menuContainer.animProgress > 0.001) ? menuContainer : null
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function s(val) { return (typeof Scaler !== "undefined") ? Scaler.s(val) : val; }
    function glyph(code) { return code ? String.fromCodePoint(code) : ""; }

    property bool isVisible: PhoneMenuController.isVisible
    property real targetX: PhoneMenuController.targetX
    property real targetY: PhoneMenuController.targetY
    property bool alignRight: PhoneMenuController.alignRight
    property bool alignBottom: PhoneMenuController.alignBottom
    property bool isSideBar: PhoneMenuController.isSideBar

    property int configRevision: 0

    Connections {
        target: (typeof Config !== "undefined") ? Config : null
        function onSettingsLoaded() {
            PhoneMenuController.hide();
            phoneMenuWindow.configRevision++;
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

    onBarStyleChanged: PhoneMenuController.hide()

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

    readonly property var deviceActions: [
        { action: "findmyphone.ring", icon: 0xF009E, key: "phone.menu.ring", text: "Ring" },
        { action: "ping.ping", icon: 0xF048A, key: "phone.menu.ping", text: "Ping" },
        { action: "clipboard.push", icon: 0xF0C57, key: "phone.menu.clipboard_push", text: "Send clipboard" },
        { action: "clipboard.pull", icon: 0xF014A, key: "phone.menu.clipboard_pull", text: "Get clipboard" },
        { action: "sftp.browse", icon: 0xF0870, key: "phone.menu.browse", text: "Browse files" }
    ]

    property var rows: {
        let out = [];
        let list = Phone.paired;
        for (let i = 0; i < list.length; i++) {
            let d = list[i];
            let on = Phone.isConnected(d);
            if (i > 0) out.push({ kind: "sep" });
            out.push({ kind: "header", dev: d, connected: on });
            for (let j = 0; j < deviceActions.length; j++) {
                let a = deviceActions[j];
                out.push({ kind: "device", dev: d, action: a.action, icon: a.icon,
                    text: I18n.t(a.key, a.text), enabled: on && Phone.hasAction(d, a.action) });
            }
            out.push({ kind: "settings", dev: d, icon: 0xF0493,
                text: I18n.t("phone.menu.settings", "Device settings"), enabled: true });
        }
        if (list.length === 0) {
            out.push({ kind: "empty", icon: 0xF0950,
                text: I18n.t("phone.menu.none", "No paired device"), enabled: false });
            out.push({ kind: "app", action: "window", icon: 0xF011C,
                text: I18n.t("phone.menu.open", "Open Valent"), enabled: true });
            return out;
        }
        out.push({ kind: "sep" });
        out.push({ kind: "app", action: "share-dialog", icon: 0xF022A,
            text: I18n.t("phone.menu.share", "Send files…"), enabled: Phone.primary !== null && Phone.isConnected(Phone.primary) });
        out.push({ kind: "app", action: "messages-window", icon: 0xF0369,
            text: I18n.t("phone.menu.messages", "Messages"), enabled: true });
        return out;
    }

    function run(row) {
        if (!row || !row.enabled) return;
        if (row.kind === "device") Phone.deviceAction(row.dev, row.action);
        else if (row.kind === "settings") Phone.openWindow(row.dev);
        else if (row.kind === "app" && row.action === "window") Phone.openWindow(null);
        else if (row.kind === "app") Phone.appAction(row.action);
        PhoneMenuController.hide();
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
                let barEdge = (targetX > phoneMenuWindow.width / 2) ? targetX : (phoneMenuWindow.width - barHeight);
                x = isSolid ? (phoneMenuWindow.width - barHeight - w) : (barEdge - w - menuMargin);
            } else {
                let barEdge = (targetX > 0 && targetX < phoneMenuWindow.width / 2) ? targetX : barHeight;
                x = isSolid ? barHeight : (barEdge + menuMargin);
            }
        } else {
            x = targetX - (w / 2);
        }
        let edgeBound = (isSolid && !isSideBar) ? (cornerRadius + s(4)) : s(8);
        return Math.max(edgeBound, Math.min(phoneMenuWindow.width - w - edgeBound, x));
    }

    property real clampedY: {
        let h = menuHeight;
        let y = 0;
        if (isSideBar) {
            y = targetY - (h / 2);
        } else if (alignBottom) {
            let barEdge = (targetY > phoneMenuWindow.height / 2) ? targetY : (phoneMenuWindow.height - barHeight);
            y = isSolid ? (phoneMenuWindow.height - barHeight - h) : (barEdge - h - menuMargin);
        } else {
            let barEdge = (targetY > 0 && targetY < phoneMenuWindow.height / 2) ? targetY : barHeight;
            y = isSolid ? barHeight : (barEdge + menuMargin);
        }
        let edgeBound = (isSolid && isSideBar) ? (cornerRadius + s(4)) : s(8);
        return Math.max(edgeBound, Math.min(phoneMenuWindow.height - h - edgeBound, y));
    }

    Timer {
        id: autoCloseTimer
        interval: 2400
        onTriggered: {
            if (!menuHover.hovered) PhoneMenuController.hide();
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

            property real animProgress: phoneMenuWindow.isVisible ? 1.0 : 0.0
            Behavior on animProgress {
                NumberAnimation {
                    duration: phoneMenuWindow.isVisible ? 280 : 220
                    easing.type: Easing.OutCubic
                }
            }

            property real dynamicCornerRadius: phoneMenuWindow.isSolid ? Math.max(0, Math.min(phoneMenuWindow.cornerRadius, (phoneMenuWindow.isSideBar ? width : height))) : 0

            x: {
                if (phoneMenuWindow.isSolid) {
                    if (phoneMenuWindow.isSideBar && phoneMenuWindow.alignRight) {
                        return phoneMenuWindow.clampedX + (phoneMenuWindow.menuWidth - width);
                    }
                    return phoneMenuWindow.clampedX;
                }
                let slideOffset = phoneMenuWindow.s(16) * (1.0 - animProgress);
                if (phoneMenuWindow.isSideBar) {
                    return phoneMenuWindow.alignRight ? (phoneMenuWindow.clampedX + slideOffset) : (phoneMenuWindow.clampedX - slideOffset);
                }
                return phoneMenuWindow.clampedX;
            }

            y: {
                if (phoneMenuWindow.isSolid) {
                    if (!phoneMenuWindow.isSideBar && phoneMenuWindow.alignBottom) {
                        return phoneMenuWindow.clampedY + (phoneMenuWindow.menuHeight - height);
                    }
                    return phoneMenuWindow.clampedY;
                }
                let slideOffset = phoneMenuWindow.s(16) * (1.0 - animProgress);
                if (!phoneMenuWindow.isSideBar) {
                    return phoneMenuWindow.alignBottom ? (phoneMenuWindow.clampedY + slideOffset) : (phoneMenuWindow.clampedY - slideOffset);
                }
                return phoneMenuWindow.clampedY;
            }

            width: (phoneMenuWindow.isSolid && phoneMenuWindow.isSideBar) ? phoneMenuWindow.menuWidth * animProgress : phoneMenuWindow.menuWidth
            height: (phoneMenuWindow.isSolid && !phoneMenuWindow.isSideBar) ? phoneMenuWindow.menuHeight * animProgress : phoneMenuWindow.menuHeight

            opacity: animProgress
            scale: !phoneMenuWindow.isSolid ? (0.92 + (0.08 * animProgress)) : 1.0

            transformOrigin: {
                if (phoneMenuWindow.isSideBar) return phoneMenuWindow.alignRight ? Item.Right : Item.Left;
                return phoneMenuWindow.alignBottom ? Item.Bottom : Item.Top;
            }

            GlassFillets {
                id: rootFillets
                card: menuBox
                filletRadius: (phoneMenuWindow.isSolid && menuContainer.dynamicCornerRadius > 0.5) ? menuContainer.dynamicCornerRadius : 0
                filletDir: phoneMenuWindow.isSideBar
                    ? (phoneMenuWindow.alignRight ? Qt.vector2d(1, 0) : Qt.vector2d(-1, 0))
                    : (phoneMenuWindow.alignBottom ? Qt.vector2d(0, 1) : Qt.vector2d(0, -1))
            }

            ShaderEffect {
                visible: phoneMenuWindow.isSolid && menuContainer.dynamicCornerRadius > 0.5
                x: phoneMenuWindow.isSideBar ? (phoneMenuWindow.alignRight ? (parent.width - menuContainer.dynamicCornerRadius) : 0) : -menuContainer.dynamicCornerRadius
                y: phoneMenuWindow.isSideBar ? -menuContainer.dynamicCornerRadius : (phoneMenuWindow.alignBottom ? (parent.height - menuContainer.dynamicCornerRadius) : 0)
                width: menuContainer.dynamicCornerRadius
                height: menuContainer.dynamicCornerRadius
                property vector2d itemSize: Qt.vector2d(width, height)
                property real cornerIndex: phoneMenuWindow.isSideBar ? (phoneMenuWindow.alignRight ? 3.0 : 2.0) : (phoneMenuWindow.alignBottom ? 3.0 : 1.0)
                property color color: Qt.alpha(ThemeBackend.base, ThemeBackend.elementOpacity)
                fragmentShader: "file://" + Caching.serpantinumDir + "/assets/shaders/ui/corner_cutout.frag.qsb"
            }

            ShaderEffect {
                visible: phoneMenuWindow.isSolid && menuContainer.dynamicCornerRadius > 0.5
                x: phoneMenuWindow.isSideBar ? (phoneMenuWindow.alignRight ? (parent.width - menuContainer.dynamicCornerRadius) : 0) : parent.width
                y: phoneMenuWindow.isSideBar ? parent.height : (phoneMenuWindow.alignBottom ? (parent.height - menuContainer.dynamicCornerRadius) : 0)
                width: menuContainer.dynamicCornerRadius
                height: menuContainer.dynamicCornerRadius
                property vector2d itemSize: Qt.vector2d(width, height)
                property real cornerIndex: phoneMenuWindow.isSideBar ? (phoneMenuWindow.alignRight ? 1.0 : 0.0) : (phoneMenuWindow.alignBottom ? 2.0 : 0.0)
                property color color: Qt.alpha(ThemeBackend.base, ThemeBackend.elementOpacity)
                fragmentShader: "file://" + Caching.serpantinumDir + "/assets/shaders/ui/corner_cutout.frag.qsb"
            }

            Rectangle {
                id: menuBox
                anchors.fill: parent
                color: Qt.alpha(ThemeBackend.base, ThemeBackend.elementOpacity)
                radius: phoneMenuWindow.cornerRadius
                readonly property bool flatCorners: phoneMenuWindow.isSolid
                topLeftRadius: (flatCorners && (phoneMenuWindow.isSideBar ? !phoneMenuWindow.alignRight : !phoneMenuWindow.alignBottom)) ? 0 : phoneMenuWindow.cornerRadius
                topRightRadius: (flatCorners && (phoneMenuWindow.isSideBar ? phoneMenuWindow.alignRight : !phoneMenuWindow.alignBottom)) ? 0 : phoneMenuWindow.cornerRadius
                bottomLeftRadius: (flatCorners && (phoneMenuWindow.isSideBar ? !phoneMenuWindow.alignRight : phoneMenuWindow.alignBottom)) ? 0 : phoneMenuWindow.cornerRadius
                bottomRightRadius: (flatCorners && (phoneMenuWindow.isSideBar ? phoneMenuWindow.alignRight : phoneMenuWindow.alignBottom)) ? 0 : phoneMenuWindow.cornerRadius
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
                        } else if (phoneMenuWindow.isVisible) {
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
                    anchors.margins: phoneMenuWindow.s(8)

                    GlassLens {
                        id: hoverLens
                        z: -1
                        targetX: menuList.hoverItem ? menuList.hoverItem.x : 0
                        targetY: menuList.hoverItem ? menuList.hoverItem.y : 0
                        targetWidth: menuList.hoverItem ? menuList.hoverItem.width : 0
                        targetHeight: menuList.hoverItem ? menuList.hoverItem.height : 0
                        radius: phoneMenuWindow.s(4)
                        tintColor: ThemeBackend.surface0
                        tintAmount: 0.3
                        shadow: 0
                        restPress: 0.2
                        magnify: phoneMenuWindow.s(3)
                        press: menuList.hoverItem && menuList.hoverItem.pressed ? 0.8 : 0
                    }

                    Column {
                        id: menuList
                        width: parent.width
                        property Item hoverItem: null

                        Repeater {
                            model: phoneMenuWindow.rows

                            delegate: Item {
                                id: rowItem
                                width: menuList.width
                                height: phoneMenuWindow.rowHeight(modelData)
                                readonly property bool isHeader: modelData.kind === "header"
                                readonly property bool isSep: modelData.kind === "sep"
                                readonly property bool clickable: !isHeader && !isSep && modelData.enabled
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
                                    width: parent.width - phoneMenuWindow.s(16)
                                    height: 1
                                    color: ThemeBackend.surface0
                                    anchors.centerIn: parent
                                    visible: rowItem.isSep
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    visible: !rowItem.isSep
                                    radius: phoneMenuWindow.s(4)
                                    color: (hoverGlass.active || hoverLens.glassActive) ? "transparent" : (rowItem.lensWanted ? ThemeBackend.surface0 : "transparent")
                                    opacity: (rowItem.isHeader || modelData.enabled) ? 1.0 : 0.4

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
                                        anchors.leftMargin: phoneMenuWindow.s(8)
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: phoneMenuWindow.s(18)
                                        horizontalAlignment: Text.AlignHCenter
                                        text: rowItem.isHeader
                                            ? phoneMenuWindow.glyph(modelData.connected ? 0xF011C : 0xF0950)
                                            : phoneMenuWindow.glyph(modelData.icon)
                                        color: rowItem.isHeader && modelData.connected ? ThemeBackend.peach : ThemeBackend.text
                                        font.family: ThemeBackend.iconFont
                                        font.pixelSize: phoneMenuWindow.s(rowItem.isHeader ? 17 : 15)
                                    }

                                    Text {
                                        anchors.left: rowIcon.right
                                        anchors.leftMargin: phoneMenuWindow.s(8)
                                        anchors.right: statusText.visible ? statusText.left : parent.right
                                        anchors.rightMargin: phoneMenuWindow.s(8)
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: (rowItem.isHeader ? modelData.dev.name : modelData.text) || ""
                                        color: ThemeBackend.text
                                        font.family: ThemeBackend.fontFamily
                                        font.pixelSize: phoneMenuWindow.s(13)
                                        font.bold: rowItem.isHeader
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Text {
                                        id: statusText
                                        anchors.right: parent.right
                                        anchors.rightMargin: phoneMenuWindow.s(8)
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: rowItem.isHeader
                                        text: {
                                            if (!rowItem.isHeader) return "";
                                            if (!modelData.connected) return I18n.t("phone.menu.disconnected", "Disconnected");
                                            let b = modelData.dev.battery;
                                            if (!b) return "";
                                            return (b.charging ? phoneMenuWindow.glyph(0xF140B) + " " : "") + b.percentage + " %";
                                        }
                                        color: ThemeBackend.subtext0
                                        font.family: ThemeBackend.fontFamily
                                        font.pixelSize: phoneMenuWindow.s(12)
                                    }

                                    MouseArea {
                                        id: rowMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled: rowItem.clickable
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: phoneMenuWindow.run(modelData)
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

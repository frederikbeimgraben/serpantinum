import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../"

// The overlay of the color picker with a magnifier, see
// singletons/system/Colorpick.qml. While Colorpick.picking is true, each
// screen shows its screenshot, frozen. A round magnifier sits centered on the
// pointer, which is hidden, and enlarges the pixels around it by
// Colorpick.zoom without smoothing. A crosshair and a frame in its center
// mark the pixel that a click picks. The magnifier shows only after the first
// pointer movement of a pick, so it does not appear at the place of the last
// pick. Esc or a right click cancels.
Variants {
    model: Quickshell.screens

    delegate: Component {
        PanelWindow {
            id: overlay
            required property var modelData

            screen: modelData
            visible: Colorpick.picking
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "colorpick"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: Colorpick.picking ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Shortcut {
                sequence: "Escape"
                context: Qt.WindowShortcut
                enabled: Colorpick.picking
                onActivated: Colorpick.cancel()
            }

            readonly property string shotPath: Colorpick.shots[modelData.name] || ""
            // Screenshot pixels per logical pixel, for scaled screens.
            readonly property real pixelScale: shot.implicitWidth > 0 && overlay.width > 0 ? shot.implicitWidth / overlay.width : 1
            readonly property real lensSize: 150
            property bool moved: false

            onVisibleChanged: overlay.moved = false
            readonly property real zoom: Colorpick.zoom

            Image {
                id: shot
                anchors.fill: parent
                source: overlay.shotPath !== "" && Colorpick.picking ? "file://" + overlay.shotPath + "?" + Colorpick.shotRevision : ""
                cache: false
                smooth: false
                fillMode: Image.Stretch
            }

            MouseArea {
                id: pointer
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: overlay.moved ? Qt.BlankCursor : Qt.CrossCursor
                onPositionChanged: overlay.moved = true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        Colorpick.cancel();
                        return;
                    }
                    Colorpick.finish(overlay.modelData.name, Math.floor(mouse.x * overlay.pixelScale), Math.floor(mouse.y * overlay.pixelScale));
                }
            }

            Item {
                id: lens
                visible: overlay.moved && pointer.containsMouse && shot.status === Image.Ready
                width: overlay.lensSize
                height: overlay.lensSize
                x: pointer.mouseX - width / 2
                y: pointer.mouseY - height / 2

                Item {
                    id: lensContent
                    anchors.fill: parent
                    visible: false
                    layer.enabled: true

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                    }

                    Image {
                        source: shot.source
                        cache: false
                        smooth: false
                        width: shot.implicitWidth * overlay.zoom / overlay.pixelScale
                        height: shot.implicitHeight * overlay.zoom / overlay.pixelScale
                        x: lens.width / 2 - (Math.floor(pointer.mouseX * overlay.pixelScale) + 0.5) * overlay.zoom / overlay.pixelScale
                        y: lens.height / 2 - (Math.floor(pointer.mouseY * overlay.pixelScale) + 0.5) * overlay.zoom / overlay.pixelScale
                    }

                    Rectangle {
                        width: 1
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Qt.rgba(1, 1, 1, 0.45)
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        anchors.verticalCenter: parent.verticalCenter
                        color: Qt.rgba(1, 1, 1, 0.45)
                    }

                    Rectangle {
                        width: overlay.zoom / overlay.pixelScale + 2
                        height: width
                        anchors.centerIn: parent
                        color: "transparent"
                        border.width: 1
                        border.color: "white"
                    }
                }

                Rectangle {
                    id: lensMask
                    anchors.fill: parent
                    radius: width / 2
                    visible: false
                    layer.enabled: true
                }

                MultiEffect {
                    anchors.fill: parent
                    source: lensContent
                    maskEnabled: true
                    maskSource: lensMask
                }

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: ThemeBackend.text
                }
            }
        }
    }
}

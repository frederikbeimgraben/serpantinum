pragma Singleton
import QtQuick
import Quickshell
import "../../"

// Open state and position of the phone menu, see popouts/PhoneMenu.qml. The
// phone face of the bar opens it on a click.
Item {
    id: controller

    property bool isVisible: false
    property real targetX: 0
    property real targetY: 0
    property bool alignRight: false
    property bool alignBottom: false
    property bool isSideBar: false
    property var screen: null

    function show(scr, posX, posY, isRight, isBottom, isSide) {
        controller.screen = scr;
        controller.targetX = posX;
        controller.targetY = posY;
        controller.alignRight = isRight;
        controller.alignBottom = isBottom;
        controller.isSideBar = isSide;
        controller.isVisible = true;
        Phone.refresh();
    }

    function hide() {
        controller.isVisible = false;
    }

    function toggle(scr, posX, posY, isRight, isBottom, isSide) {
        if (controller.isVisible) controller.hide();
        else controller.show(scr, posX, posY, isRight, isBottom, isSide);
    }
}

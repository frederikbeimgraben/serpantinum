import QtQuick
import Quickshell.Services.UPower
import "../../"
import "../../../"
import "../../../bar"

GuideTab {
    id: barModulesRoot

    property real cardRadius: ThemeBackend.clampedBorderRadius

    property bool isDesktop: (typeof UPower !== "undefined" && UPower.displayDevice && UPower.displayDevice.ready) ? !UPower.displayDevice.isLaptopBattery : (typeof SystemInfo !== "undefined" ? SystemInfo.isDesktop : false)

    property string barPosition: {
        let bs = Config.getSetting("bar", {});
        return bs && bs.position !== undefined ? bs.position : "top";
    }
    readonly property bool isSideBar: barPosition === "left" || barPosition === "right"

    property string workspacesStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.workspacesStyle) return bs.workspacesStyle;
        return "pills";
    }

    property int workspaceCount: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.workspaceCount !== undefined) return bs.workspaceCount;
        return 8;
    }

    property bool hideEmptyWorkspaces: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.hideEmptyWorkspaces !== undefined) return Boolean(bs.hideEmptyWorkspaces);
        return false;
    }

    property string timeStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.timeStyle) return bs.timeStyle;
        return "classic";
    }

    property bool timeShowDate: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.timeShowDate !== undefined) return bs.timeShowDate;
        if (bs && bs.showDate !== undefined) return bs.showDate;
        return true;
    }

    property string timeFormat: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.time && bs.time.format !== undefined) return bs.time.format;
        return "HH:mm:ss";
    }

    property int visBarCount: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.visBarCount !== undefined) return bs.visBarCount;
        return 16;
    }

    property string visAlignment: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.visAlignment) return bs.visAlignment;
        return "center";
    }

    property bool visContinuous: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.visContinuous !== undefined) return Boolean(bs.visContinuous);
        return false;
    }

    property string sysmonStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.sysmonStyle) return bs.sysmonStyle;
        if (bs && bs.sysmon && bs.sysmon.style) return bs.sysmon.style;
        return "wave";
    }

    property var sysmonStats: {
        let bs = Config.getSetting("bar", {});
        if (bs && Array.isArray(bs.sysmonStats)) return bs.sysmonStats;
        if (bs && bs.sysmon && Array.isArray(bs.sysmon.stats)) return bs.sysmon.stats;
        if (bs && (bs.sysmonShowCpu !== undefined || bs.sysmonShowRam !== undefined || bs.sysmonShowTemp !== undefined || bs.sysmonShowDisk !== undefined)) {
            let stats = [];
            if (bs.sysmonShowCpu !== false) stats.push("cpu");
            if (bs.sysmonShowRam !== false) stats.push("ram");
            if (bs.sysmonShowTemp !== false) stats.push("temp");
            if (bs.sysmonShowDisk === true) stats.push("disk");
            return stats;
        }
        return ["cpu", "ram", "temp"];
    }

    readonly property var menuStyles: BarModuleRegistry.variantList("left")
    readonly property var workspaceStyles: BarModuleRegistry.variantList("workspaces")
    readonly property var timeStyles: BarModuleRegistry.variantList("timedate")
    readonly property var batStyles: BarModuleRegistry.variantList("bat")
    readonly property var wifiStyles: BarModuleRegistry.variantList("wifi")
    readonly property var btStyles: BarModuleRegistry.variantList("bt")
    readonly property var lidStyles: BarModuleRegistry.variantList("lid")
    readonly property var phoneStyles: BarModuleRegistry.variantList("phone")
    readonly property var gatusStyles: BarModuleRegistry.variantList("gatus")
    readonly property var colorpickStyles: BarModuleRegistry.variantList("colorpick")
    readonly property var privacyStyles: BarModuleRegistry.variantList("privacy")
    readonly property var btbatStyles: BarModuleRegistry.variantList("btbat")
    readonly property var vpnStyles: BarModuleRegistry.variantList("vpn")
    readonly property var volStyles: BarModuleRegistry.variantList("vol")
    readonly property var kbStyles: BarModuleRegistry.variantList("kb")

    property string menuStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.menuStyle) return bs.menuStyle;
        return "button";
    }

    property bool menuShowSettings: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.menuShowSettings !== undefined) return Boolean(bs.menuShowSettings);
        return true;
    }

    property bool menuShowLauncher: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.menuShowLauncher !== undefined) return Boolean(bs.menuShowLauncher);
        return true;
    }

    property string wifiStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.wifiStyle) return bs.wifiStyle;
        return "button";
    }

    property bool wifiShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.wifiShowIcon !== undefined) return Boolean(bs.wifiShowIcon);
        return true;
    }

    property bool wifiShowName: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.wifiShowName !== undefined) return Boolean(bs.wifiShowName);
        return true;
    }

    property string btStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.btStyle) return bs.btStyle;
        return "button";
    }

    property bool btShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.btShowIcon !== undefined) return Boolean(bs.btShowIcon);
        return true;
    }

    property bool btShowName: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.btShowName !== undefined) return Boolean(bs.btShowName);
        return true;
    }

    property string lidStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.lidStyle) return bs.lidStyle;
        return "button";
    }

    property bool lidShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.lidShowIcon !== undefined) return Boolean(bs.lidShowIcon);
        return true;
    }

    property bool lidShowName: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.lidShowName !== undefined) return Boolean(bs.lidShowName);
        return false;
    }

    property string phoneStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.phoneStyle) return bs.phoneStyle;
        return "classic";
    }

    property bool phoneShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.phoneShowIcon !== undefined) return Boolean(bs.phoneShowIcon);
        return true;
    }

    property bool phoneShowPercent: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.phoneShowPercent !== undefined) return Boolean(bs.phoneShowPercent);
        return true;
    }

    property string gatusStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.gatusStyle) return bs.gatusStyle;
        return "button";
    }

    property bool gatusShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.gatusShowIcon !== undefined) return Boolean(bs.gatusShowIcon);
        return true;
    }

    property bool gatusShowCount: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.gatusShowCount !== undefined) return Boolean(bs.gatusShowCount);
        return true;
    }

    property string colorpickStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.colorpickStyle) return bs.colorpickStyle;
        return "button";
    }

    property bool colorpickShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.colorpickShowIcon !== undefined) return Boolean(bs.colorpickShowIcon);
        return true;
    }

    property bool colorpickShowLabel: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.colorpickShowLabel !== undefined) return Boolean(bs.colorpickShowLabel);
        return true;
    }

    property string colorpickFormat: (Config.getSetting("colorpick", {}) || {}).format || "hex"
    property bool colorpickNotify: (Config.getSetting("colorpick", {}) || {}).notify !== false
    property bool colorpickLens: (Config.getSetting("colorpick", {}) || {}).lens !== false
    property string colorpickShortcut: (Config.getSetting("colorpick", {}) || {}).shortcut || ""
    property int colorpickZoom: Number((Config.getSetting("colorpick", {}) || {}).zoom) || 8
    property int colorpickResetAfter: {
        let c = Config.getSetting("colorpick", {}) || {};
        return c.resetAfter === undefined ? 5 : (Number(c.resetAfter) || 0);
    }

    property string privacyStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.privacyStyle) return bs.privacyStyle;
        return "button";
    }

    property bool privacyShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.privacyShowIcon !== undefined) return Boolean(bs.privacyShowIcon);
        return true;
    }

    property bool privacyShowLabel: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.privacyShowLabel !== undefined) return Boolean(bs.privacyShowLabel);
        return true;
    }

    property bool privacyShowMic: (Config.getSetting("privacy", {}) || {}).showMic !== false
    property bool privacyShowCam: (Config.getSetting("privacy", {}) || {}).showCam !== false
    property var privacyIgnore: {
        let p = Config.getSetting("privacy", {}) || {};
        return Array.isArray(p.ignore) ? p.ignore : [];
    }

    property string btbatStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.btbatStyle) return bs.btbatStyle;
        return "classic";
    }

    property bool btbatShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.btbatShowIcon !== undefined) return Boolean(bs.btbatShowIcon);
        return true;
    }

    property bool btbatShowPercent: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.btbatShowPercent !== undefined) return Boolean(bs.btbatShowPercent);
        return true;
    }

    property int btbatLowThreshold: Number((Config.getSetting("btbat", {}) || {}).lowThreshold) || 20
    property bool btbatWarn: (Config.getSetting("btbat", {}) || {}).warn !== false

    property string vpnStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.vpnStyle) return bs.vpnStyle;
        return "button";
    }

    property bool vpnShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.vpnShowIcon !== undefined) return Boolean(bs.vpnShowIcon);
        return true;
    }

    property bool vpnShowLabel: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.vpnShowLabel !== undefined) return Boolean(bs.vpnShowLabel);
        return true;
    }

    property string vpnCheckHost: (Config.getSetting("vpn", {}) || {}).checkHost || ""

    property var gatusUrls: {
        let g = Config.getSetting("gatus", {});
        return (g && Array.isArray(g.urls)) ? g.urls : [];
    }

    property string volStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.volStyle) return bs.volStyle;
        return "button";
    }

    property bool volShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.volShowIcon !== undefined) return Boolean(bs.volShowIcon);
        return true;
    }

    property bool volShowPercent: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.volShowPercent !== undefined) return Boolean(bs.volShowPercent);
        return true;
    }

    property string kbStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.kbStyle) return bs.kbStyle;
        return "button";
    }

    property bool kbShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.kbShowIcon !== undefined) return Boolean(bs.kbShowIcon);
        return true;
    }

    property string mediaInfoMode: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.mediaInfoMode) return bs.mediaInfoMode;
        return "duration";
    }

    property int mediaWidth: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.mediaWidth !== undefined) return Math.round(Number(bs.mediaWidth));
        return 120;
    }

    property bool mediaShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.mediaShowIcon !== undefined) return Boolean(bs.mediaShowIcon);
        return true;
    }

    property bool mediaShowControls: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.mediaShowControls !== undefined) return Boolean(bs.mediaShowControls);
        return true;
    }

    property string batStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.batStyle) return bs.batStyle;
        return "classic";
    }

    property bool batShowPercent: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.batShowPercent !== undefined) return Boolean(bs.batShowPercent);
        return true;
    }

    property bool batShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.batShowIcon !== undefined) return Boolean(bs.batShowIcon);
        return true;
    }

    property real barOpacity: ThemeBackend.elementOpacity

    function syncSettings() {
        let bs = Config.getSetting("bar", {});
        barModulesRoot.barPosition = (bs && bs.position !== undefined) ? bs.position : "top";

        if (bs && bs.workspacesStyle) {
            barModulesRoot.workspacesStyle = bs.workspacesStyle;
        } else {
            barModulesRoot.workspacesStyle = "pills";
        }

        if (bs && bs.workspaceCount !== undefined) {
            barModulesRoot.workspaceCount = bs.workspaceCount;
        } else {
            barModulesRoot.workspaceCount = 8;
        }

        if (bs && bs.hideEmptyWorkspaces !== undefined) {
            barModulesRoot.hideEmptyWorkspaces = Boolean(bs.hideEmptyWorkspaces);
        } else {
            barModulesRoot.hideEmptyWorkspaces = false;
        }

        if (bs && bs.timeStyle) {
            barModulesRoot.timeStyle = bs.timeStyle;
        } else {
            barModulesRoot.timeStyle = "classic";
        }

        if (bs && bs.timeShowDate !== undefined) {
            barModulesRoot.timeShowDate = bs.timeShowDate;
        } else if (bs && bs.showDate !== undefined) {
            barModulesRoot.timeShowDate = bs.showDate;
        } else {
            barModulesRoot.timeShowDate = true;
        }

        if (bs && bs.time && bs.time.format !== undefined) {
            barModulesRoot.timeFormat = bs.time.format;
        } else {
            barModulesRoot.timeFormat = "HH:mm:ss";
        }

        if (bs && bs.visBarCount !== undefined) {
            barModulesRoot.visBarCount = bs.visBarCount;
        } else {
            barModulesRoot.visBarCount = 16;
        }

        if (bs && bs.visAlignment) {
            barModulesRoot.visAlignment = bs.visAlignment;
        } else {
            barModulesRoot.visAlignment = "center";
        }

        if (bs && bs.visContinuous !== undefined) {
            barModulesRoot.visContinuous = Boolean(bs.visContinuous);
        } else {
            barModulesRoot.visContinuous = false;
        }

        if (bs && bs.sysmonStyle) {
            barModulesRoot.sysmonStyle = bs.sysmonStyle;
        } else {
            barModulesRoot.sysmonStyle = "wave";
        }

        if (bs && Array.isArray(bs.sysmonStats)) {
            barModulesRoot.sysmonStats = bs.sysmonStats;
        } else if (bs && (bs.sysmonShowCpu !== undefined || bs.sysmonShowRam !== undefined || bs.sysmonShowTemp !== undefined || bs.sysmonShowDisk !== undefined)) {
            let stats = [];
            if (bs.sysmonShowCpu !== false) stats.push("cpu");
            if (bs.sysmonShowRam !== false) stats.push("ram");
            if (bs.sysmonShowTemp !== false) stats.push("temp");
            if (bs.sysmonShowDisk === true) stats.push("disk");
            barModulesRoot.sysmonStats = stats;
        } else {
            barModulesRoot.sysmonStats = ["cpu", "ram", "temp"];
        }

        if (bs && bs.batStyle) {
            barModulesRoot.batStyle = bs.batStyle;
        } else {
            barModulesRoot.batStyle = "classic";
        }

        if (bs && bs.batShowPercent !== undefined) {
            barModulesRoot.batShowPercent = Boolean(bs.batShowPercent);
        } else {
            barModulesRoot.batShowPercent = true;
        }

        if (bs && bs.batShowIcon !== undefined) {
            barModulesRoot.batShowIcon = Boolean(bs.batShowIcon);
        } else {
            barModulesRoot.batShowIcon = true;
        }

        barModulesRoot.menuStyle = (bs && bs.menuStyle) ? bs.menuStyle : "button";
        barModulesRoot.menuShowSettings = (bs && bs.menuShowSettings !== undefined) ? Boolean(bs.menuShowSettings) : true;
        barModulesRoot.menuShowLauncher = (bs && bs.menuShowLauncher !== undefined) ? Boolean(bs.menuShowLauncher) : true;
        if (!barModulesRoot.menuShowSettings && !barModulesRoot.menuShowLauncher) {
            barModulesRoot.menuShowSettings = true;
        }

        if (bs && bs.wifiStyle) {
            barModulesRoot.wifiStyle = bs.wifiStyle;
        } else {
            barModulesRoot.wifiStyle = "button";
        }

        if (bs && bs.wifiShowIcon !== undefined) {
            barModulesRoot.wifiShowIcon = Boolean(bs.wifiShowIcon);
        } else {
            barModulesRoot.wifiShowIcon = true;
        }

        if (bs && bs.wifiShowName !== undefined) {
            barModulesRoot.wifiShowName = Boolean(bs.wifiShowName);
        } else {
            barModulesRoot.wifiShowName = true;
        }

        if (bs && bs.btStyle) {
            barModulesRoot.btStyle = bs.btStyle;
        } else {
            barModulesRoot.btStyle = "button";
        }

        if (bs && bs.btShowIcon !== undefined) {
            barModulesRoot.btShowIcon = Boolean(bs.btShowIcon);
        } else {
            barModulesRoot.btShowIcon = true;
        }

        if (bs && bs.btShowName !== undefined) {
            barModulesRoot.btShowName = Boolean(bs.btShowName);
        } else {
            barModulesRoot.btShowName = true;
        }

        if (bs && bs.lidStyle) {
            barModulesRoot.lidStyle = bs.lidStyle;
        } else {
            barModulesRoot.lidStyle = "button";
        }

        if (bs && bs.lidShowIcon !== undefined) {
            barModulesRoot.lidShowIcon = Boolean(bs.lidShowIcon);
        } else {
            barModulesRoot.lidShowIcon = true;
        }

        if (bs && bs.lidShowName !== undefined) {
            barModulesRoot.lidShowName = Boolean(bs.lidShowName);
        } else {
            barModulesRoot.lidShowName = false;
        }

        if (bs && bs.phoneStyle) {
            barModulesRoot.phoneStyle = bs.phoneStyle;
        } else {
            barModulesRoot.phoneStyle = "classic";
        }

        if (bs && bs.phoneShowIcon !== undefined) {
            barModulesRoot.phoneShowIcon = Boolean(bs.phoneShowIcon);
        } else {
            barModulesRoot.phoneShowIcon = true;
        }

        if (bs && bs.phoneShowPercent !== undefined) {
            barModulesRoot.phoneShowPercent = Boolean(bs.phoneShowPercent);
        } else {
            barModulesRoot.phoneShowPercent = true;
        }

        if (bs && bs.gatusStyle) {
            barModulesRoot.gatusStyle = bs.gatusStyle;
        } else {
            barModulesRoot.gatusStyle = "button";
        }

        if (bs && bs.gatusShowIcon !== undefined) {
            barModulesRoot.gatusShowIcon = Boolean(bs.gatusShowIcon);
        } else {
            barModulesRoot.gatusShowIcon = true;
        }

        if (bs && bs.gatusShowCount !== undefined) {
            barModulesRoot.gatusShowCount = Boolean(bs.gatusShowCount);
        } else {
            barModulesRoot.gatusShowCount = true;
        }

        if (bs && bs.colorpickStyle) {
            barModulesRoot.colorpickStyle = bs.colorpickStyle;
        } else {
            barModulesRoot.colorpickStyle = "button";
        }

        if (bs && bs.colorpickShowIcon !== undefined) {
            barModulesRoot.colorpickShowIcon = Boolean(bs.colorpickShowIcon);
        } else {
            barModulesRoot.colorpickShowIcon = true;
        }

        if (bs && bs.colorpickShowLabel !== undefined) {
            barModulesRoot.colorpickShowLabel = Boolean(bs.colorpickShowLabel);
        } else {
            barModulesRoot.colorpickShowLabel = true;
        }

        if (bs && bs.privacyStyle) {
            barModulesRoot.privacyStyle = bs.privacyStyle;
        } else {
            barModulesRoot.privacyStyle = "button";
        }

        if (bs && bs.privacyShowIcon !== undefined) {
            barModulesRoot.privacyShowIcon = Boolean(bs.privacyShowIcon);
        } else {
            barModulesRoot.privacyShowIcon = true;
        }

        if (bs && bs.privacyShowLabel !== undefined) {
            barModulesRoot.privacyShowLabel = Boolean(bs.privacyShowLabel);
        } else {
            barModulesRoot.privacyShowLabel = true;
        }

        if (bs && bs.btbatStyle) {
            barModulesRoot.btbatStyle = bs.btbatStyle;
        } else {
            barModulesRoot.btbatStyle = "classic";
        }

        if (bs && bs.btbatShowIcon !== undefined) {
            barModulesRoot.btbatShowIcon = Boolean(bs.btbatShowIcon);
        } else {
            barModulesRoot.btbatShowIcon = true;
        }

        if (bs && bs.btbatShowPercent !== undefined) {
            barModulesRoot.btbatShowPercent = Boolean(bs.btbatShowPercent);
        } else {
            barModulesRoot.btbatShowPercent = true;
        }

        if (bs && bs.vpnStyle) {
            barModulesRoot.vpnStyle = bs.vpnStyle;
        } else {
            barModulesRoot.vpnStyle = "button";
        }

        if (bs && bs.vpnShowIcon !== undefined) {
            barModulesRoot.vpnShowIcon = Boolean(bs.vpnShowIcon);
        } else {
            barModulesRoot.vpnShowIcon = true;
        }

        if (bs && bs.vpnShowLabel !== undefined) {
            barModulesRoot.vpnShowLabel = Boolean(bs.vpnShowLabel);
        } else {
            barModulesRoot.vpnShowLabel = true;
        }

        let gs = Config.getSetting("gatus", {});
        barModulesRoot.gatusUrls = (gs && Array.isArray(gs.urls)) ? gs.urls : [];

        if (bs && bs.volStyle) {
            barModulesRoot.volStyle = bs.volStyle;
        } else {
            barModulesRoot.volStyle = "button";
        }

        if (bs && bs.volShowIcon !== undefined) {
            barModulesRoot.volShowIcon = Boolean(bs.volShowIcon);
        } else {
            barModulesRoot.volShowIcon = true;
        }

        if (bs && bs.volShowPercent !== undefined) {
            barModulesRoot.volShowPercent = Boolean(bs.volShowPercent);
        } else {
            barModulesRoot.volShowPercent = true;
        }

        if (bs && bs.kbStyle) {
            barModulesRoot.kbStyle = bs.kbStyle;
        } else {
            barModulesRoot.kbStyle = "button";
        }

        if (bs && bs.kbShowIcon !== undefined) {
            barModulesRoot.kbShowIcon = Boolean(bs.kbShowIcon);
        } else {
            barModulesRoot.kbShowIcon = true;
        }

        barModulesRoot.mediaInfoMode = (bs && bs.mediaInfoMode) ? bs.mediaInfoMode : "duration";
        barModulesRoot.mediaWidth = (bs && bs.mediaWidth !== undefined) ? Math.round(Number(bs.mediaWidth)) : 120;

        if (bs && bs.mediaShowIcon !== undefined) {
            barModulesRoot.mediaShowIcon = Boolean(bs.mediaShowIcon);
        } else {
            barModulesRoot.mediaShowIcon = true;
        }

        if (bs && bs.mediaShowControls !== undefined) {
            barModulesRoot.mediaShowControls = Boolean(bs.mediaShowControls);
        } else {
            barModulesRoot.mediaShowControls = true;
        }

        if (!barModulesRoot.batShowPercent && !barModulesRoot.batShowIcon) {
            barModulesRoot.batShowIcon = true;
        }
        if (!barModulesRoot.wifiShowIcon && !barModulesRoot.wifiShowName) {
            barModulesRoot.wifiShowIcon = true;
        }
        if (!barModulesRoot.btShowIcon && !barModulesRoot.btShowName) {
            barModulesRoot.btShowIcon = true;
        }
        if (!barModulesRoot.lidShowIcon && !barModulesRoot.lidShowName) {
            barModulesRoot.lidShowIcon = true;
        }
        if (!barModulesRoot.phoneShowIcon && !barModulesRoot.phoneShowPercent) {
            barModulesRoot.phoneShowIcon = true;
        }
        if (!barModulesRoot.gatusShowIcon && !barModulesRoot.gatusShowCount) {
            barModulesRoot.gatusShowIcon = true;
        }
        if (!barModulesRoot.colorpickShowIcon && !barModulesRoot.colorpickShowLabel) {
            barModulesRoot.colorpickShowIcon = true;
        }
        if (!barModulesRoot.privacyShowIcon && !barModulesRoot.privacyShowLabel) {
            barModulesRoot.privacyShowIcon = true;
        }
        if (!barModulesRoot.btbatShowIcon && !barModulesRoot.btbatShowPercent) {
            barModulesRoot.btbatShowIcon = true;
        }
        if (!barModulesRoot.vpnShowIcon && !barModulesRoot.vpnShowLabel) {
            barModulesRoot.vpnShowIcon = true;
        }
        if (!barModulesRoot.volShowIcon && !barModulesRoot.volShowPercent) {
            barModulesRoot.volShowIcon = true;
        }
    }

    function setWorkspacesStyle(styleName) {
        barModulesRoot.workspacesStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.workspacesStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setWorkspaceCount(count) {
        barModulesRoot.workspaceCount = count;
        let current = Config.getSetting("bar", {});
        current.workspaceCount = count;
        Config.setSetting("bar", current);
    }

    function setHideEmptyWorkspaces(val) {
        barModulesRoot.hideEmptyWorkspaces = val;
        let current = Config.getSetting("bar", {});
        current.hideEmptyWorkspaces = val;
        Config.setSetting("bar", current);
    }

    function setTimeStyle(styleName) {
        barModulesRoot.timeStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.timeStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setTimeShowDate(show) {
        barModulesRoot.timeShowDate = show;
        let current = Config.getSetting("bar", {});
        current.timeShowDate = show;
        if (current.showDate !== undefined) delete current.showDate;
        Config.setSetting("bar", current);
    }

    function setTimeFormat(fmt) {
        barModulesRoot.timeFormat = fmt;
        let current = Config.getSetting("bar", {});
        if (!current.time) current.time = {};
        current.time.format = fmt;
        Config.setSetting("bar", current);
    }

    function setVisBarCount(count) {
        barModulesRoot.visBarCount = count;
        let current = Config.getSetting("bar", {});
        current.visBarCount = count;
        Config.setSetting("bar", current);
    }

    function setVisAlignment(align) {
        barModulesRoot.visAlignment = align;
        let current = Config.getSetting("bar", {});
        current.visAlignment = align;
        Config.setSetting("bar", current);
    }

    function setVisContinuous(val) {
        barModulesRoot.visContinuous = val;
        let current = Config.getSetting("bar", {});
        current.visContinuous = val;
        Config.setSetting("bar", current);
    }

    function setSysmonStyle(styleName) {
        barModulesRoot.sysmonStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.sysmonStyle = styleName;
        Config.setSetting("bar", current);
    }

    function isSysmonStatEnabled(stat) {
        return barModulesRoot.sysmonStats && barModulesRoot.sysmonStats.indexOf(stat) !== -1;
    }

    function toggleSysmonStat(stat, enabled) {
        let list = barModulesRoot.sysmonStats ? barModulesRoot.sysmonStats.slice() : ["cpu", "ram", "temp"];
        let allStats = ["cpu", "ram", "temp", "disk"];
        let set = {};
        for (let i = 0; i < list.length; i++) set[list[i]] = true;
        if (enabled) {
            set[stat] = true;
        } else {
            delete set[stat];
        }
        let res = [];
        for (let i = 0; i < allStats.length; i++) {
            if (set[allStats[i]]) res.push(allStats[i]);
        }
        barModulesRoot.sysmonStats = res;
        let current = Config.getSetting("bar", {});
        current.sysmonStats = res;
        Config.setSetting("bar", current);
    }

    function setBatStyle(styleName) {
        barModulesRoot.batStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.batStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setBatShowPercent(val) {
        if (!val && !barModulesRoot.batShowIcon) return;
        barModulesRoot.batShowPercent = val;
        let current = Config.getSetting("bar", {});
        current.batShowPercent = val;
        Config.setSetting("bar", current);
    }

    function setBatShowIcon(val) {
        if (!val && !barModulesRoot.batShowPercent) return;
        barModulesRoot.batShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.batShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setMenuStyle(styleName) {
        barModulesRoot.menuStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.menuStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setMenuShowSettings(val) {
        if (!val && !barModulesRoot.menuShowLauncher) return;
        barModulesRoot.menuShowSettings = val;
        let current = Config.getSetting("bar", {});
        current.menuShowSettings = val;
        Config.setSetting("bar", current);
    }

    function setMenuShowLauncher(val) {
        if (!val && !barModulesRoot.menuShowSettings) return;
        barModulesRoot.menuShowLauncher = val;
        let current = Config.getSetting("bar", {});
        current.menuShowLauncher = val;
        Config.setSetting("bar", current);
    }

    function setWifiStyle(styleName) {
        barModulesRoot.wifiStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.wifiStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setWifiShowIcon(val) {
        if (!val && !barModulesRoot.wifiShowName) return;
        barModulesRoot.wifiShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.wifiShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setWifiShowName(val) {
        if (!val && !barModulesRoot.wifiShowIcon) return;
        barModulesRoot.wifiShowName = val;
        let current = Config.getSetting("bar", {});
        current.wifiShowName = val;
        Config.setSetting("bar", current);
    }

    function setBtStyle(styleName) {
        barModulesRoot.btStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.btStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setBtShowIcon(val) {
        if (!val && !barModulesRoot.btShowName) return;
        barModulesRoot.btShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.btShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setBtShowName(val) {
        if (!val && !barModulesRoot.btShowIcon) return;
        barModulesRoot.btShowName = val;
        let current = Config.getSetting("bar", {});
        current.btShowName = val;
        Config.setSetting("bar", current);
    }

    function setLidStyle(styleName) {
        barModulesRoot.lidStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.lidStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setLidShowIcon(val) {
        if (!val && !barModulesRoot.lidShowName) return;
        barModulesRoot.lidShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.lidShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setLidShowName(val) {
        if (!val && !barModulesRoot.lidShowIcon) return;
        barModulesRoot.lidShowName = val;
        let current = Config.getSetting("bar", {});
        current.lidShowName = val;
        Config.setSetting("bar", current);
    }

    function setPhoneStyle(styleName) {
        barModulesRoot.phoneStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.phoneStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setPhoneShowIcon(val) {
        if (!val && !barModulesRoot.phoneShowPercent) return;
        barModulesRoot.phoneShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.phoneShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setPhoneShowPercent(val) {
        if (!val && !barModulesRoot.phoneShowIcon) return;
        barModulesRoot.phoneShowPercent = val;
        let current = Config.getSetting("bar", {});
        current.phoneShowPercent = val;
        Config.setSetting("bar", current);
    }

    function setGatusStyle(styleName) {
        barModulesRoot.gatusStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.gatusStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setGatusShowIcon(val) {
        if (!val && !barModulesRoot.gatusShowCount) return;
        barModulesRoot.gatusShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.gatusShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setGatusShowCount(val) {
        if (!val && !barModulesRoot.gatusShowIcon) return;
        barModulesRoot.gatusShowCount = val;
        let current = Config.getSetting("bar", {});
        current.gatusShowCount = val;
        Config.setSetting("bar", current);
    }

    function setColorpickStyle(styleName) {
        barModulesRoot.colorpickStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.colorpickStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setColorpickShowIcon(val) {
        if (!val && !barModulesRoot.colorpickShowLabel) return;
        barModulesRoot.colorpickShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.colorpickShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setColorpickShowLabel(val) {
        if (!val && !barModulesRoot.colorpickShowIcon) return;
        barModulesRoot.colorpickShowLabel = val;
        let current = Config.getSetting("bar", {});
        current.colorpickShowLabel = val;
        Config.setSetting("bar", current);
    }

    function setPrivacyStyle(styleName) {
        barModulesRoot.privacyStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.privacyStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setPrivacyShowIcon(val) {
        if (!val && !barModulesRoot.privacyShowLabel) return;
        barModulesRoot.privacyShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.privacyShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setPrivacyShowLabel(val) {
        if (!val && !barModulesRoot.privacyShowIcon) return;
        barModulesRoot.privacyShowLabel = val;
        let current = Config.getSetting("bar", {});
        current.privacyShowLabel = val;
        Config.setSetting("bar", current);
    }

    function setBtbatStyle(styleName) {
        barModulesRoot.btbatStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.btbatStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setBtbatShowIcon(val) {
        if (!val && !barModulesRoot.btbatShowPercent) return;
        barModulesRoot.btbatShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.btbatShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setBtbatShowPercent(val) {
        if (!val && !barModulesRoot.btbatShowIcon) return;
        barModulesRoot.btbatShowPercent = val;
        let current = Config.getSetting("bar", {});
        current.btbatShowPercent = val;
        Config.setSetting("bar", current);
    }

    function setVpnStyle(styleName) {
        barModulesRoot.vpnStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.vpnStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setVpnShowIcon(val) {
        if (!val && !barModulesRoot.vpnShowLabel) return;
        barModulesRoot.vpnShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.vpnShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setVpnShowLabel(val) {
        if (!val && !barModulesRoot.vpnShowIcon) return;
        barModulesRoot.vpnShowLabel = val;
        let current = Config.getSetting("bar", {});
        current.vpnShowLabel = val;
        Config.setSetting("bar", current);
    }

    // Writes one field of a top-level settings object of a module, such as
    // vpn.connection.
    function setModuleConfig(key, field, value) {
        let current = Config.getSetting(key, {}) || {};
        current[field] = value;
        Config.setSetting(key, current);
    }

    // The Gatus base URLs. A URL without a scheme gets https://, and a slash at
    // the end is removed, so the API path joins cleanly.
    function normalizeGatusUrl(u) {
        u = String(u || "").trim().replace(/\/+$/, "");
        if (u !== "" && !/^https?:\/\//.test(u)) u = "https://" + u;
        return u;
    }

    function setGatusUrls(list) {
        barModulesRoot.gatusUrls = list;
        let current = Config.getSetting("gatus", {}) || {};
        current.urls = list;
        Config.setSetting("gatus", current);
    }

    function addGatusUrl(u) {
        u = normalizeGatusUrl(u);
        if (u === "" || barModulesRoot.gatusUrls.indexOf(u) !== -1) return;
        setGatusUrls(barModulesRoot.gatusUrls.concat([u]));
    }

    function setGatusUrl(index, u) {
        u = normalizeGatusUrl(u);
        let list = barModulesRoot.gatusUrls.slice();
        if (u === "") list.splice(index, 1);
        else list[index] = u;
        setGatusUrls(list);
    }

    function removeGatusUrl(index) {
        let list = barModulesRoot.gatusUrls.slice();
        list.splice(index, 1);
        setGatusUrls(list);
    }

    function setVolStyle(styleName) {
        barModulesRoot.volStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.volStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setVolShowIcon(val) {
        if (!val && !barModulesRoot.volShowPercent) return;
        barModulesRoot.volShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.volShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setVolShowPercent(val) {
        if (!val && !barModulesRoot.volShowIcon) return;
        barModulesRoot.volShowPercent = val;
        let current = Config.getSetting("bar", {});
        current.volShowPercent = val;
        Config.setSetting("bar", current);
    }

    function setKbStyle(styleName) {
        barModulesRoot.kbStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.kbStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setKbShowIcon(val) {
        barModulesRoot.kbShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.kbShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setMediaInfoMode(val) {
        barModulesRoot.mediaInfoMode = val;
        let current = Config.getSetting("bar", {});
        current.mediaInfoMode = val;
        Config.setSetting("bar", current);
    }

    function setMediaWidth(val) {
        let current = Config.getSetting("bar", {});
        current.mediaWidth = val;
        Config.setSetting("bar", current);
    }

    function setMediaShowIcon(val) {
        barModulesRoot.mediaShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.mediaShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setMediaShowControls(val) {
        barModulesRoot.mediaShowControls = val;
        let current = Config.getSetting("bar", {});
        current.mediaShowControls = val;
        Config.setSetting("bar", current);
    }

    onVisibleChanged: {
        if (visible) {
            syncSettings();
        }
    }

    Component.onCompleted: {
        syncSettings();
    }

    Connections {
        target: Config
        function onSettingsLoaded() {
            barModulesRoot.syncSettings();
        }
        function onRawSettingsChanged() {
            barModulesRoot.syncSettings();
        }
    }
}

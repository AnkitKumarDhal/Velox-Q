import QtQuick
import qs.src.theme

Item {
    id: root

    property var model: []
    property string currentPage: ""
    property string orientation: "horizontal"

    signal pageChanged(string key)

    property string defaultPage: model.length > 0 ? model[0].key : ""
    function reset() {
        pageChanged(defaultPage);
    }

    implicitWidth: orientation === "vertical" ? Theme.controlHeightLarge : 0
    implicitHeight: orientation === "horizontal" ? 46 : 0

    property bool _scrollBusy: false

    Timer {
        id: scrollCooldown
        interval: 300
        onTriggered: root._scrollBusy = false
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (root._scrollBusy)
                return;
            root._scrollBusy = true;
            scrollCooldown.restart();
            const keys = root.model.map(m => m.key);
            const dir = event.angleDelta.y < 0 ? 1 : -1;
            const idx = (keys.indexOf(root.currentPage) + dir + keys.length) % keys.length;
            root.pageChanged(keys[idx]);
        }
    }

    // Horizontal
    Row {
        id: hRow
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: Theme.controlHeightLarge
        visible: root.orientation === "horizontal"

        Repeater {
            model: root.orientation === "horizontal" ? root.model : []

            delegate: Item {
                id: hTab
                readonly property bool isActive: root.currentPage === modelData.key

                width: hRow.width / root.model.length
                height: hRow.height

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - Theme.spacingXs, hIcon.implicitWidth + (hLabel.visible ? hLabel.implicitWidth + Theme.spacingMd : 0) + 24)
                    height: parent.height - Theme.spacingMd
                    radius: height / 2
                    color: hTab.isActive ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.18) : (hHov.containsMouse ? Colors.onSurfaceWeak : "transparent")

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motionFast
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spacingSm

                    Text {
                        id: hIcon
                        text: modelData.icon
                        font.pixelSize: Theme.fontSizeBody
                        font.family: Fonts.font
                        anchors.verticalCenter: parent.verticalCenter
                        color: hTab.isActive ? Colors.primary : (hHov.containsMouse ? Colors.onSurfaceStrong : Colors.onSurfaceMuted)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motionFast
                            }
                        }
                    }

                    Text {
                        id: hLabel
                        visible: modelData.label !== undefined
                        text: modelData.label ?? ""
                        font.pixelSize: Theme.fontSizeLabel
                        font.weight: hTab.isActive ? Theme.fontWeightBold : Theme.fontWeightRegular
                        font.family: Fonts.font
                        anchors.verticalCenter: parent.verticalCenter
                        color: hTab.isActive ? Colors.primary : (hHov.containsMouse ? Colors.onSurfaceStrong : Colors.onSurfaceMuted)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motionFast
                            }
                        }
                    }
                }

                MouseArea {
                    id: hHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pageChanged(modelData.key)
                }
            }
        }
    }

    // Bottom divider ( horizontal only )
    Rectangle {
        visible: root.orientation === "horizontal"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.borderThin
        color: Colors.outlineVariant
        opacity: 0.5
    }

    // Vertical
    Column {
        id: vCol
        anchors.centerIn: parent
        visible: root.orientation === "vertical"

        readonly property int tabH: 60
        spacing: root.model.length > 1 ? (root.height - root.model.length * tabH) / (root.model.length - 1) : 0

        Repeater {
            model: root.orientation === "vertical" ? root.model : []

            delegate: Rectangle {
                id: vTab
                readonly property bool isActive: root.currentPage === modelData.key

                width: Theme.controlHeightLarge
                height: vCol.tabH
                radius: Theme.pillRadius
                color: vTab.isActive ? Colors.primary : (vHov.containsMouse ? Colors.onSurfaceWeak : "transparent")

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.motionFast
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.pixelSize: Theme.fontSizeTitle
                    font.family: Fonts.font
                    color: vTab.isActive ? Colors.on_Primary : Colors.primary

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motionFast
                        }
                    }
                }

                MouseArea {
                    id: vHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pageChanged(modelData.key)
                }
            }
        }
    }
}

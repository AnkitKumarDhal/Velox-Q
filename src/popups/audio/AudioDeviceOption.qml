import QtQuick
import QtQuick.Layouts

import qs.src.theme

Item {
    id: root

    required property string deviceName
    required property bool isDefault
    required property string icon
    signal selected
    implicitHeight: 48

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusMd
        color: rowHov.pressed ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, Theme.statePressedOpacity) : rowHov.containsMouse ? Colors.surfaceContainerHighest : (root.isDefault ? Colors.primaryContainer : Colors.surfaceContainerHigh)

        border.width: root.isDefault ? 1 : 0
        border.color: Colors.primary

        Behavior on color {
            ColorAnimation {
                duration: Theme.motionFast
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: Theme.motionFast
            }
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: Theme.spacingXl
                rightMargin: Theme.spacingXl
            }
            spacing: Theme.spacingLg

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: Theme.radiusLg
                color: root.isDefault && !rowHov.containsMouse ? Colors.surface : Colors.surfaceContainerHighest

                Text {
                    anchors.centerIn: parent
                    text: root.icon
                    color: root.isDefault && !rowHov.containsMouse ? Colors.on_Surface : Colors.on_SurfaceVariant
                    font.family: Fonts.font
                    font.pixelSize: 14
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: root.deviceName
                    color: root.isDefault && !rowHov.containsMouse ? Colors.surface : Colors.on_SurfaceVariant
                    font.family: Fonts.font
                    font.pixelSize: 11
                    font.bold: root.isDefault
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: root.isDefault
                    text: "Default device"
                    color: root.isDefault && !rowHov.containsMouse ? Colors.surface : Colors.on_SurfaceVariant
                    font.family: Fonts.font
                    font.pixelSize: 8
                    Layout.fillWidth: true
                }
            }

            Text {
                visible: root.isDefault
                text: "󰄵"
                color: root.isDefault && !rowHov.containsMouse ? Colors.surface : Colors.primary
                font.family: Fonts.font
                font.pixelSize: 13
            }
        }

        MouseArea {
            id: rowHov
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!root.isDefault)
                    root.selected();
            }
        }
    }
}

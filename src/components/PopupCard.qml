import QtQuick
import qs.src.theme

Rectangle {
    id: root
    default property alias contentData: root.data
    radius: Theme.popupRadius
    color: Colors.surfaceContainer
    border.color: Colors.outlineVariant
    border.width: Theme.popupBorder
    clip: true
}

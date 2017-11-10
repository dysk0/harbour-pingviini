import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem {
    id: delegate
    property string label: ""
    property string value: ""
    width: parent.width
    height: Theme.itemSizeExtraSmall
    Label {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeSmall
        text: label
        color: (delegate.enabled ? (pressed ? Theme.highlightColor : Theme.primaryColor) : Theme.highlightColor)
    }
    Label {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeSmall
        text: value
        color: (delegate.enabled ? (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor) : Theme.secondaryHighlightColor)
    }
}

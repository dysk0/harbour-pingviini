import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property int value: 0;
    property string label: "Text";
    width: Theme.itemSizeMedium
    height: width



        Label {
            text: value
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.bold
            color: Theme.secondaryColor
        }
        Label {
            text: label.toUpperCase()
            font.pixelSize: Theme.fontSizeExtraSmall/2
            color: Theme.secondaryColor

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }

}

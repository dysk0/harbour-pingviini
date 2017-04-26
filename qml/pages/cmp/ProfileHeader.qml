import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property int value: 0;
    property string title: "Text";
    property string description: "Text";
    property string image: "";
    property string bg: "";
    width: parent.width
    height: icon.height + Theme.paddingLarge*2
    Image {
        anchors.fill: parent
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        source: bg
        opacity: 0.3
    }
    Rectangle {
        anchors.fill: parent
        opacity: 0.9
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#BF000000"  }
        }

    }
    Image {
        id: icon
        anchors {
            left: parent.left
            leftMargin: Theme.paddingLarge
            top: parent.top
            topMargin: Theme.paddingLarge
        }
        asynchronous: true
        width: Theme.iconSizeLarge
        height: width
        source: image.replace("_normal.", "_bigger.")
    }
    Label {
        id: ttl
        text: title
        height: contentHeight
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        font.family: Theme.fontFamilyHeading
        horizontalAlignment: Text.AlignRight
        anchors {
            top: icon.top
            left: icon.left
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingLarge
        }
    }
    Label {
        text: description
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeSmall
        font.family: Theme.fontFamilyHeading
        horizontalAlignment: Text.AlignRight
        anchors {
            top: ttl.bottom
            left: icon.left
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingLarge
        }
    }

}

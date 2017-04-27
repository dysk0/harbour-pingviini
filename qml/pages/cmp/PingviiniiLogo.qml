import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    width: Theme.itemSizeMedium
    height: width
    property int w: width
    property double opac: 1.0
    property int line: w*0.13
    Rectangle {
        id: circle
        anchors.fill: parent
        radius: width;
        color: "#404041"
        opacity: opac
    }



    Rectangle {
        anchors {
            fill: parent
            topMargin: w/2
            leftMargin: w/2
        }
        color: "#404041"
        opacity: opac
    }
    Rectangle {
        width: line
        height: w/2
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        color: "#404041"
        opacity: opac
    }
    Rectangle {
        width: w/2
        height: line
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        color: "#404041"
        opacity: opac
    }
    Rectangle {
        id: circleSmaller
        anchors {
            fill: parent
            topMargin: line
            leftMargin: line
            rightMargin: line
            bottomMargin: line
        }
        radius: width;
        color: "#FFF"
        opacity: 0.3
    }
    Rectangle {
        id: eye
        width: w*0.48
        height: width
        anchors {
            right: parent.right
            rightMargin: line
            bottom: parent.bottom
            bottomMargin: line*1.35
        }
        radius: width;
        color: "#FFF"
        opacity: opac
    }
    Rectangle {
        id: eyeBall
        width: w*0.13
        height: width
        anchors {
            right: parent.right
            rightMargin: line*2.1
            bottom: parent.bottom
            bottomMargin: line*2.3
        }
        radius: width;
        color: "#000"
        opacity: opac
    }
}

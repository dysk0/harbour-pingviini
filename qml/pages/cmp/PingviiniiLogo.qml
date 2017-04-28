import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    width: Theme.itemSizeMedium
    height: width
    property int w: width
    property double opac: 1.0
    property int line: w*0.13
    property int eyeW:   w*0.45
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
        id: bga
        width: eyeW
        height: w/2
        anchors {
            right: parent.right
            rightMargin: line
            bottom: parent.bottom
        }

        color: "#d1d1d1"
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
        width: eyeW
        height: width
        anchors {
            right: parent.right
            rightMargin: line
            bottom: parent.bottom
            bottomMargin: line*2
        }
        radius: width;
        color: "#FFF"
        Rectangle {
            id: eyeBall
            width: w*0.13
            height: width
            anchors {
                right: parent.right
                rightMargin: parent.width*0.15
                bottom: parent.bottom
                bottomMargin: parent.width*0.25
            }
            radius: width;
            color: "#000"
        }
        Timer{
            interval: 2; running: true; repeat: true
            onTriggered: {
                parent.rotation = parent.rotation+1
            }
        }
    }

    Item {
        id: kljunMaska
        width: eyeW*0.6
        height: width
        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        Canvas {
            width: eyeW
            height: width
            anchors {
                fill:parent
            }
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var centreX = width;
                var centreY = height;

                ctx.beginPath();
                ctx.fillStyle = "#b84902";
                ctx.moveTo(centreX, centreY);
                ctx.arc(centreX, centreY, width, Math.PI * 1, Math.PI * 1.5, false);
                ctx.lineTo(centreX, centreY);
                ctx.fill();


                ctx.beginPath();
                ctx.fillStyle = "#fd6702";
                ctx.moveTo(centreX, centreY);
                ctx.arc(centreX, centreY, width, Math.PI * 1, Math.PI * 1.25, false);
                ctx.lineTo(centreX, centreY);
                ctx.fill();



            }
        }
    }


}


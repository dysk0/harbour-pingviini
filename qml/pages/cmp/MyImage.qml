import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Item {
    property string type: ""
    property string previewURL: ""
    property string mediaURL: ""
    Rectangle {
        opacity: 0.2
        anchors.fill: parent
        color: Theme.highlightDimmerColor
    }
    Rectangle {
        id: progressRec
        anchors.bottom: parent.bottom
        width: 0
        height: Theme.paddingSmall
        color: Theme.highlightBackgroundColor
    }
    Image {
        anchors.fill: parent
        id:image
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        source: previewURL
        opacity: status === Image.Ready ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }
        onStatusChanged: {
            if (status === Image.Error)
                source = "image://theme/icon-m-image?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
        }
        onProgressChanged: progressRec.width = progress != 1 ? parent.width * progress : 0

        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("./../ImageFullScreen.qml"), {
                                   "type": type,
                                   "previewURL": previewURL,
                                   "mediaURL": mediaURL
                               })
                ///PageStack.push("./ImageFullScreen.qml", {"mediaURL": mediaURL})
                console.log(type); console.log(previewURL); console.log(mediaURL);
            }
        }


    }
    BusyIndicator {
        anchors.centerIn: image
        running: image.status !== Image.Ready
        size: BusyIndicatorSize.ExtraSmall
    }
}

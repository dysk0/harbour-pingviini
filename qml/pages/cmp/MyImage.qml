import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Item {
    property string mediaURL: ""
    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        source: mediaURL
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("./../ImageFullScreen.qml"), {"mediaURL": mediaURL})
                ///PageStack.push("./ImageFullScreen.qml", {"mediaURL": mediaURL})
                console.log(mediaURL)
            }
        }
    }
}

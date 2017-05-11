import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property string mediaURL: ""
    allowedOrientations: Orientation.All

    Item {
        anchors.fill: parent
        clip: true
        Image {
            id: image
            anchors.centerIn: parent
            //fillMode: Image.PreserveAspectCrop
            asynchronous: true
            source: mediaURL
            onStatusChanged: {
                if (status === Image.Ready) {
                    console.log('Loaded')
                    width = sourceSize.width
                    height = sourceSize.height
                    if (width > height)
                        pinch.scale = page.width / width
                    else
                        pinch.scale = page.height / height
                }
            }

        }
        PinchArea {
            id: pinch
            anchors.fill: parent
            pinch.target: image
            pinch.minimumScale: 0.1
            pinch.maximumScale: 10
            pinch.dragAxis: Pinch.XAndYAxis
        }
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Page {
    id: page

    property bool loadStarted: false
    allowedOrientations: Orientation.All

    ListModel {
        id: homeTimeLine
    }

    SilicaListView {
        id: listView
        header: PageHeader {
            title: qsTr("Messages")
        }

        anchors {
            fill: parent
        }

        width: parent.width
        model: homeTimeLine
        delegate: CmpTweet {

        }


        VerticalScrollDecorator {}


    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            //pageStack.pushAttached(Qt.resolvedUrl("Navigation.qml"), {"settings": {}})
        }
    }
    function showError(status, statusText) {
        infoPanel.open = true;

        if (status === 401){
            lblMsg.text = "Error: Unable to authorize with Twitter. Make sure the time/date of your phone is set correctly."
        } else {
            lblMsg.text = statusText
        }
    }
}


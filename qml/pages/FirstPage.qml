import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Page {
    id: page

    property bool loadStarted: false
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    ListModel {
        id: homeTimeLine
    }

    SilicaListView {
        id: listView
        header: PageHeader {
            title: qsTr("Pingviini")
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Add account")
                onClicked: pageStack.push(Qt.resolvedUrl("AccountAdd.qml"))
            }
        }
        anchors {
            fill: parent
            bottom: infoPanel.top
        }

        width: parent.width
        model: homeTimeLine
        delegate: CmpTweet {

        }


        footer: Item{
            width: parent.width
            height: Theme.iconSizeMedium

            Button {
                width: parent.width
                anchors.margins: Theme.paddingSmall
                onClicked: {
                    //console.log(JSON.stringify([Logic.OAUTH_CONSUMER_KEY, Logic.OAUTH_CONSUMER_SECRET, Logic.OAUTH_TOKEN, Logic.OAUTH_TOKEN_SECRET]))
                    var sinceId = false;
                    var maxId = false;
                    if (homeTimeLine.count){
                        maxId = homeTimeLine.get(homeTimeLine.count-1).id
                    }


                    Logic.getHomeTimeline(sinceId, maxId, function(data) {
                        for (var i=0; i < data.length; i++) {
                            homeTimeLine.append(data[i])
                            if (i < 1){
                                console.log(JSON.stringify(data[i]));
                            }
                        }
                    }, showError)
                }
            }
            BusyIndicator {
                size: BusyIndicatorSize.Small
                running: true;
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        VerticalScrollDecorator {}

        onContentYChanged: {
            if(contentY+200 > listView.contentHeight-listView.height-listView.footerItem.height && !loadStarted){
                loadStarted = true;
            }
            console.log((contentY+200) + ' ' + listView.contentHeight)
        }
    }
    DockedPanel {
        id: infoPanel
        open: true
        width: page.isPortrait ? parent.width : Theme.itemSizeExtraLarge + Theme.paddingLarge
        height: page.isPortrait ? Theme.itemSizeExtraLarge + Theme.paddingLarge : parent.height
        dock: page.isPortrait ? Dock.Bottom : Dock.Right
        Label {
            id: lblMsg
            anchors {
                verticalCenter: parent.verticalCenter
            }
            horizontalAlignment: Text.Center
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.secondaryColor
        }
        MouseArea {
            enabled: infoPanel.open
            anchors.fill: parent
            onClicked: infoPanel.open = false
        }

    }
    Component.onCompleted: {
        console.log("-------------getConf")
        console.log(JSON.stringify(Logic.conf))

        /**/
    }
    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("Navigation.qml"), {"settings": {}})
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


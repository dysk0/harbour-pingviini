import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Page {
    id: page
    property bool loadStarted: false
    property int scrollOffset: 0
    property string activeView: "timeline"
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    Loader {
        id: componentLoader
        anchors {
            fill: parent
            leftMargin: 0
            topMargin: 0
            rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
            bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
        }
        sourceComponent: activeView == "timeline" ? timelineViewComponent : messagessViewComponent
    }

    ListModel {
        id: homeTimeLine
    }


    DockedPanel {
        id: infoPanel
        open: true
        width: page.isPortrait ? parent.width : Theme.itemSizeLarge
        height: page.isPortrait ? Theme.itemSizeLarge : parent.height
        dock: page.isPortrait ? Dock.Bottom : Dock.Right
        Navigation {
            isPortrait: !page.isPortrait
        }

    }
    Component.onCompleted: {
        console.log("-------------getConf")
        console.log(JSON.stringify(Logic.conf))

        /**/
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

    Component {
        id: timelineViewComponent
        SilicaListView {
            id: timeline
            anchors.fill: parent
            header: PageHeader {
                title: qsTr("Pingviini")
            }
            PullDownMenu {
                MenuItem {
                    text: qsTr("Add account")
                    onClicked: pageStack.push(Qt.resolvedUrl("AccountAdd.qml"))
                }
            }


            clip: isPortrait && (infoPanel.expanded)

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
                if(contentY+200 > timeline.contentHeight-timeline.height-timeline.footerItem.height && !loadStarted){
                    loadStarted = true;
                }
                //console.log((contentY+200) + ' ' + listView.contentHeight)
                if (contentY > scrollOffset) {
                    infoPanel.open = false
                } else {
                    infoPanel.open = true
                }

                scrollOffset = contentY;
            }
        }
    }


    Component {
        id: messagessViewComponent
        SilicaListView {
            id: timeline
            anchors.fill: parent
            header: PageHeader {
                title: qsTr("Messagess")
            }



            clip: isPortrait && (infoPanel.expanded)

            width: parent.width


            VerticalScrollDecorator {}

            onContentYChanged: {
                if(contentY+200 > timeline.contentHeight-timeline.height-timeline.footerItem.height && !loadStarted){
                    loadStarted = true;
                }
                //console.log((contentY+200) + ' ' + listView.contentHeight)
                if (contentY > scrollOffset) {
                    infoPanel.open = false
                } else {
                    infoPanel.open = true
                }

                scrollOffset = contentY;
            }
        }
    }


}




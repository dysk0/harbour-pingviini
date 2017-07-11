import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "./cmp/"



Page {
    id: mainPage
    property bool isFirstPage: true
    allowedOrientations: Orientation.All

    DockedPanel {
        id: infoPanel
        open: true
        width: mainPage.isPortrait ? parent.width : Theme.itemSizeLarge
        height: mainPage.isPortrait ? Theme.itemSizeLarge : parent.height
        dock: mainPage.isPortrait ? Dock.Bottom : Dock.Right
        Navigation {
            id: navigation
            isPortrait: !mainPage.isPortrait
            onSlideshowShow: {
                console.log(vIndex)
                slideshow.positionViewAtIndex(vIndex, ListView.SnapToItem)
            }
        }
    }


    VisualItemModel {
        id: visualModel
        MyList {
            id: timelineViewComponent
            header: PageHeader {
                title: qsTr("Timeline")
                description: qsTr("Pingviini")
            }
            model: Logic.modelTL
            action: "statuses_homeTimeline"
            vars: {"count":200}
            conf: Logic.getConfTW()
            width: parent.width
            height: parent.height
            onOpenDrawer:  infoPanel.open = setDrawer
            delegate: Tweet {}
        }

        MyList {
            id: mentionsViewComponent
            header: PageHeader {
                title: qsTr("Mentions")
                description: qsTr("Pingviini")
            }
            model: Logic.modelMN
            action: "statuses_mentionsTimeline"
            vars: {"count":200}
            conf: Logic.getConfTW()
            width: parent.width
            height: parent.height
            onOpenDrawer:  infoPanel.open = setDrawer
            delegate: Tweet {}
        }
        MyList {
            id: dmList
            header: PageHeader {
                title: qsTr("Messages")
                description: qsTr("Pingviini")
            }
            mdl: Logic.modelDM
            action: ""
            vars: {"count":200}
            conf: Logic.getConfTW()
            width: parent.width
            height: parent.height
            onOpenDrawer:  infoPanel.open = setDrawer
            delegate: BackgroundItem {
                height: Theme.itemSizeLarge
                Column {
                    anchors.fill: parent
                    Label { text: user_id}
                    Label { text: "aa"}
                }
                onPressAndHold: {
                    console.log(JSON.stringify(Logic.getUserFromModel(user_id)))
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Conversation.qml"), { tweets: Logic.parseDM.getThread(user_id)})
                }
            }
        }

       MyList{
            id: tlSearch;
            property string search;
            onSearchChanged: {
                mdl = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
                tlSearch.action = "search_tweets"
                //Logic.modelSE.clear()
                tlSearch.vars = {'q' : search }
                loadData("append")

            }
            onTypeChanged: {
                console.log("type changed")
            }
            title: qsTr("Search")
            type: ""
            mdl: ListModel {}
            vars: {}
            conf: Logic.getConfTW()
            width: parent.width
            height: parent.height
            onOpenDrawer:  infoPanel.open = setDrawer
            action: ""
            delegate: Tweet {}
            header: SearchField {
                width: parent.width
                text: tlSearch.search
                placeholderText: "Search"
                labelVisible: false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    tlSearch.search = text
                    focus = false
                }
            }
            ViewPlaceholder {
                                enabled: tlSearch.mdl === 0
                                text: "Only #hastag search works"
                            }
        }
    }

    SlideshowView {
        id: slideshow
        width: parent.width
        height: parent.height
        itemWidth: parent.width
        clip: true
        onCurrentIndexChanged: {
            navigation.slideshowIndexChanged(currentIndex)
        }

        anchors {
            fill: parent
            leftMargin: 0
            top: parent.top
            topMargin: 0
            rightMargin: mainPage.isPortrait ? 0 : infoPanel.visibleSize
            bottomMargin: mainPage.isPortrait ? infoPanel.visibleSize : 0
        }
        model: visualModel
        Component.onCompleted: {
        }
    }

    IconButton {
        anchors {
            right: (mainPage.isPortrait ? parent.right : infoPanel.left)
            bottom: (mainPage.isPortrait ? infoPanel.top : parent.bottom)
            margins: {
                left: Theme.paddingLarge
                bottom: Theme.paddingLarge
            }
        }

        id: newTweet
        width: Theme.iconSizeLarge
        height: width
        visible: !isPortrait ? true : !infoPanel.open
        icon.source: "image://theme/icon-l-add"
        onClicked: {
            pageStack.push(Qt.resolvedUrl("TweetDetails.qml"), {title: "New Tweet", tweetType: "New"})
        }
    }
    function onLinkActivated(href){
        if (href[0] === '#' || href[0] === '@' ) {
            tlSearch.search = href
            slideshow.positionViewAtIndex(3, ListView.SnapToItem)
            navigation.navigateTo('search')

        } else {
            pageStack.push(Qt.resolvedUrl("Browser.qml"), {"href" : href})
        }
    }
    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            if (messageObject.error){
                console.log(JSON.stringify(messageObject))
            }
        }
    }
    Component.onCompleted: {
        var obj = {};
        Logic.mediator.installTo(obj);
        obj.subscribe('bgCommand', function(msg){
            worker.sendMessage({conf: Logic.getConfTW(), headlessAction: msg[0].headlessAction, params: msg[0].params});
        })
    }
}




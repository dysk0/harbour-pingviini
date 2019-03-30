import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "./cmp/"


Page {

    id: mainPage
    property bool isFirstPage: true
    allowedOrientations: Orientation.All
    Banner {
        id: banner
    }

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
        //*
        MyList {
            id: timelineViewComponent
            header: PageHeader {
                title: qsTr("Timeline")
                description: qsTr("Pingviini")
            }
            mdl: Logic.modelTL
            action: "statuses_homeTimeline"
            vars: {"count":200}
            conf: Logic.getConfTW()
            width: parent.width
            height: parent.height
            onOpenDrawer:  infoPanel.open = setDrawer
            delegate: CmpTweet { tweet: model}
        }

        MyList {
            id: mentionsViewComponent
            header: PageHeader {
                title: qsTr("Mentions")
                description: qsTr("Pingviini")
            }
            mdl: Logic.modelMN
            action: "statuses_mentionsTimeline"
            vars: {"count":200}
            conf: Logic.getConfTW()
            width: parent.width
            height: parent.height
            onOpenDrawer:  infoPanel.open = setDrawer
            delegate: CmpTweet { tweet: model}
        }



        DirectMessages {
            width: parent.width
            height: parent.height
        }

        MyList{

            ListView {
                visible: tlSearch.mdl.count === 0
                model: ListModel {id: modelTrends}
                width: parent.width
                height: parent.height
                clip: true
                anchors {
                    top: parent.top
                    topMargin: Theme.itemSizeLarge
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                delegate: BackgroundItem {
                    width: parent.width
                    height: Theme.itemSizeSmall
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.name
                        color: (pressed ? Theme.highlightColor : Theme.primaryColor)
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    Label {
                        visible: model.tweets > 0
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: Theme.horizontalPageMargin
                        text: model.tweets.toLocaleString()
                        color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    onClicked: {
                        searchField.text = tlSearch.search = modelTrends.get(index).name
                    }
                }
                Component.onCompleted: {
                    worker.sendMessage({
                                           'bgAction'  : 'trends_place',
                                           'params'    : { id: 1 },
                                           'model'     : modelTrends,
                                           'mode'      : "append",
                                           'conf'      : Logic.getConfTW()
                                       });
                }
            }
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
            delegate: CmpTweet { tweet: model}
            header: Item {
                id: header
                width: tlSearchheaderContainer.width
                height: tlSearchheaderContainer.height
                Component.onCompleted: tlSearchheaderContainer.parent = header
            }
            Column {
                id: tlSearchheaderContainer

                width: tlSearch.width

                SearchField {
                    width: parent.width
                    id: searchField
                    placeholderText: qsTr("Search")
                    labelVisible: false
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: {
                        tlSearch.search = text
                        focus = false
                    }
                    onTextChanged: {
                        if (text === "")
                            tlSearch.mdl.clear();
                    }
                }
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
            pageStack.push(Qt.resolvedUrl("TweetDetails.qml"), {title: qsTrId("new-tweet"), tweetType: "New"})
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
            if (messageObject.success){
                if (["directMessages_events_list"].indexOf(messageObject.action) > -1){
                    generateDirMsgList()
                    if(messageObject.action === "directMessages") {
                    }
                }
            }
        }
    }
    Component.onCompleted: {


        var obj = {};
        Logic.mediator.installTo(obj);
        obj.subscribe('bgCommand', function(msg){
            console.log(JSON.stringify(msg))
            worker.sendMessage({conf: Logic.getConfTW(), headlessAction: msg[0].headlessAction, params: msg[0].params});
        })
    }
    function generateDirMsgList(){
        console.log("APAPPAPAPAPAPPAPAPAPAPPAPPAPAPAPPAPA")
        var filter = []

        Logic.modelDM.clear();
        for(var i = 0; i < Logic.modelDMraw.count; i++){
            var item = Logic.modelDMraw.get(i)
            if (filter.indexOf(item.group) === -1){
                Logic.modelDM.append(item)
                filter.push(item.group)
            }
        }
    }
}




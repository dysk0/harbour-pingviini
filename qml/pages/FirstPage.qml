import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic



Page {
    id: page
    property var locale: Qt.locale()
    property bool loadStarted: false
    property int scrollOffset: 0
    property string activeView: "timeline"
    property double scrollOffsetTL: 0
    property int currentIndexTL: 0
    property double scrollOffsetMN: 0
    property int currentIndexMN: 0
    property double scrollOffsetDM: 0
    property int currentIndexDM: 0
    allowedOrientations: Orientation.All

    signal buttonPressedAtBPage();
    onButtonPressedAtBPage: console.log("Mouse pressed at B page");

    /*Loader {
        id: componentLoader
        anchors {
            fill: parent
            leftMargin: 0
            topMargin: 0
            rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
            bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
        }
        sourceComponent: timelineViewComponent
    }*/
    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: myText.text = messageObject.reply
    }





    DockedPanel {
        id: infoPanel
        open: true
        width: page.isPortrait ? parent.width : Theme.itemSizeLarge
        height: page.isPortrait ? Theme.itemSizeLarge : parent.height
        dock: page.isPortrait ? Dock.Bottom : Dock.Right
        Navigation {
            id: navigation
            isPortrait: !page.isPortrait
        }

    }
    /* Component.onCompleted: {
        console.log("-------------getConf")
        console.log(JSON.stringify(Logic.conf))

        var obj = {};
        Logic.mediator.installTo(obj);
        obj.subscribe('confLoaded', function(){
            console.log(typeof arguments)
            console.log('confLoaded');

            pageStack.pushAttached(Qt.resolvedUrl("SecondPage.qml"), {"model": model})
            console.log(JSON.stringify(arguments));

            var msg = {
                'action': 'statuses_homeTimeline',
                'model' : Logic.modelTL,
                'mode'  : placement,
                'conf'  : Logic.getConfTW()
            };
            worker.sendMessage(msg);
        });


    }*/
    onStatusChanged: {
        if (status === PageStatus.Active) {



            //pageStack.pushAttached(Qt.resolvedUrl("Navigation.qml"), {"settings": {}})
            var str = "Fri Feb 10 14:16:37 +0000 2017"
            //2017-02-10T13:47:17.000Z

            print(Date.fromLocaleString(locale, str, "ddd MMM dd HH:mm:ss +0000 yyyy"));
            //console.log(parseISO8601(str))
        }
    }
    function showError(status, statusText) {
        infoPanel.open = true;

        if (status === 401){
            lblMsg.text = "Error: Unable to authorize with Twitter. Make sure the time/date of your phone is set correctly."
        } else {
            console.log(statusText)
        }
    }

    Timeline {
        id: timelineViewComponent

    }
    Mentions {
        id: mentionsViewComponent
        visible: false;
    }


    CmpDirectMessages {
        id: dmsgViewComponent
        visible: false;
    }
    SearchView {
        id: searchViewComponent
        visible: false;
    }
    IconButton {
        anchors {
            right: (page.isPortrait ? parent.right : infoPanel.left)
            bottom: (page.isPortrait ? infoPanel.top : parent.bottom)
            margins: {
                left: Theme.paddingLarge
                bottom: Theme.paddingLarge
            }
        }

        id: newTweet
        width: Theme.iconSizeLarge
        height: width
        visible: !infoPanel.open
        icon.source: "image://theme/icon-l-add"
        onClicked: {
            pageStack.push(Qt.resolvedUrl("TweetDetails.qml"), {title: "New Tweet", tweetType: "New"})
        }
    }
    function onLinkActivated(href){
        if (href[0] === '#' || href[0] === '@' ) {
            searchViewComponent.search(href)
            navigation.navigateTo('search')

        } else {
            pageStack.push(Qt.resolvedUrl("Browser.qml"), {"href" : href})
        }
    }

}




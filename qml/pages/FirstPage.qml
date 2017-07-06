import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.notifications 1.0
import "../lib/Logic.js" as Logic
import "./cmp/"



Page {
    id: page
    property var locale: Qt.locale()
    property bool isFirstPage: true
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
    signal openDrawer (bool open)
    signal navigateTo(string slug)
    onNavigateTo: console.log("Navigate to " + slug )

    onOpenDrawer: {
        infoPanel.open = !isPortrait ? true : open
    }

    signal notify (string what, int num)
    onNotify: {
        console.log(what + " a - " + num)
        switch (what) {
            case "statuses_homeTimeline":
                navigation.model.setProperty(0, "unread", true)
                break;
            case "statuses_mentionsTimeline":
                navigation.model.setProperty(1, "unread", true)
                break;
        }
    }

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
        onMessage: {
            console.log(JSON.stringify(messageObject))
        }
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

    onStatusChanged: {


        if (status === PageStatus.Active) {
            app.cover.status = "BABABAB"
            //pageStack.pushAttached(Qt.resolvedUrl("Navigation.qml"), {"settings": {}})
            var str = "Fri Feb 10 14:16:37 +0000 2017"
            //2017-02-10T13:47:17.000Z

            print(Date.fromLocaleString(locale, str, "ddd MMM dd HH:mm:ss +0000 yyyy"));
            //console.log(parseISO8601(str))
        }
        if (status == PageStatus.Deactivating) {
            app.cover.status = "Aaa"

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


   MyList {
        id: timelineViewComponent
        onSend: {
            console.log("Main View send signal emitted with notice: " + notice)
            onLinkActivated(notice)
        }

        onNotify: {
            page.notify(what, num)
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Load more")
                onClicked: {
                    loadData("prepend")
                }
            }

        }
        header: PageHeader {
            title: qsTr("Timeline")
            description: qsTr("Pingviini")
        }

        anchors {
            fill: parent
            leftMargin: 0
            top: parent.top
            topMargin: 0
            rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
            bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
        }
        clip: true

        model: Logic.modelTL
        action: "statuses_homeTimeline"
        vars: {"count":200}
        conf: Logic.getConfTW()
        onOpenDrawer: {
            infoPanel.open = setDrawer
        }
    }

    MyList {
        id: mentionsViewComponent
        visible: false;
        onSend: {
            console.log("Main View send signal emitted with notice: " + notice)
            onLinkActivated(notice)
        }
        header: PageHeader {
            title: qsTr("Mentions")
            description: qsTr("Pingviini")
        }

        anchors {
            fill: parent
            leftMargin: 0
            top: parent.top
            topMargin: 0
            rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
            bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
        }
        clip: true

        model: Logic.modelMN
        action: "statuses_mentionsTimeline"
        vars: {"count":200}
        conf: Logic.getConfTW()
        onOpenDrawer: {
            infoPanel.open = setDrawer
        }
    }





    DirectMessages {
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
        visible: !isPortrait ? true : !infoPanel.open
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


        Notification {
            id: notification
            category: "x-nemo.example"
            summary: "Notification summary"
            previewBody : "sss"
            body: "Notification body"
            onClicked: console.log("Clicked")
            urgency: Notification.Critical

        }




}




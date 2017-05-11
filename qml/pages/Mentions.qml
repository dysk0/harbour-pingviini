import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic


SilicaListView {
    id: timeline
    property var locale: Qt.locale()
    anchors {
        fill: parent
        leftMargin: 0
        topMargin: 0
        rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
        bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
    }

    Component.onCompleted: {
        if (Logic.modelMN.count === 0){
            loadData("append")
        }
    }
    ViewPlaceholder {
        enabled: Logic.modelMN.count === 0
        text: "Loading tweets"
        hintText: "Please wait..."
    }


    function loadData(placement){
        var msg = {
            'action': 'statuses_mentionsTimeline',
            'model' : Logic.modelMN,
            'mode'  : placement,
            'conf'  : Logic.getConfTW()
        };
        worker.sendMessage(msg);
    }

    section {
        property: 'section'
        criteria: ViewSection.FullString
        delegate: SectionHeader  {
            text: {
                var dat = Date.fromLocaleDateString(locale, section);
                dat = Format.formatDate(dat, Formatter.TimepointRelativeCurrentDay)
                if (dat === "00:00:00") {
                    visible = false;
                    height = 0;
                    return  " ";
                }else {
                    return dat;
                }

            }

        }
    }

    header: PageHeader {
        title: qsTr("Mentions")
        description: qsTr("Pingviini")
    }
    PullDownMenu {
        spacing: Theme.paddingLarge
        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("prepend")
            }
        }
    }
    PushUpMenu {
        spacing: Theme.paddingLarge
        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("append")
            }
        }
    }


    clip: isPortrait && (infoPanel.expanded)


    model: Logic.modelMN
    delegate: CmpTweet {
        onClicked: {
            pageStack.push(Qt.resolvedUrl("TweetDetails.qml"), {
                               "tweets": Logic.modelMN,
                               "screenName": Logic.modelMN.get(index).screenName,
                               "selected": index
                           })
        }
    }

    VerticalScrollDecorator {}


    onMovementEnded: {
        scrollOffsetMN = contentY
        currentIndexMN = currentIndex
    }
    onCountChanged: {
        if (scrollOffsetMN)
            contentY = scrollOffsetMN
        // currentIndex  = currentIndexMN
    }
    onContentYChanged: {

        if(contentY+200 > timeline.contentHeight-timeline.height&& !loadStarted){
            openDrawer(true)
        }
        if (contentY > scrollOffsetMN) {
            openDrawer(false)
        } else {
            openDrawer(true)
        }
        scrollOffsetMN = contentY
        currentIndexMN = currentIndex
    }
}


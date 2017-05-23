import QtQuick 2.0
import Sailfish.Silica 1.0
import "./cmp/"
import "../lib/Logic.js" as Logic


    SilicaListView {
        //property type name: value
        id: timeline
        signal navigateTo(string slug)
        onNavigateTo: parent.navigateTo(slug)
        anchors {
            fill: parent
            leftMargin: 0
            top: parent.top
            topMargin: 0
            rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
            bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
        }

        Component.onCompleted: {
            if (modelTL.count === 0){
                loadData("append")
            }

        }
        ViewPlaceholder {
            enabled: Logic.modelTL.count === 0
            text: "Loading tweets"
            hintText: "Please wait..."
        }


        function loadData(placement){
            var msg = {
                'action': 'statuses_homeTimeline',
                'model' : Logic.modelTL,
                'mode'  : placement,
                'conf'  : Logic.getConfTW()
            };
            worker.sendMessage(msg);
        }
        property var locale: Qt.locale()
        section {
            property: 'section'
            criteria: ViewSection.FullString
            delegate: SectionHeader  {
                text: {
                    var dat = Date.fromLocaleDateString(locale, section);
                    dat = Format.formatDate(dat, Formatter.TimepointRelativeCurrentDay)
                    if (dat === "00:00:00" || dat === "00:00") {
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
            title: qsTr("Timeline")
            description: qsTr("Pingviini")
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Add account")
                onClicked: pageStack.push(Qt.resolvedUrl("AccountAdd.qml"))
            }
            MenuItem {
                text: qsTr("Show navigation")
                onClicked: {
                    infoPanel.open = true;
                }
            }
            MenuItem {
                text: qsTr("Load more")
                onClicked: {
                    timeline.loadData("prepend")
                }
            }
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Load more")
                onClicked: {
                    timeline.loadData("append")
                }
            }
        }


        clip: isPortrait && (infoPanel.expanded)


        model: Logic.modelTL
        delegate: CmpTweet {
            onClicked: {
                pageStack.push(Qt.resolvedUrl("TweetDetails.qml"), {
                                   "tweets": Logic.modelTL,
                                   "screenName": Logic.modelTL.get(index).screenName,
                                   "selected": index
                               })
            }
        }

        VerticalScrollDecorator {}

        onCountChanged: {
            timeline.contentY = scrollOffsetTL
            // currentIndex  = currentIndexTL
        }
        onContentYChanged: {

            if(contentY+200 > timeline.contentHeight-timeline.height&& !loadStarted){
                openDrawer(true)
            }
            if (contentY > scrollOffsetTL) {
                openDrawer(false)
            } else {
                if (contentY < 100 && !loadStarted){
                    //timeline.loadData("prepend")
                    //loadStarted = true;
                }
                openDrawer(true)
            }
            scrollOffsetTL = contentY
            currentIndexTL = currentIndex
        }
    }

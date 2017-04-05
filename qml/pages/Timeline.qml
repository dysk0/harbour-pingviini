import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Component {
    SilicaListView {
        //property type name: value
        id: timeline
        anchors.fill: parent

        Component.onCompleted: {
            if (modelTL.count === 0){
                loadData("append")
            } else {

                console.log("positioning")
                timeline.contentY = scrollOffsetTL

            }
            var obj = {};
            Logic.mediator.installTo(obj);
            obj.subscribe('confLoaded', function(){
                console.log(typeof arguments)
                console.log('confLoaded');
                //timeline.loadData("append")
                console.log(JSON.stringify(arguments));
            });
        }
        ViewPlaceholder {
            enabled: Logic.modelTL.count === 0
            text: "Loading tweets"
            hintText: "Please wait..."
        }


        function loadData(placement){
            /*var msg = {
                'action': 'getHomeTimeline',
                'model' : modelTL,
                'mode'  : placement,
                'conf'  : Logic.getConfTW()
            };
            worker.sendMessage(msg);*/
        }

        header: PageHeader {
            title: qsTr("Timeline")
            description: qsTr("Pingviini")
        }
        PullDownMenu {
            spacing: Theme.paddingLarge
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
            spacing: Theme.paddingLarge
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

        }

        VerticalScrollDecorator {}

        onCountChanged: {
            timeline.contentY = scrollOffsetTL
            // currentIndex  = currentIndexTL
        }
        onContentYChanged: {

            if(contentY+200 > timeline.contentHeight-timeline.height&& !loadStarted){
                loadStarted = true;
            }
            //console.log((contentY+200) + ' ' + listView.contentHeight)
            if (contentY > scrollOffsetTL) {
                infoPanel.open = false
            } else {
                if (contentY < 100 && !loadStarted){
                    //timeline.loadData("prepend")
                    //loadStarted = true;
                }
                infoPanel.open = true
            }
            scrollOffsetTL = contentY
            currentIndexTL = currentIndex
        }
    }
}

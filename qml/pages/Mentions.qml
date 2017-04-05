import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Component {
    SilicaListView {
        id: timeline
        anchors.fill: parent

        Component.onCompleted: {
            if (modelMN.count === 0){
                loadData("append")
            } else {
                if (scrollOffsetMN)
                    contentY = scrollOffsetMN
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
            enabled: Logic.modelMN.count == 0
            text: "Loading tweets"
            hintText: "Please wait..."
        }


        function loadData(placement){
            /*var msg = {
                'action': 'getMentionsTimeline',
                'model' : modelMN,
                'mode'  : placement,
                'conf'  : Logic.getConfTW()
            };
            worker.sendMessage(msg);*/
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


        model: Logic.modelMN
        delegate: CmpTweet {

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
                loadStarted = true;
            }
            //console.log((contentY+200) + ' ' + listView.contentHeight)
            if (contentY > scrollOffsetMN) {
                infoPanel.open = false
            } else {
                if (contentY < 100 && !loadStarted){
                    //timeline.loadData("prepend")
                    //loadStarted = true;
                }
                infoPanel.open = true
            }
            scrollOffsetMN = contentY
            currentIndexMN = currentIndex
        }
    }
}

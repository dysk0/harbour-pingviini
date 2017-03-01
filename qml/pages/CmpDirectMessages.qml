import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Mediator.js" as Mediator
import "../lib/Logic.js" as Logic

Component {
    SilicaListView {
        id: timelineDM
        anchors.fill: parent

        Component.onCompleted: {
            if (modelDM.count === 0){
                loadData("append")
            } else {
                timelineDM.contentY = scrollOffsetDM
            }
            var obj = {};
            Logic.mediator.installTo(obj);
            obj.subscribe('confLoaded', function(){
                console.log(typeof arguments)
                console.log('confLoaded');
                //timelineDM.loadData("append")
                console.log(JSON.stringify(arguments));
            });
        }
        ViewPlaceholder {
            enabled: modelDM.count == 0
            text: "Loading tweets"
            hintText: "Please wait..."
        }


        function loadData(placement){
            var msg = {
                'action': 'getDirectMsg',
                'model' : modelDM,
                'mode'  : placement,
                'conf'  : Logic.getConfTW()
            };
            worker.sendMessage(msg);
        }

        header: PageHeader {
            title: qsTr("Messages")
            description: qsTr("Pingviini")
        }
        PullDownMenu {
            spacing: Theme.paddingLarge
            MenuItem {
                text: qsTr("Load more")
                onClicked: {
                    timelineDM.loadData("prepend")
                }
            }
        }
        PushUpMenu {
            spacing: Theme.paddingLarge
            MenuItem {
                text: qsTr("Load more")
                onClicked: {
                    timelineDM.loadData("append")
                }
            }
        }


        clip: isPortrait && (infoPanel.expanded)


        model: modelDM
        delegate: CmpTweet {

        }

        VerticalScrollDecorator {}

        onMovementEnded: {
            scrollOffsetDM = contentY
            currentIndexDM = currentIndex
        }
        onCountChanged: {
            contentY = scrollOffsetDM
            // currentIndex  = currentIndexDM
        }
        onContentYChanged: {
            //console.log(".....contentY: " + contentY)

            if(contentY+200 > timelineDM.contentHeight-timelineDM.height&& !loadStarted){
                loadStarted = true;
            }
            //console.log((contentY+200) + ' ' + listView.contentHeight)
            if (contentY > scrollOffsetDM) {
                infoPanel.open = false
            } else {
                if (contentY < 100 && !loadStarted){
                    //timelineDM.loadData("prepend")
                    //loadStarted = true;
                }
                infoPanel.open = true
            }
        }
    }
}

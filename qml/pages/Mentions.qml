import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Mediator.js" as Mediator
import "../lib/Logic.js" as Logic

Component {
    SilicaListView {
        Component.onCompleted: {
            if (modelMN.count === 0){
                loadData("append")
            } else {
                timeline.contentY = scrollOffsetMN
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

        id: timeline
        function parseISO8601(str) {
            try {
                // we assume str is a UTC date ending in 'Z'
                var _date = new Date();
                var parts = str.split(' '),
                        timeParts = parts[3].split(":"),
                        monthPart = parts[1].replace("Jan", "1").replace("Feb", "2").replace("Mar", "3").replace("Apr", "4").replace("May", "5").replace("Jun", "6").replace("Jul", "7").replace("Aug", "8").replace("Sep", "9").replace("Oct", "10").replace("Nov", "11").replace("Dec", "12");
                //console.log(JSON.stringify([parts, timeParts]))

                _date.setUTCFullYear(Number(parts[5]));
                _date.setUTCMonth(Number(monthPart)-1);
                _date.setUTCDate(Number(parts[2]));
                _date.setUTCHours(Number(timeParts[0]));
                _date.setUTCMinutes(Number(timeParts[1]));
                _date.setUTCSeconds(Number(timeParts[2]));

                return _date;
            }
            catch (error) {
                return null;
            }
        }
        function loadData(placement){
            console.log(placement)
            var sinceId = false;
            var maxId = false;
            if (modelMN.count){
                maxId = model.get(modelMN.count-1).id
                if (placement === "prepend"){
                    maxId = false;
                    sinceId = modelMN.get(0).id
                }
            }


            Logic.getMentions(sinceId, maxId, function(data) {

                var now = new Date().getTime()
                for (var i=0; i < data.length; i++) {
                    data[i].created_at = parseISO8601(data[i].created_at) //Date.fromLocaleString(locale, data[i].created_at, "ddd MMM dd HH:mm:ss +0000 yyyy")
                    if (placement === "prepend"){
                        modelMN.insert(0, data[i])
                    } else {
                        modelMN.append(data[i])
                    }
                    if (i < 1){
                        //console.log(JSON.stringify(data[i]));
                    }
                }
                loadStarted = false;
            }, showError)
        }
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Mentions")
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Show navigation")
                onClicked: {
                    infoPanel.open = true;
                }
            }
        }


        clip: isPortrait && (infoPanel.expanded)


        model: modelMN
        delegate: CmpTweet {

        }


        footer: Item{
            width: parent.width
            height: Theme.iconSizeMedium

            Button {
                width: parent.width
                anchors.margins: Theme.paddingSmall
                onClicked: {
                    timeline.loadData("append")
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

        onMovementEnded: {
            scrollOffsetMN  = contentY
        }

        onContentYChanged: {
            if(contentY+200 > timeline.contentHeight-timeline.height-timeline.footerItem.height && !loadStarted){
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
        }
    }
}

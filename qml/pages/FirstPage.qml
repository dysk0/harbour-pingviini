import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Mediator.js" as Mediator
import "../lib/Logic.js" as Logic


Page {
    id: page
    property var locale: Qt.locale()
    property bool loadStarted: false
    property int scrollOffset: 0
    property string activeView: "timeline"
    allowedOrientations: Orientation.All

    Loader {
        id: componentLoader
        anchors {
            fill: parent
            leftMargin: 0
            topMargin: 0
            rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
            bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
        }
        sourceComponent: activeView == "timeline" ? timelineViewComponent : messagessViewComponent
    }

    ListModel {
        id: homeTimeLine
    }


    DockedPanel {
        id: infoPanel
        open: true
        width: page.isPortrait ? parent.width : Theme.itemSizeLarge
        height: page.isPortrait ? Theme.itemSizeLarge : parent.height
        dock: page.isPortrait ? Dock.Bottom : Dock.Right
        Navigation {
            isPortrait: !page.isPortrait
        }

    }
    Component.onCompleted: {
        console.log("-------------getConf")
        console.log(JSON.stringify(Logic.conf))

        var obj = {};
        Logic.mediator.installTo(obj);
        obj.subscribe('confLoaded', function(){
            console.log(typeof arguments)
            console.log('confLoaded');
            console.log(JSON.stringify(arguments));
        });


    }
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

    Component {
        id: timelineViewComponent


        SilicaListView {
            Component.onCompleted: {
                var obj = {};
                Logic.mediator.installTo(obj);
                obj.subscribe('confLoaded', function(){
                    console.log(typeof arguments)
                    console.log('confLoaded');
                    timeline.loadData("append")
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
                if (homeTimeLine.count){
                    maxId = homeTimeLine.get(homeTimeLine.count-1).id
                    if (placement === "prepend"){
                        maxId = false;
                        sinceId = homeTimeLine.get(0).id
                    }
                }


                Logic.getHomeTimeline(sinceId, maxId, function(data) {

                    var now = new Date().getTime()
                    for (var i=0; i < data.length; i++) {
                        data[i].created_at = parseISO8601(data[i].created_at) //Date.fromLocaleString(locale, data[i].created_at, "ddd MMM dd HH:mm:ss +0000 yyyy")
                        if (placement === "prepend"){
                            homeTimeLine.insert(0, data[i])
                        } else {
                            homeTimeLine.append(data[i])
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
                title: qsTr("Pingviini")
            }
            PullDownMenu {
                MenuItem {
                    text: qsTr("Add account")
                    onClicked: pageStack.push(Qt.resolvedUrl("AccountAdd.qml"))
                }
            }


            clip: isPortrait && (infoPanel.expanded)

            width: parent.width
            model: homeTimeLine
            delegate: CmpTweet {

            }


            footer: Item{
                width: parent.width
                height: Theme.iconSizeMedium

                Button {
                    width: parent.width
                    anchors.margins: Theme.paddingSmall
                    onClicked: {
                        //console.log(JSON.stringify([Logic.OAUTH_CONSUMER_KEY, Logic.OAUTH_CONSUMER_SECRET, Logic.OAUTH_TOKEN, Logic.OAUTH_TOKEN_SECRET]))
                        timeline.loadData("aaa")
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

            onContentYChanged: {
                if(contentY+200 > timeline.contentHeight-timeline.height-timeline.footerItem.height && !loadStarted){
                    loadStarted = true;
                }
                //console.log((contentY+200) + ' ' + listView.contentHeight)
                if (contentY > scrollOffset) {
                    infoPanel.open = false
                } else {
                    if (contentY < 100 && !loadStarted){
                        timeline.loadData("prepend")
                        loadStarted = true;
                    }
                    infoPanel.open = true
                }

                scrollOffset = contentY;
            }
        }
    }


    Component {
        id: messagessViewComponent
        SilicaListView {
            id: timeline
            anchors.fill: parent
            header: PageHeader {
                title: qsTr("Messagess")
            }



            clip: isPortrait && (infoPanel.expanded)

            width: parent.width


            VerticalScrollDecorator {}

            onContentYChanged: {
                if(contentY+200 > timeline.contentHeight-timeline.height-timeline.footerItem.height && !loadStarted){
                    loadStarted = true;
                }
                //console.log((contentY+200) + ' ' + listView.contentHeight)
                if (contentY > scrollOffset) {
                    infoPanel.open = false
                } else {
                    infoPanel.open = true

                }

                scrollOffset = contentY;
            }
        }
    }


}




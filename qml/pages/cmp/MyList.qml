import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView {
    id: myList
    property string action: ""
    property variant vars
    property variant conf
    signal send (string notice)
    onSend: {
        console.log("LIST send signal emitted with notice: " + notice)
    }
    WorkerScript {
        id: worker
        source: "../../lib/Worker.js"
        onMessage: {
            //console.log(JSON.stringify(messageObject))
        }
    }
    Component.onCompleted: {
        var msg = {
            'bgAction'  : action,
            'params'    : vars,
            'model'     : model,
            'conf'      : conf
        };
        worker.sendMessage(msg);
    }

    function loadData(mode){
        var msg = {
            'bgAction'  : action,
            'params'    : vars,
            'model'     : model,
            'mode'      : mode,
            'conf'      : conf
        };
        worker.sendMessage(msg);
    }

    PullDownMenu {
        MenuItem {
            visible: action === 'statuses_userTimeline'
            text: (following ? "Unfollow" : "Follow")
            onClicked: {
                var msg = { 'action': following ? "friendships_destroy" : "friendships_create", 'screen_name': username, 'conf'  : conf
                };
                worker.sendMessage(msg);
                following = !following
            }
        }
        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("prepend")
            }
        }
    }
    PushUpMenu {
        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("append")
            }
        }
    }
    anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
    }
    clip: true
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

    delegate: Tweet {
        onSend: {
            myList.send(notice)
        }
    }
    add: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 800 }
        NumberAnimation { property: "x"; duration: 800; easing.type: Easing.InOutBack }
    }

    displaced: Transition {
        NumberAnimation { properties: "x,y"; duration: 800; easing.type: Easing.InOutBack }
    }
    VerticalScrollDecorator {}
}

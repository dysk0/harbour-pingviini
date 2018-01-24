import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../lib/Logic.js" as Logic
import "."


SilicaListView {
    id: myList
    property string type;
    property string title
    property string description
    property ListModel mdl
    property variant params: []
    property var locale: Qt.locale()
    property bool loadStarted : false;
    property int scrollOffset;
    property string action: ""
    property variant vars: { }
    property variant conf
    property bool notifier : false;
    property string next_cursor: ""
    property string previous_cursor: ""
    model:  mdl
    signal notify (string what, int num)
    onNotify: {
        console.log(what + " - " + num)
    }

    signal openDrawer (bool setDrawer)
    onOpenDrawer: {
        //console.log("Open drawer: " + setDrawer)
    }
    signal send (string notice)
    onSend: {
        console.log("LIST send signal emitted with notice: " + notice)
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        running: myList.model.count === 0 && !viewPlaceHolder.visible
        anchors.centerIn: parent
    }
    header: PageHeader {
        title: myList.title
        description: myList.description
    }

    ViewPlaceholder {
        id: viewPlaceHolder
        enabled: model.count === 0
        text: ""
        hintText: ""
    }

    PullDownMenu {
        //MenuItem {
        //    text: qsTr("Users")
        //    onClicked: pageStack.push(Qt.resolvedUrl("../UsersDebug.qml"))
        //}
        MenuItem {
            text: qsTr("Settings")
            onClicked: pageStack.push(Qt.resolvedUrl("../Settings.qml"))
        }
        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("prepend")
            }
        }
    }


    clip: true
    section {
        property: 'section'
        delegate: SectionHeader  {
            height: Theme.itemSizeExtraSmall
            text: Format.formatDate(section, Formatter.DateMedium)
        }
    }


    add: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 800 }
        NumberAnimation { property: "x"; duration: 800; easing.type: Easing.InOutBack }
    }

    remove: Transition {
        NumberAnimation { properties: "x,y"; duration: 800; easing.type: Easing.InOutBack }
    }

    onCountChanged: {
        loadStarted = false;
        /*contentY = scrollOffset
        console.log("CountChanged!")*/

    }

    footer: Item{
        width: parent.width
        height: Theme.itemSizeLarge
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: Theme.paddingSmall
            anchors.bottomMargin: Theme.paddingLarge
            visible: false
            onClicked: {
                loadData("append")
            }
        }
        BusyIndicator {
            size: BusyIndicatorSize.Small
            running: loadStarted;
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    onContentYChanged: {

        if (Math.abs(contentY - scrollOffset) > Theme.itemSizeMedium) {
            openDrawer(contentY - scrollOffset  > 0 ? false : true )
            scrollOffset = contentY
        }

        if(contentY+height > footerItem.y && !loadStarted){
            loadData("append")
            loadStarted = true;
        }
    }
    VerticalScrollDecorator {}

    WorkerScript {
        id: worker
        source: "../../lib/Worker.js"
        onMessage: {
            if (messageObject.error){
                console.log(JSON.stringify(messageObject))
            }
            if (messageObject.fireNotification && notifier){
                Logic.notifier(messageObject.data)
            }
            if (messageObject.cursor && messageObject.action === action){
                next_cursor = messageObject.next_cursor
                previous_cursor = messageObject.previous_cursor
                console.log("############# Cursors updated #############")
                console.log(next_cursor)
                console.log(previous_cursor)
                console.log("############# ############### #############")
            }

        }
    }

    function loadData(mode){
        var msg = {
            'bgAction'              : action,
            'params'                : vars,
            'model'                 : model,
            'modelUsers'            : Logic.modelUsers,
            'next_cursor'           : next_cursor,
            'previous_cursor'       : previous_cursor,
            'mode'                  : mode,
            'conf'                  : conf
        };
        worker.sendMessage(msg);
    }

    Component.onCompleted: {
        loadData("prepend")
    }

}

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic



SilicaListView {

    property string searchTerm: "valuea"
    ListModel {
        id: searchModel
    }

    header: SearchField {
        width: parent.width
        placeholderText: "Search"
        labelVisible: false
        EnterKey.iconSource: "image://theme/icon-m-enter-close"
        EnterKey.onClicked: {
            loadData("append")
            focus = false
        }
    }


    function loadData(placement){
        var msg = {
            'action': 'search_tweets',
            'model' : searchModel,
            'mode'  : placement,
            'params'  : {'q' : headerItem.text},
            'conf'  : Logic.getConfTW()
        };
        worker.sendMessage(msg);
    }
    Component.onCompleted: loadData("append")




    model: searchModel
    delegate: CmpTweet {}


    anchors {
        fill: parent
        leftMargin: 0
        topMargin: 0
        rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
        bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
    }


    ViewPlaceholder {
        enabled: searchModel.count == 0
        text: "Searching"
        hintText: "Please wait..."
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

    }


    clip: isPortrait && (infoPanel.expanded)




    VerticalScrollDecorator {}


}


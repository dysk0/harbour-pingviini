import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic



SilicaListView {

    property string searchTerm: headerItem.text
    property bool loadStarted : false;
    property var locale: Qt.locale()
    property int scrollOffset;

    signal search(string term);
    ListModel {
        id: modelSE
    }

    onSearch: {

        searchTerm = term;
        headerItem.text = term
        loadData("append")
    }

    header: SearchField {
        width: parent.width
        placeholderText: "Search"
        labelVisible: false
        EnterKey.iconSource: "image://theme/icon-m-enter-close"
        EnterKey.onClicked: {

            searchTerm = text
            loadData("append")
            focus = false
        }
    }


    function loadData(placement){
        var msg = {
            'action': 'search_tweets',
            'model' : modelSE,
            'mode'  : "append",
            'params'  : {'q' : searchTerm},
            'conf'  : Logic.getConfTW()
        };
        modelSE.clear()
        if (searchTerm)
            worker.sendMessage(msg);
    }





    model: modelSE
    delegate: CmpTweet {}


    anchors {
        fill: parent
        leftMargin: 0
        topMargin: 0
        rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
        bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
    }


    ViewPlaceholder {
        enabled: modelSE.count === 0 && headerItem.text !== ""
        text: "Searching"
        hintText: "Please wait..."
    }



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


    PushUpMenu {
        spacing: Theme.paddingLarge
        /*MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("prepend")
            }
        }*/
    }


    clip: isPortrait && (infoPanel.expanded)

    onCountChanged: {
        contentY = scrollOffset
    }
    onContentYChanged: {

        if (contentY > scrollOffset) {
            infoPanel.open = false
        } else {
            if (contentY < 100 && !loadStarted){
                //timeline.loadData("prepend")
                //loadStarted = true;
            }
            infoPanel.open = true
        }
        scrollOffset = contentY
    }




    VerticalScrollDecorator {}


}


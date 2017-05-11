import QtQuick 2.0
import Sailfish.Silica 1.0
import "./cmp/"
import "../lib/Logic.js" as Logic



SilicaListView {
    id: searchPage
    property string searchTerm: headerItem.text
    property bool loadStarted : false;
    property var locale: Qt.locale()
    property string refresh_url: ""
    property string next_results: ""
    property int scrollOffset;

    signal search(string term);


    onSearch: {
        Logic.modelSE.clear()
        searchTerm = term;
        headerItem.text = term
        loadData("resetSearch")
    }

    header: SearchField {
        width: parent.width
        placeholderText: "Search"
        labelVisible: false
        EnterKey.iconSource: "image://theme/icon-m-enter-close"
        EnterKey.onClicked: {
            searchTerm = text
            search(text)
            focus = false
        }
    }



    function loadData(placement){
        var msg = {
            'action': 'search_tweets',
            'model' : Logic.modelSE,
            'mode'  : placement,
            'params'  : {'q' : searchTerm},
            'conf'  : Logic.getConfTW()
        };
        if (searchTerm)
            worker.sendMessage(msg);
    }





    model: Logic.modelSE
    delegate: Tweet {}


    anchors {
        fill: parent
        leftMargin: 0
        topMargin: 0
        rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
        bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
    }


    ViewPlaceholder {
        enabled: Logic.modelSE.count === 0 && headerItem.text !== ""
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


    PullDownMenu {
        spacing: Theme.paddingLarge
        MenuItem {
            text: refresh_url //qsTr("Load more")
            onClicked: {
                loadData("prepend")
            }
        }
    }
    PushUpMenu {
        spacing: Theme.paddingLarge
        MenuItem {
            text: next_results // qsTr("Load more")
            onClicked: {
                loadData("append")
            }
        }
    }


    clip: isPortrait && (infoPanel.expanded)

    onCountChanged: {
        contentY = scrollOffset
    }
    onContentYChanged: {

        if (contentY > scrollOffset) {
            openDrawer(false)

        } else {
            if (contentY < 100 && !loadStarted){
            }
            openDrawer(true)
        }
        scrollOffset = contentY
    }




    VerticalScrollDecorator {}


}


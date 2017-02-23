import QtQuick 2.0
import Sailfish.Silica 1.0

Component {

    SilicaListView {
        id: timeline
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Component {
    SilicaListView {
        id: timelineDM
        anchors.fill: parent


        ViewPlaceholder {
            enabled: modelDM.count == 0
            text: "Loading tweets"
            hintText: "Please wait..."
        }




        header: PageHeader {
            title: qsTr("Search")
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

        }


        clip: isPortrait && (infoPanel.expanded)




        VerticalScrollDecorator {}


    }
}

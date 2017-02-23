import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Mediator.js" as Mediator
import "../lib/Logic.js" as Logic

Component {

    SilicaListView {
        id: listView
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Direct Messages")
        }
        ListModel {
            id: modelDM
        }

        model: Logic.modelDM


        PullDownMenu {
            MenuItem {
                text: qsTr("Show navigation")
                onClicked: {
                    infoPanel.open = true;
                }
            }
        }
        Component.onCompleted: {
            listView.loadData()

        }

        function loadData(placement){
            console.log(placement)
            var sinceId = false;
            var maxId = false;



            Logic.getDirectMsg(sinceId, maxId, function(data) {
                //jsonModel1.json = data;
                //var now = new Date().getTime()
                //data =JSON.flatten(data);
                for (var i=0; i < data.length; i++) {
                    data[i] =JSON.flatten(data[i]);
                    Logic.modelDM.append(data[i])
                    modelDM.append(data[i])
                }
                Logic.modelDM.sync()
                console.log(JSON.stringify(data))
                //Logic.modelDM.append(data)
                loadStarted = false;
            }, showError)
        }
        delegate: BackgroundItem {
            width: parent.width
            height: Theme.itemSizeExtraLarge
            Image {
                id: avatar
                x: Theme.horizontalPageMargin
                y: Theme.paddingLarge
                asynchronous: true
                width: Theme.iconSizeMedium
                height: width
                source: model['sender.profile_image_url_https']
            }

            Label {
                id: lblName
                anchors {
                    top: avatar.top
                    left: avatar.right
                    leftMargin: Theme.paddingMedium
                }
                text: model.text
                font.weight: Font.Bold
                font.pixelSize: Theme.fontSizeSmall
                color: (pressed ? Theme.highlightColor : Theme.primaryColor)
            }
            onClicked: {
                console.log(JSON.stringify(model))
            }
        }

        clip: isPortrait && (infoPanel.expanded)




        VerticalScrollDecorator {}

        onContentYChanged: {
            if(contentY+200 > listView.contentHeight-listView.height && !loadStarted){
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

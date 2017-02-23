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
            id: modelDMfiltered
        }

        model: modelDMfiltered


        PullDownMenu {
            MenuItem {
                text: qsTr("Show navigation")
                onClicked: {
                    infoPanel.open = true;
                }
            }
        }
        Component.onCompleted: {
            if (modelDM.count === 0){
                listView.loadData()
            } else {
                listView.contentY = scrollOffsetDM
            }

        }

        function loadData(placement){
            console.log(placement)
            var sinceId = false;
            var maxId = false;



            Logic.getDirectMsg(sinceId, maxId, function(data) {
                //jsonModel1.json = data;
                //var now = new Date().getTime()
                //data =JSON.flatten(data);

                var unique = [];
                for (var i=0; i < data.length; i++) {
                    //data[i] =JSON.flatten(data[i]);
                    if (!unique[data[i].sender.screen_name]){
                        modelDMfiltered.append(data[i])
                        unique[data[i].sender.screen_name] = true;
                    }
                    modelDM.append(data[i])
                }
                console.log(JSON.stringify(data))
                //Logic.modelDM.append(data)
                loadStarted = false;
            }, showError)
        }
        delegate: BackgroundItem {
            id: delegate
            //property string text: "0"
            width: parent.width
            height: lblText.paintedHeight + lblName.paintedHeight + lblScreenName.paintedHeight + Theme.paddingLarge
            Image {
                id: avatar
                x: Theme.horizontalPageMargin
                y: Theme.paddingLarge
                asynchronous: true
                width: Theme.iconSizeMedium
                height: width
                source: sender.profile_image_url_https
            }

            Label {
                id: lblName
                anchors {
                    top: avatar.top
                    left: avatar.right
                    leftMargin: Theme.paddingMedium
                }
                text: sender.name
                font.weight: Font.Bold
                font.pixelSize: Theme.fontSizeSmall
                color: (pressed ? Theme.highlightColor : Theme.primaryColor)
            }
            Label {
                id: lblScreenName
                anchors {
                    left: lblName.right
                    right: lblDate.left
                    leftMargin: Theme.paddingMedium
                    baseline: lblName.baseline
                }
                truncationMode: TruncationMode.Fade
                text: '@'+sender.screen_name
                font.pixelSize: Theme.fontSizeExtraSmall
                color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
            }
            Label {
                function timestamp() {
                    var txt = Format.formatDate(created_at, Formatter.Timepoint)
                    var elapsed = Format.formatDate(created_at, Formatter.DurationElapsedShort)
                    return (elapsed ? elapsed  : txt )
                }
                id: lblDate
                color: (pressed ? Theme.highlightColor : Theme.primaryColor)
                text: timestamp()
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
                anchors {
                    right: parent.right
                    baseline: lblName.baseline
                    rightMargin: Theme.paddingLarge
                }
            }

            Label {
                id: lblText
                anchors {
                    left: lblName.left
                    right: parent.right
                    top: lblScreenName.bottom
                    topMargin: Theme.paddingSmall
                    rightMargin: Theme.paddingLarge
                }
                height: paintedHeight
                text: Theme.highlightText(model.text, "@", Theme.highlightColor)
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: (pressed ? Theme.highlightColor : Theme.primaryColor)
            }

            onClicked: {
                console.log(JSON.stringify(model.id))
            }
        }

        clip: isPortrait && (infoPanel.expanded)




        VerticalScrollDecorator {}

        onMovementEnded: {
            scrollOffsetDM  = contentY
        }

        onContentYChanged: {
            if(contentY+200 > listView.contentHeight-listView.height && !loadStarted){
                loadStarted = true;
            }
            //console.log((contentY+200) + ' ' + listView.contentHeight)
            if (contentY > scrollOffsetDM) {
                infoPanel.open = false
            } else {
                infoPanel.open = true

            }
        }
    }
}

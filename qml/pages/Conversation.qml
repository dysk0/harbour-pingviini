import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "./cmp/"
import QtGraphicalEffects 1.0

Page {

    property var locale: Qt.locale()
    property string recipient_id : "";
    property string user_id : "";
    property string user_name : "";
    property string user_screen_name : "";
    property string user_avatar: "";
    property bool listloaded: false;


    Component.onCompleted: {
        var msg = {
            parser_action : "create_conversation",
            sender_id: user_id,
            recipient_id: recipient_id,
            modelSent: Logic.modelDMsent,
            modelReceived: Logic.modelDMreceived,
            modelConversation: tweets
        }

        parser.sendMessage(msg)
    }

    ProfileHeader {
        id: header
        title: user_name
        description: '@'+user_screen_name
        image: user_avatar
    }


    allowedOrientations: Orientation.All

    NewTweet {
        type: "DM"
        screenName: user_screen_name
        id: tweetPanel
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    SilicaListView {
        id: list
        model: ListModel {
            id: tweets
            onCountChanged: {
                if (!listloaded){
                    list.positionViewAtIndex(count - 1, ListView.End)
                    listloaded = !listloaded
                }
            }
        }
        anchors {
            top: header.bottom
            bottom: tweetPanel.top
            left: parent.left
            right: parent.right
        }
        clip: true
        property var locale: Qt.locale()
        section {
            property: 'section'
            delegate: SectionHeader  {
                height: Theme.itemSizeExtraSmall
                text: Format.formatDate(section, Formatter.DateMedium)
            }
        }

        delegate: BackgroundItem {
            height: lblText.paintedHeight + lblDate.paintedHeight + Theme.paddingMedium
            Label {
                id: lblText
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: Theme.paddingMedium
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
                onLinkActivated: page.onLinkActivated(link)
                text: model.text
                textFormat:Text.RichText
                linkColor : Theme.highlightColor
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: !model.sent ? Text.AlignLeft :Text.AlignRight
                color: (pressed ? Theme.highlightColor : (!model.sent ? Theme.highlightColor : Theme.primaryColor))
            }

            Label {
                function timestamp() {
                    var txt = Format.formatDate(created_at, Formatter.Timepoint)
                    var elapsed = Format.formatDate(created_at, Formatter.DurationElapsedShort)
                    return (elapsed ? elapsed  : txt )
                }
                id: lblDate
                color: (pressed ? Theme.highlightColor : Theme.secondaryColor)
                text: Format.formatDate(created_at, new Date() - created_at < 60*60*1000 ? Formatter.DurationElapsedShort : Formatter.TimepointRelativeCurrentDayDetailed)
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: !model.sent ? Text.AlignLeft :Text.AlignRight
                width: lblText.width
                anchors {
                    top: lblText.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                    bottomMargin: Theme.paddingSmall
                }
            }
            onClicked: {
                console.log(JSON.stringify(sent))
            }
        }
    }

    WorkerScript {
        id: parser
        source: "../lib/Parser.js"
        onMessage: {

        }
    }
}

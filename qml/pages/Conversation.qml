import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import QtGraphicalEffects 1.0

Page {
    property ListModel tweets;
    property string name : "";
    property string username : "";
    property string profileImage: "";


    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All
    Component.onCompleted: {

    }

    SilicaListView {
        header: Item {
            width: parent.width
            height: avatar.height + Theme.paddingLarge*2
            PageHeader {
                title: name
                description: '@'+username
            }
            Image {
                id: avatar
                x: Theme.horizontalPageMargin
                y: Theme.paddingLarge
                asynchronous: true
                width: Theme.iconSizeLarge
                height: width
                source: profileImage
            }
        }
        model: tweets
        anchors.fill: parent
        delegate: BackgroundItem {
            height: lblText.paintedHeight + lblDate.paintedHeight + Theme.paddingSmall
            Label {
                id: lblText
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: Theme.paddingSmall
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
                onLinkActivated: page.onLinkActivated(link)
                text: richText
                textFormat:Text.RichText
                linkColor : Theme.highlightColor
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeMedium
                horizontalAlignment: isReceiveDM ? Text.AlignLeft :Text.AlignRight
                color: (pressed ? Theme.highlightColor : (isReceiveDM ? Theme.highlightColor : Theme.primaryColor))
            }

            Label {
                function timestamp() {
                    var txt = Format.formatDate(createdAt, Formatter.Timepoint)
                    var elapsed = Format.formatDate(createdAt, Formatter.DurationElapsedShort)
                    return (elapsed ? elapsed  : txt )
                }
                id: lblDate
                color: (pressed ? Theme.highlightColor : Theme.secondaryColor)
                text: Format.formatDate(createdAt, new Date() - createdAt < 60*60*1000 ? Formatter.DurationElapsedShort : Formatter.TimepointRelativeCurrentDayDetailed)
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: isReceiveDM ? Text.AlignLeft :Text.AlignRight
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
        }
    }
}

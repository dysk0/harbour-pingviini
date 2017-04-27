import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "./cmp/"
import QtGraphicalEffects 1.0

Page {
    property ListModel tweets;
    property string name : "";
    property string username : "";
    property string profileImage: "";
    ProfileHeader {
        id: header
        title: name
        description: '@'+username
        image: profileImage
    }



    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    NewTweet {
        type: "DM"
        screenName: username
        id: tweetPanel
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    SilicaListView {

        Component.onCompleted: { positionViewAtIndex(count - 1, ListView.End)}
        model: tweets
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
                font.pixelSize: Theme.fontSizeSmall
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

import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem {
    id: delegate
    //property string text: "0"
    width: parent.width
    height: lblText.paintedHeight + lblName.paintedHeight + lblScreenName.paintedHeight + Theme.paddingLarge*2 + details.height*2 + mediaImg.height
    Image {
        id: avatar
        x: Theme.horizontalPageMargin
        y: Theme.paddingLarge
        asynchronous: true
        width: Theme.iconSizeMedium
        height: width
        source: profileImageUrl
    }

    Label {
        id: lblName
        anchors {
            top: avatar.top
            left: avatar.right
            leftMargin: Theme.paddingMedium
        }
        text: name
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
        text: '@'+screenName
        font.pixelSize: Theme.fontSizeExtraSmall
        color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
    }
    Label {
        function timestamp() {
            var txt = Format.formatDate(createdAt, Formatter.Timepoint)
            var elapsed = Format.formatDate(createdAt, Formatter.DurationElapsedShort)
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
        text: (highlights.length > 0 ? Theme.highlightText(plainText, new RegExp(highlights, "igm"), Theme.highlightColor) : plainText)
        textFormat:Text.RichText
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall
        color: (pressed ? Theme.highlightColor : Theme.primaryColor)
    }

    Image {
        id: mediaImg
        anchors {
            left: lblName.left
            right: parent.right
            top: lblText.bottom
            topMargin: Theme.paddingSmall
            rightMargin: Theme.paddingLarge
        }
        opacity: pressed ? 0.6 : 1
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        width: 200
        height: 0
        visible: {
            if (mediaUrl){
                source = mediaUrl
                height = 200
                return true
            } else {
                height = 0
                return false
            }
        }


    }

    TweetToolBar {
        id: details
        anchors {
            left: lblName.left
            right: parent.right
            top: mediaImg.bottom
            topMargin: Theme.paddingSmall
            rightMargin: Theme.paddingLarge
        }
        //width:
    }


    onClicked: {
        pageStack.push(Qt.resolvedUrl("TweetDetails.qml"), {"tweets": (timeline ? timeline.model : timeline.model ), "selected": index})
        console.log(JSON.stringify(model.highlights))
    }
}

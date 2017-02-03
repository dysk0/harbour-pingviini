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
        source: user.profile_image_url_https
    }

    Label {
        id: lblName
        anchors {
            top: avatar.top
            left: avatar.right
            leftMargin: Theme.paddingMedium
        }
        text: user.name
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSizeSmall
        color: (pressed ? Theme.highlightColor : Theme.primaryColor)
    }
    Label {
        id: lblScreenName
        anchors {
            left: lblName.right
            leftMargin: Theme.paddingMedium
            baseline: lblName.baseline
        }
        text: '@'+user.screen_name
        font.pixelSize: Theme.fontSizeExtraSmall
        color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
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
            if (entities.media){
                source = entities.media[0].media_url
                height = 200
                return true
            } else {
                height = 0
                return false
            }
        }


    }


    Row {
        id: details
        height: Theme.iconSizeExtraSmall
        anchors {
            left: lblName.left
            right: parent.right
            top: mediaImg.bottom
            topMargin: Theme.paddingMedium
            rightMargin: Theme.paddingLarge
        }
        spacing: Theme.paddingSmall
        Image {
            id: iconRT
            width: Theme.iconSizeExtraSmall
            height: width
            source: (retweeted ?
                         "image://theme/icon-s-retweet?" + (pressed ? Theme.primaryColor : Theme.secondaryColor)
                       :
                         "image://theme/icon-s-retweet?" + (pressed ? Theme.highlightColor: Theme.secondaryHighlightColor)
                     )
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            height: paintedHeight
            text: retweet_count
            font.pixelSize: Theme.fontSizeExtraSmall
            color: (pressed ? Theme.highlightColor : Theme.secondaryHighlightColor)
        }
        Label { text: " "}

        Image {
            id: iconFav
            width: Theme.iconSizeExtraSmall
            height: width
            source: (favorited ?
                         "image://theme/icon-s-new?" + (pressed ? Theme.primaryColor : Theme.secondaryColor)
                       :
                         "image://theme/icon-s-new?" + (pressed ? Theme.highlightColor: Theme.secondaryHighlightColor)
                     )
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            height: paintedHeight
            text: favorite_count
            font.pixelSize: Theme.fontSizeExtraSmall
            color: (pressed ? Theme.highlightColor : Theme.secondaryHighlightColor)
        }

    }
    onClicked: {
        console.log(JSON.stringify(model.id))
    }
}

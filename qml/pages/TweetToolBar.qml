import QtQuick 2.0
import Sailfish.Silica 1.0


Row {
    property int w
    id: delegate
    height: Theme.iconSizeExtraSmall
    spacing: Theme.paddingLarge+Theme.paddingSmall


    IconButton {
        anchors {
            top: delegate.top
        }
        id: iconReply
        width: Theme.iconSizeSmall
        height: width
        icon.source: "image://theme/icon-s-edit?" + (pressed ? Theme.highlightColor: Theme.secondaryHighlightColor)
        onClicked: {
            console.log(JSON.stringify(model.id))
        }
    }
    Row {
        IconButton {
            id: iconRT
            width: iconReply.width
            height: width
            icon.source: (retweeted ?
                              "image://theme/icon-s-retweet?" + (pressed ? Theme.primaryColor : Theme.secondaryColor)
                            :
                              "image://theme/icon-s-retweet?" + (pressed ? Theme.highlightColor: Theme.secondaryHighlightColor)
                          )
        }
        Label {
            visible: retweet_count
            anchors.verticalCenter: parent.verticalCenter
            height: paintedHeight
            text: retweet_count
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
        }
    }

    Row {
        IconButton {
            id: iconFav
            width: iconReply.width
            height: width
            icon.source: (favorited ?
                              "image://theme/icon-s-favorite?" + (pressed ? Theme.primaryColor : Theme.secondaryColor)
                            :
                              "image://theme/icon-s-new?" + (pressed ? Theme.highlightColor: Theme.secondaryHighlightColor)
                          )
        }
        Label {
            visible: favorite_count
            anchors.verticalCenter: parent.verticalCenter
            height: paintedHeight
            text: favorite_count
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
        }
    }

    IconButton {
        id: iconDM
        anchors {
            top: delegate.top
        }
        width: iconReply.width
        height: width
        icon.source: (favorited ?
                          "image://theme/icon-s-message?" + (pressed ? Theme.primaryColor : Theme.secondaryColor)
                        :
                          "image://theme/icon-s-message?" + (pressed ? Theme.highlightColor: Theme.secondaryHighlightColor)
                      )
    }

}

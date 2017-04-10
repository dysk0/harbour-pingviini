import QtQuick 2.0
import Sailfish.Silica 1.0


Row {
    property int w
    id: delegate
    height: Theme.iconSizeExtraSmall
    spacing: Theme.paddingLarge+Theme.paddingSmall


    Row {
        IconButton {
            id: iconRT
            width: Theme.iconSizeSmall
            height: width
            icon.source: (isRetweet ?
                              "image://theme/icon-s-retweet?" + (pressed ? Theme.primaryColor : Theme.secondaryColor)
                            :
                              "image://theme/icon-s-retweet?" + (pressed ? Theme.highlightColor: Theme.secondaryHighlightColor)
                          )
        }
        Label {
            visible: retweetCount
            anchors.verticalCenter: parent.verticalCenter
            height: paintedHeight
            text: retweetCount
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
        }
    }

    Row {
        IconButton {
            id: iconFav
            width: iconRT.width
            height: width
            icon.source: (isFavourited ?
                              "image://theme/icon-s-favorite?" + (pressed ? Theme.primaryColor : Theme.secondaryColor)
                            :
                              "image://theme/icon-s-new?" + (pressed ? Theme.highlightColor: Theme.secondaryHighlightColor)
                          )
        }
        Label {
            visible: favoriteCount
            anchors.verticalCenter: parent.verticalCenter
            height: paintedHeight
            text: favoriteCount
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
        }
    }

    /*IconButton {
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
    }*/

}

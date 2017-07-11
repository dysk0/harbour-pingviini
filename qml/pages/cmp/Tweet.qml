import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

BackgroundItem {
    signal send (string notice)

    id: delegate
    //property string text: "0"
    width: parent.width
    signal navigateTo(string link)
    height: lblText.paintedHeight + (lblText.text.length > 0 ? Theme.paddingLarge : 0 )+ lblName.paintedHeight + lblScreenName.paintedHeight +  mediaImg.height + (isRetweet ? Theme.paddingLarge + iconRT.height : 0)
    Image {
        id: iconRT
        y: Theme.paddingLarge
        anchors {
            right: avatar.right
        }
        visible: isRetweet
        width: Theme.iconSizeExtraSmall
        height: width
        source: "image://theme/icon-s-retweet?" + (pressed ? Theme.primaryColor : Theme.secondaryColor)
    }
    Label {
        id: lblRtByName
        visible: isRetweet
        anchors {
            left: lblName.left
            bottom: iconRT.bottom
        }
        text: 'retweeted by @' + retweetScreenName
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
    }

    Image {
        id: avatar
        x: Theme.horizontalPageMargin
        y: Theme.paddingLarge + (isRetweet ? iconRT.height+Theme.paddingMedium : 0)
        asynchronous: true
        width: Theme.iconSizeMedium
        height: width
        smooth: true
        source: profileImageUrl
        visible: true
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../Profile.qml"), {
                                   "name": name,
                                   "username": screenName,
                                   "profileImage": profileImageUrl
                               })
            }

        }

    }

    /*Image {
        id: avatar
        x: Theme.horizontalPageMargin
        y: Theme.paddingLarge + (isRetweet ? iconRT.height+Theme.paddingMedium : 0)
        asynchronous: true
        width: Theme.iconSizeMedium
        height: width
        smooth: true
        source: profileImageUrl
        visible: false
    }
    Rectangle {
        id: avatarMask
        x: Theme.horizontalPageMargin
        y: Theme.paddingLarge
        width: Theme.iconSizeMedium
        height: width
        smooth: true
        color: Theme.primaryColor
        radius: Theme.iconSizeMedium*0.08
        anchors.centerIn: avatar
        visible: true

    }

    OpacityMask {
        id: maskedProfilePicture
        source: avatar
        maskSource: avatarMask
        anchors.fill: avatar
        visible: avatar.status === Image.Ready ? true : false
        opacity: avatar.status === Image.Ready ? 1 : 0
        Behavior on opacity { NumberAnimation {} }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../Profile.qml"), {
                                   "name": name,
                                   "username": screenName,
                                   "profileImage": profileImageUrl
                               })
            }

        }
    }*/

    Label {
        id: lblName
        anchors {
            top: avatar.top
            topMargin: 0
            left: avatar.right
            leftMargin: Theme.paddingMedium
        }
        text: name
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSizeSmall
        color: (pressed ? Theme.highlightColor : Theme.primaryColor)
    }

    Image {
        id: iconVerified
        y: Theme.paddingLarge
        anchors {
            left: lblName.right
            leftMargin: Theme.paddingSmall
            verticalCenter: lblName.verticalCenter
        }
        visible: isVerified
        width: isVerified ? Theme.iconSizeExtraSmall*0.8 : 0
        opacity: 0.8
        height: width
        source: "../../verified.svg"
    }
    ColorOverlay {
        anchors.fill: iconVerified
        source: iconVerified
        color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
    }

    Label {
        id: lblScreenName
        anchors {
            left: iconVerified.right
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
        text: Format.formatDate(createdAt, new Date() - createdAt < 60*60*1000 ? Formatter.DurationElapsedShort : Formatter.TimeValueTwentyFourHours)
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
        height: richText.length ? paintedHeight : 0
        //text: (highlights.length > 0 ? Theme.highlightText(plainText, new RegExp(highlights, "igm"), Theme.highlightColor) : plainText)
        //textFormat:Text.RichText
        onLinkActivated: {
            console.log(link)
            if (link[0] === "@") {
                pageStack.push(Qt.resolvedUrl("../Profile.qml"), {
                                   "name": "",
                                   "username": link.substring(1),
                                   "profileImage": ""
                               })
            } else if (link[0] === "#") {

                    pageStack.pop(pageStack.find(function(page) {
                        var check = page.isFirstPage === true;
                        if (check)
                            page.onLinkActivated(link)
                        return check;
                    }));

                send(link)
            } else {
                pageStack.push(Qt.resolvedUrl("../Browser.qml"), {"href" : link})
            }


        }
        text: richText
        textFormat:Text.StyledText
        linkColor : (pressed ? Theme.primaryColor : Theme.highlightColor)
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall
        color: (pressed ? Theme.highlightColor : Theme.primaryColor)
    }

    MediaBlock {
        id: mediaImg
        anchors {
            left: lblName.left
            right: parent.right
            top: lblText.bottom
            topMargin: Theme.paddingSmall
            rightMargin: Theme.paddingLarge
        }
        model: (media ? media : '')
        width: lblDate.x - lblName.x- Theme.paddingLarge
        height: 100
    }
    onClicked: {
        pageStack.push(Qt.resolvedUrl("../TweetDetails.qml"), {
                                          "tweets": [],
                                          "screenName": screenName,
                                          "selected": index
                                      })
    }

}

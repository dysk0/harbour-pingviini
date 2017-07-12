import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../lib/Logic.js" as Logic
import QtGraphicalEffects 1.0

BackgroundItem {
    signal send (string notice)
    id: delegate
    //property string text: "0"
    width: parent.width
    signal navigateTo(string link)
    height: mnu.height + lblText.paintedHeight + (lblText.text.length > 0 ? Theme.paddingLarge : 0 )+ lblName.paintedHeight + lblScreenName.paintedHeight +  mediaImg.height + (isRetweet ? Theme.paddingLarge + iconRT.height : 0)
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
        width: visualStyle == 0 ? Theme.iconSizeMedium : 0
        height: width
        smooth: true
        source: profileImageUrl
        visible: visualStyle == 0
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

    Label {
        id: lblName
        anchors {
            top: avatar.top
            topMargin: 0
            left: avatar.right
            leftMargin: visualStyle == 0 ? Theme.paddingMedium : 0
        }
        visible: visualStyle == 0
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
        visible: visualStyle == 0 ? isVerified : false
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
        visible: visualStyle == 0
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
        if(pageStack.depth > 1) {
            pageStack.replace(Qt.resolvedUrl("../TweetDetails.qml"), { "tweet": model })
        } else {
            pageStack.push(Qt.resolvedUrl("../TweetDetails.qml"), { "tweet": model })
        }
    }

    ContextMenu {
        id: mnu

        MenuItem {
            text: favorited ? qsTr("Unfavorite") : qsTr("Favorite")
            onClicked: {
                var msg = {
                    'headlessAction': 'favorites_' + (favorited ? 'destroy' : 'create'),
                    'params': {'id': id_str}
                };
                Logic.mediator.publish("bgCommand", msg)
                favorited = !favorited
            }
            Image {
                id: icFA
                anchors {
                    leftMargin: Theme.horizontalPageMargin
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: Theme.iconSizeExtraSmall
                height: width
                source: "image://theme/icon-s-favorite?" + (!favorited ? Theme.highlightColor : Theme.primaryColor)
            }
            Label {
                anchors {
                    left: icFA.right
                    leftMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                text: favoriteCount
                font.pixelSize: Theme.fontSizeExtraSmall
                color: !favorited ? Theme.highlightColor : Theme.primaryColor
            }
        }
        MenuItem {
            text: qsTr("Retweet")
            enabled: !retweeted
            onClicked: {
                var msg = {
                    'headlessAction': 'statuses_retweet_ID',
                    'params': {'id': id_str}
                };
                Logic.mediator.publish("bgCommand", msg)
                retweeted = true;
            }
            Image {
                id: icRT
                anchors {
                    leftMargin: Theme.horizontalPageMargin
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: Theme.iconSizeExtraSmall
                height: width
                source: "image://theme/icon-s-retweet?" + (!model.retweeted ? Theme.highlightColor : Theme.primaryColor)
            }
            Label {
                anchors {
                    left: icRT.right
                    leftMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                text: retweetCount
                font.pixelSize: Theme.fontSizeExtraSmall
                color: !model.retweeted ? Theme.highlightColor : Theme.primaryColor
            }
        }
    }
    onPressAndHold: {
        mnu.show(delegate)
    }

}

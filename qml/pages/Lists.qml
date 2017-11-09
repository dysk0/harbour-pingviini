import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import "../lib/Logic.js" as Logic
import "./cmp/"

Page {
    id: page
    property ListModel tweets;
    property string name : "Ludi Bozo";
    property string description : "Followers";
    property string username : "dysko";
    property string profileImage : "";
    property int user_id;
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge
        contentWidth: parent.width


        WorkerScript {
            id: worker
            source: "../lib/Worker.js"
            onMessage: {
                console.log(JSON.stringify(messageObject))
            }
        }


        ListModel {
            id: listModel
        }



        MyList {

            header: ProfileHeader {
                id: header
                bg: profile_background
                title: name
                description: page.description
                image: profileImage
            }
            model: listModel
            action: "followers_list"
            vars: { 'screen_name': username, "count":200, 'skip_status': true}
            conf: Logic.getConfTW()
            width: parent.width
            height: parent.height
            anchors.fill: parent
            anchors {
                top: parent.top
                bottom: expander.top
                left: parent.left
                right: parent.right
            }
            clip: true
            delegate: BackgroundItem {
                width: parent.width
                height: lblDescr.height + lblName.height + Theme.paddingLarge*2
                Image {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: Theme.paddingLarge
                    anchors.leftMargin: Theme.horizontalPageMargin
                    id: avatar
                    asynchronous: true
                    width: Theme.iconSizeMedium
                    height: width
                    smooth: true
                    source: model.avatar
                    opacity: status === Image.Ready ? 1.0 : 0.0
                    Behavior on opacity { FadeAnimator {} }
                    onStatusChanged: {
                        if (status === Image.Error)
                            source = "image://theme/icon-m-person?" + (pressed
                                                                       ? Theme.highlightColor
                                                                       : Theme.primaryColor)
                    }

                }
                Label {
                    id: lblName
                    anchors {
                        top: avatar.top
                        left: avatar.right
                        leftMargin: Theme.paddingMedium
                    }
                    text: model.name
                    font.weight: Font.Bold
                    font.pixelSize: Theme.fontSizeSmall
                    color: (pressed ? Theme.highlightColor : Theme.primaryColor)
                }
                Image {
                    id: iconVerified
                    anchors {
                        left: lblName.right
                        verticalCenter: lblName.verticalCenter
                        leftMargin: model.verified ? Theme.paddingMedium : 0
                    }
                    width: model.verified ? Theme.iconSizeExtraSmall*0.8 : 0
                    opacity: 0.8
                    height: width
                    source: "../verified.svg"
                    ColorOverlay {
                        anchors.fill: parent
                        source: iconVerified
                        color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                    }
                }

                Label {
                    id: lblScreenName
                    anchors {
                        left: iconVerified.right
                        right: parent.right
                        baseline: lblName.baseline
                        leftMargin: Theme.paddingMedium
                    }
                    textFormat: Text.RichText
                    truncationMode: TruncationMode.Fade
                    text: '@'+model.screen_name
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                }

                Label {
                    id: lblDescr
                    anchors {
                        left: lblName.left
                        right: parent.right
                        top: lblName.bottom
                    }
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    truncationMode: TruncationMode.Fade
                    text: model.description
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                }
            }
        }
    }
    Component.onCompleted: {
        var msg = {
            'headlessAction': 'followers/list',
            'params': {'screen_name': username},
            'conf'  : Logic.getConfTW()
        };
        // worker.sendMessage(msg);
    }
}

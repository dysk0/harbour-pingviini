import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import QtGraphicalEffects 1.0

SilicaListView {
    header: PageHeader {
        title: qsTr("Messages")
        description: qsTr("Pingviini")
    }
    clip: true
    section {
        property: 'section'
        delegate: SectionHeader  {
            height: Theme.itemSizeExtraSmall
            text: Format.formatDate(section, Formatter.DateMedium)
        }
    }
    model:  Logic.modelDM
    delegate: BackgroundItem {
        height: Theme.itemSizeMedium + Theme.paddingMedium*2
        anchors.left: parent.left
        anchors.right: parent.right
        Image {
            id: mainAvatar
            anchors {
                top: parent.top
                topMargin: Theme.paddingLarge
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
            }
            width: Theme.iconSizeMedium
            height: width
            //source: model.sender_id != Logic.conf.USER_ID ? Logic.getUserData(model.sender_id, "avatar"): Logic.conf.AVATAR
            source: Logic.getUserData(model.sender_id, "avatar")
            smooth: true
            opacity: status === Image.Ready ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {} }
            asynchronous: true
            Image {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: -width/3
                    left: parent.left
                    leftMargin: -width/3
                }
                asynchronous: true
                width: Theme.iconSizeSmall
                height: width
                smooth: true
                opacity: status === Image.Ready ? 1.0 : 0.0
                Behavior on opacity { FadeAnimator {} }
                source: Logic.getUserData(model.recipient_id, "avatar")
            }
        }
        Label {
            id: lblName
            anchors {
                left: mainAvatar.right
                leftMargin: Theme.paddingLarge
                top: parent.top
                topMargin: Theme.paddingLarge
                right: lblDate.left
            }
            text: Logic.getUserData(model.sender_id != Logic.conf.USER_ID ? model.sender_id : model.recipient_id, "name")
            color: (pressed ? Theme.highlightColor : Theme.primaryColor)
            wrapMode: Text.NoWrap
        }
        Label {
            id: lblDate
            color: (pressed ? Theme.highlightColor : Theme.primaryColor)
            text: Format.formatDate(created_at, new Date() - created_at < 60*60*1000 ? Formatter.DurationElapsedShort : Formatter.TimeValueTwentyFourHours)
            font.pixelSize: Theme.fontSizeExtraSmall
            horizontalAlignment: Text.AlignRight
            anchors {
                right: parent.right
                baseline: lblName.baseline
                rightMargin: Theme.horizontalPageMargin
            }
        }
        Label {
            anchors {
                left: lblName.left
                right: lblDate.right
                top: lblName.bottom
            }
            text: model.text
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeSmall
            maximumLineCount: 1
            color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
        }
        onClicked: {
            banner.notify(Logic.conf.USER_ID + " " + model.group)
            pageStack.push(Qt.resolvedUrl("Conversation.qml"), {
               "group" : model.group,
               user_id : model.sender_id != Logic.conf.USER_ID ? model.sender_id : model.recipient_id,
               //recipient_id : model.recipient_id,
               user_name : Logic.getUserData(model.sender_id != Logic.conf.USER_ID ? model.sender_id : model.recipient_id, "name"),
               user_screen_name : Logic.getUserData(model.sender_id != Logic.conf.USER_ID ? model.sender_id : model.recipient_id, "screen_name"),
               user_avatar: Logic.getUserData(model.sender_id != Logic.conf.USER_ID ? model.sender_id : model.recipient_id, "avatar")
           })

        }
    }
    Timer {
        id: timer
    }
    function delay(delayTime, cb) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.start();
        }
    Component.onCompleted: {
        delay(500, function() {
            worker.sendMessage({conf: Logic.getConfTW(), model: Logic.modelDMraw, model2: Logic.modelDM, mode: 'append', bgAction: 'directMessages_events_list', params: {count: 50}});
            //worker.sendMessage({conf: Logic.getConfTW(), model: Logic.modelUsers, mode: '', bgAction: 'users_lookup', params: {"user_id": "19210452,253986430,17104521,45883815,330188211,47890560"}});
        })

    }
}

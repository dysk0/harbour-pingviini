import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic



Item {
    id: newTweetPanel
    property string type: "New" //"New","Reply", "RT" or "DM"
    property string tweetId
    property string screenName //for "DM"
    property string placedText: ""
    property double latitude: 0
    property double longitude: 0
    width: parent.width
    height: newTweet.height + Theme.paddingMedium*3 + (tweetExtra.open ? tweetExtra.height + Theme.paddingLarge*2 : 0)
    anchors {
        left: parent.left
        right: parent.right
    }
    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: console.log(JSON.stringify(messageObject))
    }
    function tweet(){

        var msg = {
            'action': 'statuses_update',
            'model' : Logic.modelTL,
            'params'  : {'status': newTweet.text},
            'conf'  : Logic.getConfTW()
        };
        if (type === "DM") {
            msg.params.status = "D @" + screenName + " " + newTweet.text
        }
        if (type === "Reply") {
            msg.params['in_reply_to_status_id'] = tweetId
            if (msg.params['status'].toLowerCase().indexOf(screenName.toLowerCase()) < 0){
                msg.params['status'] = "@" + screenName + " " + newTweet.text
            }
        }

        console.log(screenName + " " + msg.params['status'].indexOf(screenName) + ' ' + type + " " + JSON.stringify(msg.params))
        worker.sendMessage(msg);
    }



    IconButton {
        id: attachBtn
        visible: newTweet.text.length == 0 ? true : false
        width: visible ? Theme.iconSizeMedium : 0
        height: width
        icon.source: "image://theme/icon-s-attach"
        anchors {
            right: parent.right
            bottom: newTweet.bottom
        }
        onClicked: {
            tweetExtra.open = !tweetExtra.open
        }


    }
    IconButton {
        id: sendBtn
        visible: newTweet.text.length != 0 ? true : false
        width: Theme.iconSizeMedium
        height: width
        icon.source: "image://theme/icon-m-enter-next"
        anchors {
            right: parent.right
            bottom: newTweet.bottom
        }
        onClicked: tweet()
    }

    Rectangle {
        width: parent.width
        height: progressBar.height
        color: Theme.highlightBackgroundColor
        opacity: 0.2
        anchors {
            left: parent.left
            right: parent.right
            bottom: newTweet.top
        }
    }
    Rectangle {
        id: progressBar
        width: newTweet.text.length ? newTweetPanel.width*(newTweet.text.length/140) : 0;

        height: Theme.itemSizeSmall * 0.05
        color: Theme.highlightBackgroundColor
        opacity: 0.3
        anchors {
            left: parent.left
            bottom: newTweet.top
        }
    }

    TextArea {
        id: newTweet

        property string shortenText: newTweet.text.replace(/https?:\/\/\S+/g, __replaceLink)
        function __replaceLink(w) {
            if (w.indexOf("https://") === 0)
                return "https://t.co/xxxxxxxxxx" // Length: 23
            else return "http://t.co/xxxxxxxxxx" // Length: 22
        }

        errorHighlight: newTweet.text < 0 && type != "RT"
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall
            left: parent.left
            rightMargin: Theme.paddingSmall
            right: sendBtn.left

        }
        autoScrollEnabled: true
        //label: (140 - shortenText.length) + ' chars left for your ' + (type == "New" ? "tweet" : "reply")
        placeholderText: "Enter your tweet"
        text: placedText
        labelVisible: false
        focus: true
        height: implicitHeight
        horizontalAlignment: Text.AlignLeft
        EnterKey.onClicked: {
            //tweet()
        }
        onTextChanged: {
            sendBtn.enabled = text.length > 140 ? false : true
            newTweet.color = (text.length > 140 ? "red": Theme.primaryColor)
        }

    }

    DockedPanel {
        id: tweetExtra

        width: parent.width
        height: Theme.itemSizeExtraLarge

        dock: Dock.Bottom

        Flow {
            anchors.centerIn: parent

            Switch {
                icon.source: "image://theme/icon-m-shuffle"
            }
            Switch {
                icon.source: "image://theme/icon-m-repeat"
            }
            Switch {
                icon.source: "image://theme/icon-m-share"
            }
        }
    }

}

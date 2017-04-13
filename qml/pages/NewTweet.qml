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
    height: newTweet.height + Theme.paddingMedium*2
    anchors {
        left: parent.left
        right: parent.right
    }
    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: myText.text = messageObject.reply
    }
    function tweet(){
        /*Logic.postStatus(newTweet.text, tweetId, latitude, longitude, function(e){
           console.log(JSON.stringify(e))
       }, function(e){console.log(JSON.stringify(e))})*/
        var msg = {
            'action': 'statuses_update',
            'model' : Logic.modelTL,
            'params'  : {'status': newTweet.text, 'in_reply_to_status_id':tweetId},
            'conf'  : Logic.getConfTW()
        };
        worker.sendMessage(msg);
    }



    IconButton {
        id: attachBtn
        width: Theme.iconSizeSmall
        height: width
        icon.source: "image://theme/icon-s-attach"
        anchors {
            left: parent.left
            leftMargin: Theme.paddingLarge
            bottom: newTweet.bottom
        }


    }
    IconButton {
        id: sendBtn
        width: Theme.iconSizeMedium
        height: width
        icon.source: "image://theme/icon-m-enter-next"
        anchors {
            right: parent.right
            bottom: attachBtn.bottom
        }
        onClicked: tweet()
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
            left: attachBtn.right
            rightMargin: Theme.paddingSmall
            right: sendBtn.left
            verticalCenter: parent.verticalCenter
        }
        autoScrollEnabled: true
        label: (140 - shortenText.length) + ' chars left for your ' + (type == "New" ? "tweet" : "reply")
        placeholderText: "Enter your tweet"
        text: placedText
        focus: true
        height: implicitHeight
        horizontalAlignment: Text.AlignLeft
        EnterKey.onClicked: {
            //tweet()
        }
        onTextChanged: {
            newTweet.color = (text.length > 140 ? "red": Theme.primaryColor)
        }

    }


}

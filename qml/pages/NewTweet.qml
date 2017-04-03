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
       Logic.postStatus(newTweet.text, tweetId, latitude, longitude, function(e){
           console.log(JSON.stringify(e))
       }, function(e){console.log(JSON.stringify(e))})
    }



    Label {
        id: newTweetCounter
        property string shortenText: newTweet.text.replace(/https?:\/\/\S+/g, __replaceLink)
        function __replaceLink(w) {
            if (w.indexOf("https://") === 0)
                return "https://t.co/xxxxxxxxxx" // Length: 23
            else return "http://t.co/xxxxxxxxxx" // Length: 22
        }


        text: 140 - shortenText.length

        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }


    }

    TextField {
        id: newTweet
        errorHighlight: newTweetCounter.text < 0 && type != "RT"
        anchors {
            left: parent.left
            rightMargin: Theme.paddingMedium
            right: newTweetCounter.left
            verticalCenter: parent.verticalCenter
        }
        autoScrollEnabled: true
        label: "New tweet"
        placeholderText: "New tweet"
        text: screenName
        focus: true
        height: implicitHeight
        horizontalAlignment: Text.AlignLeft
        EnterKey.onClicked: {
            tweet()
        }
        onTextChanged: {
            newTweetCounter.color = (text.length > 140 ? "red": Theme.primaryColor)
        }
    }


}

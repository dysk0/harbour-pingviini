import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import harbour.pingviini.Uploader 1.0
import "../lib/Logic.js" as Logic
import "../lib/codebird.js" as CB




Item {
    id: newTweetPanel
    property int tweetMaxChar: type == "DM" ? 1000: 280
    property int userId
    property string type: "New" //"New","Reply", "RT" or "DM"
    property string tweetId
    property string screenName //for "DM"
    property string placedText: ""
    property double latitude: 0
    property double longitude: 0
    property bool attachGeo: false
    property bool setFocus: false
    property string nextImageSrc: ""
    width: parent.width
    height: newTweet.height + btnLocation.height + uploadedImages.height
    anchors {
        left: parent.left
        right: parent.right
    }

    PositionSource {
        id: positionSource
        active: attachGeo
        //updateInterval: 120000 // 2 mins
        property variant fromCoordinate: QtPositioning.coordinate(latitude, longitude)
        onPositionChanged:  {
            //var currentPosition = positionSource.position.coordinate
            latitude = positionSource.position.coordinate.latitude
            longitude = positionSource.position.coordinate.longitude
            console.log(latitude + " " +longitude)
        }
    }

    ListModel {
        id: mediaModel
        onCountChanged: {
            //btnAddImage.enabled = mediaModel.count < 4
        }
    }
    ImageUploader {
        id: imageUploader

        onProgressChanged: {
            console.log("progress "+progress)
            uploadProgress.width = parent.width*progress
            attachBtn.enabled = (mediaModel.count < 5)
        }

        onSuccess: {
            uploadProgress.width =0
            replyData = JSON.parse(replyData)
            if (nextImageSrc !== ""){
                mediaModel.append({
                                      src: nextImageSrc,
                                      media_id: replyData.media_id,
                                      media_id_string: replyData.media_id_string
                                  })
                nextImageSrc = ""
            }
        }

        onFailure: {
            uploadProgress.width =0
            //btnAddImage.enabled = true;
            console.log(status)
            console.log(statusText)

        }
    }
    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            if (messageObject.success) {
                console.log(JSON.stringify(messageObject))
                newTweet.text = "";
            }
            newTweet.enabled = true;
            sendBtn.enabled = true;
        }
    }
    function tweet(){

        var msg = {
            'headlessAction': 'statuses_update',
            'model' : Logic.modelTL,
            'params'  : {'status': newTweet.text},
            'conf'  : Logic.getConfTW()
        };

        if (attachGeo && positionSource.valid) {
            msg.params['lat'] = latitude
            msg.params['long'] = longitude
        }
        if (mediaModel.count){
            var ids = [];
            for(var i =0; i <mediaModel.count; i++ ){
                console.log(mediaModel.get(i).media_id)
                ids.push(mediaModel.get(i).media_id_string)
            }
            msg.params['media_ids'] = ids.join(',')
        }

        if (type === "DM") {
            msg.model = Logic.modelDMsent
            msg.headlessAction = "directMessages_new"
            msg.params = {
                "text": newTweet.text,
                "screen_name": screenName
            }
        }
        if (type === "Reply") {
            msg.params['in_reply_to_status_id'] = tweetId
            if (msg.params['status'].toLowerCase().indexOf(screenName.toLowerCase()) < 0){
                //msg.params['status'] = "@" + screenName + " " + newTweet.text
            }
            msg.params['auto_populate_reply_metadata'] = true
        }

        console.log(JSON.stringify(msg))
        worker.sendMessage(msg);
        mediaModel.clear()
    }

    Rectangle {
        width: parent.width
        height: progressBar.height
        color: Theme.highlightBackgroundColor
        opacity: 0.2
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }
    Rectangle {
        id: progressBar
        width: newTweet.text.length ? newTweetPanel.width*(newTweet.text.length/tweetMaxChar) : 0;

        height: Theme.itemSizeSmall * 0.05
        color: Theme.highlightBackgroundColor
        opacity: 0.7
        anchors {
            left: parent.left
            top: parent.top
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
            topMargin: Theme.paddingMedium
            left: parent.left
            rightMargin: Theme.paddingSmall
            right: parent.right

        }
        autoScrollEnabled: true
        //label: (tweetMaxChar - shortenText.length) + ' chars left for your ' + (type == "New" ? "tweet" : "reply")
        placeholderText: "Enter your tweet"
        text: placedText
        labelVisible: false
        focus: setFocus
        height: implicitHeight
        horizontalAlignment: Text.AlignLeft
        // EnterKey.onClicked: { tweet() }
        onTextChanged: {
            sendBtn.enabled = text.length > tweetMaxChar ? false : true
            newTweet.color = (text.length > tweetMaxChar ? "red": Theme.primaryColor)
        }

    }


    SilicaGridView {
        id: uploadedImages
        width: parent.width
        anchors.bottom: parent.bottom
        height: mediaModel.count ? Theme.itemSizeSmall : 0
        model: mediaModel
        cellWidth: uploadedImages.width / 4
        cellHeight: Theme.itemSizeSmall
        delegate: BackgroundItem {
            id: myDelegate
            width: uploadedImages.cellWidth
            height: uploadedImages.cellHeight
            RemorseItem { id: remorse }
            Image {
                anchors.fill: parent
                source: model.src
                fillMode: Image.PreserveAspectCrop
                clip: true
            }

            onClicked: {
                var idx = index
                console.log(idx)
                //mediaModel.remove(idx)
                remorse.execute(myDelegate, qsTr("Delete"), function() { mediaModel.remove(idx) } )
            }
        }
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 800 }
        }

        remove: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0; duration: 800 }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 800; easing.type: Easing.InOutBack }
        }
    }

    IconButton {
        visible: type !== "DM"
        id: btnLocation
        anchors {
            top: newTweet.bottom
            topMargin: -Theme.paddingSmall
            left: newTweet.left
            //leftMargin: Theme.paddingMedium
        }
        width: Theme.itemSizeExtraSmall
        height: width
        icon.source: "image://theme/icon-cover-location?" + (pressed
                                                                ? Theme.secondaryHighlightColor
                                                                : (attachGeo ? Theme.primaryColor : Theme.highlightColor))
        onClicked: attachGeo = !attachGeo
    }
    IconButton {
        visible: type !== "DM"
        id: attachBtn
        icon.source: "image://theme/icon-s-attach?" + (pressed
                                                       ? Theme.primaryColor
                                                       : Theme.highlightColor)
        width: Theme.itemSizeExtraSmall
        height: width
        anchors {
            left: btnLocation.right
            top: btnLocation.top
        }
        onClicked: {
            var imagePicker = pageStack.push("Sailfish.Pickers.ImagePickerPage", { "allowedOrientations" : Orientation.All });
            imagePicker.selectedContentChanged.connect(function () {

                var conf = Logic.getConfTW();
                var cb = new CB.Fcodebird;
                cb.setConsumerKey(conf.OAUTH_CONSUMER_KEY, conf.OAUTH_CONSUMER_SECRET);
                cb.setToken(conf.OAUTH_TOKEN, conf.OAUTH_TOKEN_SECRET);
                cb.setUseProxy(false);

                var imagePath = imagePicker.selectedContent;
                var path = imagePath+"";

                nextImageSrc = path.substr(7)

                var sign = cb._sign('POST', 'https://upload.twitter.com/1.1/media/upload.json');
                imageUploader.setUploadUrl("https://upload.twitter.com/1.1/media/upload.json")
                //imageUploader.setUploadUrl("https://httpbin.org/post")
                imageUploader.setFile(imagePath);
                imageUploader.setAuthorizationHeader(sign);
                imageUploader.upload();
                 attachBtn.enabled = false;
            });
        }
    }
    IconButton {
        id: sendBtn
        width: Theme.iconSizeMedium
        height: width
        icon.source: "image://theme/icon-m-enter-next"
        anchors {
            right: parent.right
            top: btnLocation.top
        }
        onClicked: {
            tweet()
        }
    }
    Rectangle {
        id: uploadProgress
        color: Theme.highlightBackgroundColor
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 3
    }

}

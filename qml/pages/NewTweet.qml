import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import harbour.pingviini.Uploader 1.0
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
    height: newTweet.height + (tweetExtra.open ? tweetExtra.height : 0)
    anchors {
        left: parent.left
        right: parent.right
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
        }

        onSuccess: {
            uploadProgress.width =0
            console.log(replyData);
            mediaModel.append(JSON.parse(replyData))
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
        if (switchGPS.checked && positionSource.valid) {
            msg.params['lat'] = latitude
            msg.params['long'] = longitude
        }

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
        onClicked: {
            tweet()
            newTweet.enabled = false;
            sendBtn.enabled = false;
        }
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
        height: Theme.itemSizeExtraLarge+Theme.paddingLarge

        dock: Dock.Bottom
        PositionSource {
            id: positionSource
            active: false
            //updateInterval: 120000 // 2 mins
            property variant fromCoordinate: QtPositioning.coordinate(latitude, longitude)
            onPositionChanged:  {
                //var currentPosition = positionSource.position.coordinate
                latitude = positionSource.position.coordinate.latitude
                longitude = positionSource.position.coordinate.longitude
                console.log(latitude + " " +longitude)
            }
        }
        Flow {
            anchors.centerIn: parent

            Switch {
                id: switchGPS
                icon.source: "image://theme/icon-m-gps"
                onClicked: {
                    positionSource.active = checked
                }

            }
            Image {
                id: test
                onStatusChanged: {
                    if (status == Image.Ready) {
                        console.log('Loaded')
                        console.log(JSON.stringify(test.data))
                    }
                }
            }

            Switch {
                icon.source: "image://theme/icon-m-image"
                visible: true
                onClicked: {
                    if (checked){
                        var imagePicker = pageStack.push("Sailfish.Pickers.ImagePickerPage", { "allowedOrientations" : Orientation.All });
                        imagePicker.selectedContentChanged.connect(function () {
                            var imagePath = imagePicker.selectedContent;
                            console.log(imagePath)
                            imageUploader.setUploadUrl("https://upload.twitter.com/1.1/media/upload.json")
                            imageUploader.setUploadUrl("https://httpbin.org/post")
                            imageUploader.setFile(imagePath);
                            imageUploader.setAuthorizationHeader(Logic.conf.OAUTH_TOKEN);
                            imageUploader.upload();
                        });

                    }
                }
            }
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

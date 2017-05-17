import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import harbour.pingviini.Uploader 1.0
import harbour.pingviini.MyObject 1.0
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
            'action': 'statuses_update',
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
            MyObject {
                id: test2
            }
            Switch {
                icon.source: "image://theme/icon-m-image"
                onClicked: {
                    if (checked){
                        var dialog = pageStack.push(Qt.resolvedUrl("ImageChooser.qml"),
                                                    {"name": header.title})
                        dialog.accepted.connect(function() {
                            console.log(JSON.stringify(dialog.img))
                            header.title = "My name: " + dialog.img

                            test.source = dialog.img
                            test2.setFile(dialog.img)
                            test2.upload();
                            console.log(test2.getBase64())




                            var xhr = new XMLHttpRequest();



                            xhr.onprogress = function(evt) {
                            if (evt.lengthComputable) {
                                evt.target.curLoad = evt.loaded;
                                evt.target.log.parentNode.parentNode.previousSibling.textContent =
                                    Number(evt.loaded/k).toFixed() + "/"+ Number(evt.total/k).toFixed() + "kB";
                            }
                            if (evt.lengthComputable) {
                                var loaded = (evt.loaded / evt.total);
                                if (loaded < 1) {
                                    var newW = loaded * width;
                                    if (newW < 10) newW = 10;
                                        evt.target.log.style.width = newW + "px";
                                    }
                                }
                            };

                            xhr.open("POST", "https://upload.twitter.com/1.1/media/upload.json");
                            xhr.overrideMimeType('text/plain; charset=x-user-defined-binary');
                            xhr.sendAsBinary(file.getAsBinary());


                        })
                    }
                }
            }
        }
    }

}

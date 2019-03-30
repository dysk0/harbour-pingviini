import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "../lib/codebird.js" as CB

import "./cmp/"


Page {
    id: coversation
    property var locale: Qt.locale()
    property int group : 0;
    property string recipient_id : "";
    property string user_id : "";
    property string user_name : "";
    property string user_screen_name : "";
    property string user_avatar: "";
    property bool listloaded: false;
    signal navigateTo(string link)
    function isSent(id) {
        return id != Logic.conf.USER_ID
    }

    function generateData() {
        var t;
        if (!group){
            return;
        }
        tweets.clear();
        console.log("Items in model: " + Logic.modelDMraw.count)
        for(var i = Logic.modelDMraw.count; i >= 0 ; i--){
            t = Logic.modelDMraw.get(i); // i can't beleive what I am doing...
            console.log("DBG: "+JSON.stringify(t))

            //console.log(t.recipient_id )
            //if ((t.sender_id*1 + t.recipient_id*1 )=== group)
                tweets.append(t)
        }
        listloaded = true
        list.positionViewAtEnd()

    }

    Component.onCompleted: {
        generateData();
    }

    ProfileHeader {
        id: header
        title: user_name
        description: user_screen_name ? '@'+user_screen_name : ""
        image: user_avatar
    }


    allowedOrientations: Orientation.All

    DockedPanel {
        id: panel
        open: true
        height: tweetPanel.height
        width: parent.width
        onExpandedChanged: {
            if (!expanded) {
                show()
            }
        }
        NewTweet {
            suggestedModel: ListModel {}
            type: "DM"
            userId: user_id
            screenName: user_screen_name
            id: tweetPanel
        }
    }
    Rectangle {
        id: predictionList
        visible: true
        anchors.bottom: panel.top
        anchors.left: panel.left
        anchors.right: panel.right
        height: suggestedModel.count > 3 ? Theme.itemSizeExtraSmall * 3 : Theme.itemSizeExtraSmall * suggestedModel.count
        color: Theme.highlightBackgroundColor //Theme.highlightDimmerColor

        SilicaListView {
            anchors.fill: parent
            model: tweetPanel.suggestedModel
            clip: true

            delegate: BackgroundItem {
                Label {
                    text: "@" + model.screen_name
                }
                onClicked: {
                    var start = newTweet.cursorPosition;
                    while(newTweet.text[start] !== "@" && start > 0){
                        start--;
                    }
                    textOperations.text = newTweet.text
                    textOperations.cursorPosition = newTweet.cursorPosition
                    textOperations.moveCursorSelection(start-1,TextInput.SelectWords)
                    newTweet.text = textOperations.text.substring(0, textOperations.selectionStart) + ' @'+model.screen_name + ' ' + textOperations.text.substring(textOperations.selectionEnd).trim()

                    newTweet.cursorPosition = newTweet.text.indexOf('@'+model.screen_name)
                }
            }
            onCountChanged: {
                positionViewAtIndex(suggestedModel.count-1, ListView.End )
            }
        }
    }
    SilicaListView {

        id: list
        model: ListModel {
            id: tweets
            onCountChanged: {
                if (!listloaded){
                    list.positionViewAtIndex(count - 1, ListView.End)
                    listloaded = !listloaded
                }
            }
        }
        anchors {
            top: header.bottom
            bottom: panel.top
            left: parent.left
            right: parent.right
        }
        clip: true
        property var locale: Qt.locale()

        delegate: Item {
            width: parent.width
            visible: model.group == coversation.group
            height: model.group == coversation.group ? col.height+Theme.paddingLarge : 0

            Column {
                id: col
                width: parent.width
                Label {
                    id: lblText
                    anchors {
                        left: parent.left
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                    }
                    onLinkActivated: navigateTo(link)

                    text: model.text
                    textFormat:Text.RichText
                    linkColor : Theme.highlightColor
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: isSent(model.sender_id) ? Text.AlignLeft :Text.AlignRight
                    color: (pressed ? Theme.highlightColor : (isSent(model.sender_id) ? Theme.highlightColor : Theme.primaryColor))
                }
                Repeater {
                    id: rep
                    model: ListModel {
                        id: media
                    }
                    Label {
                        text: type
                    }

                    Image {
                        id: image
                        fillMode: Image.PreserveAspectCrop

                        anchors {
                            topMargin: Theme.paddingSmall
                            rightMargin: Theme.paddingLarge
                            leftMargin: Theme.paddingLarge
                        }
                        width: Theme.iconSizeLarge;
                        height: width

                        source: "image://theme/icon-l-image?" + (pressed
                                                                ? Theme.highlightColor
                                                                : Theme.primaryColor)

                        Component.onCompleted: {
                            if(!sent) {
                                image.anchors.left = parent.left
                            } else {
                                image.anchors.right = parent.right
                            }
                            if (rep.model.get(index).type === "sticker") {
                                source = rep.model.get(index).cover
                                height = width = Theme.iconSizeLarge

                            } else {
                                height = width = Math.round(parent.width*0.75)
                                var conf = Logic.getConfTW();
                                var cb = new CB.Fcodebird;
                                cb.setConsumerKey(conf.OAUTH_CONSUMER_KEY, conf.OAUTH_CONSUMER_SECRET);
                                cb.setToken(conf.OAUTH_TOKEN, conf.OAUTH_TOKEN_SECRET);
                                cb.setUseProxy(false);

                                var url = rep.model.get(index).cover;
                                var sign = cb._sign('GET', url);

                                //url = "http://api.grave-design.com/pingviini/?img="+encodeURIComponent(rep.model.get(index).cover)+'&oauth='+encodeURIComponent(sign)
                                //console.log(sign); console.log(JSON.stringify(rep.model.get(index).cover)) ; console.log(url)
                                //source = url
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("./ImageFullScreen.qml"), {"mediaURL": image.source})
                                console.log(mediaURL)
                            }
                        }
                    }
                }

                /*Image {
                    id: mediaImg
                    anchors {
                        topMargin: Theme.paddingSmall
                        rightMargin: Theme.paddingLarge
                    }
                    width: parent.width*0.8
                    height: 100
                    onStatusChanged: {
                        if (status == Image.Error) {
                            console.log("source: " + source + ": failed to load");
                            source = "image://theme/icon-l-play";
                        }
                    }
                    Component.onCompleted: {
                        if (!model.sent)
                            anchors.left = parent.left
                        else
                            anchors.right = parent.right

                        if (model && model.count){
                            mediaURL = model.get(0).cover
                        }
                    }
                }*/



                Label {
                    function timestamp() {
                        var txt = Format.formatDate(created_at, Formatter.Timepoint)
                        var elapsed = Format.formatDate(created_at, Formatter.DurationElapsedShort)
                        return (elapsed ? elapsed  : txt )
                    }
                    id: lblDate
                    color: (pressed ? Theme.highlightColor : Theme.secondaryColor)
                    text: Format.formatDate(created_at, new Date() - created_at < 60*60*1000 ? Formatter.DurationElapsedShort : Formatter.TimepointRelativeCurrentDayDetailed)
                    font.pixelSize: Theme.fontSizeExtraSmall
                    horizontalAlignment: isSent(model.sender_id) ? Text.AlignLeft :Text.AlignRight
                    width: lblText.width
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                        bottomMargin: Theme.paddingLarge
                    }
                }
            }}
    }

    WorkerScript {
        id: parser
        source: "../lib/Worker.js"
        onMessage: {

        }
    }
}

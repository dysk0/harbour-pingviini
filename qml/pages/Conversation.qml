import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "../lib/codebird.js" as CB

import "./cmp/"


Page {

    property var locale: Qt.locale()
    property string recipient_id : "";
    property string user_id : "";
    property string user_name : "";
    property string user_screen_name : "";
    property string user_avatar: "";
    property bool listloaded: false;
    signal navigateTo(string link)


    Component.onCompleted: {
        var msg = {
            parser_action : "create_conversation",
            sender_id: user_id,
            recipient_id: recipient_id,
            modelSent: Logic.modelDMsent,
            modelReceived: Logic.modelDMreceived,
            modelConversation: tweets
        }




        var data = [];
        var i;
        var item;
        for (i = 0; i < Logic.modelDMsent.count; i++){
            if (Logic.modelDMsent.get(i).recipient_id === user_id && Logic.modelDMsent.get(i).sender_id === recipient_id){
                //item = JSON.parse(JSON.stringify(msg.modelSent.get(i)))
                item = Logic.modelDMsent.get(i)
                item['sent'] = true;
                //console.log(JSON.stringify(item.media))
                //item['section'] = getDate(item['created_at']);
                data.push(item)
            }
        }
        for (i = 0; i < Logic.modelDMreceived.count; i++){
            if ((Logic.modelDMreceived.get(i).sender_id === user_id)){
                //item = JSON.parse(JSON.stringify(msg.modelReceived.get(i)))
                item = Logic.modelDMreceived.get(i)
                item['sent'] = false;
                //item['section'] = getDate(item['created_at']);
                data.push(item)
            }
        }
        tweets.clear();
        data = data.sort(function(a,b){ return a.created_at - b.created_at; })
        tweets.append(data);
        //parser.sendMessage(msg)
    }

    ProfileHeader {
        id: header
        title: Logic.getUserName(user_name)
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
            type: "DM"
            screenName: user_screen_name
            id: tweetPanel
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
        section {
            property: 'section'
            delegate: SectionHeader  {
                height: Theme.itemSizeExtraSmall
                text: Format.formatDate(section, Formatter.DateMedium)
            }
        }

        delegate: Item {
            width: parent.width
            height: col.height+Theme.paddingLarge
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
                    horizontalAlignment: !model.sent ? Text.AlignLeft :Text.AlignRight
                    color: (pressed ? Theme.highlightColor : (!model.sent ? Theme.highlightColor : Theme.primaryColor))
                }
                Repeater {
                    id: rep
                    model: media
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
                    horizontalAlignment: !model.sent ? Text.AlignLeft :Text.AlignRight
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

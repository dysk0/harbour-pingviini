/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "./cmp/"

Page {
    property variant tweet
    property string selected;
    property string  title;
    property string  avatar;
    property string tweet_id;
    property string user_id;

    property alias screenName: tweetPanel.screenName;
    property string tweetType: "Reply";
    property bool isFavourited: false;

    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
         console.log(messageObject.reply)
        }
    }


    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All




    /*ProfileHeader {
        id: header
        title: ""
        description: screenName ? '@'+screenName : ""
    }*/
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
            width: parent.width
            id: tweetPanel
            type: tweetType
            tweetId: tweet_id
            screenName: screenName ? screenName : ""
        }
    }


    SilicaListView {
        header: PageHeader {
            title: qsTr("Conversation")
        }
        BusyIndicator {
            size: BusyIndicatorSize.Large
            running: listView.model.count === 0;
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        id: listView
        model: ListModel {}
        RemorseItem { id: remorse }
        /*PullDownMenu {
            id: menu
            spacing: Theme.paddingLarge
            MenuItem {
                text: qsTr("Report as spam")
                onClicked: {
                    Logic.mediator.publish("bgCommand", {
                                               'headlessAction': 'users_reportSpam',
                                               'params': {'screen_name': tweet.screenName, 'user_id': tweet.id_str}
                                           })
                }
            }
            MenuItem {
                text: qsTr("Retweet")
                onClicked: {
                    var msg = {
                        'headlessAction': 'statuses_retweet_ID',
                        'params': {'id': tweet.id_str}
                    };
                    Logic.mediator.publish("bgCommand", msg)
                    tweet.retweeted = true;
                }
            }
            MenuItem {
                text: (typeof tweet.favorited !== "undefined" && tweet.favorited ? qsTr("Unfavorite") : qsTr("Favorite"))
                onClicked: {
                    Logic.mediator.publish("bgCommand", {
                                               'headlessAction': 'favorites_' + (tweet.favorited ? 'destroy' : 'create'),
                                               'params': {'id': tweet.id_str}
                                           })
                    tweet.favorited = !tweet.favorited
                }
            }
        }*/
        anchors {
            top: parent.top
            bottom: panel.top
            left: parent.left
            right: parent.right
        }
        clip: true
        section {
            property: 'section'
            delegate: SectionHeader  {
                height: Theme.itemSizeExtraSmall
                text: Format.formatDate(section, Formatter.DateMedium)
            }
        }


        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 800 }
            NumberAnimation { property: "x"; duration: 800; easing.type: Easing.InOutBack }
        }

        remove: Transition {
            NumberAnimation { properties: "x,y"; duration: 800; easing.type: Easing.InOutBack }
        }
        delegate: CmpTweet{ tweet: model}
        VerticalScrollDecorator {}
        Component.onCompleted: {
            if (typeof tweet.id !== "undefined"){

                title =  tweet.name
                screenName =  tweet.screen_name + " "+ tweet.id_str
                //header.image = tweet.avatar
                if (tweet.id_str)
                    tweetPanel.tweetId = tweet.id_str;
                if (tweet.user_id_str)
                    tweetPanel.userId = tweet.user_id_str;
                isFavourited = tweet.favorited;

                var req = 'http://api.grave-design.com/conversation/?username=' + tweet.screen_name + '&id='+tweet.id_str;
                console.log(req)
                Logic.request(req, function (data) {
                    // log the json response
                    data = JSON.parse(data.responseText)
                    var i;
                    if (data.ancestors) {
                        for(i= 0; i < data.ancestors.length; i++) {
                            data.ancestors[i] = Logic.parseTweet(data.ancestors[i])
                        }
                    }
                    if (data.tweet) {
                        for(i= 0; i < data.tweet.length; i++) {
                            data.tweet[i] = Logic.parseTweet(data.tweet[i])
                            data.tweet[i]["enlarge"] = true
                        }
                    }
                    if (data.descendants) {
                        for(i= 0; i < data.descendants.length; i++) {
                            data.descendants[i] = Logic.parseTweet(data.descendants[i])
                        }
                    }
                    model.clear();
                    model.append(data.ancestors)
                    model.append(data.tweet)
                    model.append(data.descendants)

                    positionViewAtIndex(data.ancestors.length, ListView.Center)
                    console.log(JSON.stringify(data.tweet))
                });



                /*var since = tweet.created_at
                var until = new Date(new Date().setDate(new Date(since).getDate() + 7));
                console.log(since)
                console.log(until)
                //console.log(since.toISOString().substr(0, 10))
                //console.log(until.toISOString().substr(0, 10))
                var user = '@'+screenName + (tweet.inReplyToStatusId ? ' OR @'+tweet.inReplyToScreenName : '')
                var msg = {
                    'bgAction'    : 'search_tweets',
                    'params': {
                        f: "tweets",
                        count: 100,
                        result_type: "recent",
                        q: user + ' -RT  filter:replies since:'+since.toISOString().substr(0, 10)+ ' until:'+until.toISOString().substr(0, 10),
                        since_id: tweet.inReplyToStatusId ? tweet.inReplyToStatusId: tweet.id
                    },
                    'mode'      : 'prepend',
                    'model'     : modelCO,
                    'conf'      : Logic.getConfTW()
                };
                //worker.sendMessage(msg);*/
            }
        }
    }

}

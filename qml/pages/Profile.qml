import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "./cmp/"
import QtGraphicalEffects 1.0

Page {
    property ListModel tweets;
    property string name : "";
    property string username : "";
    property string profileImage : "";
    property int user_id;
    property int statuses_count;
    property int friends_count;
    property int followers_count;
    property int favourites_count;
    property int count_moments;
    property string profile_background : "";
    property string location : "";
    property bool following : false;

    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            console.log(JSON.stringify(messageObject))
            if(messageObject.action === "users_show" || messageObject.action === "friendships_destroy" || messageObject.action ===  "friendships_create"){
                followers_count = messageObject.reply.followers_count
                friends_count = messageObject.reply.friends_count
                statuses_count = messageObject.reply.statuses_count
                favourites_count = messageObject.reply.favourites_count
                profile_background = messageObject.reply.profile_background_image_url_https
                location = messageObject.reply.location
                following= messageObject.reply.following
                user_id = messageObject.reply.id

            }
        }
    }



    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All


    SilicaFlickable {
        anchors {
            fill: parent
        }
        contentHeight: column.height + Theme.paddingLarge




        Component.onCompleted: {
            var msg = {
                'action': 'users_show',
                'screen_name': username,
                'conf'  : Logic.getConfTW()
            };
            worker.sendMessage(msg);
        }



        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            ProfileHeader {
                id: header
                bg: profile_background
                title: name
                description: '@'+username
                image: profileImage
            }
            ExpandingSectionGroup {
                currentIndex: 0
                anchors {
                    top: header.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                ExpandingSection {
                    title: "Summary"
                    content.sourceComponent: Column {
                        spacing: Theme.paddingMedium
                        anchors.bottomMargin: Theme.paddingLarge
                        DetailItem {
                            visible: location != "" ? true : false
                            label: "Location"
                            value: location
                        }
                        DetailItem {
                            visible: followers_count ? true : false
                            label: "Followers"
                            value: followers_count
                        }
                        DetailItem {
                            visible: friends_count ? true : false
                            label: "Following"
                            value: (friends_count)
                        }
                        DetailItem {
                            visible: statuses_count ? true : false
                            label: "Tweets"
                            value: (statuses_count)
                        }
                        DetailItem {
                            visible: favourites_count ? true : false
                            label: "Favourites"
                            value: (favourites_count)
                        }
                        Row {
                            anchors.horizontalCenter:     parent.horizontalCenter
                            Button {
                                id: btnFollow
                                text: (following ? "Unfollow" : "Follow")
                                onClicked: {

                                    var msg = {
                                        'action': following ? "friendships_destroy" : "friendships_create",
                                                              'screen_name': username,
                                                              'conf'  : Logic.getConfTW()
                                    };
                                    worker.sendMessage(msg);
                                    following = !following
                                }
                            }
                        }
                        Label {
                            text: " "
                        }
                    }

                }
                ExpandingSection {
                    title: "Tweets"
                    content.sourceComponent: Column {
                        width: parent.width

                        Repeater {
                            model: 100

                            TextSwitch {
                                text: "Option " + (index + 1)
                            }
                        }
                    }
                }
            }
        }




        /*


    */
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0
import "./cmp/"
import "../lib/Logic.js" as Logic



Page {
    id: page
    property var locale: Qt.locale()
    property bool loadStarted: false

    function pullData(){
        /*var msg = {
            'action': 'statuses_homeTimeline',
            'model' : Logic.modelTL,
            'mode'  : "append",
            'conf'  : Logic.getConfTW()
        };
        worker.sendMessage(msg);

        var msg2 = {
            'action': 'statuses_mentionsTimeline',
            'model' : Logic.modelMN,
            'mode'  : "append",
            'conf'  : Logic.getConfTW()
        };*/
        worker.sendMessage({
                               'bgUpdate': true,
                               'modelTL' : Logic.modelTL,
                               'modelME' : Logic.modelME,
                               'modelRawDM' : Logic.modelRawDM,
                               'modelDM' : Logic.modelDM,
                               'conf'  : Logic.getConfTW()
                           });
    }
    Timer {
        interval: 5*60*1000; running: true; repeat: true
        onTriggered: {
           // pullData()


            /*Logic.modelTL.append(Logic.parseTweet(Logic.tweet1))
            Logic.modelTL.append(Logic.parseTweet(Logic.tweet3))
            Logic.modelTL.append(Logic.parseTweet(Logic.tweet2))*/
        }
    }
    Timer {
        id: splashTimer
        interval: 500; running: false; repeat: false
        onTriggered: {
            //pageStack.replace(Qt.resolvedUrl("Conversation.qml"), {})




            if(Logic.getConfTW().OAUTH_TOKEN){
                pageStack.replace(Qt.resolvedUrl("MainPage.qml"), {})
                //pageStack.replace(Qt.resolvedUrl("TweetDetails.qml"), {})
            } else {
                pageStack.replace(Qt.resolvedUrl("AccountAdd.qml"), {})
            }



        }
    }


    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            if (messageObject.key === "account_verifyCredentials"){
                if (messageObject.reply.screen_name){
                    Logic.conf['USER_ID'] = messageObject.reply.id;
                    Logic.conf['SCREEN_NAME'] = messageObject.reply.screen_name;
                    Logic.conf['USER'] = messageObject.reply.name;
                    console.log(JSON.stringify(messageObject.reply))
                    pageStack.replace(Qt.resolvedUrl("MainPage.qml"), {})
                    //pageStack.replace(Qt.resolvedUrl("TweetDetails.qml"), {tweet:{}})
                    //pullData();
                } else {
                    pageStack.replace(Qt.resolvedUrl("AccountAdd.qml"), {})
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("Splash Conf!")

        var obj = {};
        Logic.mediator.installTo(obj);
        obj.subscribe('confLoaded', function(){
            console.log(typeof arguments)
            console.log('confLoaded');
            console.log(JSON.stringify(Logic.conf))
            //console.log(JSON.stringify(Logic.getConfTW()))

            //pullData()
            //pageStack.pushAttached(Qt.resolvedUrl("FirstPage.qml"), {})
            /*Logic.modelTL.append(Logic.parseTweet(Logic.tweet1))
            Logic.modelTL.append(Logic.parseTweet(Logic.tweet2))
            Logic.modelTL.append(Logic.parseTweet(Logic.tweet3))
            Logic.modelTL.append(Logic.parseTweet(Logic.tweet4))
            Logic.modelTL.append(Logic.parseTweet(Logic.tweet5))
            Logic.modelTL.append(Logic.parseTweet(Logic.tweet6))
            Logic.modelTL.append(Logic.parseTweet(Logic.tweet7))*/


            //splashTimer.running = true
            logo.opacity = 1;
            console.log("https://api.twitter.com/1.1/account/verify_credentials.json")

            // request verify credentials
            var verify = {
                'headlessAction': 'account_verifyCredentials',
                'conf'  : Logic.getConfTW()
            };
            worker.sendMessage(verify);

        });


    }

    Image {
        width: Theme.itemSizeHuge
        height: width
        fillMode: Image.PreserveAspectFit
        //source: "../logo.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        PingviiniiLogo {
            id: logo
            opacity: 0;
            anchors.fill: parent
            Behavior on opacity { NumberAnimation {} }
        }
    }

}




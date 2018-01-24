import QtQuick 2.0
import Sailfish.Silica 1.0
import "./cmp/"
import "../lib/Logic.js" as Logic
import "../lib/codebird.js" as CB



Page {
    id: page
    property var locale: Qt.locale()
    property bool loadStarted: false
    Image {
        id: test
    }

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
                    //pageStack.replace(Qt.resolvedUrl("Lists.qml"), {})
                    //pageStack.replace(Qt.resolvedUrl("TweetDetails.qml"), {tweet:{}})
                    //pullData();

                    var xhr = new XMLHttpRequest();

                    var conf = Logic.getConfTW();
                    var cb = new CB.Fcodebird;
                    cb.setConsumerKey(conf.OAUTH_CONSUMER_KEY, conf.OAUTH_CONSUMER_SECRET);
                    cb.setToken(conf.OAUTH_TOKEN, conf.OAUTH_TOKEN_SECRET);
                    cb.setUseProxy(false);

                    var url = "https://ton.twitter.com/i/ton/data/dm/888372972796469251/888372963925532672/8l54wuIc.jpg:large";
                    var sign = cb._sign('GET', url);
                    console.log(sign)
                    //xhr.responseType    = "arraybuffer";
                    xhr.open("GET", url);

                    xhr.onreadystatechange = function () {
                        if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {

                            var base64     = Logic.customBase64Encode (xhr.responseText);

                            /*var uInt8Array = new Uint8Array(xhr.response);
                                var i = uInt8Array.length;
                                var binaryString = new Array(i);
                                while (i--)
                                {
                                  binaryString[i] = String.fromCharCode(uInt8Array[i]);
                                }
                                var data = binaryString.join('');

                                var base64 = Qt.btoa(data);

                            //test.source = byteArray*/
                            console.log('data:image/jpeg;base64,' + base64);
                        } else {
                            console.log(xhr.statusText)
                        }
                    };

                    xhr.setRequestHeader("Authorization", sign)
                    //xhr.send();

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




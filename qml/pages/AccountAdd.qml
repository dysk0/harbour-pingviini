import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Page {
    id: page
    property string tokenTempo;
    property string tokenSecretTempo;
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            console.log(JSON.stringify(messageObject))
            if (messageObject.key === "oauth_accessToken") {
                Logic.OAUTH_TOKEN = messageObject.reply.oauth_token
                Logic.OAUTH_TOKEN_SECRET = messageObject.reply.oauth_token_secret
                Logic.USER_ID = messageObject.reply.user_id
                Logic.SCREEN_NAME = messageObject.reply.screen_name
                Logic.conf = Logic.getConfTW()
                console.log(JSON.stringify(Logic.conf))
                console.log("User added")
                console.log(JSON.stringify(Logic.getConfTW()))
                Logic.saveData();
                if (messageObject.reply.oauth_token)
                    pageStack.replace(Qt.resolvedUrl("MainPage.qml"), {})
                //Logic.initialize()

            } else if (messageObject.key === "oauth_authorize") {
                console.log("Open url: " + messageObject.reply)
                Qt.openUrlExternally(messageObject.reply);

            } else if (messageObject.key === "oauth_requestToken") {
                var conf = Logic.getConfTW();
                conf.OAUTH_TOKEN = tokenTempo = messageObject.reply.oauth_token
                conf.OAUTH_TOKEN_SECRET = tokenSecretTempo = messageObject.reply.oauth_token_secret
                var msg = {
                    'headlessAction': 'oauth_authorize',
                    'params': {oauth_callback: "oob"},
                    'conf'  : conf
                };
                worker.sendMessage(msg);
            }
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Add Account")
            }
            ExpandingSectionGroup {
                currentIndex: 0
                width: parent.width
                ExpandingSection {
                    id: step1
                    title: "Step 1"
                    content.sourceComponent: Column {
                        width: parent.width
                        spacing: Theme.paddingMedium
                        anchors.bottomMargin: Theme.paddingLarge
                        Label {
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: {
                                    left: Theme.paddingLarge
                                    rigth: Theme.paddingLarge
                                }
                            }
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: "Click on the button below and authorize Pingviini for Sailfish OS to use your Twitter account."
                        }

                        Button {
                            text: 'Open browser'
                            anchors { horizontalCenter: parent.horizontalCenter;}
                            onClicked: {
                                enabled = !enabled
                                step1.expanded = false
                                step2.expanded = true
                                var msg = {
                                    'headlessAction': 'oauth_requestToken',
                                    'params': {oauth_callback: "oob"},
                                    'conf'  : Logic.getConfTW()
                                };
                                worker.sendMessage(msg);

                                // console.log("Launching web browser with url:", signInUrl);

                                //console.log({tokenTempo: tokenTempo, tokenSecretTempo: tokenSecretTempo})
                            }
                        }
                        Label {
                            text: " "
                        }
                    }

                }
                ExpandingSection {
                    id: step2
                    title: "Step 2"
                    content.sourceComponent: Column {
                        width: step2.width
                        Label {
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: {
                                    left: Theme.paddingLarge
                                    rigth: Theme.paddingLarge
                                    bottom: Theme.paddingLarge
                                }
                            }
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: "Authorize Pingviini to use your account by entering PIN to complete the authorization process:"
                        }

                        TextField {
                            id: oauthVerifier
                            width: parent.width
                            label: "Authorization Code"
                            inputMethodHints: Qt.ImhDialableCharactersOnly
                            placeholderText: "Retype authorization code here"
                            focus: true
                            EnterKey.onClicked: {
                                parent.focus = true;
                                auth()
                            }
                            onTextChanged: {
                                if (text.length == 7)
                                    btnAuth.enabled = true;
                            }
                        }

                        Button {
                            id: btnAuth
                            text: 'Authorize'
                            enabled: false
                            anchors { horizontalCenter: parent.horizontalCenter;}
                            onClicked: {
                                auth()
                            }

                        }
                        function auth(){
                            enabled = !enabled
                            step1.expanded = false
                            step2.expanded = true
                            var conf = Logic.getConfTW();
                            conf.OAUTH_TOKEN = tokenTempo
                            conf.OAUTH_TOKEN_SECRET = tokenSecretTempo
                            var msg = {
                                'headlessAction': 'oauth_accessToken',
                                'params': { 'oauth_verifier': oauthVerifier.text},
                                'conf'  : conf
                            };
                            worker.sendMessage(msg);
                        }
                        Label {
                            text: " "
                        }
                    }

                }
            }
        }
    }
    Component.onCompleted: {
        console.log("-------------getConf")
        console.log(JSON.stringify(Logic.conf))
    }
}


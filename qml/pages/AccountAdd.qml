import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Page {
    id: page
    property string tokenTempo;
    property string tokenSecretTempo;
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

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
                ExpandingSection {
                    id: step1
                    title: "Step 1"
                    content.sourceComponent: Column {
                        width: step1.width
                        spacing: Theme.paddingLarge
                        Label {
                            anchors {
                                margins:  Theme.paddingLarge
                            }
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: "Click on the button below and authorize Pingviini for Sailfish OS to use your Twitter account."
                        }

                        Button {
                            text: 'Authorize app'
                            anchors { horizontalCenter: parent.horizontalCenter;}
                            onClicked: {
                                enabled = !enabled
                                step1.expanded = false
                                step2.expanded = true
                                Logic.postRequestToken(function(token, tokenSecret) {
                                    tokenTempo = token;
                                    tokenSecretTempo = tokenSecret;
                                    var signInUrl = "https://api.twitter.com/oauth/authorize?oauth_token=" + tokenTempo;
                                    console.log("Launching web browser with url:", signInUrl);
                                    Qt.openUrlExternally(signInUrl);
                                    console.log({tokenTempo: tokenTempo, tokenSecretTempo: tokenSecretTempo})
                                },
                                function(status, statusText) {
                                    if (status === 401){
                                        console.log("Error: Unable to authorize with Twitter. Make sure the time/date of your phone is set correctly.")
                                    } else {
                                        showHttpError(status, statusText)
                                    }
                                });
                            }
                        }
                    }

                }
                ExpandingSection {
                    id: step2
                    title: "Step 2"
                    content.sourceComponent: Column {
                        width: step2.width
                        TextField {
                            id: oauthVerifier
                            width: parent.width
                            label: "Authorization Code"
                            placeholderText: "Retype authorization code here"
                            focus: true
                            EnterKey.onClicked: {
                                parent.focus = true;
                            }
                        }

                        Button {
                            text: 'Go!'
                            onClicked: {
                                enabled = !enabled
                                step1.expanded = false
                                step2.expanded = true
                                Logic.postAccessToken(
                                tokenTempo, tokenSecretTempo, oauthVerifier.text,
                                function(token, tokenSecret, screenName) {
                                    Logic.conf.OAUTH_TOKEN = Logic.OAUTH_TOKEN = token;
                                    Logic.conf.OAUTH_TOKEN_SECRET = Logic.OAUTH_TOKEN_SECRET = tokenSecret;
                                    Logic.conf.SCREEN_NAME = Logic.SCREEN_NAME = screenName;
                                    console.log(JSON.stringify([token, tokenSecret, screenName]))
                                },
                                function(status, statusText) {
                                    if (status === 401){
                                        console.log("Error: Unable to authorize with Twitter. Make sure the time/date of your phone is set correctly.")
                                    } else {
                                        showHttpError(status, statusText)
                                    }
                                });
                            }
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


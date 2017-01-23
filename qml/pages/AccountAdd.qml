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
            Button {
                text: "Authorize app"
                onClicked: {
                    enabled = !enabled
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

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Hello Sailors")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
    Component.onCompleted: {
        console.log("-------------getConf")
        console.log(JSON.stringify(Logic.conf))
    }
}


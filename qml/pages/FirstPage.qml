import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Page {
    id: page
    PageHeader {
        title: qsTr("Pingviini")
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Add account")
                onClicked: pageStack.push(Qt.resolvedUrl("AccountAdd.qml"))
            }
        }


        ListModel {
            id: homeTimeLine
        }

        SilicaListView {
            anchors {
                fill: parent
            }

            id: firstColumn
            width: parent.width
            model: homeTimeLine
            delegate: CmpTweet {

            }


            footer:    Button {
                text: "go!"
                onClicked: {
                    console.log(JSON.stringify([Logic.OAUTH_CONSUMER_KEY, Logic.OAUTH_CONSUMER_SECRET, Logic.OAUTH_TOKEN, Logic.OAUTH_TOKEN_SECRET]))
                    Logic.getHomeTimeline(false, false, function(data) {

                        for (var i=0; i < data.length; i++) {
                            homeTimeLine.append(data[i])
                            if (i < 10)
                                console.log(JSON.stringify(data[i]));
                        }
                    }, function(status, statusText) {
                        if (status === 401){
                            console.log("Error: Unable to authorize with Twitter. Make sure the time/date of your phone is set correctly.")
                        } else {
                            showHttpError(status, statusText)
                        }
                    })
                }
            }
        }


    }
    Component.onCompleted: {
        console.log("-------------getConf")
        console.log(JSON.stringify(Logic.conf))

        /**/
    }
    Component.onDestruction: {
        Logic.saveData()
    }
}


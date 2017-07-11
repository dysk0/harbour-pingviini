import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "."



Page {
    SilicaListView {
        anchors.fill: parent
        header: PageHeader {
            title: Logic.modelUsers.count + " Users"
        }
        model: Logic.modelUsers
        delegate: BackgroundItem {
            width: parent.width
            height: Theme.itemSizeLarge
            Image {
                id: avatarImg
                width: Theme.itemSizeLarge
                height: width
                source: avatar
            }

            Column {
                anchors {
                    left: avatarImg.right
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    text: name
                }
                Label {
                    text: id
                }
                Label {
                    text: screen_name
                }
            }
        }
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "."



Page {
    SilicaGridView {
        id: grid
        anchors.fill: parent
        header: PageHeader {
            title: Logic.modelUsers.count + " Users"
        }
        model: Logic.modelUsers
        cellWidth: width / 8
        cellHeight: cellWidth

        delegate: BackgroundItem {
            width: grid.cellWidth
            height: grid.cellWidth
            Image {
                id: avatarImg
                anchors.fill: parent
                source: model.avatar
                /*Label {
                    text: id_str
                    font.pixelSize: Theme.fontSizeExtraSmall
                    anchors.margins: 20
                }*/
            }

            /*Column {
                anchors {
                    left: avatarImg.right
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    text: name
                    font.family: Theme.fontFamilyHeading
                }

                Label {
                    text: '@'+screen_name
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }*/
        }
    }
}

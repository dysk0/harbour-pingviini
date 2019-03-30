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
        cellWidth: width / 2
        cellHeight: cellWidth

        delegate: BackgroundItem {
            width: grid.cellWidth
            height: grid.cellWidth
            Image {
                id: avatarImg
                anchors.fill: parent
                source: model.avatar
                Column {
                    anchors {
                        left: avatarImg.left
                        verticalCenter: parent.verticalCenter
                        margins: 20
                    }
                    Label {
                        text: model.user_id
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }

                    Label {
                        text: model.name
                        font.family: Theme.fontFamilyHeading
                    }

                    Label {
                        text: '@'+model.screen_name
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }
        }
    }
}

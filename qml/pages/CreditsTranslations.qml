import QtQuick 2.0

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    allowedOrientations: Orientation.All

    SilicaListView {
        id: listview
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Credits")
        }

        model: ListModel {

            ListElement {
                section: "Translation"
                name: "	Italian"
                author: "fravaccaro"
                url: "https://github.com/fravaccaro"
            }
            ListElement {
                section: "Translation"
                name: "Dutch"
                author: "d9h02f"
                url: "https://github.com/d9h02f"
            }
            ListElement {
                section: "Development"
                name: ""
                author: "Miodrag Nikolić"
                url: "#"
            }
            ListElement {
                section: "Development"
                name: ""
                author: "Duško Angirević"
                url: "http://grave-design.com/"
            }
            ListElement {
                section: "Credits"
                name: "codebird.js"
                author: "jublonet"
                license: "GNU GPL v3.0"
                file: "https://raw.githubusercontent.com/jublonet/codebird-js/develop/LICENSE"
                url: "https://github.com/jublonet/codebird-js"
            }
            ListElement {
                section: "Credits"
                name: "Author of Piepmatz"
                author: "Sebastian J. Wolf"
                license: "GNU GPL v3.0"
                file: "https://raw.githubusercontent.com/Wunderfitz/harbour-piepmatz/master/LICENSE"
                url: "https://github.com/Wunderfitz/harbour-piepmatz"
            }
            ListElement {
                section: "Credits"
                name: "Author of Tweetian"
                author: "Dickson Leong"
                license: "GNU GPL v3.0"
                file: "https://raw.githubusercontent.com/Tweetian/"
                url: "https://github.com/dicksonleong/Tweetian"
            }
        }

        section {
            property: 'section'
            criteria: ViewSection.FullString
            delegate: SectionHeader  {
                text: section
            }
        }


        delegate: BackgroundItem {
            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                color: (pressed ? Theme.highlightColor : Theme.primaryColor)
                text: author
                font.pixelSize: Theme.fontSizeSmall
            }
            Label {
                anchors {
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                text: name
                color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }

        VerticalScrollDecorator {}
    }
}

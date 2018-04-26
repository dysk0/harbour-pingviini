import QtQuick 2.0
import Sailfish.Silica 1.0
import "./cmp/"

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge
        contentWidth: parent.width

        VerticalScrollDecorator {}
        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader {
                title: qsTr("Settings")
            }
            Column {
                // No spacing in this column
                width: parent.width
                IconTextSwitch {
                    text: qsTr("Add / Replace Account")
                    description: qsTr("Authorize this app to use your Twitter account in your behalf.")
                    icon.source: "image://theme/icon-m-add"
                    onClicked: pageStack.push(Qt.resolvedUrl("AccountAdd.qml"))
                }
                IconTextSwitch {
                    enabled: false
                    checked: true
                    text: qsTr("Load images in tweets")
                    description: qsTr("Disable this option if you want to preserve your data connection.")
                    icon.source: "image://theme/icon-m-mobile-network"
                }
            }
            SectionHeader {
                text: "Credits and license"
            }
            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                linkColor: Theme.highlightColor
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "<a style='text-decoration:none' href='https://github.com/dysk0/harbour-pingviini/'>Pingviini</a> is a Twitter client for SailfishOS created by Duško Angirević and licensed under GNU GPL v3. All product names, logos, and brands are property of their respective owners."
            }

            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                linkColor: Theme.secondaryHighlightColor
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "This project is heavily based on <a style='text-decoration:none' href='https://github.com/jublonet/codebird-js'>Codebird JS</a> by Jublo Solutions. Thanks for making it available under the conditions of the GNU GPL v3."
            }

            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                linkColor: Theme.secondaryHighlightColor
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "We do not collect our user's data of but some data processing is done on remote servers (mostly for more complex things like Tweet threads displaying) and those data is sent beck to and from device."
            }


            ButtonLayout {
                preferredWidth: Theme.buttonWidthMedium
                   Button {
                    ButtonLayout.newLine: true
                    text: "Credits"
                    onClicked: pageStack.push(Qt.resolvedUrl("CreditsTranslations.qml"))
                }
            }
        }
    }
}

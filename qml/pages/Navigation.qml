import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic

Page {
    id: navigationPage
    property ListModel settings
    property string searchString
    property bool keepSearchFieldFocus
    property string activeView: "grid"

    Loader {
        anchors.fill: parent
        sourceComponent: activeView == "list" ? listViewComponent : gridViewComponent
    }



    Column {
        id: headerContainer

        width: navigationPage.width

        PageHeader {
            title: qsTr("Navigation")
        }

    }
    ListModel {
        id: listModel
        ListElement {
            icon: "image://theme/icon-m-home?"
            slug: "timeline"
            name: "Timeline"
        }
        ListElement {
            icon: "image://theme/icon-m-region?"
            slug: "mentions"
            name: "Mentions"
        }
        ListElement {
            icon: "image://theme/icon-m-message?"
            slug: "msgs"
            name: "Messagess"
        }
        ListElement {
            icon: "image://theme/icon-m-search?"
            slug: "search"
            name: "Search"
        }
    }

    Component {
        id: gridViewComponent
        SilicaGridView {
            id: gridView
            model: listModel
            anchors.fill: parent
            currentIndex: -1
            header: Item {
                id: header
                width: headerContainer.width
                height: headerContainer.height
                Component.onCompleted: headerContainer.parent = header
            }

            cellWidth: gridView.width / 2
            cellHeight: cellWidth

            PullDownMenu {
                MenuItem {
                    text: "Switch to list"
                    onClicked: {
                        keepSearchFieldFocus = searchField.activeFocus
                        activeView = "list"
                    }
                }
            }

            delegate: BackgroundItem {
                id: rectangle
                width: gridView.cellWidth
                height: gridView.cellHeight
                GridView.onAdd: AddAnimation {
                    target: rectangle
                }
                GridView.onRemove: RemoveAnimation {
                    target: rectangle
                }

                OpacityRampEffect {
                    sourceItem: label
                    offset: 0.5
                }

                Image {
                    source: model.icon + (highlighted
                                 ? Theme.highlightColor
                                 : Theme.primaryColor)
                    anchors.centerIn: parent
                }

                Label {
                    id: label
                    anchors {
                        bottom: parent.bottom
                    }
                    horizontalAlignment : Text.AlignHCente
                    width: parent.width
                    color: (highlighted ? Theme.highlightColor : Theme.secondaryHighlightColor)

                    text: {
                        return model.name.toUpperCase();
                    }

                    font {
                        pixelSize: Theme.fontSizeExtraSmall
                        family: Theme.fontFamilyHeading
                    }
                }
            }

            VerticalScrollDecorator {}


        }
    }


    onStatusChanged: {
        if (status === PageStatus.Active) {
           }
    }
}

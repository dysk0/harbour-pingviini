import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0






SilicaGridView {
    id: gridView
    property bool isPortrait: false
    ListModel {
        id: listModel
        ListElement {
            icon: "../home.svg" //""
            slug: "timeline"
            name: "Timeline"
            active: true
            unread: false
        }
        ListElement {
            icon: "image://theme/icon-m-alarm?" //""
            slug: "mentions"
            name: "Mentions"
            active: false
            unread: false
        }
        ListElement {
            icon: "../mesagess.svg"  //""
            slug: "msgs"
            name: "Messagess"
            active: false
        }
        ListElement {
            icon: "../search.svg" //""
            slug: "search"
            name: "Search"
            active: false
            unread: false
        }
    }
    model: listModel
    anchors.fill: parent
    currentIndex: -1

    cellWidth: isPortrait ? gridView.width : gridView.width / 4
    cellHeight: isPortrait ? gridView.height/4 : gridView.height


    delegate: BackgroundItem {
        clip: true
        id: rectangle
        width: gridView.cellWidth
        height: gridView.cellHeight
        GridView.onAdd: AddAnimation {
            target: rectangle
        }
        GridView.onRemove: RemoveAnimation {
            target: rectangle
        }
        GlassItem {
            id: effect
            visible: !isPortrait && unread
            width: Theme.itemSizeMedium
            height: Theme.itemSizeMedium
            dimmed: true
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height/2
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.highlightColor
        }

        GlassItem {
            id: effect2
            visible: isPortrait && unread
            width: Theme.itemSizeMedium
            height: Theme.itemSizeMedium
            dimmed: false
            anchors.right: parent.right;
            anchors.rightMargin: -height/2;
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.highlightColor
        }

        OpacityRampEffect {
            sourceItem: label
            offset: 0.5
        }

        /*Image {
            source: model.icon + (highlighted
                                  ? Theme.highlightColor
                                  : (model.active ? Theme.primaryColor : Theme.secondaryHighlightColor))
            anchors.centerIn: parent
        }*/
        Image {
            id: image
            source: model.icon + (highlighted
                                  ? Theme.highlightColor
                                  : (model.active ? Theme.primaryColor : Theme.secondaryHighlightColor))
            anchors.centerIn: parent
            smooth: true
            visible: false
        }
        ColorOverlay {
            anchors.fill: image
            source: image
            color: (highlighted
                    ? Theme.highlightColor
                    : (model.active ? Theme.primaryColor : Theme.secondaryHighlightColor))
        }
        Text {
            anchors.centerIn: parent
            visible: false
            text: model.icon
            color: (highlighted
                    ? Theme.highlightColor
                    : (model.active ? Theme.primaryColor : Theme.secondaryHighlightColor))
        }

        Label {
            id: label
            visible: false
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
        onClicked: {
            navigateTo(model.slug)
            effect.state = "right"
        }

    }
    function navigateTo(slug){
        for(var i = 0; i < listModel.count; i++){
            if (listModel.get(i).slug === slug)
                listModel.setProperty(i, 'active', true);
            else
                listModel.setProperty(i, 'active', false);
        }
        dmsgViewComponent.visible = false
        timelineViewComponent.visible = false
        mentionsViewComponent.visible = false
        searchViewComponent.visible = false
        if (slug === "msgs"){
            dmsgViewComponent.visible = true
        }
        if (slug === "timeline"){
            timelineViewComponent.visible = true
        }
        if (slug === "mentions"){
            mentionsViewComponent.visible = true
        }
        if (slug === "search"){
            searchViewComponent.visible = true
        }


        console.log(slug)

    }



    VerticalScrollDecorator {}
}

import QtQuick 2.0
import Sailfish.Silica 1.0






SilicaGridView {
    id: gridView
    property bool isPortrait: false
    ListModel {
        id: listModel
        ListElement {
            icon: "image://theme/icon-m-home?"
            slug: "timeline"
            name: "Timeline"
            active: true
        }
        ListElement {
            icon: "image://theme/icon-m-region?"
            slug: "mentions"
            name: "Mentions"
            active: false
        }
        ListElement {
            icon: "image://theme/icon-m-message?"
            slug: "msgs"
            name: "Messagess"
            active: false
        }
        ListElement {
            icon: "image://theme/icon-m-search?"
            slug: "search"
            name: "Search"
            active: false
        }
    }
    model: listModel
    anchors.fill: parent
    currentIndex: -1

    cellWidth: isPortrait ? gridView.width : gridView.width / 4
    cellHeight: isPortrait ? gridView.height/4 : gridView.height


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
        GlassItem {
            id: effect
            visible: false
            objectName: "menuitem"
            height: Theme.paddingSmall
            width: parent.width
            dimmed: true
            radius: 0.06
            falloffRadius: 0.19
            ratio: 0.0
            color: Theme.highlightColor
            cache: false
        }

        OpacityRampEffect {
            sourceItem: label
            offset: 0.5
        }

        Image {
            source: model.icon + (highlighted
                                  ? Theme.highlightColor
                                  : (model.active ? Theme.primaryColor : Theme.secondaryHighlightColor))
            anchors.centerIn: parent
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
        onClicked: navigateTo(model.slug)

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

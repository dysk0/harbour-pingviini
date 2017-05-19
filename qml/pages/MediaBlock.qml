import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "./cmp/"


Item {
    property ListModel model: []
    property int count: model.count
    property double wRatio : 16/9
    property double hRatio : 9/16
    id: holder
    width: width
    height: height
    Component.onCompleted: {
        switch(count){
        case 1:
            placeholder1.width = holder.width
            placeholder1.height = placeholder1.width*hRatio
            placeholder1.visible = true;
            holder.height = placeholder1.height
            break;
        case 2:
            placeholder1.visible = true;
            placeholder2.visible = true;
            placeholder1.width = (holder.width-Theme.paddingSmall)/2
            placeholder1.height = placeholder1.width
            placeholder2.width = placeholder1.width
            placeholder2.height = placeholder1.width
            placeholder2.x = placeholder1.width + placeholder2.x + Theme.paddingSmall
            holder.height = placeholder1.height
            break;
        case 3:
        case 4:
            placeholder1.visible = true;
            placeholder2.visible = true;
            placeholder3.visible = true;

            placeholder1.width = holder.width - Theme.paddingSmall - Theme.itemSizeLarge;
            placeholder1.height = Theme.itemSizeLarge*2+Theme.paddingSmall

            placeholder2.width = Theme.itemSizeLarge;
            placeholder2.height = placeholder2.width
            placeholder2.x = placeholder1.x + placeholder1.width + Theme.paddingSmall;



            placeholder3.width = placeholder2.width
            placeholder3.height = placeholder2.width
            placeholder3.x = placeholder2.x
            placeholder3.y = placeholder2.y + placeholder2.height + Theme.paddingSmall

            holder.height = placeholder1.height
            break;
        default:
            holder.height = 0
        }
    }

    MyImage {
        id: placeholder1
        width: 2
        height: 1
        opacity: pressed ? 0.6 : 1
        visible: {
            if (count > 0 && model.get(0).type === "photo"){
                mediaURL = model.get(0).src
                height = 200
                return true
            } else {
                height = 0
                return false
            }
        }
    }
    MyImage {
        id: placeholder2
        width: 2
        height: 1
        opacity: pressed ? 0.6 : 1
        visible: {
            if (count > 0 && model.get(1).type === "photo"){
                mediaURL = model.get(1).src
                height = 200
                return true
            } else {
                height = 0
                return false
            }
        }
    }
    MyImage {
        id: placeholder3
        width: 2
        height: 1
        opacity: pressed ? 0.6 : 1
        visible: {
            if (count > 0 && model.get(2).type === "photo"){
                mediaURL = model.get(2).src
                height = 200
                return true
            } else {
                height = 0
                return false
            }
        }
    }
    MyImage {
        id: placeholder4
        width: 2
        height: 1
        opacity: pressed ? 0.6 : 1
        visible: {
            if (count > 0 && model.get(3).type === "photo"){
                mediaURL = model.get(3).src
                height = 200
                return true
            } else {
                height = 0
                return false
            }
        }
    }
}





import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "../lib/codebird.js" as CB

import "./cmp/"

Page {
    property alias title: header.title
    property string action: ""
    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            if (messageObject.key === "help_privacy"){
                label.text = messageObject.reply.privacy.replaceAll("\n", "<br>")
            }
            if (messageObject.key === "help_tos"){
                label.text = messageObject.reply.tos.replaceAll("\n", "<br>")
            }
        }
    }

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
                id: header
            }
            Label {
                id: label
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                linkColor: Theme.secondaryHighlightColor
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }
        }
        Component.onCompleted: {
            var cmd = {
                'headlessAction': action,
                'conf'  : Logic.getConfTW()
            };
            if (action !== "")
                worker.sendMessage(cmd);
        }
    }
}

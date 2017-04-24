import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import QtGraphicalEffects 1.0


SilicaListView {
    id: timelineDM

    property int loadPage: 0
    anchors {
        fill: parent
        leftMargin: 0
        topMargin: 0
        rightMargin: page.isPortrait ? 0 : infoPanel.visibleSize
        bottomMargin: page.isPortrait ? infoPanel.visibleSize : 0
    }

    Component.onCompleted: {
        if (modelDM.count === 0){
            loadData("append")
        }
    }
    ViewPlaceholder {
        enabled: modelDM.count == 0
        text: "Loading tweets"
        hintText: "Please wait..."
    }

    ListModel {
        id: modelDM
    }

    function loadData(placement){

        var msg = {
            'action': 'directMessages',
            'model' : Logic.modelDMrecived,
            'viewModel' : modelDM,
            'page'  : loadPage,
            'mode'  : placement,
            'conf'  : Logic.getConfTW()
        };
        page ++;
        worker.sendMessage(msg);
        msg = {
            'action': 'directMessages_sent',
            'model' : Logic.modelDMsent,
            'mode'  : placement,
            'conf'  : Logic.getConfTW()
        };
        worker.sendMessage(msg);
    }

    header: PageHeader {
        title: qsTr("Messages")
        description: qsTr("Pingviini")
    }
    PullDownMenu {
        spacing: Theme.paddingLarge
        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                timelineDM.loadData("prepend")
            }
        }
    }
    PushUpMenu {
        spacing: Theme.paddingLarge
        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                timelineDM.loadData("append")
            }
        }
    }


    clip: isPortrait && (infoPanel.expanded)


    model: modelDM
    delegate: BackgroundItem {
        height: Theme.itemSizeLarge
        Image {
            id: avatar
            x: Theme.horizontalPageMargin
            anchors {
                verticalCenter: parent.verticalCenter
            }
            asynchronous: true
            width: Theme.iconSizeMedium
            height: width
            smooth: true
            source: profileImageUrl
            visible: false
        }
        Rectangle {
            id: avatarMask
            x: Theme.horizontalPageMargin
            y: Theme.paddingLarge
            width: Theme.iconSizeMedium
            height: width
            smooth: true
            color: Theme.primaryColor
            radius: Theme.iconSizeMedium
            anchors.centerIn: avatar
            visible: true
        }

        OpacityMask {
            id: maskedProfilePicture
            source: avatar
            maskSource: avatarMask
            anchors.fill: avatar
            visible: avatar.status === Image.Ready ? true : false
            opacity: avatar.status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation {} }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // pageStack.push( avatar );
                }
            }
        }
        Label {
            id: lblName
            anchors {
                top: avatar.top
                topMargin: -Theme.paddingSmall
                left: avatar.right
                leftMargin: Theme.paddingMedium
            }
            text: name
            font.weight: Font.Bold
            font.pixelSize: Theme.fontSizeSmall
            color: (pressed ? Theme.highlightColor : Theme.primaryColor)
        }

        Image {
            id: iconVerified
            y: Theme.paddingLarge
            anchors {
                left: lblName.right
                leftMargin: Theme.paddingSmall
                verticalCenter: lblName.verticalCenter
            }
            visible: isVerified
            width: isVerified ? Theme.iconSizeExtraSmall : 0
            height: width
            source: "image://theme/icon-s-installed?" + (pressed ? Theme.primaryColor : Theme.secondaryColor)
        }

        Label {
            id: lblScreenName
            anchors {
                left: iconVerified.right
                right: lblDate.left
                leftMargin: Theme.paddingMedium
                baseline: lblName.baseline
            }
            truncationMode: TruncationMode.Fade
            text: '@'+screenName
            font.pixelSize: Theme.fontSizeExtraSmall
            color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
        }
        Label {
            function timestamp() {
                var txt = Format.formatDate(createdAt, Formatter.Timepoint)
                var elapsed = Format.formatDate(createdAt, Formatter.DurationElapsedShort)
                return (elapsed ? elapsed  : txt )
            }
            id: lblDate
            color: (pressed ? Theme.highlightColor : Theme.primaryColor)
            text: Format.formatDate(createdAt, new Date() - createdAt < 60*60*1000 ? Formatter.DurationElapsedShort : Formatter.TimeValueTwentyFourHours)
            font.pixelSize: Theme.fontSizeExtraSmall
            horizontalAlignment: Text.AlignRight
            anchors {
                right: parent.right
                baseline: lblName.baseline
                rightMargin: Theme.paddingLarge
            }
        }

        Label {
            id: lblText
            width: parent.width
            anchors {
                left: lblName.left
                right: parent.right
                top: lblScreenName.bottom
                topMargin: Theme.paddingSmall
                rightMargin: Theme.paddingLarge
            }
            text: richText
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeSmall
            color: (pressed ? Theme.highlightColor : Theme.primaryColor)
        }
        onClicked: {
            var name, username, profileImage;
            /*sent.concat(rec).forEach(function(el){
                if (el.sender_screen_name == "BerislavB" || el.recipient_screen_name == "BerislavB" )
                console.log(el)
            });*/
            var tweets = [];
            for (var i = 0; i < Logic.modelDMrecived.count; i++){
                var item = Logic.modelDMrecived.get(i)
                if (item.screenName === screenName) {
                    username = item.screenName;
                    name = item.name;
                    profileImage = item.profileImageUrl;
                    tweets.push(item)
                }
            }

            for (i = 0; i < Logic.modelDMsent.count; i++){
                item = Logic.modelDMsent.get(i)
                if (item.screenName === screenName) {
                    tweets.push(item)
                }
            }

            console.log(JSON.stringify(tweets))
            tweets.sort(function(a, b){return a.id-b.id});
            console.log(JSON.stringify(tweets))

            var _tweets = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
            tweets.forEach(function(el){
                _tweets.append(el)
            });

            pageStack.push(Qt.resolvedUrl("Conversation.qml"), {
                               "tweets": _tweets,
                               "name": name,
                               "username" : username,
                               "profileImage": profileImage
                           })


        }
    }

    VerticalScrollDecorator {}

    onMovementEnded: {
        scrollOffsetDM = contentY
        currentIndexDM = currentIndex
    }
    onContentYChanged: {
        //console.log(".....contentY: " + contentY)

        if(contentY+200 > timelineDM.contentHeight-timelineDM.height&& !loadStarted){
            loadStarted = true;
        }
        //console.log((contentY+200) + ' ' + listView.contentHeight)
        if (contentY > scrollOffsetDM) {
            infoPanel.open = false
        } else {
            if (contentY < 100 && !loadStarted){
                //timelineDM.loadData("prepend")
                //loadStarted = true;
            }
            infoPanel.open = true
        }
    }
}

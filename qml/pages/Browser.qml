/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

Page {
    id: webViewPage
    property string href;
    property bool screenReaderMode: true
    property string articleContent: ""
    property string articleTitle: ""
    property string articleDate: ""
    property string articleImage: ""
    allowedOrientations: Orientation.All
    function fetchData(){
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://mercury.postlight.com/parser?url="+href, true);
        xhr.onreadystatechange = function() {
            if ( xhr.readyState === xhr.DONE ) {
                if ( xhr.status === 200 ) {
                    console.log(xhr.responseText)
                    loading.running = false;
                    var response = JSON.parse(xhr.responseText);
                    if (response.date_published)
                        //articleDate = new Date(response.date_published.replace(/^(\w+) (\w+) (\d+) ([\d:]+) \+0000 (\d+)$/,"$1, $2 $3 $5 $4 GMT"));
                    if (response.title)
                        articleTitle = response.title;
                    if (response.lead_image_url)
                        articleImage = response.lead_image_url
                    if (response.content)
                        articleContent = response.content;
                    if (response.content && response.lead_image_url)
                        articleContent = articleContent.replace(articleImage, "")
                }  else {

                }
                loading.running = false;
            }
        }
        xhr.setRequestHeader("Content-Type", 'application/json');
        xhr.setRequestHeader("x-api-key", 'uakC11NlSubREs1r5NjkOCS1NJEkwti6DnDutcYC');
        xhr.send();
    }

    onStatusChanged: {

        if (status === PageStatus.Active && screenReaderMode) {
            fetchData();
        }

    }

    BusyIndicator {
        id: loading
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: true
    }

    SilicaFlickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: screenReaderMode ? article.height : parent.height
        VerticalScrollDecorator {}
        PullDownMenu {
            spacing: Theme.paddingLarge
            MenuItem {
                text: screenReaderMode ? qsTr("Web mode") : qsTr("Reading mode")
                onClicked: {
                    screenReaderMode = !screenReaderMode
                    loading.running = true
                }
            }
        }
        Column {
            visible: screenReaderMode
            id: article
            width: parent.width

            Label {
                id: title
                text: articleTitle
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                font.bold: true
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: Theme.paddingLarge
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
            }
            Label {
                id: date
                visible: articleDate !== ""
                text: articleDate
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: Theme.paddingSmall
                    bottomMargin: Theme.paddingSmall
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
            }
            Label {
                text: " "
                visible: image.visible
            }
            Image {
                id: image
                visible: articleImage !== "" ? true : false
                source: articleImage
                width: parent.width
                height: Theme.itemSizeExtraLarge
                fillMode: Image.PreserveAspectCrop
                anchors {
                    left: parent.left
                    right: parent.right
                }
                BusyIndicator {
                    size: BusyIndicatorSize.Small
                    anchors.centerIn: parent
                    running: parent.status != Image.Ready
                }

                onStatusChanged: if (image.status === Image.Ready) {
                                     var ratio = image.sourceSize.width/image.sourceSize.height
                                     height = width / ratio
                                 }
            }
            Label {
                text: " "
                visible: image.visible
            }



            Label {
                id: content
                readonly property string _linkStyle: "<style>a:link { color: " + Theme.primaryColor + "; } h1, h2, h3, h4 { color: " + Theme.highlightColor + "; } img { margin: "+Theme.paddingLarge+" 0; width: 100%}</style>"
                textFormat: Text.RichText
                text: _linkStyle + articleContent;
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: image.visible ? Theme.paddingSmall : Theme.paddingLarge
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                    bottomMargin: Theme.paddingLarge
                }

            }

        }


        SilicaWebView {
            enabled: !screenReaderMode
            visible: !screenReaderMode
            id: webView
            url: 'https://mercury.postlight.com/amp?url='+href
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }



            opacity: 0
            onLoadingChanged: {
                switch (loadRequest.status)
                {
                case WebView.LoadSucceededStatus:
                    opacity = 1
                    loading.running = false
                    break
                case WebView.LoadFailedStatus:
                    opacity = 0
                    loading.running = false
                    viewPlaceHolder.errorString = loadRequest.errorString
                    break
                default:
                    opacity = 0
                    break
                }
            }

            FadeAnimation on opacity {}
        }

        /* ViewPlaceholder {
            id: viewPlaceHolder
            property string errorString

            enabled: webView.opacity === 0 && !webView.loading
            text: errorString
            hintText: "Check network connectivity and pull down to reload"
        }*/



    }
}

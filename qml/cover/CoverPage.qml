/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../pages/cmp/"
import "../lib/Logic.js" as Logic


CoverBackground {
    property int updateWindow: 0
    onStatusChanged: {
        switch (status ){
        case PageStatus.Activating:
            console.log("PageStatus.Activating")
            break;
        case PageStatus.Inactive:
            console.log("PageStatus.Inactive")
            break;
        }
        var timestamp = Math.floor(new Date().getTime()/1000);
        if (updateWindow < timestamp - 60){
            console.log("DO update!")
            updateWindow  = timestamp;
            worker.sendMessage({
                                   'bgUpdate': true,
                                   'modelTL' : Logic.modelTL,
                                   'modelME' : Logic.modelME,
                                   'modelRawDM' : Logic.modelRawDM,
                                   'modelDM' : Logic.modelDM,
                                   'conf'  : Logic.getConfTW()
                               });
        } else {
            console.log("Skip update!")
            label.text = timestamp - updateWindow
        }
    }
    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            if(messageObject.directMessagesRaw){
                //console.log(JSON.stringify(messageObject.reply))
                Logic.parseDM.setUserId(Logic.getConfTW().USER_ID)
                Logic.parseDM.append(messageObject.reply)
            }
        }
    }
    Label {
        id: label
        anchors.centerIn: parent
        text: "status"
    }
    SilicaGridView {
        id: grid
        anchors.fill: parent
        header: PageHeader {
            title: Logic.modelUsers.count + " Users"
        }
        model: Logic.modelUsers
        cellWidth: width / 4
        cellHeight: cellWidth

        delegate: BackgroundItem {
            width: grid.cellWidth
            height: grid.cellWidth
            Image {
                id: avatarImg
                anchors.fill: parent
                source: model.avatar
            }

        }
    }
    /*PingviiniiLogo {
        id: logo
        anchors {
            centerIn: parent
        }
        width: parent.width
        height: parent.width
        opacity: 1;
        anchors.fill: parent
        Behavior on opacity { NumberAnimation {} }
    }*/




    /*CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
        }
    }*/
}


/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

.pragma library
.import QtQuick.LocalStorage 2.0 as LS
Qt.include("common.js")
var THEME_LINK_COLOR;


function setThemeLinkColor(color){
    THEME_LINK_COLOR = color
}

var OAUTH_CONSUMER_KEY = "BsVdhEDHrLgE8SUfAUEoVdnwD"
var OAUTH_CONSUMER_SECRET = "UtGso4Buc2bX3FlBmYrwamKIuPRfwBfptO0we935jyRF90RboK"
var OAUTH_TOKEN
var OAUTH_TOKEN_SECRET
var USER_AGENT = "Pingviini Client"
var SCREEN_NAME

function getConfTW(){
    return {
        OAUTH_CONSUMER_KEY: OAUTH_CONSUMER_KEY,
        OAUTH_CONSUMER_SECRET: OAUTH_CONSUMER_SECRET,
        OAUTH_TOKEN: OAUTH_TOKEN,
        OAUTH_TOKEN_SECRET: OAUTH_TOKEN_SECRET,
        USER_AGENT: USER_AGENT,
        SCREEN_NAME: SCREEN_NAME,
        THEME_LINK_COLOR: THEME_LINK_COLOR
    }
}



var modelTL = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var modelMN = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var modelSE = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var modelDM = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var modelRawDM= Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var mediator = (function(){
    var subscribe = function(channel, fn){
        if(!mediator.channels[channel]) mediator.channels[channel] = [];
        mediator.channels[channel].push({ context : this, callback : fn });
        return this;
    };
    var publish = function(channel){
        if(!mediator.channels[channel]) return false;
        var args = Array.prototype.slice.call(arguments, 1);
        for(var i = 0, l = mediator.channels[channel].length; i < l; i++){
            var subscription = mediator.channels[channel][i];
            subscription.callback.apply(subscription.context.args);
        };
        return this;
    };
    return {
        channels : {},
        publish : publish,
        subscribe : subscribe,
        installTo : function(obj){
            obj.subscribe = subscribe;
            obj.publish = publish;
        }
    };
}());

var db = LS.LocalStorage.openDatabaseSync("pingviinia", "", "pingviini", 100000);
var conf = {}



function initialize() {
    console.log("db.version: "+db.version);
    if(db.version === '') {
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings ('
                          + ' key TEXT UNIQUE, '
                          + ' value TEXT '
                          +');');
            tx.executeSql('INSERT INTO settings (key, value) VALUES (?, ?)', ["conf", "{}"]);
        });
        db.changeVersion('', '0.1', function(tx) {

        });
    }

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM settings;');
        for (var i = 0; i < rs.rows.length; i++) {
            //var json = JSON.parse(rs.rows.item(i).value);
            console.log("READED "+rs.rows.item(i).key+" in DB: "+rs.rows.item(i).value)
            //if ( rs.rows.item(i).key === "favourite" && rs.rows.item(i).value !== null)
            //    favouriteItems = JSON.parse(rs.rows.item(i).value);
            if ( rs.rows.item(i).key === "conf" && rs.rows.item(i).value !== null){
                conf= JSON.parse(rs.rows.item(i).value);
                if (conf.OAUTH_TOKEN)
                    OAUTH_TOKEN = conf.OAUTH_TOKEN;
                if (conf.OAUTH_TOKEN_SECRET)
                    OAUTH_TOKEN_SECRET = conf.OAUTH_TOKEN_SECRET;
                if (conf.SCREEN_NAME)
                    SCREEN_NAME = conf.SCREEN_NAME;

            }
        }
        mediator.publish('confLoaded', { loaded: true});
    });
}

function saveData() {
    db.transaction(function(tx) {
        if (conf.OAUTH_TOKEN){
            var rs2 = tx.executeSql('UPDATE settings SET value = ? WHERE key = ?', [JSON.stringify(conf), "conf"]);
            console.log("Saving... "+JSON.stringify(conf)+"\n"+JSON.stringify(rs2))
        }
    });
}



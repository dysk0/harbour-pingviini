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
        SCREEN_NAME: SCREEN_NAME
    }
}

JSON.flatten = function(data) {
    var result = {};
    function recurse (cur, prop) {
        if (Object(cur) !== cur) {
            result[prop] = cur;
        } else if (Array.isArray(cur)) {
             for(var i=0, l=cur.length; i<l; i++)
                 recurse(cur[i], prop + "[" + i + "]");
            if (l == 0)
                result[prop] = [];
        } else {
            var isEmpty = true;
            for (var p in cur) {
                isEmpty = false;
                recurse(cur[p], prop ? prop+"."+p : p);
            }
            if (isEmpty && prop)
                result[prop] = {};
        }
    }
    recurse(data, "");
    return result;
}
var modelDM = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var modelTL = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var modelMN = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
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

var db = LS.LocalStorage.openDatabaseSync("pingviini", "", "pingviini", 100000);
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
        var rs2 = tx.executeSql('UPDATE settings SET value = ? WHERE key = ?', [JSON.stringify(conf), "conf"]);
        console.log("Saving... "+JSON.stringify(conf)+"\n"+JSON.stringify(rs2))
    });
}


function timeDiff(tweetTimeStr) {
    var tweetTime = new Date(tweetTimeStr)
    var diff = new Date().getTime() - tweetTime.getTime() // milliseconds

    if (diff <= 0) return qsTr("Now")

    diff = Math.round(diff / 1000) // seconds

    if (diff < 60) return qsTr("Just now")

    diff = Math.round(diff / 60) // minutes

    if (diff < 60) return qsTr("%n min(s)", "", diff)

    diff = Math.round(diff / 60) // hours

    if (diff < 24) return qsTr("%n hr(s)", "", diff)

    diff = Math.round(diff / 24) // days

    if (diff === 1) return qsTr("Yesterday %1").arg(Qt.formatTime(tweetTime, "h:mm AP").toString())
    if (diff < 7 ) return Qt.formatDate(tweetTime, "ddd d MMM").toString()

    return Qt.formatDate(tweetTime, Qt.SystemLocaleShortDate).toString()
}


function parseTweet(tweetJson) {
    var tweet = {
        id: tweetJson.id_str,
        source: tweetJson.source.replace(/<[^>]+>/ig, ""),
        createdAt: new Date(tweetJson.created_at),
        isFavourited: tweetJson.favorited,
        isRetweet: false,
        retweetScreenName: tweetJson.user.screen_name,
        timeDiff: timeDiff(tweetJson.created_at)
    }

    var originalTweetJson = {};
    if (tweetJson.retweeted_status) {
        originalTweetJson = tweetJson.retweeted_status;
        tweet.isRetweet = true;
    }
    else originalTweetJson = tweetJson;

    tweet.plainText = __unescapeHtml(originalTweetJson.text);
    tweet.richText = __toRichText(originalTweetJson.text, originalTweetJson.entities);
    tweet.name = originalTweetJson.user.name;
    tweet.screenName = originalTweetJson.user.screen_name;
    tweet.profileImageUrl = originalTweetJson.user.profile_image_url;
    tweet.inReplyToScreenName = originalTweetJson.in_reply_to_screen_name;
    tweet.inReplyToStatusId = originalTweetJson.in_reply_to_status_id_str;
    tweet.latitude = "";
    tweet.longitude = "";
    tweet.mediaUrl = "";

    if (originalTweetJson.geo) {
        tweet.latitude = originalTweetJson.geo.coordinates[0];
        tweet.longitude = originalTweetJson.geo.coordinates[1];
    }

    if (Array.isArray(originalTweetJson.entities.media) && originalTweetJson.entities.media.length > 0) {
        tweet.mediaUrl = originalTweetJson.entities.media[0].media_url;
    }

    return tweet;
}

Qt.include("Twitter.js")

function showError(status, statusText) {
    console.log(status)
    console.log(statusText)
}
var __HTML_ENTITIES = {
    "&amp;": "&",
    "&lt;": "<",
    "&gt;": ">"
}

function __unescapeHtml(text) {
    return text && text.replace(/(&amp;|&lt;|&gt;)/ig, function(html) {
        return __HTML_ENTITIES[html]
    })
}

function __toHighlights(text, entities) {
    var highlightText = []
    entities.urls.forEach(function(urlObject) {
        highlightText.push('('+urlObject.url+')')
    })
    entities.hashtags.forEach(function(hashtagObject) {
        highlightText.push('(#'+hashtagObject.text+')')
    })

    entities.user_mentions.forEach(function(mentionsObject) {
        highlightText.push('(@'+mentionsObject.screen_name + ')')
    })
    return highlightText.join("|");
}

function __toRichText(text, entities) {
    if (!entities) return;

    var richText = text;
    //richText = __linkHashtags(richText, entities.hashtags);

    entities.urls.forEach(function(urlObject) {
        console.log(urlObject.url)
        richText = richText.replace(urlObject.url, linkText(urlObject.display_url, urlObject.expanded_url, true));
    })

    /*if (entities.hasOwnProperty("media")) {
        entities.media.forEach(function(mediaObject) {
            richText = richText.replace(mediaObject.url,
                                        linkText(mediaObject.display_url, mediaObject.expanded_url, true));
        })
    }
    */
    richText = __linkUserMentions(richText, entities.user_mentions);
    //richText = __linkCashtag(richText);
    return richText;
}

function __linkUserMentions(text, userMentionsEntities) {
    if (!Array.isArray(userMentionsEntities) || userMentionsEntities.length === 0)
        return text;

    var mentionsArray = [];

    userMentionsEntities.forEach(function(mentionObject) {
        mentionsArray.push(mentionObject.screen_name);
    })

    var mentionsRegExp = new RegExp("@\\b(" + mentionsArray.join("|") + ")\\b", "ig");
    var linkedText = text.replace(mentionsRegExp, function(t) { return linkText(t, t, false) })
    return linkedText;
}

function __linkHashtags(text, hashtagsEntities) {
    if (!Array.isArray(hashtagsEntities) || hashtagsEntities.length === 0)
        return text;

    // TODO: better algorithm?
    var hashtagsArray = hashtagsEntities;
    hashtagsArray.sort(function(a, b) { return a.indices[0] - b.indices[0] });

    var linkedText = text;
    var offset = 0;
    hashtagsArray.forEach(function(hashtag) {
        var linkedHashtag = linkText("#" + hashtag.text, "#" + hashtag.text, false);
        linkedText = linkedText.substring(0, hashtag.indices[0] + offset) +
                linkedHashtag + linkedText.substring(hashtag.indices[1] + offset);
        offset = (offset - (hashtag.indices[1] - hashtag.indices[0])) + linkedHashtag.length;
    })

    return linkedText;
}

// Following RegExp took and modified from:
// https://github.com/twitter/twitter-text-js/blob/b93ae29/twitter-text.js#L279
var CASHTAG_REGEXP = /(?:^|\s)(\$[a-z]{1,6}(?:[._][a-z]{1,2})?)(?=$|[\s\!'#%&"\(\)*\+,\\\-\.\/:;<=>\?@\[\]\^_{|}~\$])/gi;
function linkText(text, href, italic) {
    var html = "";
    if (italic) html = "<i><a style=\"color: LightSeaGreen; text-decoration: none\" href=\"%1\">%2</a></i>";
    else html = "<a style=\"color: LightSeaGreen; text-decoration: none\" href=\"%1\">%2</a>";

    return html.arg(href).arg(text);
}
function __linkCashtag(text) {
    return text.replace(CASHTAG_REGEXP, function(matched) {
        var text = matched;
        var firstChar = text.charAt(0);
        if (/\s/.test(firstChar)) {
            text = text.substring(1);
            return firstChar + linkText(text, text, false);
        }
        return linkText(text, text, false);
    })
}
function parseISO8601(str) {
    try {
        // we assume str is a UTC date ending in 'Z'
        var _date = new Date();
        var parts = str.split(' '),
                timeParts = parts[3].split(":"),
                monthPart = parts[1].replace("Jan", "1").replace("Feb", "2").replace("Mar", "3").replace("Apr", "4").replace("May", "5").replace("Jun", "6").replace("Jul", "7").replace("Aug", "8").replace("Sep", "9").replace("Oct", "10").replace("Nov", "11").replace("Dec", "12");
        //console.log(JSON.stringify([parts, timeParts]))

        _date.setUTCFullYear(Number(parts[5]));
        _date.setUTCMonth(Number(monthPart)-1);
        _date.setUTCDate(Number(parts[2]));
        _date.setUTCHours(Number(timeParts[0]));
        _date.setUTCMinutes(Number(timeParts[1]));
        _date.setUTCSeconds(Number(timeParts[2]));

        return _date;
    }
    catch (error) {
        return null;
    }
}
function parseTweet(tweetJson) {
    var tweet = {
        id: tweetJson.id_str,
        source: tweetJson.source.replace(/<[^>]+>/ig, ""),
        createdAt: parseISO8601(tweetJson.created_at),
        isFavourited: tweetJson.favorited,
        favoriteCount: tweetJson.favorite_count,
        isRetweet: tweetJson.retweeted,
        retweetCount: tweetJson.retweet_count,
        highlights: "",
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
    tweet.highlights = __toHighlights(originalTweetJson.text, originalTweetJson.entities);

    tweet.name = originalTweetJson.user.name;
    tweet.screenName = originalTweetJson.user.screen_name;
    tweet.profileImageUrl = originalTweetJson.user.profile_image_url;
    tweet.inReplyToScreenName = originalTweetJson.in_reply_to_screen_name;
    tweet.inReplyToStatusId = originalTweetJson.in_reply_to_status_id_str;
    tweet.latitude = "";
    tweet.longitude = "";
    tweet.mediaUrl = "";

    if (tweetJson.entities && tweetJson.entities.media){
         tweet.mediaUrl = tweetJson.entities.media[0].media_url_https
        tweet.plainText = tweet.plainText.replace(tweetJson.entities.media[0].url, "")
    }

    console.log(" ---------------------- "); console.log(JSON.stringify(tweetJson)); console.log(" ---------------------- "); console.log(JSON.stringify(tweet))
    return tweet;
}

function parseDM(dmJson, isReceiveDM) {
    var dm = {
        id: dmJson.id_str,
        richText: __toRichText(dmJson.text, dmJson.entities),
        name: (isReceiveDM ? dmJson.sender.name : dmJson.recipient.name),
        highlights: __toHighlights(dmJson.text, dmJson.entities),
        screenName: (isReceiveDM ? dmJson.sender_screen_name : dmJson.recipient_screen_name),
        profileImageUrl: (isReceiveDM ? dmJson.sender.profile_image_url : dmJson.recipient.profile_image_url),
        createdAt: dmJson.created_at,
        isReceiveDM: isReceiveDM
    }
    return dm;
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

WorkerScript.onMessage = function(msg) {
    if (msg.conf.OAUTH_CONSUMER_KEY)
        OAUTH_CONSUMER_KEY = msg.conf.OAUTH_CONSUMER_KEY;

    if (msg.conf.OAUTH_CONSUMER_SECRET)
        OAUTH_CONSUMER_SECRET = msg.conf.OAUTH_CONSUMER_SECRET;

    if (msg.conf.OAUTH_TOKEN)
        OAUTH_TOKEN = msg.conf.OAUTH_TOKEN;

    if (msg.conf.OAUTH_TOKEN_SECRET)
        OAUTH_TOKEN_SECRET = msg.conf.OAUTH_TOKEN_SECRET;

    if (msg.conf.USER_AGENT)
        USER_AGENT = msg.conf.USER_AGENT;

    if (msg.conf.SCREEN_NAME)
        SCREEN_NAME = msg.conf.SCREEN_NAME;

    var sinceId;
    var maxId;

    if (msg.action === 'getHomeTimeline') {
        console.log('getHomeTimeline '+JSON.stringify(msg))
        sinceId = false;
        maxId = false;
        if (msg.model.count) {
            if (msg.mode === "append") {
                maxId = msg.model.get(msg.model.count-1).id
            }
            if (msg.mode === "prepend") {
                sinceId = msg.model.get(0).id
            }
        }

        getHomeTimeline(sinceId, maxId, function(data) {
            //msg.model.clear();
            for (var i=0; i < data.length; i++) {
                var tweet = parseTweet(data[i]); //.created_at = parseISO8601(data[i].created_at) //Date.fromLocaleString(locale, data[i].created_at, "ddd MMM dd HH:mm:ss +0000 yyyy")
                if (msg.model.count) {
                    if (msg.mode === "append" && i > 0) {
                        console.log('append')

                        msg.model.append(tweet)
                    }
                    if (msg.mode === "prepend") {
                        console.log('prepend')
                        msg.model.insert(0, tweet)
                    }
                } else {
                    msg.model.append(tweet)
                }
            }
            msg.model.sync();
        }, showError)
    }

    if (msg.action === 'getMentionsTimeline') {
        console.log('getMentionsTimeline '+JSON.stringify(msg))
        sinceId = false;
        maxId = false;
        if (msg.model.count) {
            if (msg.mode === "append") {
                maxId = msg.model.get(msg.model.count-1).id
            }
            if (msg.mode === "prepend") {
                sinceId = msg.model.get(0).id
            }
        }

        getMentions(sinceId, maxId, function(data) {
            //msg.model.clear();
            for (var i=0; i < data.length; i++) {
                var tweet = parseTweet(data[i]);
                if (msg.model.count) {
                    if (msg.mode === "append" && i > 0) {
                        console.log('append')

                        msg.model.append(tweet)
                    }
                    if (msg.mode === "prepend") {
                        console.log('prepend')
                        msg.model.insert(0, tweet)
                    }
                } else {
                    msg.model.append(tweet)
                }
            }
            msg.model.sync();
        }, showError)
    }

    if (msg.action === 'getDirectMsg') {
        console.log('getDirectMsg '+JSON.stringify(msg))
        sinceId = false;
        maxId = false;
        if (msg.model.count) {
            if (msg.mode === "append") {
                maxId = msg.model.get(msg.model.count-1).id
            }
            if (msg.mode === "prepend") {
                sinceId = msg.model.get(0).id
            }
        }

        getDirectMsg(sinceId, maxId, function(data) {
            //msg.model.clear();
            for (var i=0; i < data.length; i++) {
                console.log(JSON.stringify(data[i]))
                var tweet = parseDM(data[i], true);
                if (msg.model.count) {
                    if (msg.mode === "append" && i > 0) {
                        console.log('append')
                        msg.model.append(tweet)
                    }
                    if (msg.mode === "prepend") {
                        console.log('prepend')
                        msg.model.insert(0, tweet)
                    }
                } else {
                    msg.model.append(tweet)
                }
            }
            msg.model.sync();
        }, showError)
    }
}
//WorkerScript.sendMessage({ 'reply': 'Mouse is at ' + message.x + ',' + message.y })


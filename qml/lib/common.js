String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};
var __HTML_ENTITIES = {
    "&amp;": "&",
    "&lt;": "<",
    "&gt;": ">"
}
function getValidDate(twitterDate) {
    return new Date(twitterDate.replace(/^(\w+) (\w+) (\d+) ([\d:]+) \+0000 (\d+)$/,"$1, $2 $3 $5 $4 GMT"));
}
function getDate(ts){
    return new Date(ts.getFullYear(), ts.getMonth(), ts.getDate(), 0, 0, 0)
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
    richText = __linkHashtags(richText, entities.hashtags);

    entities.urls.forEach(function(urlObject) {

        richText = richText.replace(urlObject.url, linkText(urlObject.display_url, urlObject.expanded_url, true));
    })

    if (entities.hasOwnProperty("media")) {
        entities.media.forEach(function(mediaObject) {
            richText = richText.replace(mediaObject.url,"");
        })
    }

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
    if (italic) html = "<a style=\"text-decoration: none\" href=\"%1\">%2</a>";
    else html = "<a style=\"text-decoration: none\" href=\"%1\">%2</a>";
    html = html.arg(href).arg(text)
    //console.log(html )
    return html ;
}
function __linkCashtag(text) {
    return text.replace(CASHTAG_REGEXP, function(matched) {
        var text = matched;
        var firstChar = text.charAt(0);
        if (/\s/.test(firstChar)) {
            text = text.substring(1);
            return firstChar + linkText(text, text, true);
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

function parseEntities(text, entities){
    if (entities.user_mentions){
        entities.user_mentions.forEach(function(item) {
            //console.info(JSON.stringify(item))
            text = text.replace(new RegExp( '@'+item.screen_name, "gi" ), '<a href="@'+item.screen_name+'">@'+item.screen_name+'</a>');
        });
    }
    if (entities.hashtags){
        entities.hashtags.forEach(function(item) {
            //console.info(JSON.stringify(item))
            text = text.replace('#'+item.text, '<a href="#'+item.text+'">#'+item.text+'</a>');
        });
    }
    if (entities.urls){
        entities.urls.forEach(function(item) {
            //console.info(JSON.stringify(item))
            text = text.replaceAll(item.url, '<a href="'+item.url+'">'+item.display_url+"</a>")
        });
    }
    return text;
}
function getUserFromModel(id) {
    for(var i = 0; i< modelUsers.count; i++){
        if (modelUsers.get(i).id === id){
            return modelUsers.get(i);
        }
    }
    return {
        name: "Not found",
        id: "0000000",
        screen_name:  "Not found",
        avatar: ""
    };
}
function addUsersToModel(modelUsers, data) {
    if (!modelUsers)
        return;
    console.log(JSON.stringify(data))
    var exists = false;
    for(var i = 0; i< modelUsers.count; i++){
        if (modelUsers.get(i).id === data.id){
            exists = true;
            break;
        }
    }
    if (!exists){
        modelUsers.append(data)
    }
}

function parseTweet(tweetJson, modelUsers) {


    var tweet = {
        id: tweetJson.id,
        id_str: tweetJson.id_str,
        source: tweetJson.source.replace(/<[^>]+>/ig, ""),
        createdAt: getValidDate(tweetJson.created_at),
        isVerified: false,
        favorited: tweetJson.favorited,
        favoriteCount: tweetJson.favorite_count,
        retweeted: tweetJson.retweeted,
        retweetCount: tweetJson.retweet_count,
        isRetweet: false,
        highlights: "",
        retweetScreenName: tweetJson.user.screen_name
    }
    tweet.section = getDate(tweet.createdAt)

    var originalTweetJson = {};
    if (tweetJson.retweeted_status) {
        tweet.isRetweet = true;
        originalTweetJson = tweetJson.retweeted_status;
    } else {
        originalTweetJson = tweetJson;
    }


    tweet.isVerified = originalTweetJson.user.verified;
    tweet.name = originalTweetJson.user.name;
    tweet.userId = originalTweetJson.user.id;
    tweet.userIdStr = originalTweetJson.user.id_str;
    tweet.screenName = originalTweetJson.user.screen_name;
    tweet.profileImageUrl = originalTweetJson.user.profile_image_url;
    tweet.inReplyToScreenName = originalTweetJson.in_reply_to_screen_name;
    tweet.inReplyToStatusId = originalTweetJson.in_reply_to_status_id;
    tweet.inReplyToStatusIdStr = originalTweetJson.in_reply_to_status_id_str;
    tweet.latitude = "";
    tweet.longitude = "";
    tweet.is_quote_status = originalTweetJson.is_quote_status ? true : false;
    if (tweet.is_quote_status) {
        tweet.quote_status_id = originalTweetJson.quoted_status_id
    }


    var text = originalTweetJson.full_text ? originalTweetJson.full_text : originalTweetJson.text

    tweet.media = [];

    if (originalTweetJson.entities){
        text = parseEntities(text, originalTweetJson.entities);
        if (originalTweetJson.extended_entities && originalTweetJson.extended_entities.media){
            originalTweetJson.extended_entities.media.forEach(function(item) {
                var media;
                if (item.type ==="photo"){
                    media = {
                        id:         item.id,
                        id_str:     item.id_str,
                        type:       item.type,
                        cover:      item.media_url_https+":small",
                        media:      item.media_url_https+":large"
                    }
                    //console.info(JSON.stringify(item))
                } else {
                    media = {
                        id:         item.id,
                        id_str:     item.id_str,
                        type:       item.type,
                        cover:      item.media_url_https+":medium",
                        media:      item.video_info.variants.length ? item.video_info.variants[item.video_info.variants.length-1].url : false
                    }
                }
                tweet.media.push(media)
                text = text.replaceAll(item.url, '')
            });
        }
    }

    tweet.richText = text;

    //if(tweet.screenName === "dysko"){
    //console.log(JSON.stringify(originalTweetJson))
    //console.log(JSON.stringify(tweet))
    //}

    return tweet;
}

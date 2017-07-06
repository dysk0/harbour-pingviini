
var __HTML_ENTITIES = {
    "&amp;": "&",
    "&lt;": "<",
    "&gt;": ">"
}
function getValidDate(twitterDate) {
    return new Date(twitterDate.replace(/^(\w+) (\w+) (\d+) ([\d:]+) \+0000 (\d+)$/,"$1, $2 $3 $5 $4 GMT"));
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
    if (italic) html = "<a style=\"color: "+highlightColor+"; text-decoration: none\" href=\"%1\">%2</a>";
    else html = "<a style=\"color: "+highlightColor+"; text-decoration: none\" href=\"%1\">%2</a>";
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

function parseDM(dmJson, isReceiveDM) {
    //console.log(JSON.stringify(dmJson))
    var dm = {
        id: dmJson.id,
        richText: dmJson.message_create.message_data.text,
        sender_id: dmJson.message_create.sender_id,
        recipient_id: dmJson.message_create.target.recipient_id,
        name: dmJson.message_create.sender_id,
        //screenName: name,
        //profileImageUrl: (isReceiveDM ? dmJson.sender.profile_image_url_https : dmJson.sender.profile_image_url_https),
        createdAt: dmJson.created_timestamp
    }
    //dm.section = dm.createdAt.toLocaleDateString()
    return dm;
}

function parseTweet(tweetJson) {
    var tweet = {
        id: tweetJson.id,
        id_str: tweetJson.id_str,
        source: tweetJson.source.replace(/<[^>]+>/ig, ""),
        createdAt: getValidDate(tweetJson.created_at),
        isVerified: false,
        isFavourited: tweetJson.favorited,
        favoriteCount: tweetJson.favorite_count,
        isRetweet: tweetJson.retweeted,
        retweetCount: tweetJson.retweet_count,
        highlights: "",
        retweetScreenName: tweetJson.user.screen_name
    }
    tweet.section = tweet.createdAt.toLocaleDateString()
    var originalTweetJson = {};
    if (tweetJson.retweeted_status) {
        originalTweetJson = tweetJson.retweeted_status;
        tweet.isRetweet = true;
    }
    else originalTweetJson = tweetJson;
    tweet.plainText = __unescapeHtml(originalTweetJson.full_text);
    tweet.richText = __toRichText(originalTweetJson.full_text, originalTweetJson.entities);

    tweet.highlights = __toHighlights(originalTweetJson.full_text, originalTweetJson.entities);

    tweet.isVerified = originalTweetJson.user.verified;
    tweet.name = originalTweetJson.user.name;
    tweet.userIdStr = originalTweetJson.user.id_str;
    tweet.screenName = originalTweetJson.user.screen_name;
    tweet.profileImageUrl = originalTweetJson.user.profile_image_url;
    tweet.inReplyToScreenName = originalTweetJson.in_reply_to_screen_name;
    tweet.inReplyToStatusId = originalTweetJson.in_reply_to_status_id;
    tweet.inReplyToStatusIdStr = originalTweetJson.in_reply_to_status_id_str;
    tweet.latitude = "";
    tweet.longitude = "";
    tweet.mediaUrl = "";
    //tweet.richText = tweet.id + " <br> "+tweet.id_str + " <br><br> "+tweet.inReplyToStatusId + " <br> "+tweet.inReplyToStatusIdStr
    tweet.media = [];

    if (tweetJson.extended_entities && tweetJson.extended_entities.media){
        tweetJson.extended_entities.media.forEach(function(el) {

            if (el.type === "video" || el.type === "animated_gif"){
                for (var j = 0; j < el.video_info.variants.length; j++) {
                    if (el.video_info.variants[j].content_type === "video/mp4") {
                        tweet.media.push({
                                             "type" : el.type,
                                             "video": el.video_info.variants[j].url,
                                             "src": el.media_url_https
                                         })
                    }
                }
                //console.log(JSON.stringify(tweet.media))
            } else {
                tweet.media.push({ "type" : "photo", "src": el.media_url_https})

            }

        });

        tweet.mediaUrl = tweetJson.entities.media[0].media_url_https
        tweet.plainText = tweet.plainText.replace(tweetJson.entities.media[0].url, "")
        tweet.plainText = tweet.plainText + '<a href="blablabla">test M</a>'
    }

//    /tweet.mediaPhotos = tweet.mediaPhotos.join("/#/")

    //console.log(" ---------------------- "); console.log(JSON.stringify(tweetJson)); console.log(" ---------------------- "); console.log(JSON.stringify(tweet))
    return tweet;
}

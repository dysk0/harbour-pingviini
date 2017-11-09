Qt.include("twitter-text.js")
String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};
function getValidDate(twitterDate) {
    return new Date(twitterDate.replace(/^(\w+) (\w+) (\d+) ([\d:]+) \+0000 (\d+)$/,"$1, $2 $3 $5 $4 GMT"));
}
function getDate(ts){
    return new Date(ts.getFullYear(), ts.getMonth(), ts.getDate(), 0, 0, 0)
}
function parseUser(data){
    var usr = {
        id: data.id,
        id_str: data.id_str,
        name: data.name,
        screen_name: data.screen_name,
        location: data.location,
        description: data.description.trim(),
        avatar: data.profile_image_url_https,
        favourites_count: data.favourites_count,
        followers_count: data.followers_count,
        friends_count: data.friends_count,
        listed_count: data.listed_count,
        statuses_count: data.statuses_count,
        created_at: getValidDate(data.created_at),
        verified: data.verified
    }
    console.log(JSON.stringify(usr))
    return usr;
}

function parseEntities(tweet, entities){
    tweet.richText = tweet.text
    tweet.media = [] //Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
    if (entities.user_mentions){
        entities.user_mentions.forEach(function(item) {
            //console.info(JSON.stringify(item))
            tweet.richText = tweet.richText.replace(new RegExp( '@'+item.screen_name, "gi" ), '<a href="@'+item.screen_name+'">@'+item.screen_name+'</a>');
        });
    }
    if (entities.hashtags){
        entities.hashtags.forEach(function(item) {
            //console.info(JSON.stringify(item))
            tweet.richText = tweet.richText.replace('#'+item.text, '<a href="#'+item.text+'">#'+item.text+'</a>');
        });
    }
    if (entities.urls){
        entities.urls.forEach(function(item) {
            if(item.expanded_url.indexOf("/i/stickers/") === -1) {
                tweet.richText = tweet.richText.replaceAll(item.url, '<a href="'+item.url+'">'+item.display_url+"</a>")
            } else {
                var media;
                media = {
                    type:       'sticker',
                    cover:      item.expanded_url+"",
                    media:      item.expanded_url+":large"
                }

                tweet.media.push(media)
                tweet.richText = tweet.text.replaceAll(item.url, '')
            }
        });
    }
    if (entities.media){
        entities.media.forEach(function(item) {
            var media;
            if (item.type ==="photo"){
                media = {
                    id:         item.id,
                    id_str:     item.id_str,
                    type:       item.type,
                    cover:      item.media_url_https+"",
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
            tweet.richText = tweet.text.replaceAll(item.url, '')
        });
    }
    return tweet;
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

function parseTrends(json) {
    console.log(JSON.stringify(json))
    return {name: json.name, tweets: json.tweet_volume};
}

function parseDM(json) {
    var tweet = {
        id: json.id,
        id_str: json.id_str,
        sent: false,
        created_at: getValidDate(json.created_at),
        text: json.text.trim(),
        sender_id: json.sender_id_str,
        sender_name: json.sender_screen_name,
        sender_screen_name: json.sender.screen_name,
        sender_avatar: json.sender.profile_image_url_https,
        recipient_id: json.recipient_id_str,
        recipient_name: json.recipient.name,
        recipient_screen_name: json.recipient_screen_name,
        recipient_avatar: json.recipient.profile_image_url_https,
        media: []
    }
    //tweet = parseEntities(tweet, json.entities);
    //console.log(JSON.stringify(json.entities))
    tweet.section = getDate(tweet.created_at)
    return tweet;
}

function parseTweet(tweetJson) {


    var tweet = {
        id: tweetJson.id,
        id_str: tweetJson.id_str,
        source: tweetJson.source.replace(/<[^>]+>/ig, ""),
        created_at: getValidDate(tweetJson.created_at),
        isVerified: false,
        favorited: tweetJson.favorited,
        favoriteCount: tweetJson.favorite_count,
        retweeted: tweetJson.retweeted,
        retweetCount: tweetJson.retweet_count,
        isRetweet: false,
        highlights: "",
        retweetScreenName: tweetJson.user.screen_name
    }
    tweet.section = getDate(tweet.created_at)
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
        tweet.quoted_status = {
            id: originalTweetJson.quoted_status.id,
            id_str: originalTweetJson.quoted_status.id_str,
            created_at: getValidDate(originalTweetJson.quoted_status.created_at),
            favorited: originalTweetJson.quoted_status.favorited,
            favoriteCount: originalTweetJson.quoted_status.favorite_count,
            retweeted: originalTweetJson.quoted_status.retweeted,
            retweetCount: originalTweetJson.quoted_status.retweet_count,
            isVerified: originalTweetJson.quoted_status.user.verified,
            userId: originalTweetJson.quoted_status.user.id,
            userIdStr: originalTweetJson.quoted_status.user.id_str,
            name: originalTweetJson.quoted_status.user.name,
            screenName: originalTweetJson.quoted_status.user.screen_name,
            profileImageUrl: originalTweetJson.quoted_status.user.profile_image_url,
            text: originalTweetJson.quoted_status.full_text
        }
        tweet.quoted_status = parseEntities(tweet.quoted_status, originalTweetJson.quoted_status.entities);
        tweet.quoted_status.richText = twttr.txt.autoLink(tweet.quoted_status.text, originalTweetJson.quoted_status.entities.urls)
    }


    tweet.text = originalTweetJson.full_text ? originalTweetJson.full_text : originalTweetJson.text
    if (originalTweetJson.entities)
        tweet = parseEntities(tweet, originalTweetJson.entities);
    tweet.richText = tweet.text;
    tweet.richText = twttr.txt.autoLink(tweet.text, originalTweetJson.entities.urls);




    //if(tweet.screenName === "dysko"){
    //console.log(JSON.stringify(originalTweetJson))
    //console.log(JSON.stringify(tweet))
    //}

    return tweet;
}

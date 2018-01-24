Qt.include("twitter-text.js")
String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};
function getValidDate(twitterDate) {
    return new Date(twitterDate.replace(/^(\w+) (\w+) (\d+) ([\d:]+) \+0000 (\d+)$/,"$1, $2 $3 $5 $4 GMT"));
}
function getDate(ts){
    var date = new Date();
    try {
        date = new Date(ts.getFullYear(), ts.getMonth(), ts.getDate(), 0, 0, 0)
    } catch(err) {
        console.log(err.message);
    }
    finally {
        return date;
    }
}
function parseUser(data){
    var usr = {}
    try {
        usr = {
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
        //console.log(JSON.stringify(usr))
    } catch(err) {
        console.log(err.message);
    }
    finally {
        return usr;
    }
}

function parseEntities(tweet, entities){
    try {
        tweet.rich_text = tweet.text
        //Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
        if ('user_mentions' in entities){
            entities.user_mentions.forEach(function(item) {
                //console.info(JSON.stringify(item))
                tweet.rich_text = tweet.rich_text.replace(new RegExp( '@'+item.screen_name, "gi" ), '<a style="text-decoration: none; color:COLOR" href="@'+item.screen_name+'">@'+item.screen_name+'</a>');
            });
        }
        if ('hashtags' in entities){
            entities.hashtags.forEach(function(item) {
                //console.info(JSON.stringify(item))
                tweet.rich_text = tweet.rich_text.replace('#'+item.text, '<a style="text-decoration: none; color:COLOR" href="#'+item.text+'">#'+item.text+'</a>');
            });
        }
        if ('urls' in entities){
            entities.urls.forEach(function(item) {
                if(item.expanded_url.indexOf("/i/stickers/") === -1) {
                    if(item.expanded_url.indexOf("https://twitter.com/") !== -1) {
                        tweet.rich_text = tweet.rich_text.replaceAll(item.url, ' ')
                    }
                    tweet.rich_text = tweet.rich_text.replaceAll(item.url, '<a style="text-decoration: none; color:COLOR" href="'+item.url+'">'+item.display_url+"</a>")
                } else {
                    var media;
                    media = {
                        type:       'sticker',
                        cover:      item.expanded_url+"",
                        media:      item.expanded_url+":large"
                    }

                    tweet.media.push(media)
                    tweet.rich_text = tweet.rich_text.replaceAll(item.url, '')
                }
            });
        }
        if ('media' in entities){
            entities.media.forEach(function(item) {

                var media = {
                        'id':         item.id,
                        'id_str':     item.id_str,
                        'type':       item.type,
                        'preview':      item.media_url_https+":medium",
                        'full':      item.media_url_https+":large"
                    }
                if (item.type !=="photo"){
                    //console.info(JSON.stringify(item))
                    media.full = item.video_info.variants.length ? item.video_info.variants[item.video_info.variants.length-1].url : false
                }


                if (tweet.media.filter(function (el) { return el.id_str === media.id_str}).length === 0) {
                    tweet.media.push(media)
                    tweet.text = tweet.text.replaceAll(item.url, '')
                    tweet.rich_text = tweet.rich_text.replaceAll(item.url, '')
                }
            });
        }
    } catch(err) {
        console.log(err.message);
        console.log(JSON.stringify(err));
        console.log(tweet.rich_text);
        console.log(tweet.text);

    }
    finally {
        return tweet;
    }

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
    return {name: json.name, tweets: json.tweet_volume};
}

function parseDM(json) {
    var tweet = {}
    try {
        tweet = {
            id: json.id,
            id_str: json.id_str,
            sent: false,
            created_at: getValidDate(json.created_at),
            text: (json.full_text ? json.full_text : json.text),
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
        tweet = parseEntities(tweet, json.entities);
        //console.log(JSON.stringify(json.entities))
        tweet.section = getDate(tweet.created_at)
    } catch(err) {
        console.log(err.message);
    }
    finally {
        return tweet;
    }
}

function parseTweet(tweetJson) {
    var tweet = {}
    try {
        tweet = {
            id: tweetJson.id,
            id_str: tweetJson.id_str,
            source: tweetJson.source.replace(/<[^>]+>/ig, ""),
            created_at: getValidDate(tweetJson.created_at),
            verified: false,
            favorited: tweetJson.favorited,
            favorite_count: tweetJson.favorite_count,
            retweeted: tweetJson.retweeted,
            retweet_count: tweetJson.retweet_count,
            retweet: false,
            retweeted_status: tweetJson.retweeted_status,
            highlights: "",
            media: [],
            retweet_screen_name: tweetJson.user.screen_name,
            retweet_avatar: tweetJson.user.profile_image_url
        }
        tweet.section = getDate(tweet.created_at)
        var originalTweetJson = {};
        if (tweetJson.retweeted_status) {
            tweet.retweet = true;
            originalTweetJson = tweetJson.retweeted_status;
        } else {
            originalTweetJson = tweetJson;
        }





        tweet.verified = originalTweetJson.user.verified;
        tweet.name = originalTweetJson.user.name;
        tweet.user_id = originalTweetJson.user.id;
        tweet.user_id_str = originalTweetJson.user.id_str;
        tweet.screen_name = originalTweetJson.user.screen_name;
        tweet.avatar = originalTweetJson.user.profile_image_url;
        tweet.in_reply_to_screen_name = originalTweetJson.in_reply_to_screen_name;
        tweet.in_reply_to_status_id = originalTweetJson.in_reply_to_status_id;
        tweet.in_reply_to_status_id_str = originalTweetJson.in_reply_to_status_id_str;
        tweet.latitude = "";
        tweet.longitude = "";
        tweet.is_quote_status = originalTweetJson.is_quote_status ? true : false;
        if (tweet.is_quote_status) {
            tweet.quote_status_id = originalTweetJson.quoted_status_id
            tweet.quoted_status = {
                id: originalTweetJson.quoted_status.id,
                media: [ ],
                id_str: originalTweetJson.quoted_status.id_str,
                created_at: getValidDate(originalTweetJson.quoted_status.created_at),
                favorited: originalTweetJson.quoted_status.favorited,
                favorite_count: originalTweetJson.quoted_status.favorite_count,
                retweet: false,
                retweeted: originalTweetJson.quoted_status.retweeted,
                retweet_count: originalTweetJson.quoted_status.retweet_count,
                verified: originalTweetJson.quoted_status.user.verified,
                user_id: originalTweetJson.quoted_status.user.id,
                user_id_str: originalTweetJson.quoted_status.user.id_str,
                name: originalTweetJson.quoted_status.user.name,
                screen_name: originalTweetJson.quoted_status.user.screen_name,
                avatar: originalTweetJson.quoted_status.user.profile_image_url,
                text: originalTweetJson.quoted_status.full_text,
            }
            if ('extended_entities' in originalTweetJson.quoted_status)
                tweet.quoted_status = parseEntities(tweet.quoted_status, originalTweetJson.quoted_status.extended_entities);
            if ('entities' in originalTweetJson.quoted_status)
                tweet.quoted_status = parseEntities(tweet.quoted_status, originalTweetJson.quoted_status.entities);


        }


        tweet.text = originalTweetJson.full_text ? originalTweetJson.full_text : originalTweetJson.text
        tweet.rich_text = tweet.text;

        if ('extended_entities' in originalTweetJson)
            tweet = parseEntities(tweet, originalTweetJson.extended_entities);

        if ('entities' in originalTweetJson)
            tweet = parseEntities(tweet, originalTweetJson.entities);

        //tweet.rich_text = twttr.txt.autoLink(tweet.rich_text, originalTweetJson.entities.urls);




        //if(tweet.screenName === "dysko"){
        //console.log(JSON.stringify(originalTweetJson))
        //console.log(JSON.stringify(tweet))
        //}
    } catch(err) {
        console.log(err.message);
        console.log(JSON.stringify(err));
    }
    finally {
        return tweet;
    }

}

function request(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = (function(myxhr) {
        return function() {
            callback(myxhr);
        }
    })(xhr);
    xhr.open('GET', url, true);
    xhr.send('');
}

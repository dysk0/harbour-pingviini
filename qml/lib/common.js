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
    //richText = __linkHashtags(richText, entities.hashtags);

    entities.urls.forEach(function(urlObject) {
        //console.log(urlObject.url)
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
        id: tweetJson.id,
        id_str: tweetJson.id_str,
        source: tweetJson.source.replace(/<[^>]+>/ig, ""),
        createdAt: getValidDate(tweetJson.created_at),
        isFavourited: tweetJson.favorited,
        favoriteCount: tweetJson.favorite_count,
        isRetweet: tweetJson.retweeted,
        retweetCount: tweetJson.retweet_count,
        highlights: "",
        retweetScreenName: tweetJson.user.screen_name
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

    tweet.mediaPhotos = [];

    if (tweetJson.extended_entities && tweetJson.extended_entities.media){
        tweetJson.extended_entities.media.forEach(function(el) {
            if (el.type === "photo"){
                console.log(el.media_url_https)
                tweet.mediaPhotos.push(el.media_url_https)
            }

        });

        tweet.mediaUrl = tweetJson.entities.media[0].media_url_https
        tweet.plainText = tweet.plainText.replace(tweetJson.entities.media[0].url, "")
    }

    tweet.mediaPhotos = tweet.mediaPhotos.join("/#/")

    //console.log(" ---------------------- "); console.log(JSON.stringify(tweetJson)); console.log(" ---------------------- "); console.log(JSON.stringify(tweet))
    return tweet;
}


var tweet1 = {
    "created_at": "Thu Apr 06 12:05:43 +0000 2017",
    "id": 849956281020547074,
    "id_str": "849956281020547074",
    "text": "RT @markoper101: Bravo deco! Najbolji hroni\u010dar ove beskrupulozne vlasti. https:\/\/t.co\/vZRRqdNaT3",
    "truncated": false,
    "entities": {
        "hashtags": [],
        "symbols": [],
        "user_mentions": [{
            "screen_name": "markoper101",
            "name": "Marko",
            "id": 735925838156304386,
            "id_str": "735925838156304386",
            "indices": [3, 15]
        }],
        "urls": [],
        "media": [{
            "id": 849909239191666688,
            "id_str": "849909239191666688",
            "indices": [73, 96],
            "media_url": "http:\/\/pbs.twimg.com\/media\/C8t78zVXgAAoWtJ.jpg",
            "media_url_https": "https:\/\/pbs.twimg.com\/media\/C8t78zVXgAAoWtJ.jpg",
            "url": "https:\/\/t.co\/vZRRqdNaT3",
            "display_url": "pic.twitter.com\/vZRRqdNaT3",
            "expanded_url": "https:\/\/twitter.com\/markoper101\/status\/849909263434698752\/photo\/1",
            "type": "photo",
            "sizes": {
                "medium": {
                    "w": 748,
                    "h": 733,
                    "resize": "fit"
                },
                "small": {
                    "w": 680,
                    "h": 666,
                    "resize": "fit"
                },
                "large": {
                    "w": 748,
                    "h": 733,
                    "resize": "fit"
                },
                "thumb": {
                    "w": 150,
                    "h": 150,
                    "resize": "crop"
                }
            },
            "source_status_id": 849909263434698752,
            "source_status_id_str": "849909263434698752",
            "source_user_id": 735925838156304386,
            "source_user_id_str": "735925838156304386"
        }]
    },
    "extended_entities": {
        "media": [{
            "id": 849909239191666688,
            "id_str": "849909239191666688",
            "indices": [73, 96],
            "media_url": "http:\/\/pbs.twimg.com\/media\/C8t78zVXgAAoWtJ.jpg",
            "media_url_https": "https:\/\/pbs.twimg.com\/media\/C8t78zVXgAAoWtJ.jpg",
            "url": "https:\/\/t.co\/vZRRqdNaT3",
            "display_url": "pic.twitter.com\/vZRRqdNaT3",
            "expanded_url": "https:\/\/twitter.com\/markoper101\/status\/849909263434698752\/photo\/1",
            "type": "photo",
            "sizes": {
                "medium": {
                    "w": 748,
                    "h": 733,
                    "resize": "fit"
                },
                "small": {
                    "w": 680,
                    "h": 666,
                    "resize": "fit"
                },
                "large": {
                    "w": 748,
                    "h": 733,
                    "resize": "fit"
                },
                "thumb": {
                    "w": 150,
                    "h": 150,
                    "resize": "crop"
                }
            },
            "source_status_id": 849909263434698752,
            "source_status_id_str": "849909263434698752",
            "source_user_id": 735925838156304386,
            "source_user_id_str": "735925838156304386"
        }]
    },
    "source": "\u003ca href=\"http:\/\/twitter.com\" rel=\"nofollow\"\u003eTwitter Web Client\u003c\/a\u003e",
    "in_reply_to_status_id": null,
    "in_reply_to_status_id_str": null,
    "in_reply_to_user_id": null,
    "in_reply_to_user_id_str": null,
    "in_reply_to_screen_name": null,
    "user": {
        "id": 19210452,
        "id_str": "19210452",
        "name": "Du\u0161ko Angirevi\u0107",
        "screen_name": "dysko",
        "location": "Banja Luka",
        "description": "So\u0161l 'hor, aten\u0161n siker...\r\nDo\u017eivotni korisnik GSP-a",
        "url": "https:\/\/t.co\/bpcHls2hlc",
        "entities": {
            "url": {
                "urls": [{
                    "url": "https:\/\/t.co\/bpcHls2hlc",
                    "expanded_url": "http:\/\/www.grave-design.com",
                    "display_url": "grave-design.com",
                    "indices": [0, 23]
                }]
            },
            "description": {
                "urls": []
            }
        },
        "protected": false,
        "followers_count": 952,
        "friends_count": 954,
        "listed_count": 20,
        "created_at": "Tue Jan 20 00:18:06 +0000 2009",
        "favourites_count": 392,
        "utc_offset": 7200,
        "time_zone": "Sarajevo",
        "geo_enabled": true,
        "verified": false,
        "statuses_count": 6219,
        "lang": "en",
        "contributors_enabled": false,
        "is_translator": false,
        "is_translation_enabled": false,
        "profile_background_color": "F6F8F7",
        "profile_background_image_url": "http:\/\/pbs.twimg.com\/profile_background_images\/560385559\/BG1.jpg",
        "profile_background_image_url_https": "https:\/\/pbs.twimg.com\/profile_background_images\/560385559\/BG1.jpg",
        "profile_background_tile": true,
        "profile_image_url": "http:\/\/pbs.twimg.com\/profile_images\/508008295333130241\/zSYce4jv_normal.jpeg",
        "profile_image_url_https": "https:\/\/pbs.twimg.com\/profile_images\/508008295333130241\/zSYce4jv_normal.jpeg",
        "profile_banner_url": "https:\/\/pbs.twimg.com\/profile_banners\/19210452\/1413361771",
        "profile_link_color": "AF643D",
        "profile_sidebar_border_color": "200E0D",
        "profile_sidebar_fill_color": "DCDCDC",
        "profile_text_color": "000000",
        "profile_use_background_image": true,
        "has_extended_profile": true,
        "default_profile": false,
        "default_profile_image": false,
        "following": false,
        "follow_request_sent": false,
        "notifications": false,
        "translator_type": "none"
    },
    "geo": null,
    "coordinates": null,
    "place": null,
    "contributors": null,
    "retweeted_status": {
        "created_at": "Thu Apr 06 08:58:53 +0000 2017",
        "id": 849909263434698752,
        "id_str": "849909263434698752",
        "text": "Bravo deco! Najbolji hroni\u010dar ove beskrupulozne vlasti. https:\/\/t.co\/vZRRqdNaT3",
        "truncated": false,
        "entities": {
            "hashtags": [],
            "symbols": [],
            "user_mentions": [],
            "urls": [],
            "media": [{
                "id": 849909239191666688,
                "id_str": "849909239191666688",
                "indices": [56, 79],
                "media_url": "http:\/\/pbs.twimg.com\/media\/C8t78zVXgAAoWtJ.jpg",
                "media_url_https": "https:\/\/pbs.twimg.com\/media\/C8t78zVXgAAoWtJ.jpg",
                "url": "https:\/\/t.co\/vZRRqdNaT3",
                "display_url": "pic.twitter.com\/vZRRqdNaT3",
                "expanded_url": "https:\/\/twitter.com\/markoper101\/status\/849909263434698752\/photo\/1",
                "type": "photo",
                "sizes": {
                    "medium": {
                        "w": 748,
                        "h": 733,
                        "resize": "fit"
                    },
                    "small": {
                        "w": 680,
                        "h": 666,
                        "resize": "fit"
                    },
                    "large": {
                        "w": 748,
                        "h": 733,
                        "resize": "fit"
                    },
                    "thumb": {
                        "w": 150,
                        "h": 150,
                        "resize": "crop"
                    }
                }
            }]
        },
        "extended_entities": {
            "media": [{
                "id": 849909239191666688,
                "id_str": "849909239191666688",
                "indices": [56, 79],
                "media_url": "http:\/\/pbs.twimg.com\/media\/C8t78zVXgAAoWtJ.jpg",
                "media_url_https": "https:\/\/pbs.twimg.com\/media\/C8t78zVXgAAoWtJ.jpg",
                "url": "https:\/\/t.co\/vZRRqdNaT3",
                "display_url": "pic.twitter.com\/vZRRqdNaT3",
                "expanded_url": "https:\/\/twitter.com\/markoper101\/status\/849909263434698752\/photo\/1",
                "type": "photo",
                "sizes": {
                    "medium": {
                        "w": 748,
                        "h": 733,
                        "resize": "fit"
                    },
                    "small": {
                        "w": 680,
                        "h": 666,
                        "resize": "fit"
                    },
                    "large": {
                        "w": 748,
                        "h": 733,
                        "resize": "fit"
                    },
                    "thumb": {
                        "w": 150,
                        "h": 150,
                        "resize": "crop"
                    }
                }
            }]
        },
        "source": "\u003ca href=\"http:\/\/twitter.com\/download\/iphone\" rel=\"nofollow\"\u003eTwitter for iPhone\u003c\/a\u003e",
        "in_reply_to_status_id": null,
        "in_reply_to_status_id_str": null,
        "in_reply_to_user_id": null,
        "in_reply_to_user_id_str": null,
        "in_reply_to_screen_name": null,
        "user": {
            "id": 735925838156304386,
            "id_str": "735925838156304386",
            "name": "Marko",
            "screen_name": "markoper101",
            "location": "Belgrade, Republic of Serbia",
            "description": "Zdrav razum bez ograni\u010denja.",
            "url": null,
            "entities": {
                "description": {
                    "urls": []
                }
            },
            "protected": false,
            "followers_count": 52,
            "friends_count": 109,
            "listed_count": 0,
            "created_at": "Thu May 26 20:09:27 +0000 2016",
            "favourites_count": 953,
            "utc_offset": null,
            "time_zone": null,
            "geo_enabled": false,
            "verified": false,
            "statuses_count": 638,
            "lang": "en",
            "contributors_enabled": false,
            "is_translator": false,
            "is_translation_enabled": false,
            "profile_background_color": "F5F8FA",
            "profile_background_image_url": null,
            "profile_background_image_url_https": null,
            "profile_background_tile": false,
            "profile_image_url": "http:\/\/pbs.twimg.com\/profile_images\/735939499730063360\/k3ivdhMK_normal.jpg",
            "profile_image_url_https": "https:\/\/pbs.twimg.com\/profile_images\/735939499730063360\/k3ivdhMK_normal.jpg",
            "profile_banner_url": "https:\/\/pbs.twimg.com\/profile_banners\/735925838156304386\/1464297867",
            "profile_link_color": "1DA1F2",
            "profile_sidebar_border_color": "C0DEED",
            "profile_sidebar_fill_color": "DDEEF6",
            "profile_text_color": "333333",
            "profile_use_background_image": true,
            "has_extended_profile": true,
            "default_profile": true,
            "default_profile_image": false,
            "following": false,
            "follow_request_sent": false,
            "notifications": false,
            "translator_type": "none"
        },
        "geo": null,
        "coordinates": null,
        "place": null,
        "contributors": null,
        "is_quote_status": false,
        "retweet_count": 184,
        "favorite_count": 553,
        "favorited": true,
        "retweeted": true,
        "possibly_sensitive": false,
        "lang": "und"
    },
    "is_quote_status": false,
    "retweet_count": 184,
    "favorite_count": 0,
    "favorited": true,
    "retweeted": true,
    "possibly_sensitive": false,
    "lang": "und"
}

var tweet2 = {
    "created_at": "Wed Apr 05 07:08:17 +0000 2017",
    "id": 849519041748361219,
    "id_str": "849519041748361219",
    "text": "evo par fotki od juce iz #novisad #protest #srbija ..nastavak danas u 18h na trgu slobode #protest2017 https:\/\/t.co\/c3QMp6OXYe",
    "truncated": false,
    "entities": {
        "hashtags": [{
            "text": "novisad",
            "indices": [25, 33]
        }, {
            "text": "protest",
            "indices": [34, 42]
        }, {
            "text": "srbija",
            "indices": [43, 50]
        }, {
            "text": "protest2017",
            "indices": [90, 102]
        }],
        "symbols": [],
        "user_mentions": [],
        "urls": [],
        "media": [{
            "id": 849518908914761729,
            "id_str": "849518908914761729",
            "indices": [103, 126],
            "media_url": "http:\/\/pbs.twimg.com\/media\/C8oY8lvXgAEM5tM.jpg",
            "media_url_https": "https:\/\/pbs.twimg.com\/media\/C8oY8lvXgAEM5tM.jpg",
            "url": "https:\/\/t.co\/c3QMp6OXYe",
            "display_url": "pic.twitter.com\/c3QMp6OXYe",
            "expanded_url": "https:\/\/twitter.com\/zarkobns\/status\/849519041748361219\/photo\/1",
            "type": "photo",
            "sizes": {
                "small": {
                    "w": 680,
                    "h": 454,
                    "resize": "fit"
                },
                "thumb": {
                    "w": 150,
                    "h": 150,
                    "resize": "crop"
                },
                "medium": {
                    "w": 1024,
                    "h": 683,
                    "resize": "fit"
                },
                "large": {
                    "w": 1024,
                    "h": 683,
                    "resize": "fit"
                }
            }
        }]
    },
    "extended_entities": {
        "media": [{
            "id": 849518908914761729,
            "id_str": "849518908914761729",
            "indices": [103, 126],
            "media_url": "http:\/\/pbs.twimg.com\/media\/C8oY8lvXgAEM5tM.jpg",
            "media_url_https": "https:\/\/pbs.twimg.com\/media\/C8oY8lvXgAEM5tM.jpg",
            "url": "https:\/\/t.co\/c3QMp6OXYe",
            "display_url": "pic.twitter.com\/c3QMp6OXYe",
            "expanded_url": "https:\/\/twitter.com\/zarkobns\/status\/849519041748361219\/photo\/1",
            "type": "photo",
            "sizes": {
                "small": {
                    "w": 680,
                    "h": 454,
                    "resize": "fit"
                },
                "thumb": {
                    "w": 150,
                    "h": 150,
                    "resize": "crop"
                },
                "medium": {
                    "w": 1024,
                    "h": 683,
                    "resize": "fit"
                },
                "large": {
                    "w": 1024,
                    "h": 683,
                    "resize": "fit"
                }
            }
        }, {
            "id": 849518908881162240,
            "id_str": "849518908881162240",
            "indices": [103, 126],
            "media_url": "http:\/\/pbs.twimg.com\/media\/C8oY8lnW0AA5B6I.jpg",
            "media_url_https": "https:\/\/pbs.twimg.com\/media\/C8oY8lnW0AA5B6I.jpg",
            "url": "https:\/\/t.co\/c3QMp6OXYe",
            "display_url": "pic.twitter.com\/c3QMp6OXYe",
            "expanded_url": "https:\/\/twitter.com\/zarkobns\/status\/849519041748361219\/photo\/1",
            "type": "photo",
            "sizes": {
                "large": {
                    "w": 1024,
                    "h": 1534,
                    "resize": "fit"
                },
                "small": {
                    "w": 454,
                    "h": 680,
                    "resize": "fit"
                },
                "thumb": {
                    "w": 150,
                    "h": 150,
                    "resize": "crop"
                },
                "medium": {
                    "w": 801,
                    "h": 1200,
                    "resize": "fit"
                }
            }
        }, {
            "id": 849518908885413892,
            "id_str": "849518908885413892",
            "indices": [103, 126],
            "media_url": "http:\/\/pbs.twimg.com\/media\/C8oY8loXsAQKhTe.jpg",
            "media_url_https": "https:\/\/pbs.twimg.com\/media\/C8oY8loXsAQKhTe.jpg",
            "url": "https:\/\/t.co\/c3QMp6OXYe",
            "display_url": "pic.twitter.com\/c3QMp6OXYe",
            "expanded_url": "https:\/\/twitter.com\/zarkobns\/status\/849519041748361219\/photo\/1",
            "type": "photo",
            "sizes": {
                "large": {
                    "w": 1024,
                    "h": 683,
                    "resize": "fit"
                },
                "thumb": {
                    "w": 150,
                    "h": 150,
                    "resize": "crop"
                },
                "small": {
                    "w": 680,
                    "h": 454,
                    "resize": "fit"
                },
                "medium": {
                    "w": 1024,
                    "h": 683,
                    "resize": "fit"
                }
            }
        }, {
            "id": 849518908889591811,
            "id_str": "849518908889591811",
            "indices": [103, 126],
            "media_url": "http:\/\/pbs.twimg.com\/media\/C8oY8lpXcAMD2o0.jpg",
            "media_url_https": "https:\/\/pbs.twimg.com\/media\/C8oY8lpXcAMD2o0.jpg",
            "url": "https:\/\/t.co\/c3QMp6OXYe",
            "display_url": "pic.twitter.com\/c3QMp6OXYe",
            "expanded_url": "https:\/\/twitter.com\/zarkobns\/status\/849519041748361219\/photo\/1",
            "type": "photo",
            "sizes": {
                "small": {
                    "w": 680,
                    "h": 454,
                    "resize": "fit"
                },
                "thumb": {
                    "w": 150,
                    "h": 150,
                    "resize": "crop"
                },
                "large": {
                    "w": 1024,
                    "h": 683,
                    "resize": "fit"
                },
                "medium": {
                    "w": 1024,
                    "h": 683,
                    "resize": "fit"
                }
            }
        }]
    },
    "source": "\u003ca href=\"https:\/\/about.twitter.com\/products\/tweetdeck\" rel=\"nofollow\"\u003eTweetDeck\u003c\/a\u003e",
    "in_reply_to_status_id": null,
    "in_reply_to_status_id_str": null,
    "in_reply_to_user_id": null,
    "in_reply_to_user_id_str": null,
    "in_reply_to_screen_name": null,
    "user": {
        "id": 211685069,
        "id_str": "211685069",
        "name": "zarko bogosavljevic",
        "screen_name": "zarkobns",
        "location": "Serbia, Novi Sad",
        "description": "Ako budete samo posmatrali, gadovi \u0107e nas jednog po jednog ubijati..novinar\/d\u017eeda\/ka\u017eu i hejter... tvitovi su moji i nisu stav\/misljenje redakcije",
        "url": null,
        "entities": {
            "description": {
                "urls": []
            }
        },
        "protected": false,
        "followers_count": 4305,
        "friends_count": 1822,
        "listed_count": 92,
        "created_at": "Wed Nov 03 23:31:18 +0000 2010",
        "favourites_count": 13251,
        "utc_offset": 7200,
        "time_zone": "Belgrade",
        "geo_enabled": true,
        "verified": false,
        "statuses_count": 86330,
        "lang": "en",
        "contributors_enabled": false,
        "is_translator": false,
        "is_translation_enabled": false,
        "profile_background_color": "C0DEED",
        "profile_background_image_url": "http:\/\/pbs.twimg.com\/profile_background_images\/202889556\/lavovizamenik.jpg",
        "profile_background_image_url_https": "https:\/\/pbs.twimg.com\/profile_background_images\/202889556\/lavovizamenik.jpg",
        "profile_background_tile": true,
        "profile_image_url": "http:\/\/pbs.twimg.com\/profile_images\/1159174542\/prvomajska_normal.jpg",
        "profile_image_url_https": "https:\/\/pbs.twimg.com\/profile_images\/1159174542\/prvomajska_normal.jpg",
        "profile_banner_url": "https:\/\/pbs.twimg.com\/profile_banners\/211685069\/1398194566",
        "profile_link_color": "1290BA",
        "profile_sidebar_border_color": "000000",
        "profile_sidebar_fill_color": "DDEEF6",
        "profile_text_color": "F71111",
        "profile_use_background_image": true,
        "has_extended_profile": false,
        "default_profile": false,
        "default_profile_image": false,
        "following": false,
        "follow_request_sent": false,
        "notifications": false,
        "translator_type": "none"
    },
    "geo": null,
    "coordinates": null,
    "place": null,
    "contributors": null,
    "is_quote_status": false,
    "retweet_count": 5,
    "favorite_count": 32,
    "favorited": false,
    "retweeted": false,
    "possibly_sensitive": false,
    "possibly_sensitive_appealable": false,
    "lang": "und"
}

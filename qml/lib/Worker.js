Qt.include("codebird.js")
Qt.include("common.js")
var highlightColor = "#f00";

function showError(status, statusText) {
    console.log(status)
    console.log(statusText)
}

function findRelated(model, id){
    var res = [];
    for(var i = 0; i < model.count; i++){
        var tweet = model.get(i)
        if (id.indexOf(tweet.id_str) > -1 || id.indexOf(tweet.inReplyToStatusId) > -1) {
            res.push(tweet)
            console.log(tweet.id_str + ' / ' + tweet.inReplyToStatusId);
        }
    }
    return res;
}






WorkerScript.onMessage = function(msg) {
    console.log('///////////////////////////////////////////////////////////')
    console.log(JSON.stringify(msg))
    console.log('///////////////////////////////////////////////////////////')
    var cb = new Fcodebird;
    cb.setUseProxy(false);

    if (msg.conf.OAUTH_CONSUMER_KEY && msg.conf.OAUTH_CONSUMER_SECRET ){
        cb.setConsumerKey(msg.conf.OAUTH_CONSUMER_KEY, msg.conf.OAUTH_CONSUMER_SECRET);
    }
    if (msg.conf.OAUTH_TOKEN && msg.conf.OAUTH_TOKEN_SECRET){
        cb.setToken(msg.conf.OAUTH_TOKEN, msg.conf.OAUTH_TOKEN_SECRET);
    }
    if (msg.conf.USER_ID){
        parseDM.setUserId(msg.conf.USER_ID)
    }


    var sinceId;
    var maxId;
    var params;

    if (msg.headlessAction) {
        cb.__call(
                    msg.headlessAction,
                    msg.params,
                    function (reply, rate, err) {
                        if (reply){
                            WorkerScript.sendMessage({ 'success': true, 'key': msg.headlessAction,  "reply": reply})
                        }
                        console.log("$$$$$$$$$$$$$$$$$$$ headlessAction $$$$$$$$$$$$$$");
                        console.log(JSON.stringify(reply));
                        console.log(JSON.stringify(err));
                        console.log("$$$$$$$$$$$$$$$$$$$ headlessAction $$$$$$$$$$$$$$");
                    }
                    );
    }

    if (msg.bgAction){
        console.log("BG ACTION >" + msg.bgAction)
        console.log("BG MODE >" + msg.mode)
        console.log("CONF >" + JSON.stringify(msg.conf))
        if (!msg.params)
            msg.params = {}
        msg.params['tweet_mode'] = "extended";
        //msg.params['count'] = 200;
        if (msg.model.count) {
            if (msg.mode === "append") {
                msg.params['max_id'] = msg.model.get(msg.model.count-1).id
            }
            if (msg.mode === "prepend" && msg.model.count) {
                msg.params['since_id'] = msg.model.get(0).id
            }
        } else {
            msg.mode = "append";
        }
        console.log(JSON.stringify(msg.params))
        cb.__call(msg.bgAction, msg.params, function (reply, rate, err) {
            console.log(JSON.stringify(rate));
            if ('errors' in reply) {
                reply.errors.forEach(function(entry) {
                    WorkerScript.sendMessage({ 'error': true,  "message": entry.message})
                });
                console.log(JSON.stringify(reply.errors))
            }
            //console.log(JSON.stringify(reply))
            if (msg.model){
                var items = [];
                var parser = false;
                switch(msg.bgAction){
                case "search_tweets":
                    if ('statuses' in reply)
                        items = reply.statuses;
                    parser = parseTweet
                    break;
                case "statuses_homeTimeline":
                case "statuses_mentionsTimeline":
                case "statuses_userTimeline":
                    items = reply;
                    parser = parseTweet
                    break;
                case "directMessages":
                case "directMessages_sent":
                    items = reply;
                    parser = parseDM
                    break;
                default:
                    break;
                }

                var length = items.length
                var i = 0

                if (msg.mode === "prepend") {
                    if (msg.model.count > 0){
                        length--;
                    }
                } else if (msg.mode === "append"){
                    if (msg.model.count > 0 ){
                        i = 1;
                    }
                }

                // conversation fixup
                if (msg.bgAction === "search_tweets" && msg.params.f === "tweets"){
                    if (msg.mode === "prepend")
                        length++;
                    if (msg.mode === "append")
                        i = 0;
                }
                // conversation fixup end

                console.log("i: " +i + " length: " + length)

                if (parser) {
                    console.log("Parsing!")
                    for(var k = i; k < length; k++){
                        items[k] = parser(items[k])
                        //console.log(JSON.stringify(items[i]))
                        if (items[k].userId && msg.modelUsers) {
                            msg.modelUsers.append({
                                                      "id": items[k].userId,
                                                      "id_str": items[k].userIdStr,
                                                      "name": items[k].name,
                                                      "screen_name": items[k].screenName,
                                                      "avatar": items[k].profileImageUrl+""
                                                  })
                        }
                    }
                    console.log("parsed!")
                }




                for(k = i; k < length; k++){
                    if (msg.mode === "append") {
                        msg.model.append(items[k])
                    }
                    if (msg.mode === "prepend") {
                        msg.model.insert(0, items[length-k-1])
                    }
                }


            }

            msg.model.sync();

            if (msg.modelUsers){
                var userIDs = [];
                var indexesToRemove = [];
                if (msg.modelUsers && msg.modelUsers.count) {
                    for (i = msg.modelUsers.count-1; i >= 0; i--) {
                        var id = msg.modelUsers.get(i).id_str;
                        //console.log("USERS " + i + " " + id)
                        if (userIDs.indexOf(id) === -1){
                            // user is unique keep
                            userIDs.push(id)
                        } else {
                            // user is duplicate
                            indexesToRemove.push(i)
                        }
                    }
                    indexesToRemove.forEach(function(item) {
                        msg.modelUsers.remove(item)
                    });
                }
                //console.log("USERS " + JSON.stringify(indexesToRemove))
                msg.modelUsers.sync();
            }

            WorkerScript.sendMessage({ 'success': true,  "action": msg.bgAction})
        });
    }
}



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

    if (msg.parser_action === "create_conversation"){
        var data = [];
        var i;
        var item;
        for (i = 0; i < msg.modelSent.count; i++){
            if (msg.modelSent.get(i).recipient_id === msg.sender_id && msg.modelSent.get(i).sender_id === msg.recipient_id){
                //item = JSON.parse(JSON.stringify(msg.modelSent.get(i)))
                item = msg.modelSent.get(i)
                console.log(JSON.stringify(item.media))
                item['section'] = getDate(item['created_at']);
                data.push(item)
            }
        }
        for (i = 0; i < msg.modelReceived.count; i++){

            if ((msg.modelReceived.get(i).sender_id === msg.sender_id)){
                //item = JSON.parse(JSON.stringify(msg.modelReceived.get(i)))
                item = msg.modelReceived.get(i)
                console.log(JSON.stringify(item.media))
                item['section'] = getDate(item['created_at']);
                data.push(item)
            }
        }
        msg.modelConversation.clear();
        data = data.sort(function(a,b){ return a.created_at - b.created_at; })
        msg.modelConversation.append(data);
        msg.modelConversation.sync();
        return;
    }

    var cb = new Fcodebird;
    cb.setUseProxy(false);

    if (msg.conf.OAUTH_CONSUMER_KEY && msg.conf.OAUTH_CONSUMER_SECRET ){
        cb.setConsumerKey(msg.conf.OAUTH_CONSUMER_KEY, msg.conf.OAUTH_CONSUMER_SECRET);
    }
    if (msg.conf.OAUTH_TOKEN && msg.conf.OAUTH_TOKEN_SECRET){
        cb.setToken(msg.conf.OAUTH_TOKEN, msg.conf.OAUTH_TOKEN_SECRET);
    }



    var sinceId;
    var maxId;
    var params;

    if (msg.headlessAction) {
        cb.__call(
                    msg.headlessAction,
                    msg.params,
                    function (reply, rate, err) {
                        console.log("$$$$$$$$$$$$$$$$$$$ headlessAction $$$$$$$$$$$$$$");
                        console.log(JSON.stringify(reply));
                        console.log(JSON.stringify(err));
                        console.log("$$$$$$$$$$$$$$$$$$$ headlessAction $$$$$$$$$$$$$$");

                        switch(msg.headlessAction) {
                        case "users_lookup":
                            if (msg.suggestedModel)
                                msg.suggestedModel.clear()
                            for(var j = 0; j < reply.length; j++) {
                                console.log( reply[j].id )
                                if (msg.suggestedModel)
                                    msg.suggestedModel.append({
                                                               "user_id": reply[j].id,
                                                               "name": reply[j].name,
                                                               "screen_name": reply[j].screen_name,
                                                               "avatar": reply[j].profile_image_url_https
                                                           })
                                for(var i = 0; i < msg.modelUsers.count; i++){
                                    var item = msg.modelUsers.get(i)
                                    if ( reply[j].id  == item.user_id ) {
                                        msg.modelUsers.set(i, {
                                                                    "user_id": reply[j].id,
                                                                    "name": reply[j].name,
                                                                    "screen_name": reply[j].screen_name,
                                                                    "avatar": reply[j].profile_image_url_https
                                                                })
                                        console.log("found in model")
                                    }
                                }
                            }
                            msg.modelUsers.sync();
                            if (msg.suggestedModel)
                                msg.suggestedModel.sync()


                            break;

                        }

                        if (reply){
                            WorkerScript.sendMessage({ 'success': true, 'key': msg.headlessAction,  "reply": reply})
                        }


                        //Logic.modelDMsent
                    },
                    msg.forth ? true : false
                    );
        return;
    }

    if (msg.bgAction !== "" && msg.bgAction !== "undefined"){
        console.log("BG ACTION >" + msg.bgAction)
        console.log("BG MODE >" + msg.mode)
        console.log("CONF >" + JSON.stringify(msg.conf))
        if (!msg.params)
            msg.params = {}
        msg.params['tweet_mode'] = "extended";
        msg.params['extended_entities'] = true;


        if (msg.model && msg.model.count === 0) {
            msg.mode = "append";
        }

        if (msg.next_cursor === ""){
            if (msg.model && msg.model.count) {
                if (msg.mode === "append") {
                    msg.params['max_id'] = msg.model.get(msg.model.count-1).id
                }
                if (msg.mode === "prepend" && msg.model.count) {
                    msg.params['since_id'] = msg.model.get(0).id
                }
            }
        } else {
            if (msg.mode === "prepend" ) {
                if (msg.previous_cursor)
                    msg.params['cursor'] = msg.previous_cursor
            } else {
                if (msg.next_cursor)
                    msg.params['cursor'] = msg.next_cursor
            }
        }


        console.log(JSON.stringify(msg.params))
        cb.__call(msg.bgAction, msg.params, function (reply, rate, err) {
            console.log(JSON.stringify(rate));
            if ('next_cursor' in reply && 'previous_cursor' in reply) {

                console.log("--------------------/////////////////////////////")
                console.log(JSON.stringify(reply.next_cursor))
                console.log(JSON.stringify(reply.previous_cursor))
                console.log("--------------------/////////////////////////////")
                // send cursor to the list for the next navigations
                WorkerScript.sendMessage({
                                             "cursor": true,
                                             "action": msg.bgAction,
                                             "next_cursor": reply.next_cursor_str,
                                             "previous_cursor": reply.previous_cursor_str
                                         })
            }
            if ('errors' in reply) {
                reply.errors.forEach(function(entry) {
                    WorkerScript.sendMessage({ 'error': true,  "message": entry.message, "range": msg.bgAction})
                });
                console.log(JSON.stringify(reply.errors))
            }
            //console.log(JSON.stringify(reply))
            if (msg.model){
                var items = [];
                var parser = false;
                switch(msg.bgAction){
                case "users_search":
                    items = reply;
                    parser = parseUser
                    break;
                case "users_lookup":
                    items = reply;
                    parser = parseUser
                    break;
                case "trends_place":
                    if (reply[0] && 'trends' in reply[0])
                        items = reply[0].trends;
                    parser = parseTrends
                    break;
                case "search_tweets":
                    if ('statuses' in reply)
                        items = reply.statuses;
                    parser = parseTweet
                    break;
                case "followers_list":
                case "friends_list":
                    if ('users' in reply)
                        items = reply.users;
                    parser = parseUser
                    break;
                case "statuses_homeTimeline":
                case "statuses_mentionsTimeline":
                case "statuses_userTimeline":
                    items = reply;
                    parser = parseTweet
                    break;
                case "directMessages_events_list":
                case "directMessages_sent":
                    items = reply.events;
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
                    for(var k = i; k < length; k++){
                        items[k] = parser(items[k])
                        // add users from DM
                        if (items[k].sender_id) {
                            addUsersToModel(msg.conf.modelUsers, { "user_id": items[k].sender_id, "name": "", "screen_name": "", "avatar": "" })
                            addUsersToModel(msg.conf.modelUsers, { "user_id": items[k].recipient_id, "name": "", "screen_name": "", "avatar": "" })
                        }
                        // add users from tweets
                        if (items[k].user_id) {
                            addUsersToModel(msg.conf.modelUsers, { "user_id": items[k].user_id, "name": items[k].name, "screen_name": items[k].screen_name, "avatar": items[k].avatar })
                        }
                    }
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



            if (msg.modelDM){
                if (msg.modelDM && msg.modelDM.count) {
                    for (i = msg.modelDM.count-1; i >= 0; i--) {
                        msg.modelDM.remove(i)
                    }
                }
                console.log("DM DM DM DM DM " + msg.modelDMraw.count)
                msg.modelDM.sync();
            }

            if (msg.conf.modelUsers){
                var d = []
                var filter = []
                var incomplete = []
                for( i = 0; i < msg.conf.modelUsers.count; i++){
                    var item = msg.conf.modelUsers.get(i)
                    if (filter.indexOf(item.user_id) === -1){
                        if ( item.name === "")
                            incomplete.push(item.user_id)
                        d.push({
                                   "user_id": item.user_id,
                                   "name": item.name,
                                   "screen_name": item.screen_name,
                                   "avatar": item.avatar
                               })
                        filter.push(item.user_id)
                    }
                }
                msg.conf.modelUsers.clear();
                msg.conf.modelUsers.append(d)
                msg.conf.modelUsers.sync();
                console.log(incomplete.join(" JAME "))


            }

            WorkerScript.sendMessage({ 'success': true,  "action": msg.bgAction})
        });
    }
}



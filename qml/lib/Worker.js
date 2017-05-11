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
    var cb = new Fcodebird;
    cb.setUseProxy(false);
    if (msg.conf.THEME_LINK_COLOR){
        highlightColor = msg.conf.THEME_LINK_COLOR;
        console.log(JSON.stringify(msg.conf.THEME_LINK_COLOR))
        console.log(highlightColor)
    }

    if (msg.conf.OAUTH_CONSUMER_KEY && msg.conf.OAUTH_CONSUMER_SECRET ){
        cb.setConsumerKey(msg.conf.OAUTH_CONSUMER_KEY, msg.conf.OAUTH_CONSUMER_SECRET);
    }


    if (msg.conf.OAUTH_TOKEN && msg.conf.OAUTH_TOKEN_SECRET){
        cb.setToken(msg.conf.OAUTH_TOKEN, msg.conf.OAUTH_TOKEN_SECRET);
    }

    var sinceId;
    var maxId;
    var params;



    if (msg.action === 'statuses_homeTimeline' || msg.action === 'statuses_mentionsTimeline') {
        params = {"count":200}
        if (msg.model.count) {
            if (msg.mode === "append") {
                params['max_id'] = msg.model.get(msg.model.count-1).id
            }
            if (msg.mode === "prepend") {
                params['since_id'] = msg.model.get(0).id
            }
        } else {
            msg.mode = "append";
        }

        if (msg.model.count){
            console.log("First id: " + msg.model.get(0).id)
            console.log("Last id: " + msg.model.get(msg.model.count-1).id)
        }
        console.log("Mode: " + msg.mode)
        console.log(JSON.stringify(params))
        cb.__call(
                    msg.action,
                    params,
                    function (reply, rate, err) {
                        //msg.model.clear()
                        var length = reply.length
                        var i = 0;
                        if (msg.mode === "prepend") {
                            length--;
                        } else if (msg.mode === "append"){
                            i = msg.model.count === 0 ? 0 : 1 ;
                        }

                        for (i; i < length; i++) {
                            var tweet;

                            if (msg.mode === "append") {
                                tweet = parseTweet(reply[i])
                                msg.model.append(tweet)
                            }
                            if (msg.mode === "prepend") {
                                tweet = parseTweet(reply[length-i-1])
                                msg.model.insert(0, tweet)
                            }

                        }
                        msg.model.sync();
                        console.log(msg.model.count);
                        // console.log(JSON.stringify(err));
                    }
                    );
    }

    if (msg.action === 'statuses_update') {
        cb.__call(
                    msg.action,
                    msg.params,
                    function (reply, rate, err) {
                        if (reply){
                            //tweet = parseTweet(reply)
                            WorkerScript.sendMessage({ 'success': true,  "reply": reply})
                        }

                        //console.log(JSON.stringify(reply));
                        console.log(JSON.stringify(err));
                    }
                    );
    }




    if (msg.action === 'search_tweets') {
        var resetSearch = false;
        if (msg.mode === "resetSearch") {
            resetSearch = true;
            msg.mode = "append"
        }

        params = { "include_entities" : true, "result_type": "recent", "count" : 100}
        if (msg.params.q) {
            params['q'] = msg.params.q + " AND -filter:retweets AND -filter:replies"
        }
        if (msg.model.count && !resetSearch) {
            if (msg.mode === "append") {
                params['max_id'] = msg.model.get(msg.model.count-1).id
            }
            if (msg.mode === "prepend") {
                params['since_id'] = msg.model.get(0).id
            }
        } else {
            msg.mode = "append";
        }

        console.log('search_tweets '+JSON.stringify(params))

        cb.__call(
                    'search_tweets',
                    msg.params,
                    function (reply) {
                        if (!reply || !reply.statuses || !reply.statuses.length) {
                            return;
                        }

                        var i = 0;
                        if (msg.mode === "prepend") {
                            length--;
                        } else if (msg.mode === "append"){
                            i = 1;
                        }

                        if (resetSearch) {
                            i = 0;
                            while (reply.statuses.length < msg.model.count-1){
                                msg.model.remove(0)
                            }
                        }

                        for (i; i < reply.statuses.length; i++) {
                            var tweet;

                            if (msg.mode === "append") {
                                tweet = parseTweet(reply.statuses[i])
                                if (i < msg.model.count) {
                                    msg.model.set(i, tweet)
                                } else {
                                    msg.model.append(tweet)
                                }
                            }
                            if (msg.mode === "prepend") {
                                tweet = parseTweet(reply.statuses[length-i-1])
                                msg.model.insert(0, tweet)
                            }

                        }
                        msg.model.sync();
                        console.log(reply.statuses.length)
                        console.log(msg.model.count)
                        WorkerScript.sendMessage({
                                                     'success': true,
                                                     'action': "search",
                                                     "next_results": reply.search_metadata.next_results,
                                                     "refresh_url":reply.search_metadata.refresh_url
                                                 })
                    });


    }

    if (msg.action === 'directMessages' || msg.action === 'directMessages_sent') {
        console.log('directMessages '+JSON.stringify(msg))
        sinceId = false;
        maxId = false;
        params = {"include_entities":false, skip_status: true}
        if (msg.model.count) {
            params['max_id'] = msg.model.get(msg.model.count-1).id
        }
        var shownDMs = []
        console.log('directMessages '+JSON.stringify(params))
        cb.__call(
                    msg.action,
                    params,
                    function (reply, rate, err) {
                        var length = reply.length
                        console.log(length)
                        var i = 0;

                        for (i; i < length; i++) {
                            var tweet = {};
                            //console.log(JSON.stringify(reply[i]))
                            tweet = parseDM(reply[i], msg.action === 'directMessages_sent' ? false : true)
                            msg.model.append(tweet)
                            if (!shownDMs[tweet.screenName]) {
                                shownDMs[tweet.screenName] = true;
                                if (msg.viewModel)
                                    msg.viewModel.append(tweet)
                            }

                        }
                        msg.model.sync();
                        if(msg.viewModel)
                            msg.viewModel.sync();
                        console.log(msg.model.count);
                    }
                    );


    }

    if (msg.action === 'postTweet') {
        console.log('postTweet '+JSON.stringify(msg))
    }

    if (msg.action === 'oauth_requestToken') {
        cb.__call(
                    "oauth_requestToken",
                    {oauth_callback: "oob"},
                    function (reply,rate,err) {
                        if (err) {
                            WorkerScript.sendMessage({ 'success': false,  "msg": "error response or timeout exceeded" + err.error})
                        }
                        if (reply) {
                            // stores it
                            //WorkerScript.sendMessage({ 'success': true,  "token": reply.oauth_token, "token_secret":reply.oauth_token_secret})
                            cb.setToken(reply.oauth_token, reply.oauth_token_secret);
                            WorkerScript.sendMessage({ 'success': true,  "token": reply.oauth_token, "token_secret":reply.oauth_token_secret})

                            // gets the authorize screen URL
                            cb.__call(
                                        "oauth_authorize",
                                        {},
                                        function (auth_url) {
                                            WorkerScript.sendMessage({ 'success': true,  "url":auth_url})
                                            //window.codebird_auth = window.open(auth_url);
                                        }
                                        );
                        }
                    }
                    );
    }
    if (msg.action === 'oauth_accessToken') {
        cb.__call(
                    "oauth_accessToken",
                    {oauth_verifier: msg.oauth_verifier},
                    function (reply) {
                        cb.setToken(reply.oauth_token, reply.oauth_token_secret);
                        WorkerScript.sendMessage({ 'success': true,  "oauth_accessToken": true, "token": reply.oauth_token, "token_secret":reply.oauth_token_secret})
                    }
                    );
    }

    if (msg.action === 'users_show') {
        cb.__call(
                    "users_show",
                    {screen_name: msg.screen_name},
                    function (reply) {
                        WorkerScript.sendMessage({ 'success': true,  "reply": reply, "action": msg.action})
                    }
                    );
    }

    if (msg.action === "friendships_destroy" || msg.action ===  "friendships_create") {
        cb.__call(
                    msg.action,
                    {screen_name: msg.screen_name},
                    function (reply) {
                        WorkerScript.sendMessage({ 'success': true,  "reply": reply})
                    }
                    );
    }

    if (msg.action === "createConversation") {
        console.log("OPAAA " + msg.selectedId)
        var tl = findRelated(msg.mentions, [msg.selectedId]);
        msg.model.append(tl)
        msg.model.sync()
    }

    if (msg.bgAction){
        console.log("BG ACTION >" + msg.bgAction)
        console.log(JSON.stringify(msg.params))
        cb.__call(msg.bgAction, msg.params, function (reply) {
            console.log(JSON.stringify(reply))
            //WorkerScript.sendMessage({ 'success': true,  "reply": reply})
        });
    }

}



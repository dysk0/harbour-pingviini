Qt.include("codebird.js")
Qt.include("common.js")
var highlightColor = "#f00";

function showError(status, statusText) {
    console.log(status)
    console.log(statusText)
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
                            i = 1;
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
                        console.log(JSON.stringify(reply));
                        console.log(JSON.stringify(err));
                    }
                    );
    }




    if (msg.action === 'search_tweets') {

        sinceId = false;
        maxId = false;
        params = {}
        if (msg.params.q) {
            params['q'] = msg.params.q
        }

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

        console.log('search_tweets '+JSON.stringify(params))

        cb.__call(
                    'search_tweets',
                    msg.params,
                    function (reply) {

                        if (!reply || !reply.statuses || !reply.statuses.length) {
                            return;
                        }

                        console.log(JSON.stringify(reply.statuses))
                        var i = 0;
                        if (msg.mode === "prepend") {
                            length--;
                        } else if (msg.mode === "append"){
                            i = 1;
                        }

                        for (i; i < reply.statuses.length; i++) {
                            var tweet;

                            if (msg.mode === "append") {
                                tweet = parseTweet(reply.statuses[i])
                                msg.model.append(tweet)
                            }
                            if (msg.mode === "prepend") {
                                tweet = parseTweet(reply.statuses[length-i-1])
                                msg.model.insert(0, tweet)
                            }

                        }
                        msg.model.sync();
                        console.log(msg.model.count);

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

}



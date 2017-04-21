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
        console.log('search_tweets '+JSON.stringify(msg))
        sinceId = false;
        maxId = false;
        params = {"count":200}
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


        cb.__call(
                    msg.action,
                    msg.params,
                    function (reply, rate, err) {
                        var length = reply.length
                        console.log(length)
                        var i = 0;
                        if (msg.mode === "prepend") {
                            length--;
                        } else if (msg.mode === "append"){
                            i = 1;
                        }

                        /*for (i; i < length; i++) {
                            var tweet;

                            if (msg.mode === "append") {
                                tweet = parseTweet(reply[i])
                                msg.model.append(tweet)
                            }
                            if (msg.mode === "prepend") {
                                tweet = parseTweet(reply[length-i-1])
                                msg.model.insert(0, tweet)
                            }

                        }*/
                        msg.model.sync();
                        console.log(msg.model.count);
                    }
                    );


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

}
//WorkerScript.sendMessage({ 'reply': 'Mouse is at ' + message.x + ',' + message.y })


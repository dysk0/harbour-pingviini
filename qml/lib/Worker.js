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
            console.log(JSON.stringify(reply))
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
                    if (msg.model.count > 0){
                        i = 1;
                    }
                }
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
            //WorkerScript.sendMessage({ 'success': true,  "reply": reply})
        });
    }

    //var a = {"events":[{"type":"message_create","id":"883660746277695494","created_timestamp":"1499516114192","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"19210452","source_app_id":"268278","message_data":{"text":"https:\/\/t.co\/oLIVBvlEjp","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[{"url":"https:\/\/t.co\/oLIVBvlEjp","expanded_url":"https:\/\/twitter.com\/zribor\/status\/883587832065007617","display_url":"twitter.com\/zribor\/status\/\u2026","indices":[0,23]}]}}}},{"type":"message_create","id":"883600253898960899","created_timestamp":"1499501691685","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"14320917","message_data":{"text":" https:\/\/t.co\/8tfLrxjDwD","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[{"url":"https:\/\/t.co\/8tfLrxjDwD","expanded_url":"https:\/\/twitter.com\/messages\/media\/883600253898960899","display_url":"pic.twitter.com\/8tfLrxjDwD","indices":[1,24]}]},"attachment":{"type":"media","media":{"id":883600243442544640,"id_str":"883600243442544640","indices":[1,24],"media_url":"https:\/\/pbs.twimg.com\/dm_gif_preview\/883600243442544640\/d1DL1Ys9_33-wdtMeAxhwyOpRU84L9wb72Rtb8Bp1pUfDPCeVZ.jpg","media_url_https":"https:\/\/pbs.twimg.com\/dm_gif_preview\/883600243442544640\/d1DL1Ys9_33-wdtMeAxhwyOpRU84L9wb72Rtb8Bp1pUfDPCeVZ.jpg","url":"https:\/\/t.co\/8tfLrxjDwD","display_url":"pic.twitter.com\/8tfLrxjDwD","expanded_url":"https:\/\/twitter.com\/messages\/media\/883600253898960899","type":"animated_gif","sizes":{"medium":{"w":300,"h":160,"resize":"fit"},"thumb":{"w":150,"h":150,"resize":"crop"},"large":{"w":300,"h":160,"resize":"fit"},"small":{"w":300,"h":160,"resize":"fit"}},"video_info":{"aspect_ratio":[15,8],"variants":[{"bitrate":0,"content_type":"video\/mp4","url":"https:\/\/video.twimg.com\/dm_gif\/883600243442544640\/d1DL1Ys9_33-wdtMeAxhwyOpRU84L9wb72Rtb8Bp1pUfDPCeVZ.mp4"}]}}}}}},{"type":"message_create","id":"883599864650715142","created_timestamp":"1499501598881","message_create":{"target":{"recipient_id":"14320917"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"it will be back... :)","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883599733696102403","created_timestamp":"1499501567659","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"14320917","message_data":{"text":"Sorry to say it but I liked more the previous version :) there's no more the estimation for the month revenue :(","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883599092772941827","created_timestamp":"1499501414851","message_create":{"target":{"recipient_id":"14320917"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"i didn't have a much time to fix it... it happens only once","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883599023269191683","created_timestamp":"1499501398280","message_create":{"target":{"recipient_id":"14320917"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"yup just reopen it","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883598972602003460","created_timestamp":"1499501386200","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"14320917","message_data":{"text":"Reopened the app and seems ok","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883598906545901571","created_timestamp":"1499501370451","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"14320917","message_data":{"text":"It's probably because I used the functionality of the right menu","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883598751604117507","created_timestamp":"1499501333510","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"14320917","message_data":{"text":"Ok now it works, but there's something a bit messy https:\/\/t.co\/7oQEATko4e","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[{"url":"https:\/\/t.co\/7oQEATko4e","expanded_url":"https:\/\/twitter.com\/messages\/media\/883598751604117507","display_url":"pic.twitter.com\/7oQEATko4e","indices":[51,74]}]},"attachment":{"type":"media","media":{"id":883598736911413248,"id_str":"883598736911413248","indices":[51,74],"media_url":"https:\/\/ton.twitter.com\/1.1\/ton\/data\/dm\/883598751604117507\/883598736911413248\/4gAEDFnt.jpg","media_url_https":"https:\/\/ton.twitter.com\/1.1\/ton\/data\/dm\/883598751604117507\/883598736911413248\/4gAEDFnt.jpg","url":"https:\/\/t.co\/7oQEATko4e","display_url":"pic.twitter.com\/7oQEATko4e","expanded_url":"https:\/\/twitter.com\/messages\/media\/883598751604117507","type":"photo","sizes":{"small":{"w":340,"h":604,"resize":"fit"},"thumb":{"w":150,"h":150,"resize":"crop"},"medium":{"w":600,"h":1066,"resize":"fit"},"large":{"w":1024,"h":1820,"resize":"fit"}}}}}}},{"type":"message_create","id":"883598272211845123","created_timestamp":"1499501219214","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"14320917","message_data":{"text":"Oh ok let me try","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883598212879314947","created_timestamp":"1499501205068","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"14320917","message_data":{"text":"It looks like it found an account but there's nothing https:\/\/t.co\/8aBlrby5YN","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[{"url":"https:\/\/t.co\/8aBlrby5YN","expanded_url":"https:\/\/twitter.com\/messages\/media\/883598212879314947","display_url":"pic.twitter.com\/8aBlrby5YN","indices":[54,77]}]},"attachment":{"type":"media","media":{"id":883598199373656064,"id_str":"883598199373656064","indices":[54,77],"media_url":"https:\/\/ton.twitter.com\/1.1\/ton\/data\/dm\/883598212879314947\/883598199373656064\/VpEA9UDn.jpg","media_url_https":"https:\/\/ton.twitter.com\/1.1\/ton\/data\/dm\/883598212879314947\/883598199373656064\/VpEA9UDn.jpg","url":"https:\/\/t.co\/8aBlrby5YN","display_url":"pic.twitter.com\/8aBlrby5YN","expanded_url":"https:\/\/twitter.com\/messages\/media\/883598212879314947","type":"photo","sizes":{"small":{"w":340,"h":604,"resize":"fit"},"thumb":{"w":150,"h":150,"resize":"crop"},"medium":{"w":600,"h":1066,"resize":"fit"},"large":{"w":1024,"h":1820,"resize":"fit"}}}}}}},{"type":"message_create","id":"883598165966024707","created_timestamp":"1499501193883","message_create":{"target":{"recipient_id":"14320917"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"i forgot to remove that one","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883598121900679172","created_timestamp":"1499501183377","message_create":{"target":{"recipient_id":"14320917"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"add acoount with left menu misc \"Add Account\". But not with 3 dots menu on the right","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883597820665749507","created_timestamp":"1499501111557","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"14320917","message_data":{"text":"Yeah, nothing happens","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883597739833032707","created_timestamp":"1499501092285","message_create":{"target":{"recipient_id":"14320917"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"did you try to ad account by clicking on the add account?","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883597667858874373","created_timestamp":"1499501075125","message_create":{"target":{"recipient_id":"14320917"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"hi.","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883596904076017667","created_timestamp":"1499500893025","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"14320917","message_data":{"text":"Hi Dusko! After the last update nwallet doesn't work anymore. I already deleted and reinstalled but no luck","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883069000854495235","created_timestamp":"1499375031089","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"13405489","message_data":{"text":"Za pare ok, za kafu se javi i prije :)","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883040425086513158","created_timestamp":"1499368218095","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"2795891903","message_data":{"text":"Idem sutra da prebacim pare na svoj racun pa cu u ponedjeljak podici kes. Nisu jos uplatili ali to je moj problem. Ajd cujemo se i pijemo kafu...","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883040064388960260","created_timestamp":"1499368132098","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"2795891903","message_data":{"text":"Jesam, kuci sam...","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"883038238050586628","created_timestamp":"1499367696665","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"13310191","message_data":{"text":"Prezivio?","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"882636781333737475","created_timestamp":"1499271981925","message_create":{"target":{"recipient_id":"436493867"},"sender_id":"19210452","source_app_id":"13405489","message_data":{"text":"Tnx :)","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"882636733728292867","created_timestamp":"1499271970575","message_create":{"target":{"recipient_id":"436493867"},"sender_id":"19210452","source_app_id":"13405489","message_data":{"text":":) yeiii promotion :)","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"882623764621643783","created_timestamp":"1499268878499","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"436493867","message_data":{"text":"Yes we will. Thank you for developing Tooter \ud83d\ude03","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"882247319575506947","created_timestamp":"1499179127006","message_create":{"target":{"recipient_id":"436493867"},"sender_id":"19210452","source_app_id":"268278","message_data":{"text":"Hi there... Would you mind to retweet some of my tweets regarding #Tooter app for Sailfish OS?","entities":{"hashtags":[{"text":"Tooter","indices":[66,73]}],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881949746528649220","created_timestamp":"1499108180063","message_create":{"target":{"recipient_id":"14367815"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":":)","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881949742833561604","created_timestamp":"1499108179182","message_create":{"target":{"recipient_id":"14367815"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"posalj ponudu","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881949723577470979","created_timestamp":"1499108174591","message_create":{"target":{"recipient_id":"14367815"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"https:\/\/t.co\/XSUg3kvqVl","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[{"url":"https:\/\/t.co\/XSUg3kvqVl","expanded_url":"http:\/\/www.youngmeninitiative.net\/en\/?page=42&kat=1&vijest=428","display_url":"youngmeninitiative.net\/en\/?page=42&ka\u2026","indices":[0,23]}]}}}},{"type":"message_create","id":"881817544012824579","created_timestamp":"1499076660527","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"2795891903","message_data":{"text":"Ma da, ali nemam kada to napraviti jer de ja vracam kuci poslije isteka roka. A ovdje ne mogu na telefonu odraditi sta treba...","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881813051699322883","created_timestamp":"1499075589476","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"268278","message_data":{"text":"oni nisu duzni placati porez tako da si miran","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881812958388637699","created_timestamp":"1499075567229","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"268278","message_data":{"text":"ma treba ti samo finansijska ponuda i neke reference... prijavi se kao fizicko lice","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881812740008005635","created_timestamp":"1499075515163","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"2795891903","message_data":{"text":"E jebi ga prika, rok za ponude je 4. do 12h, a ja bi tek popodne taj dan trebao izaci. Nema sanse da mogu pripremiti sve sto traze...","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881808880191369219","created_timestamp":"1499074594911","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"13405489","message_data":{"text":"Polet jer je rok dan dva","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881808782929612803","created_timestamp":"1499074571722","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"13405489","message_data":{"text":"Limit je 4500","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881733150237499395","created_timestamp":"1499056539483","message_create":{"target":{"recipient_id":"19210452"},"sender_id":"2795891903","message_data":{"text":"Vazi, hajde pogledam pa se prijavim...","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881628984852795399","created_timestamp":"1499031704520","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"ne treba ti nista sem ok portfolija, cijene i cv-a","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881628825897119749","created_timestamp":"1499031666622","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"pogledaj ovo... ja cu se prijavljivati i staviti neku cifru oko 4k... Ti pogledaj i prijavi se i ti... pa koji prodje... Redovno placaju, sve je ok...","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}},{"type":"message_create","id":"881628616278278148","created_timestamp":"1499031616645","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"https:\/\/t.co\/XSUg3kvqVl","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[{"url":"https:\/\/t.co\/XSUg3kvqVl","expanded_url":"http:\/\/www.youngmeninitiative.net\/en\/?page=42&kat=1&vijest=428","display_url":"youngmeninitiative.net\/en\/?page=42&ka\u2026","indices":[0,23]}]}}}},{"type":"message_create","id":"881628611194867721","created_timestamp":"1499031615433","message_create":{"target":{"recipient_id":"2795891903"},"sender_id":"19210452","source_app_id":"557701","message_data":{"text":"stara","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]}}}}],"apps":{"557701":{"id":"557701","name":"Twitter for Mac","url":"http:\/\/itunes.apple.com\/us\/app\/twitter\/id409789998?mt=12"},"268278":{"id":"268278","name":"Twitter Web Client","url":"http:\/\/twitter.com"},"13310191":{"id":"13310191","name":"Pingviini","url":"https:\/\/www.grave-design.com\/pingviini-sailfish-os"},"13405489":{"id":"13405489","name":"Piepmatz","url":"https:\/\/github.com\/Wunderfitz\/harbour-piepmatz"}},"next_cursor":"ODgxNjI4NjExMTk0ODY3NzIx"};
    //WorkerScript.sendMessage({ 'directMessagesRaw': true,  "reply": a.events})
    /*if (msg.bgUpdate) {
        console.info("BG UPDATE")
        if (msg.modelRawDM){
            //
            var p = { count: 100, tweet_mode: "extended" }
            if (msg.params && msg.params.cursorDM)
                p["cursor"] = msg.params.cursorDM
            cb.__call(
                        "directMessages_events_list",
                        p,
                        function (reply, rate, err) {

                            console.log(JSON.stringify(reply));
                            console.log(JSON.stringify(err));

                            WorkerScript.sendMessage({ 'directMessagesRaw': true,  "reply": reply.events, "cursorDM" : reply.next_cursor})
                            //console.log(JSON.stringify(reply))
                        });
        }

        return;
    }*/

    /*

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

            msg.model.clear();
            msg.model.sync();

        }

        params = { "include_entities" : true, "result_type": "recent", count : 50, 'tweet_mode': "extended"}
        if (msg.params.q) {
            params['q'] = msg.params.q + " AND -filter:retweets "
        }
        if (msg.model.count && !resetSearch) {
            if (msg.mode === "append") {
                params['max_id'] = msg.model.get(msg.model.count-1).id
            }
            if (msg.mode === "prepend" && msg.model.count) {
                params['since_id'] = msg.model.get(0).id
            }
        } else {
            msg.mode = "append";
        }

        console.log('search_tweets '+JSON.stringify(params))

        cb.__call(
                    'search_tweets',
                    params,
                    function (reply) {
                        console.log('search_tweets '+JSON.stringify(reply.search_metadata))
                        if (!reply || !reply.statuses || !reply.statuses.length) {
                            return;
                        }

                        var i = 0;
                        var length = reply.statuses.length
                        console.log(length)
                        if (msg.mode === "prepend") {
                            length--;
                        } else if (msg.mode === "append"){
                            i = 1;
                        }

                        if (resetSearch) {
                            i = 0;
                            while (msg.model.count){
                                msg.model.remove(0)
                            }
                            msg.model.sync();
                        }

                        for (i; i < length; i++) {
                            var tweet;

                            if (msg.mode === "append") {
                                tweet = parseTweet(reply.statuses[i])
                                msg.model.append(tweet)
                            }
                            if (msg.mode === "prepend") {
                                console.log(length-i-1)
                                tweet = parseTweet(reply.statuses[length-i-1])
                                msg.model.insert(0, tweet)
                            }
                            if (msg.modelUsers)
                                msg.modelUsers.append({ "name": tweet.name, "id_str": tweet.userIdStr, "screen_name":  tweet.screenName, "avatar": tweet.profileImageUrl })

                        }
                        msg.model.sync();
                        if (msg.modelUsers)
                            msg.modelUsers.sync()
                        console.log(msg.model.count)
                        WorkerScript.sendMessage({
                                                     'success': true,
                                                     'action': "search",
                                                 })
                    });


    }

    if (msg.action === 'directMessages_events_list') {
        console.log('directMessages_events_list '+JSON.stringify(msg))
        params = { count: 50}
        if (msg.cursor !== ""){
            params['cursor'] = msg.cursor
        } else {
            msg.model.clear();
            msg.viewModel.clear();
        }

        var shownDMs = []
        console.log('directMessages_events_list '+JSON.stringify(params))
        cb.__call(
                    msg.action,
                    params,
                    function (reply, rate, err) {
                        console.log(JSON.stringify([rate.limit, rate.remaining, new Date(rate.reset*1000)]));
                        if ('errors' in reply) {
                            reply.errors.forEach(function(entry) {
                                WorkerScript.sendMessage({ 'error': true,  "message": entry.message})
                            });
                            console.log(JSON.stringify(reply.errors))
                        }

                        WorkerScript.sendMessage({ 'next_cursor': reply.next_cursor ? reply.next_cursor : "" } )


                        console.log(JSON.stringify(reply))
                        if (!reply.events)
                            return;
                        var length = reply.events.length
                        console.log(length)
                        var i = 0;

                        var uniqueUsers = [];
                        for (var msgs = 0;  msg.model.count >msgs; msgs++){
                            var  m = msg.model.get(msg)
                            uniqueUsers.push( m.sender_id +"-" + m.recipient_id)
                        }
                        console.log("PREV> " +JSON.stringify(uniqueUsers))


                        for (i; i < length; i++) {
                            var tweet = {};
                            //console.log(JSON.stringify(reply.events[i]))
                            tweet = parseDM(reply.events[i], false)
                            msg.model.append(tweet)
                            if(msg.viewModel){
                                if( uniqueUsers.indexOf(tweet.sender_id +"-"+tweet.recipient_id) > -1 || uniqueUsers.indexOf(tweet.recipient_id +"-"+tweet.sender_id) > -1 ) {
                                    console.log("IMA > "+tweet.sender_id +"-"+tweet.recipient_id)
                                } else {
                                    console.log("NEMA > "+tweet.sender_id +"-"+tweet.recipient_id)
                                    msg.viewModel.append(tweet);
                                    uniqueUsers.push(tweet.sender_id +"-"+tweet.recipient_id)
                                }
                            }
                        }
                        console.log("ALL> " +JSON.stringify(uniqueUsers))
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


*/

}



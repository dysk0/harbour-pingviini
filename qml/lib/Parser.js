Qt.include("common.js")

WorkerScript.onMessage = function(msg) {
    console.log('PARSER ///////////////////////////////////////////////////////////')
    console.log(JSON.stringify(msg))
    console.log('PARSER END///////////////////////////////////////////////////////////')
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
    }
}

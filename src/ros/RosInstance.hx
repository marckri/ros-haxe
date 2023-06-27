package ros;

import haxe.Json;
import haxe.net.WebSocket;
import ros.messages.CoreTypes;

class RosInstance {
    private var socket:WebSocket;
    private var subscribedTopics:Array<RosStorageTopicCallback> = [];
    private var serviceCallbacks:Array<RosStorageServiceCallback> = [];

    public function new(boot:Void -> Void, address:String) {
        socket = WebSocket.create(address);
        socket.onopen = boot;
        socket.onerror = err;
        socket.onmessageString = msg_handle;
    }
    public function updateSocket() {
        socket.process();
    }
    public function isOpen() {
        return (socket.readyState == ReadyState.Open);
    }

    public function subscribeTopic(topic:String, rate:Int, callb:Dynamic -> Void) {
        for (topicMatch in this.subscribedTopics){
            if(topicMatch.topic == topic){
                topicMatch.calls.push(callb);
                return;
            }         
        }
        var tmp:RosStorageTopicCallback = {topic: topic, calls: [callb]};
        this.subscribedTopics.push(tmp);
        var tmpMsg:RosGenericSubscribe = {
            op:"subscribe",
            topic:topic,
            throttle_rate:rate,
            queue_length:1
        }
        socket.sendString(Json.stringify(tmpMsg));
        return;
    }

    public function advertiseTopic(topicName:String, topicType:String){
        var tmpMsg:RosGenericAdvertise = {
            op: "advertise",
            topic: topicName,
            type: topicType
        }
        socket.sendString(Json.stringify(tmpMsg));
    }

    public function unadvertiseTopic(topicName:String){
        var tmpMsg:RosGenericUnadvertise = {
            op: "unadvertise",
            topic: topicName
        }
        socket.sendString(Json.stringify(tmpMsg));
    }

    public function publishTopic(topicName:String, topicMsg:Dynamic) {
        var tmpMsg:RosGenericPublish = {
            op: "publish",
            topic: topicName,
            msg: topicMsg
        }
        socket.sendString(Json.stringify(tmpMsg));
    }

    public function callService(serviceName:String, requestID:String, requestData:Dynamic, callbackFun:(Dynamic, String, Bool) -> Void) {
        this.serviceCallbacks.push({service: serviceName, id: requestID, callback: callbackFun});
        var tmpMsg:RosGenericCallService = {
            op: "call_service",
            id: requestID,
            service: serviceName,
            args: requestData
        }
        socket.sendString(Json.stringify(tmpMsg));
    }

    private function err(err_msg:Dynamic) {
        
    }
    private function msg_handle(msg:String) {
        var parsedMessage = Json.parse(msg);
        // Message of type topic
        if(parsedMessage.op == "publish"){
            for (topicMatch in this.subscribedTopics){
                if(topicMatch.topic == parsedMessage.topic){
                    for (clientCallback in topicMatch.calls){clientCallback(parsedMessage.msg);}
                }
            }
        }

        // Message of type service
        if(parsedMessage.op == "service_response"){
            var targetService = this.serviceCallbacks.filter((filterItem:RosStorageServiceCallback) -> {
                return ((filterItem.id == parsedMessage.id) && (filterItem.service == parsedMessage.service));
            })[0];
            targetService.callback(parsedMessage.values, parsedMessage.id, parsedMessage.result);
            this.serviceCallbacks.remove(targetService);
        }
    }
}
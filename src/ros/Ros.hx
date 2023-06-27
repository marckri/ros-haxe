package ros;
import haxe.Json;
import haxe.net.WebSocket;
import ros.messages.CoreTypes;

class Ros {
    private static var socket:WebSocket;
    private static var subscribedTopics:Array<RosStorageTopicCallback> = [];
    private static var serviceCallbacks:Array<RosStorageServiceCallback> = [];

    // -------------- Core Functions ---------------
    public static function initialize(boot:Void -> Void, address:String) {
        Ros.socket = WebSocket.create(address);
        Ros.socket.onopen = boot;
        Ros.socket.onerror = Ros.onError;
        Ros.socket.onmessageString = Ros.messageHandle;
    }

    public static function isOpen() {
        return (Ros.socket.readyState == ReadyState.Open);
    }

    public static function updateSocket() {
        Ros.socket.process();
    }

    private static function onError(error:String) {
        // TODO
    }

    private static function messageHandle(msg:String) {
        var parsedMessage = Json.parse(msg);
        // Topic messages handle
        if(parsedMessage.op == "publish"){
            for (topicMatch in Ros.subscribedTopics){
                if(topicMatch.topic == parsedMessage.topic){
                    for (clientCallback in topicMatch.calls){clientCallback(parsedMessage.msg);}
                }
            }
        }

        // Message of type service
        if(parsedMessage.op == "service_response"){
            var targetService = Ros.serviceCallbacks.filter((filterItem:RosStorageServiceCallback) -> {
                return ((filterItem.id == parsedMessage.id) && (filterItem.service == parsedMessage.service));
            })[0];
            targetService.callback(parsedMessage.values, parsedMessage.id, parsedMessage.result);
            Ros.serviceCallbacks.remove(targetService);
        }
    }

    // ----------------------------- ROS Topic Handles -------------------------------
    public static function advertiseTopic(topicName:String, topicType:String){
        var tmpMsg:RosGenericAdvertise = {op: "advertise", topic: topicName, type: topicType}
        Ros.socket.sendString(Json.stringify(tmpMsg));
    }

    public static function unadvertiseTopic(topicName:String){
        var tmpMsg:RosGenericUnadvertise = {op: "unadvertise", topic: topicName}
        Ros.socket.sendString(Json.stringify(tmpMsg));
    }

    public static function subscribeTopic(topic:String, rate:Int, callb:Dynamic -> Void) {
        for (topicMatch in Ros.subscribedTopics){
            if(topicMatch.topic == topic){
                topicMatch.calls.push(callb);
                return;
            }         
        }
        var tmp:RosStorageTopicCallback = {topic: topic, calls: [callb]};
        Ros.subscribedTopics.push(tmp);
        var tmpMsg:RosGenericSubscribe = {op:"subscribe", topic:topic, throttle_rate:rate, queue_length:1}
        socket.sendString(Json.stringify(tmpMsg));
    }

    public static function publishTopic(topicName:String, topicMsg:Dynamic) {
        var tmpMsg:RosGenericPublish = {op: "publish", topic: topicName, msg: topicMsg}
        socket.sendString(Json.stringify(tmpMsg));
    }

    // ------------------------------- ROS Service Handles ------------------------------------
    public static function callService(serviceName:String, requestID:String, requestData:Dynamic, callbackFun:(Dynamic, String, Bool) -> Void) {
        Ros.serviceCallbacks.push({service: serviceName, id: requestID, callback: callbackFun});
        var tmpMsg:RosGenericCallService = {op: "call_service", id: requestID, service: serviceName, args: requestData}
        socket.sendString(Json.stringify(tmpMsg));
    }
}
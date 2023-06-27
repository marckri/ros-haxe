package ros.messages;

typedef RosStorageTopicCallback = {
    var topic:String;
    var calls:Array<Dynamic -> Void>;
}
typedef RosStorageServiceCallback = {
    var service:String;
    var id:String;
    var callback:(Dynamic, String, Bool) -> Void;
} 

typedef RosGeneric = {
    var op:String;
}
typedef RosGenericPublish = {
    var op: String;
    var topic: String;
    var msg:Dynamic;
}
typedef RosGenericSubscribe = {
    var op: String;
    var topic: String;
    var throttle_rate: Int;
    var queue_length: Int;
}
typedef RosGenericAdvertise = {
    var op:String;
    var topic:String;
    var type:String;
}
typedef RosGenericUnadvertise = {
    var op:String;
    var topic:String;
}
typedef RosGenericCallService = {
    var op:String;
    var service:String;
    var id:String;
    var args:Dynamic;
}
typedef RosGenericServiceResponse = {
    var op:String;
    var id:String;
    var service:String;
    var ?values:Dynamic;
    var result:Bool;
}
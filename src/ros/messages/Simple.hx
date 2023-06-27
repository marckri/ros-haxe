package ros.messages;

typedef SimpleString = {
    var data:String;
}
typedef SimpleFloat64 = {
    var data:Float;
}
typedef SimpleFloat64Array = {
    var data:Array<Float>;
} 
typedef SimpleInt64 = {
    var data:Int;
}
typedef SimpleTime = {
    var sec:Int;
    var nanosec:Int;
}
typedef RosHeader = {
    var stamp:SimpleTime;
    var frame_id:String;
}
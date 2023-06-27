package ros.messages;
import ros.messages.Simple;

typedef Vector3 = {
    var x:Float;
    var y:Float;
    var z:Float;
}

typedef Twist = {
    var linear:Vector3;
    var angular:Vector3;
}

typedef JointTrajectoryPoint = {
    var positions:Array<Float>;
    var velocities:Array<Float>;
    var accelerations:Array<Float>;
    var effort:Array<Float>;
    var time_from_start:SimpleTime;
}

typedef JointTrajectory = {
    var header:RosHeader;
    var joint_names:Array<String>;
    var points:Array<JointTrajectoryPoint>;
}
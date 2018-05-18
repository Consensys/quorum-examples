var Permissions = artifacts.require("./Permissions.sol")


var perm;
var foundEvent = "NO";
var eventName = "";
var nodeId = 0;


var perm = Permissions.at("0xd9d64b7dc034fafdba5dc2902875a67b5d586420");

function printEvent (result){
	for (var i = 0; i < result.logs.length; i++) {
                var log = result.logs[i];
//              console.log(log);
                eventName = log.event;
                foundEvent = "YES";
                nodeId = log.args._nodeId;
        }
        if (foundEvent == "YES"){
                console.log("Yes. detected the event!!!!!" + eventName + "---" + nodeId);
        } else {
                console.log("No.Did not find the event !!!!!!");

        }
}
	perm.ProposeNode("ac6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef","true", "true") .then (function(result) {
	printEvent(result);
});
	perm.ProposeNode("dc6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef","true", "true") .then (function(result) {
	printEvent(result);
});
	perm.ApproveNode("ac6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef").then(function(result){
	printEvent(result);
})
	perm.ApproveNode("dc6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef") .then (function(result) {
	printEvent(result);
});
	perm.ProposeDeactivation("dc6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef").then(function(result){
	printEvent(result);
});
	perm.DeactivateNode("dc6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef").then(function(result){
	printEvent(result);
});
	perm.getNodeIndexForNode("dc6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef").then(function(result){
	console.log(result);
});


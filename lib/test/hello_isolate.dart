import 'dart:isolate';

void handleMessage(Message message) async {
  print("receiver:" + message.cmd);
  var count = 0;
  while (count < 5) {
    await Future.delayed(Duration(seconds: 3));
    message.sendPort.send("count $count");
    count++;
  }
}

void main() async {
  var port = ReceivePort("wolf");
  // var isolate = await Isolate.spawn(handleMessage, Message(port.sendPort, "start"));

  var isolate = Isolate(port.sendPort);

  port.listen((message) {
    print('sender: receive msg: $message');
  });

  isolate.controlPort.send("end");

  // isolate.ping(current.      ,response: "ack, I know you");
}

class Message {
  final SendPort sendPort;
  final String cmd;

  Message(this.sendPort, this.cmd);
}

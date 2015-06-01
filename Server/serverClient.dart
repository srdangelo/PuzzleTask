part of simple_http_server;


/* myClient and additional functions code from:
* http://stackoverflow.com/questions/25982796/sending-mass-push-message-from-server-to-client-in-dart-lang-using-web-socket-m
*/
class myClient {
  DateTime time = new DateTime.now();
  String clientID = "null";
  WebSocket _socket;

  myClient(WebSocket ws){
        _socket = ws;
        _socket.listen(messageHandler,
                       onError: errorHandler,
                       onDone: finishedHandler);
  }

  void write(String message){ _socket.add(message); }

  void messageHandler(String msg){
    // If user dragged a piece
    if(msg[0] == "d"){
      
      String tempMsg = msg.substring(2);
      List<String> data = tempMsg.split(",");
      myState.updateBox(num.parse(data[0]), num.parse(data[1]), num.parse(data[2]), data[3]);
      if (myState.dragcounter>=2){
        myState.checkPieceLocation(num.parse(data[0]));
        //myState.myBoxes[num.parse(data[0])-1].pieceLocation();
        //Data Recording format: time, trialSetNumber, trialNumber, box id, box x, box y, box name.
        time = new DateTime.now();
        //logData('${time},${trial.trialSetNum}, ${trial.trialNum}, ${data[0]}, ${data[1]}, ${data[2]}, ${data[3]},${data[4]} \n', 'clientData.csv');
        logData('${time},${trial.trialSetNum}, ${trial.trialNum}, ${data[0]}, ${data[1]}, ${data[2]}, ${data[3]},${data[4]} \n', 'gameStateData.csv');
        //print (tempMsg);
      }
    }
    // User found a pair of neighbors
    if (msg[0] == "n"){
      //print(msg);
      String tempMsg = msg.substring(2);
      List<String> data = tempMsg.split(",");
      myState.assignNeighbor(num.parse(data[0]), data[1], num.parse(data[2]));
      myState.calculateScore();
    }
    if (msg[0] == "c" && msg[1]!="o"){// touch down. Extra check because it could also be "connected"
          //print(msg);
          String tempMsg = msg.substring(2);
          List<String> data = tempMsg.split(",");
          print (data);
          time = new DateTime.now();
          logData('${time},${trial.trialSetNum}, ${trial.trialNum},${num.parse(data[0])}, Touch Down,,${data[1]},${data[2]}  \n', 'gameStateData.csv');
        }
    else if(msg[0] == "b"){//touch up
      String tempMsg = msg.substring(2);
      List<String> data = tempMsg.split(",");
      //print (data);
      myState.noDrag(num.parse(data[0]));
      time = new DateTime.now();
      logData('${time},${trial.trialSetNum}, ${trial.trialNum},${num.parse(data[0])}, Touch Up,,${data[1]},${data[2]} \n', 'gameStateData.csv');
    }
    else if (msg[0]=="s")//the client sends the stage to which they want to begin with
      {
      String tempMsg = msg.substring(2);
      List<String> data = tempMsg.split(",");
      
      if (num.parse(data[0])>=trial.assignOptions.length)
      {
        var alarmMsg='a:Number entered is too large';//a stands for alarm
        distributeMessage(alarmMsg);
        print(alarmMsg);
      }
      else if (num.parse(data[0])<0)
      {
        var alarmMsg='a:Number entered needs to be larger than 0';//a stands for alarm
        distributeMessage(alarmMsg);
        print(alarmMsg);
      }
      else if (num.parse(data[0])>=0&&num.parse(data[0])<trial.assignOptions.length){
        trial.setup([]);      
        trial.phase = 'BREAK';
        trial.phaseStarted=true;
        trial.phaseBreak = true;
        trial.phaseCongrats=false;
        trial.trialSetNum=num.parse(data[0]);
        //test set is 0. Other trials starts from 1
        trial.trialNum=0;
        trial.generateOrder();
        trial.transition();
        time = new DateTime.now();
        logData('${time},Stage ${data[0]} is chosen \n', 'gameStateData.csv');
      }
      else{
        var alarmMsg='a:Number entered is not a legal number';//a stands for alarm
        distributeMessage(alarmMsg);
        print(alarmMsg);
      }
    }
    else if (msg[0]=="I"){//sending over ID
      String tempMsg = msg.substring(2);
      List<String> data = tempMsg.split(",");
      clientID=data[0];
    }
    // send global data
    else if (msg[0]=="z"){
      print("MESSAGE RECEIVED AT Z");
      String tempMsg = msg.substring(2);
      List<String> data = tempMsg.split(",");
      time = new DateTime.now();
      logData('${time}, ${trial.trialSetNum}, ${trial.trialNum}, ${clientID}, ${data[0]}, \n', 'globalData.csv');
    }
  }

  void errorHandler(error){
     print('one socket got error: $error');
     removeClient(this);
    _socket.close();
  }

  void finishedHandler() {
    print('one socket had been closed');
    distributeMessage('one socket had been closed');
    removeClient(this);
    _socket.close();
  }
}
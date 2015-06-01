part of remotepuzzletask;

//client game class, allows us to draw images and create touch layers.
class Game extends TouchLayer{


  // this is the HTML canvas element
  CanvasElement canvas;
  
  ImageElement img = new ImageElement();

  // this object is what you use to draw on the canvas
  CanvasRenderingContext2D ctx;


  // width and height of the canvas
  int width, height;
  // The current state of the puzzle
  State myState;
  Box box;

  TouchManager tmanager = new TouchManager();
  TouchLayer tlayer = new TouchLayer();

  var score;
  var phaseBreak='false';
  var phaseCongrats='false';
  var phaseStarted='false';//Indicates that the server just started
  var phaseEnd='false';//Indicated that user finished the trial
  var clientID;
  var trialNum;
  var time=new DateTime.now();
  var time_started=new DateTime.now();
  bool flagDraw = true; //Only draw when this flag is true
  bool submittedID=false; //Whether the user has submitted their id

  Game() {
    canvas = querySelector("#game");
    ctx = canvas.getContext('2d');
    width = canvas.width;
    height = canvas.height;
    time=new DateTime.now();
    time_started=new DateTime.now();
    tmanager.registerEvents(document.documentElement);
    tmanager.addTouchLayer(this);
    
    myState = new State(this);
    drawWelcome();
    window.animationFrame.then(animate);

  }


//**
// * Animate all of the game objects makes things movie without an event
// */
  void animate(double i) {
    window.animationFrame.then(animate);
//    ws.onMessage.listen((MessageEvent e) {
//      //print (e.data);
//      handleMsg(e.data);
//    });
    draw();

  }


//**
// * Draws programming blocks
// */
  void draw() {
    if (flagDraw){
      if (phaseStarted=='false'){//If user hasn't inputted their trial choice
        flagDraw=false;
        return;
      }
      else if (phaseEnd=='true'){//If user finished all trials
        clear();
        ctx.fillStyle = 'black';
        ctx.font = '30px sans-serif';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'center';
        ctx.fillText("Gaze Experimentt: Client# ${clientID} Trial# ${trialNum}", 100, 50);
        //ctx.fillText("Score: ${score}", 100, 100);
        ctx.fillText("Congratuations! You have finished the experiment :)", 100, 150); 
        //flagDraw=false;
      }
      else{
        clear();
        if (phaseBreak == 'false'){
                if (phaseCongrats=='true'){
                  ctx.fillStyle = 'black';
                  ctx.font = '30px sans-serif';
                  ctx.textAlign = 'left';
                  ctx.textBaseline = 'center';
                  ctx.fillText("Gaze Experiment: Client# ${clientID} Trial# ${trialNum}", 100, 50);
                  ctx.fillText("Score: ${score}", 100, 100);
                  ctx.fillText("Congratuations! You have passed this trial.", 100, 150);
                  for(Box box in myState.myBoxes){
                    box.draw(ctx);
                  }
                  flagDraw = false;
                }
                else{
                  time=new DateTime.now();
                  ctx.fillStyle = 'black';
                  ctx.font = '30px sans-serif';
                  ctx.textAlign = 'left';
                  ctx.textBaseline = 'center';
                  ctx.fillText("Gaze Experiment: Client# ${clientID} Trial# ${trialNum}", 100, 50);
                  ctx.fillText("Score: ${score}  Time(Seconds): ${time.difference(time_started).inSeconds}", 100, 100);
                  
                  for(Box box in myState.myBoxes){
                    box.draw(ctx);
                  }
                  flagDraw = false;          
                }
       }
       else if (phaseBreak == 'true'){
        time_started=new DateTime.now();
        ctx.fillStyle = 'black';
        ctx.font = '30px sans-serif';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'center';
        ctx.fillText("Take a 5 second break! The trial will start automatically.", 100, 50);
       }
            }
      }
  }
//**
// * Draw the welcomg screen on canvas
// */
  void drawWelcome(){
    InputElement inputStage,inputID;
    ButtonElement submitButton,submitIDButton;
    //Helper function
    void removeElements(){
          new Timer(const Duration(microseconds :500 ), () {
                        if (phaseStarted=="true"){
                          submitButton.remove();
                          inputStage.remove();
                          inputID.remove();
                          submitIDButton.remove();
//                          replayButton.remove();
                        }
                        else removeElements();
                      });
        }
    //Main function
    if (phaseStarted==false || phaseStarted=='false'){
      clear();
      ctx.fillStyle = 'black';
      ctx.font = '30px sans-serif';
      ctx.textAlign = 'left';
      ctx.textBaseline = 'center';
      ctx.fillText("Gaze Experiment: Client# ${clientID} Trial# ${trialNum}", 100, 50);
            ctx.fillText("Instructions: For this experiment you will be building a puzzle with a partner.", 100, 150);
            ctx.fillText("Both you and your partner must simultaneously drag neighboring pieces next to each other to combine.", 100, 200);
            ctx.fillText("Score: If you correctly combine pieces you will earn 10 points. If you incorrectly move pieces you will lose 10 points.", 100, 300);
            ctx.fillText("Goal: Complete the puzzle quickly and earn points.", 100, 400);
            ctx.fillText("For Experimenter:", 100, 525);
      //stage input stuff
      inputStage=new InputElement();
      inputStage.style
        ..position='absolute'
        ..left="100px"
        ..top="650px"
        ..font='30px sans-serif';
      inputStage.value="1";
      document.body.nodes.add(inputStage);
      
      submitButton=new ButtonElement();
      submitButton.style
        ..position='absolute'
        ..left="100px"
        ..top="700px"
        ..font='30px sans-serif';
      submitButton.text="Submit Trial Number";
      var click_submit=submitButton.onClick.listen((event)
          {
            if (submittedID)
                ws.send("s:${(inputStage.value)}");
            else
              window.alert("Enter ID Number First!");
          });
      document.body.nodes.add(submitButton);
      //the id input stuff
      inputID=new InputElement();
            inputID.style
              ..position='absolute'
              ..left="100px"
              ..top="550px"
              ..font='30px sans-serif';
            inputID.value="1";
            document.body.nodes.add(inputID);
            
            submitIDButton=new ButtonElement();
            submitIDButton.style
              ..position='absolute'
              ..left="100px"
              ..top="600px"
              ..font='30px sans-serif';
            submitIDButton.text="Submit ID Number";
            var click_submit_ID=submitIDButton.onClick.listen((event)
                {
                  ws.send("I:${(inputID.value)}");
                  clientID=inputID.value.toString();
                  submittedID=true;
                });
            document.body.nodes.add(submitIDButton);
      }
    removeElements();
    
    }
    // Erase everything on canvas (except for the buttons, which needs to be removed by removeElements()
    void clear(){
      ctx.save();
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, width, height);
      ctx.restore();
    }
  
    //parse incoming messages
    handleMsg(data){
      print(data);
      flagDraw = true;
      //'u' message indicates a state update
      if(data[0] == "u"){
        //split up the message via each object
        List<String> objectsData = data.substring(2).split(";");
        for(String object in objectsData){
          //parse each object data and pass to state.
          List<String> data = object.split(",");
          if(data.length > 3){
            myState.updateBox(num.parse(data[0]), num.parse(data[1]), num.parse(data[2]), data[3]);
          }
        }
      }
      if (data[0] == "s"){//score
        score = data.substring(2);
      }
      if (data[0] == "p"){//phase info
        List<String> phaseData = data.substring(2).split(",");
        if (phaseData.length>=4){
           phaseStarted=phaseData[0];
           phaseBreak = phaseData[1];
           phaseCongrats=phaseData[2];
           phaseEnd=phaseData[3];
        }
      }
      if (data[0] == "i"){// Client number and trial chosen
        String tempMsg = data.substring(2);
        List<String> temp = tempMsg.split(",");
        clientID = temp[0];
        if (trialNum!=temp[1])
          myState=new State(this);
        trialNum = temp[1];
        
    }
      if (data[0]=="a"){//alarm
        String tempMsg = data.substring(2);
        window.alert(tempMsg);
      }
      draw();
  }
}

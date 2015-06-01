part of simple_http_server;

//State class manages all the object including motion, and most likely any interactions
//This state will be mirrored by the State class on the client
class State{

  DateTime time = new DateTime.now();

  //List of all objects in the scene that need to be communicated
  List<Box> myBoxes;

  var score = 0;//Score of the users
  var lastCount=0;
  var potential=2;//Potential is how many dragging one could do before getting their points deducted.
  var lastPotential=2;
  var dragcounter=0;//Count how many users are dragging. Currently pieces only move when both user drag
  var passedTest=false;
  State(){
    passedTest=false;
    myBoxes = new List<Box>();
  }


  //add object
  addBox(Box newBox){
    myBoxes.add(newBox);
    lastCount++;
  }


  //Update State will be run in timed intervals setup in the Main();
  updateState(){
    for(Box box in myBoxes){

      //dont move if being dragged
      if(!box.dragged){

        //random movement
        //box.x = box.x + random.nextInt(15) * (1 - 2*random.nextDouble()).round();
        //box.y = box.y + random.nextInt(15) * (1 - 2*random.nextDouble()).round();
        
        if (box.parentGroup==null)//only move the leading box in the group
        {
          for (Box boxtemp in myBoxes)
            boxtemp.moved=false;
          //box.moveAround();
          
        }
        

        //keep movement within the bounds 1570x780 hardcoded for now
        if(box.x < 0){
          box.x = box.x * -1;
        }
        else if(box.x > 1570){
          box.x = box.x -15;
        }

        if(box.y < 0){
          box.y = box.y * -1;
        }
        else if(box.y > 780){
          box.y = box.y -15;
        }
      }
    }
    sendState();

  }

  //Send state to all the clients, comes in the form of [object id, x, y, color]
  sendState(){
    String msg = "u:";
    for(Box box in myBoxes){
      msg = msg + "${box.id},${box.x},${box.y},${box.color};";
    }
    distributeMessage(msg);
    sendID();
    String phaseBreak = "p:${trial.phaseStarted},${trial.phaseBreak},${trial.phaseCongrats},${trial.phaseEnd}";
    distributeMessage(phaseBreak);
    //**********************
    //Timeout feature. If time exceeds 720 seconds for one trial
    time= new DateTime.now();
    if ((trial.phase=='CONGRATS'||trial.phase=='END') &&(!trial.phaseEnd) && (time.difference(trial.timer))>=const Duration(seconds : 720)){
      print('Time Out! Moving On');
      logData(' ${time}, ${trial.trialSetNum}, ${trial.trialNum}, ${clients[0].clientID}, Time Out! \n', 'globalData.csv');
      if ((trial.trialNum)>=trial.order.length){
        trial.phase='END';
      }
      else{
        trial.phase='BREAK';
      }
      trial.transition();
    }
    //**********************
  }

  //simple command to toggle the dragging interaction
  noDrag(num id){
    Box boxNolongerDragged=myBoxes[id-1];
    if (boxNolongerDragged.dragged==true){
      dragcounter--;
    }
    boxNolongerDragged.dragged=false;
    potential-=1;
    calculateScore();
    return;
}

  //if a object is dragged, this is called when the 'd' command is recieved
  updateBox(num id, num x, num y, String color){
    bool found = false;
    for(Box box in myBoxes){
      if(id == box.id){        
        found = true;
        if (box.dragged==false){
          dragcounter++;
        }
        if (dragcounter>=2 && !passedTest){
          box.move(x, y);
        }        
        box.color = color;
        box.dragged = true;
      }
    }
    if(found == false){
      Box temp = new Box(id, x, y, color);
      myBoxes.add(temp);
    }
    for (Box box in myBoxes){
      box.moved=false;
    }
  }
  
  assignNeighbor (num id, String side, num neighbor){
    for(Box box in myBoxes){
      if(id == box.id){
        if (side == 'right'){
          box.rightNeighbor = myBoxes[neighbor - 1];
          box.rightNeighbor.leftNeighbor=box;
          assignParent(box,box.rightNeighbor);
        }
        if (side == 'left'){
          box.leftNeighbor = myBoxes[neighbor - 1];
          box.leftNeighbor.rightNeighbor=box;
          assignParent(box.leftNeighbor,box);
        }
        if (side == 'upper'){
          box.upperNeighbor = myBoxes[neighbor - 1];
          box.upperNeighbor.lowerNeighbor=box;
          assignParent(box,box.upperNeighbor);
        }
        if (side == 'lower'){
          box.lowerNeighbor = myBoxes[neighbor - 1];
          box.lowerNeighbor.upperNeighbor=box;
          assignParent(box.lowerNeighbor,box);
       }
      }
    }
    potential+=2;//Add 2 to the potential for every successful neighbor assignment.
  }
  
  assignParent (Box box1, Box box2){
    //assign box2's group as box1 if box1 has no parent
    //otherwise, assign box2's group as box1's parent group
    if (box1.parentGroup==null){//box1 is a root
      if (box2.parentGroup==null)//if box2 is a root
      {
        if (box1!=box2)//check to make sure these two are not the same box 
        {
          box2.parentGroup=box1;
                  print('parent:'+box1.id.toString());
        }
        //else do nothing
      }
        
      else
      {
        //if box2 belongs to some group
        assignParent(box1,box2.parentGroup);
      }
    }
    else//box1 belongs to some group
    {
      if (box2.parentGroup==null)//if box2 is a root
        assignParent(box1.parentGroup,box2);
      else
      {
        //if both box1 and box2 belongs to some group
        assignParent(box1.parentGroup,box2.parentGroup);
      }
    }
  }
  //Calculate the scores for the game. 
  calculateScore(){
      int count=0;
      for(Box box in myBoxes){
        if (box.parentGroup==null)
        {
          count++;
        }
      }
      if (count!=lastCount){
        score+=(lastCount-count)*20;
        lastCount=count;
      }
      if (count==1 && myBoxes.length>0 && !passedTest){
        passedTest=true;
        myBoxes[0].moved=false;
        myBoxes[0].move(myBoxes[0].x, myBoxes[0].y);
        for (Box box in myBoxes){
          box.moved=true;
        }
        //Waiting for 500ms because we want to have every piece attached to each other
        //before we move to next stage
        new Timer(new Duration(milliseconds: 500),()=>trial.transition());
        print("Solved Puzzle!");
      }
      if (potential!=lastPotential){
        if (potential<0){
          score+=(potential-lastPotential)*10;//deduct points when potential becomes negative
          potential=0;
          lastPotential=0;
        }
        else{
          lastPotential=potential;
        }
      }
      var sendScore = "s: ${score} \n";
      distributeMessage(sendScore);
      //Record scores
      time= new DateTime.now();
      if (!passedTest){
        logData('${time},${trial.trialSetNum}, ${trial.trialNum}, ,'
                        +', , ,'
                        +', , ,${score} \n'
                        , 'gameStateData.csv');
      }
      else if (passedTest){
        logData('${time},${trial.trialSetNum}, ${trial.trialNum}, ,Final Score:'
                        +', , ,'
                        +', , ,${score} \n'
                        , 'gameStateData.csv');
      }
    }
  //Function to assign buddies. Assuming the puzzle will always be a square
  assignBuddies(){
    int myBoxesLength=myBoxes.length;
    int myBoxesLengthSqrt=sqrt(myBoxesLength).toInt();
    if (myBoxesLengthSqrt*myBoxesLengthSqrt!=myBoxesLength){
      print("Error, input is not a square");
      return;
    }
    for(Box box in myBoxes){
      int i = myBoxes.indexOf(box);
      if (i % myBoxesLengthSqrt== 0){
        box.rightBuddy = myBoxes[i + 1];
      }
      else if (i % myBoxesLengthSqrt == myBoxesLengthSqrt - 1){
        box.leftBuddy = myBoxes[i - 1];
      }
      else {
        box.leftBuddy = myBoxes[i - 1];
        box.rightBuddy = myBoxes[i + 1];
      }
      if (i/myBoxesLengthSqrt<1){
        box.lowerBuddy= myBoxes[i+myBoxesLengthSqrt];
      }
      else if (i/myBoxesLengthSqrt>=myBoxesLengthSqrt-1){
        box.upperBuddy= myBoxes[i-myBoxesLengthSqrt];
      }
      else{
        box.lowerBuddy= myBoxes[i+myBoxesLengthSqrt];
        box.upperBuddy= myBoxes[i-myBoxesLengthSqrt];
    }
  }
  }
  checkPieceLocation(num id){
    Box boxDragged = myBoxes[id-1];
    boxDragged.pieceLocation();
  }
  
}

part of simple_http_server;

//Box class, acting as general object
class Box{
  num x;
  num y;
  var color;
  num id;
  bool dragged;
  bool moved;//Used to record which box has moved (used in dragging and moveAround)
  num gl_newX = random.nextInt(400);//Not activated now. Used to generate direction of movement for puzzles
  num gl_newY = random.nextInt(400);
  
  
  //Image image;
  //Hard coded width and height here. The server cannot access image so...
  //That's the solution for now.
  num imageWidth=100;
  num imageHeight=100;
  // Neighbors means the puzzle pieces they're currently attached to.
  Box rightNeighbor = null;
  Box leftNeighbor = null;
  Box upperNeighbor = null;
  Box lowerNeighbor = null;
  // Buddies means the puzzle pieces one are SUPPOSED to be attached to.
  Box rightBuddy = null;
  Box leftBuddy = null;
  Box upperBuddy = null;
  Box lowerBuddy = null;
  
  Box parentGroup=null;//used to group boxes when they are connected to each other
  Box(this.id, this.x, this.y, this.color){
    dragged = false;//Flag for whether the piece is dragged by user
    //Flag for whether the piece has moved because either it's dragged 
    // or it's attached to a dragged piece
    moved=false;
  }
  // Function to handle moving a piece to coordinates(dx,dy)
  // Then move all pieces attached to it(all pieces belong to the same group)
  void move(num dx, num dy) {
    x = dx;
    y = dy;
    //run recursively to move all boxes that are neighbors of the moved box
    if (leftNeighbor != null &&leftNeighbor.moved==false){
      leftNeighbor.moved=true;
      leftNeighbor.move(dx-imageWidth, dy);
    }
    if (rightNeighbor != null&&rightNeighbor.moved==false){
      rightNeighbor.moved=true;
      rightNeighbor.move(dx+imageWidth, dy);
    }
    if (upperNeighbor != null && upperNeighbor.moved==false){
      upperNeighbor.moved=true;
      upperNeighbor.move(dx, dy+imageHeight);
    }
    if (lowerNeighbor != null &&lowerNeighbor.moved==false){
      lowerNeighbor.moved=true;
      lowerNeighbor.move(dx, dy-imageHeight);
    }
  }
  // Function used to handle random movements for puzzle pieces. 
  // Currently this feature is not activated
  void moveAround(){
        var dist = sqrt(pow((gl_newX - this.x), 2) + pow((gl_newY - this.y), 2));
        num head = atan2((gl_newY - this.y), (gl_newX - this.x));

        if(dist >= 1){
          num targetX = cos(head) + this.x;
          num targetY = sin(head) + this.y;
          move(targetX, targetY);
          }
        else{
          num targetX = (cos(head) * dist) + this.x;
          num targetY = (sin(head) * dist) + this.y;
          move(targetX, targetY);

          gl_newX = random.nextInt(1200);
          gl_newY = random.nextInt(800);
          //change to game width and hieght
          try{
            var time = new DateTime.now();
            logData('${time},${trial.trialSetNum}, ${trial.trialNum}, ${this.id}, ${this.x}, ${this.y}, ${this.color},'
            +',${this.gl_newX}, ${this.gl_newY} \n'
            , 'gameStateData.csv');
          }
          catch (exception,stacktrace){
            print(exception);
            print(stacktrace);
          }
        }

  }
  //return the root of the group to which box belongs
  Box getParent(){
    if (this.parentGroup==null)
      return this;
    else return this.parentGroup.getParent();
  }
  //called whenever the puzzle piece is moved
  //check whether it is close to some of its 'buddies'. If so, attach them to each other 
  //and add them to each other's neighbors list
  void pieceLocation ()
    {
      var success=false;
      num distance = 20;
      Box box=this;
      imageWidth=100;
      imageHeight=100;
        //When the boxes touch each other
        //assign the Neighbors according to the predetermined pattern.
        if (box.rightBuddy != null && box.rightNeighbor==null){
          if (box.rightBuddy.x - imageWidth - box.x < distance &&
              box.rightBuddy.x - imageWidth - box.x > -distance &&
              box.rightBuddy.y - box.y < distance &&
              box.rightBuddy.y - box.y > -distance &&
              box.rightBuddy.dragged==true&&box.dragged==true){
             box.rightNeighbor = box.rightBuddy;
             box.rightBuddy.leftNeighbor = box;
             print ('right neighbors!');
             success=true;
             myState.assignNeighbor(box.id, 'right', box.rightNeighbor.id);
             myState.calculateScore();
             
          }
        }
        if (box.leftBuddy != null && box.leftNeighbor==null){
          if (box.leftBuddy.x + imageWidth - box.x < distance &&
              box.leftBuddy.x + imageWidth - box.x > -distance &&
              box.leftBuddy.y - box.y < distance &&
              box.leftBuddy.y - box.y > -distance&&
              box.leftBuddy.dragged==true&&box.dragged==true){
             box.leftNeighbor = box.leftBuddy;
             box.leftBuddy.rightNeighbor = box;
             print ('left neighbors!');
             success=true;
             myState.assignNeighbor(box.id, 'left', box.leftNeighbor.id);
             myState.calculateScore();
          }
        }
        if (box.upperBuddy != null && box.upperNeighbor==null){
          if (box.upperBuddy.x - box.x < distance &&
              box.upperBuddy.x - box.x > -distance &&
              box.upperBuddy.y - imageWidth - box.y < distance &&
              box.upperBuddy.y - imageWidth - box.y > -distance&&
              box.upperBuddy.dragged==true&&box.dragged==true){
             box.upperNeighbor = box.upperBuddy;
             box.upperBuddy.lowerNeighbor = box;
             print ('upper neighbors!');
             success=true;
             myState.assignNeighbor(box.id, 'upper', box.upperNeighbor.id);
             myState.calculateScore();
          }
        }
        if (box.lowerBuddy != null && box.lowerNeighbor==null){
          if (box.lowerBuddy.x - box.x < distance &&
              box.lowerBuddy.x - box.x > -distance &&
              box.lowerBuddy.y + imageWidth - box.y < distance &&
              box.lowerBuddy.y + imageWidth - box.y > -distance&&
              box.lowerBuddy.dragged==true&&box.dragged==true){
             box.lowerNeighbor = box.lowerBuddy;
             box.lowerBuddy.upperNeighbor = box;
             print ('lower neighbors!');
             success=true;
             myState.assignNeighbor(box.id, 'lower', box.lowerNeighbor.id);
             myState.calculateScore();
          }
        }
      }
}


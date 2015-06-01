part of remotepuzzletask;

//client state class, doesn't need update or send state, just need to keep track of objects via updateBox()
class State{
  Game boxGame;
  List<Box> myBoxes;
  State(game){
    boxGame = game;
    myBoxes = new List<Box>();
  }

  addBox(Box newBox){
    myBoxes.add(newBox);
  }

  updateState(){
  }

  sendState(){
  }
  //Called when we receive a message from the server
  //indicating where each piece is
  updateBox(num id, num x, num y, String color){
    bool found = false;
    
    for(Box box in myBoxes){
      if(id == box.id){
        box.x = x;
        box.y = y;
        box.color = color;
        found = true;
      }
    }

    //if new box, create new object and add to touchables
    if(found == false){
      Box temp = new Box(id, x, y, color);
      boxGame.touchables.add(temp);
      myBoxes.add(temp);
    }
  }



}


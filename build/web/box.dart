
part of remotepuzzletask;

//object class, unlike server, this one is touchable but otherwise has the same properties
class Box implements Touchable{
  //Similar data structure as the Box class in the server files
  num x;
  num y;
  var color;
  num id;
  bool dragged;
  int imageWidth;
  int imageHeight;
  
  num touched_x_offset;
  num touched_y_offset;
  
  ImageElement img = new ImageElement();
  
  Box rightBuddy = null;
  Box leftBuddy = null;
  Box upperBuddy = null;
  Box lowerBuddy = null;
  Box leftNeighbor = null;
  Box rightNeighbor = null;
  Box upperNeighbor = null;
  Box lowerNeighbor = null;
  
  
  Timer dragTimer;

  Box(this.id, this.x, this.y, this.color){
    dragged= false;
    img.src = "images/${this.color}.png";
    imageWidth=img.width;
    imageHeight=img.height;
  }

  //when this object is dragged, send a 'd' message with id, x, y, color
  sendDrag(num newX, num newY){

    if (rightNeighbor != null && leftNeighbor != null){
      //ws.send("d:${id},${newX},${newY},${color},${leftNeighbor.color},${rightNeighbor.color}, Client#${game.clientID}");
      ws.send("d:${id},${newX},${newY},${color}, ${game.clientID}");
    }
    else {
      ws.send("d:${id},${newX},${newY},${color}, ${game.clientID}");
    }
    //
    }

  // If the mouse is on this puzzle piece
  bool containsTouch(Contact e) {
    if((e.touchX > x && e.touchX  < x +img.width) && 
      (e.touchY > y && e.touchY < y + img.height)){
        return true;
      }
    return false;
  }
  // Called when the user is dragging this piece
  bool touchDown(Contact e) {
    dragged = true;
    touched_x_offset=x-e.touchX;
    touched_y_offset=y-e.touchY;
    ws.send("c:${id}, ${color}, ${game.clientID}");
    return true;
  }
  // Called when the user lets go
  void touchUp(Contact event) {
    dragged = false;
    try{
          //dragTimer.cancel();
    }
    catch(exception){
          print(exception);
    }
    ws.send("b:${id}, ${color}, ${game.clientID}");
  }
  
  void touchDrag(Contact e) {
    //since touchUp has issues it impacts touchDrag so have extra bool to makes sure this are being dragged
    if(dragged){
      sendDrag(touched_x_offset+ e.touchX,touched_y_offset+ e.touchY);
      //print(e.touchX);
    }
  }

  void touchSlide(Contact event) { }







  
  void draw(CanvasRenderingContext2D ctx){
    ctx.save();
    {
    num boxWidth = img.width;
    num boxHeight = img.height;
    ctx.translate(x, y);
    ctx.drawImage(img, 0, 0);
    }
    ctx.restore();
  }

}


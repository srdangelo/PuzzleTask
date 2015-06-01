part of simple_http_server;

class Trial{
  var phase = 'Start';
  num trialSetNum = -1;
  num trialNum = -1;
  bool phaseStarted = false; //Whether we're in the intro stage(where we enter information)
  bool phaseBreak = false; //Whether we're taking a break between each stage
  bool phaseCongrats = false; //Whether we're stopping for a while to let the user 
  //                            see the full puzzle before they continue
  bool phaseEnd = false; //Whether we've reached the end of the trial
  var timer=new DateTime.now();
  // record the name of all pictures that may be used
  // list all the options of orders that the puzzles will be displayed
  List<List> assignOptions = [[24],
                              [1, 3, 14,15], 
                               [2,11,17,18], 
                               [5,6,13,21],
                               [3,1,15,14],
                               [11,2,18,17],
                               [6,5,21,13]];
  List<String> picName=['easy1','easy2',
                        'easy3','easy4',
                        'easy5','easy6',
                        'easy7','easy8',
                        'easy9','easy10',
                        'easy11','easy12',
                         'plaid1','plaid2','plaid3',
                         'plaid4','plaid5','plaid6',
                         'plaid7','plaid8','plaid9',
                         'plaid10','plaid11','plaid12',
                         'octopus'];
  List<List> order = [['world_21','world_22','world_23','world_24','world_25',
                              'world_16','world_17','world_18','world_19','world_20',
                              'world_11','world_12','world_13','world_14','world_15',
                              'world_06','world_07','world_08','world_09','world_10',
                              'world_01','world_02','world_03','world_04','world_05']
                        //This is just an example of how the order will look like after
                        //the program autogenerates it.
  ];
Trial () {
  transition();
  logData('time,trial.trialSetNum, trial.trialNum, box.id,'
                        +'box.x, box.y, box.color,'
                        +'clientID, box.gl_newX, box.gl_newY, score \n'
                        , 'gameStateData.csv');
}

  void setup(order){
    myState = new State();
    num i = 1;
    var piece,x,y;
    for (piece in order){
      //String boxNum = 'box' +  i.toString();
      //setup state and some test objects
      do {
        //Canvas size is 1580*790. 
        x=random.nextInt(1480);//1580-100
        y=random.nextInt(690);//790-100
      } while (checkRedundancy(x,y));
      Box box = new Box(i, x, y, piece);
      myState.addBox(box);
      
      i++;
      }
    
    for (Box box in myState.myBoxes){
                  //log only its initial position and the direction its heading to.
      try{
                  var time = new DateTime.now();
                  logData('${time},${trial.trialSetNum}, ${trial.trialNum+1}, ${box.id},'
                  +'${box.x}, ${box.y}, ${box.color},'
                  //+',${box.gl_newX}, ${box.gl_newY} \n'
                  +'\n'
                  , 'gameStateData.csv');
                }//plus one to trialNum so that it goes from 1 to 9
                catch (exception,stacktrace){
                  print(exception);
                  print(stacktrace);
                }
    }
    myState.assignBuddies();//Prepare the state so that each box has its buddies. 
    //(The buddies are the other boxes that a box should be connected to)
    }
  //The function to transition from one stage to the next
  void transition() {
     switch(phase){
          case 'Start':
              phase = 'BREAK';
              phaseStarted=false;
              phaseBreak = true;
              setup([]);
              break;
          case 'BREAK':
            print("ENTERING BREAK");
              phase = 'TRIAL';
              phaseStarted=true;
              phaseCongrats=false;
              phaseBreak = true;
              setup([]);

              myState.score=0;
              var sendScore = "s: ${myState.score} \n";
              distributeMessage(sendScore);
              var time = new DateTime.now();
              logData(' ${time}, ${trial.trialSetNum}, ${trial.trialNum}, ${clients[0].clientID}, start \n', 'globalData.csv');
              distributeMessage("z: start \n");
              new Timer(const Duration(seconds : 5), () {
                                transition();
              });
              break;
          case 'TRIAL':
              timer=new DateTime.now();
              phase = 'CONGRATS';
              phaseBreak = false;
              setup(order[trialNum]);
              trialNum += 1;
              if ((trialNum)==order.length){
                phase='END';
              }
              else if (trialNum>order.length){
                phase='END';
                transition();
              }              
              break;
          case 'CONGRATS':
              phase='BREAK';
              
              var Score=myState.score;//Need to store the score to show that on the Congrats page.
              setup([]);
              myState.score=Score;//Restore the score.
              myState.passedTest=true;
              var sendScore = "s: ${myState.score} \n";
              distributeMessage(sendScore);
              phaseBreak=false;
              phaseCongrats=true;
              var time = new DateTime.now();
              logData(' ${time}, ${trial.trialSetNum},'
                +'${trial.trialNum-1},${clients[0].clientID} , end, ${myState.score}\n', 'globalData.csv');
              //distributeMessage("z: end \n");
              
              new Timer(const Duration(seconds : 5), () {
                                              transition();
              });
              
              break;
           case 'END':
              phaseEnd=true;
              var time = new DateTime.now();
              logData(' ${time}, ${trial.trialSetNum},'
                       +'${trial.trialNum-1},${clients[0].clientID} , FINISHED TRIAL, ${myState.score}\n', 'globalData.csv');
              setup([]);
              break;
           }
   }
  // Generate the image order (array of arrays) from image names given in the picName array
  void generateOrder(){
      //Random randomNum = new Random();
      if (trialSetNum==0){
        order = [];
                List<String> this_image = [];
                for (int count = 0; count < 1; count++){
                    this_image = [];
                    for (int i=6;i>=0;i-=3){
                        for (int j=1;j<=3;j++){
                          if (i+j>=10){
                              this_image.add(picName[assignOptions[trialSetNum][count]]+'_'+(i+j).toString());
                           }
                           else{
                            this_image.add(picName[assignOptions[trialSetNum][count]]+'_0'+(i+j).toString());
                           }
                        }
                    }
                 order.add(this_image);
                 }
      }
      else{
        num numoftrials = assignOptions[trialSetNum].length;
        order = [];
        List<String> this_image = [];
        for (int count = 0; count < numoftrials; count++){
            this_image = [];
            for (int i=12;i>=0;i-=4){
                for (int j=1;j<=4;j++){
                  if (i+j>=10){
                      this_image.add(picName[assignOptions[trialSetNum][count]]+'_'+(i+j).toString());
                   }
                   else{
                    this_image.add(picName[assignOptions[trialSetNum][count]]+'_0'+(i+j).toString());
                   }
                }
            }
         order.add(this_image);
         }
      }
    }
  
  // Make sure we do not have two boxes laying on top of each other
  checkRedundancy(x,y){
    for (Box box in myState.myBoxes){
      if ((x>=box.x-box.imageWidth &&x<=box.x+box.imageWidth) &&(y>=box.y-box.imageHeight &&y<=box.y+box.imageHeight))
        //return true if there already exists a box that overlays the new box.
        return true;      
    }
    return false;
  }
}
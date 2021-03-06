String levelName = "Hello Bird";
String author = "Hieronymous Bosch";
int par = 24;

float startingVeloX = 2.0;
float startingVeloY = 1.0;
color lineColour = color(255,255,255,255);
color textColour = color(255,255,255,255);
color birdColour = color(50,0,50,255);
color skyColour = color(0,0,40,255);
color antiSkyColour = color(255,255,215,255);

int numGates = 4;
float gateWidth = 60;
float gateClearance = 100;
float birdDiameter = 5;
float boostY = -4.00;

boolean bumperBird = false;    /*like bumper bowling - player will bounce off surfaces instead of dying. Glitchy! */
boolean sfx = true;   /*displays neat rocket exhaust effect. */
float bounceDamping = 0.00;
boolean zoom = false;
boolean pause = false;
boolean finished = false;
boolean adjust = false;
boolean drawPath = false;
boolean drawVerticals = false;
boolean auto = false;
float storedVelX;
float storedVelY;

Player goodPlayer;
ArrayList blipList;          /*dynamic list of Blips*/
ArrayList boostList;
ArrayList gateList;          /*dynamic list of Gates*/
ArrayList exhaustList;       /*dynamic list to store exhaust particles (can this be done as a local variable in the exhaust code?) */

int arenaWidth = 3072;
int arenaHeight = 640;
int viewportWidth = 768;
int offsetX = 200;

int currentSelection = 0;

//SETUP runs once at program start
void setup(){
  size(1024,768);
  background(0);
  
  goodPlayer = new Player(20,arenaHeight/2, startingVeloX, startingVeloY, birdDiameter, lineColour, birdColour);
  blipList = new ArrayList();
  boostList = new ArrayList();
  exhaustList = new ArrayList();
  gateList = new ArrayList();
  
  /*add initial player position to blipList, corresponding lack of boost to boostList*/
  Blip newBlip = new Blip(goodPlayer.posX, goodPlayer.posY, antiSkyColour);
  blipList.add(newBlip);
  boostList.add(0.0);
  
  /*generate gates */
  for(int i = 0; i < numGates; i++){
    Gate newGate = new Gate(arenaWidth*(i+1)/(numGates + 1) + 0.3*viewportWidth, arenaHeight/2, gateWidth, gateClearance);
  gateList.add(newGate);
  }    
     

}


//DRAW runs over and over, approx. 60 times per second
//main jobs: clear background, update positions of all objects and display them on the screen
void draw(){
  
  background(0);
  /*update player position if game is running*/
  if(pause == false && finished == false){
    goodPlayer.update();
    if(auto == true){
      autoPilot();
    }
  }
  
  /*see if player has bumped into anything=*/
  checkCollisions(bumperBird, goodPlayer);  
  
  /*draw all objects to the screen*/
  pushMatrix();
    dealWithZoom();
    drawSky();
    drawWalls();
    drawGates();
    goodPlayer.display();
    drawBlips();
  
    /* if special effects are active, update and display the exhaust particles */
    if(sfx){
      updateExhaust();
    }
    


  popMatrix();
      drawUI();
  /*if player leaves the screen, start them again on the other side */  
  if(goodPlayer.posX > arenaWidth + 0.5*goodPlayer.size){
    //goodPlayer.posX = -0.5*goodPlayer.size;
   finishGame();
  }
  if(goodPlayer.posX < -0.5*goodPlayer.size){
    goodPlayer.posX = arenaWidth + 0.5*goodPlayer.size;
  }
  
}

/*User input*/  

void keyPressed()
{
  switch (keyCode) {
    case 38: /* up arrow pressed */
    if(adjust){
      adjustBoost(1.0);
      break;
    } else if(!pause){
        if(auto){
          disengageAutoPilot();
        }
        goodPlayer.boost(0, boostY);
        Blip upBlip = new Blip(goodPlayer.posX, goodPlayer.posY, antiSkyColour);
        blipList.add(upBlip);
        boostList.add(1.0);
        if(sfx){
        //create a little cloud of exhaust particles
          makeExhaust(0,-1*boostY);
        }

      }
    break;

    case 40: /* down arrow pressed */
        if(adjust){
      adjustBoost(1.0);
      break;
        } else if(!pause){
        if(auto){
          disengageAutoPilot();
        }
        goodPlayer.boost(0, -1*boostY);
        Blip downBlip = new Blip(goodPlayer.posX, goodPlayer.posY, antiSkyColour);
        blipList.add(downBlip);
        boostList.add(-1.0);
        if(sfx){
        //create a little cloud of exhaust particles
          makeExhaust(0, boostY);
        }

      }
    break;
    case 90: /* Z-key pressed */
      zoom = !zoom;
    break;
    case 83: /* S-key pressed */
      saveReplay();
    break;
    case 76: /* L-key pressed */
      loadReplay("replay01");
      break;
      
    case 80: /* P-key pressed */
      pauseGame();
      adjust = false;
      break;
      case 65: /* A-key pressed */
      beginAutoPilot();
      adjust = false;
      break;
      case 32: /* spacebar pressed */
      if(pause == true){
      adjust = true;
      cycleSelection();
      }
      break;
      case 37: /* left arrow pressed */
      if(adjust == true){
      adjustBlipX(-1.0);
      }
      break;
      case 39: /* right arrow pressed */
      if(adjust == true){
      adjustBlipX(1.0);
      }
      break;
  }
}



void pauseGame(){
  if (finished == false){
  pause = !pause;
  for(int i = 0; i < blipList.size(); i++){
    Blip thisBlip = (Blip) blipList.get(i);
    thisBlip.blipColour = antiSkyColour;
    currentSelection = 0;
    adjust = false;
  
  }
  }
}

void finishGame(){
  if(finished == false){
  finished = true;
  pause = true;
  Blip endBlip = new Blip(goodPlayer.posX,goodPlayer.posY,antiSkyColour);
  blipList.add(endBlip);
  boostList.add(0.0);
  }
  
}

void beginAutoPilot(){
  finished = false;
  auto = true;
  Blip thisBlip = (Blip) blipList.get(0);
  goodPlayer.posX = thisBlip.posX;
  goodPlayer.posY = arenaHeight/2;
  goodPlayer.velX = startingVeloX;
  goodPlayer.velY = startingVeloY;
  pause = true;
 
}

void disengageAutoPilot(){
  auto = false;
  int lastBlip = blipList.size();
  for(int i = 0; i < blipList.size(); i++){
    Blip thisBlip = (Blip) blipList.get(i);
    if(thisBlip.posX > goodPlayer.posX){
      lastBlip = i;
      break;
    }
    
    }
    for(int j = blipList.size() - 1; j >= lastBlip; j--){
      blipList.remove(blipList.size() - 1);
      boostList.remove(boostList.size() - 1);  
    }
  }
  



void autoPilot(){
  for(int i = 0; i < blipList.size(); i++){
    Blip thisBlip = (Blip) blipList.get(i);
    Float thisBoost = (Float) boostList.get(i);
    if(goodPlayer.posX == thisBlip.posX){
      goodPlayer.boost(0,thisBoost*boostY);
      if(sfx){
        //create a little cloud of exhaust particles
      makeExhaust(0, -1*thisBoost*boostY);
      }
      break;
    }
  }
}

void cycleSelection(){
    Blip thatBlip = (Blip) blipList.get(currentSelection);
  thatBlip.blipColour = antiSkyColour;
  currentSelection++;

  if(currentSelection >= blipList.size() - 1){
    currentSelection = 1;
  }

  Blip thisBlip = (Blip) blipList.get(currentSelection);
  thisBlip.blipColour = color(0,255,0);
}

void adjustBlipX(float amt){
 Blip leftBlip = (Blip) blipList.get(currentSelection - 1);
 Blip thisBlip = (Blip) blipList.get(currentSelection);
 Blip rightBlip = thisBlip;
 if (blipList.size() > currentSelection + 1){
   rightBlip = (Blip) blipList.get(currentSelection + 1);
 }
 
 thisBlip.posX = thisBlip.posX + amt;
 thisBlip.posX = constrain(thisBlip.posX, leftBlip.posX + 0.1, rightBlip.posX - 0.1);

}

void adjustBoost(float amt){

 Float thisBoost = (Float) boostList.get(currentSelection);

 
 thisBoost = thisBoost + amt;
 thisBoost = constrain(thisBoost, -5.0, 5.0);

}
class Particle{
  
  float posX;        //stores x coordinate
  float posY;        //stores y coordinate 
  float velX = 1;        //stores x (horizontal) velocity
  float velY = 1;        //stores y (vertical) velocity
  float size = 3;        //stores radius of collision boundary
  
 


  ///Constructor: runs once when object is created///
  
  Particle(float _posX, float _posY, float _velX, float _velY, float _size){
    posX = _posX;
    posY = _posY;
    velX = _velX;
    velY = _velY;
    size = _size;
  }
  
  ///Alternative constructors: in case user doesn't specify all arguments///
  Particle(){
    posX = 20;
    posY = arenaHeight/2;

     
 }
 
   Particle(float _posX, float _posY, float _velX, float _velY){
    posX = _posX;
    posY = _posY;
    velX = _velX;
    velY = _velY;

  }
  
  
  ///Methods///
  
  //method to update player parameters (location, velocity etc)
  void update(){

    //update position using velocity components
    posX = posX + velX;                
    posY = posY + velY;
    

      
  }
  
 
  

  
  
  
    
  
  
}



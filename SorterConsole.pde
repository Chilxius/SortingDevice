class SorterConsole
{
  //For cycling through different number generator behaviors
  int generatorBehaviorIndex = 0;
  int generatorSizeIndex = 4;
  GeneratorBehavior [] generatorBehaviors = { new Uniform(), new Unique(), new Sorted(), new Reverse(), new NearlySorted(), new HighDuplication(), new SmallRange(), new LargeRange(), new Alternating(), new VShape(), new AShape(), new Sawtooth(), new Sawtooth2(), new Sawtooth3() };
  int [] generatorSizes = {5,10,20,50,100,200,500,1000,2000,5000};
  NumberGenerator generator = new NumberGenerator( generatorBehaviors[generatorBehaviorIndex], generatorSizes[generatorSizeIndex], 1, generatorSizes[generatorSizeIndex] );
  
  SortRunner [] runners = new SortRunner[6];
  
  Button exitButton;
  Button startButton, numberTypeButton, moreNumbersButton, fewerNumbersButton;
  Button resetButton, backButton, pausePlayButton, forwardButton, slowDownButton, speedUpButton;
  
  ArrayList<Button> prepButtons = new ArrayList<Button>();
  ArrayList<Button> runningButtons = new ArrayList<Button>();
  
  boolean running;
  boolean playing;
  
  float consoleWidth = width;
  float consoleHeight = height;
  
  float boxX = width/16, boxY = height/10;
  float boxW = width/3.5, boxH = height/3;
  
  int replayIndex = 0;
  
  SorterConsole()
  { 
    generateButtons();
    generateRunners();
  }
  
  private void generateRunners()
  {
    //Generate the list that all SortRunners begin with
    int [] numberList = generator.getList();
    
    runners[0] = new SortRunner( new NumberSorter(numberList.clone()), new Visualizer( boxX*3,  boxY*3.25, boxW, boxH, numberList.clone() ) ); 
    runners[1] = new SortRunner( new NumberSorter(numberList.clone()), new Visualizer( boxX*8,  boxY*3.25, boxW, boxH, numberList.clone() ) );
    runners[2] = new SortRunner( new NumberSorter(numberList.clone()), new Visualizer( boxX*13, boxY*3.25, boxW, boxH, numberList.clone() ) ); 
    
    runners[3] = new SortRunner( new NumberSorter(numberList.clone()), new Visualizer( boxX*3,  boxY*7.5, boxW, boxH, numberList.clone() ) );
    runners[4] = new SortRunner( new NumberSorter(numberList.clone()), new Visualizer( boxX*8,  boxY*7.5, boxW, boxH, numberList.clone() ) );
    runners[5] = new SortRunner( new NumberSorter(numberList.clone()), new Visualizer( boxX*13, boxY*7.5, boxW, boxH, numberList.clone() ) );
  }
  
  private void resetRunners()
  {
    int [] numberList = generator.getList();
    for(SortRunner runner: runners)
      runner.reset( numberList.clone() );
  }
  
  private void generateButtons()
  {    
    exitButton = new Button( boxX*15.5, boxY*0.5, boxX*0.9, "X", color(175,0,0), color(100,0,0), color(0) );
  
    startButton      = new Button( boxX*1.15,   boxY*0.5, boxX*2.2, "Start",   color(0,200,0), color(0,100,0), color(0) );
    numberTypeButton = new Button( boxX*8,      boxY*0.5, boxX*8,   "Uniform", color(0),       color(100),     color(200,255,200) );
    fewerNumbersButton = new Button( boxX*3.45,  boxY*0.5, boxX*0.9, "—",       color(150),     color(100),     color(255) );
    moreNumbersButton = new Button( boxX*12.55,boxY*0.5, boxX*0.9, "+",       color(150),     color(100),     color(255) );
    
    resetButton     = new Button( boxX*1.15,  boxY*0.5, boxX*2.2, "Reset", color(175,0,0), color(100,0,0), color(0) );
    backButton      = new Button( boxX*6.5,   boxY*0.5, boxX*0.9, "<",     color(200),     color(150),     color(0) );
    pausePlayButton = new Button( boxX*8,     boxY*0.5, boxX*1.5, "P",     color(200),     color(150),     color(0) );
    forwardButton   = new Button( boxX*9.5,   boxY*0.5, boxX*0.9, ">",     color(200),     color(150),     color(0) );
    slowDownButton  = new Button( boxX*4.45,  boxY*0.5, boxX*0.9, "—",     color(0,0,200), color(0,0,100), color(0) );
    speedUpButton   = new Button( boxX*11.55, boxY*0.5, boxX*0.9, "+",     color(0,200,0), color(0,150,0), color(0) );
  
    prepButtons.add( startButton );
    prepButtons.add( numberTypeButton );
    prepButtons.add( moreNumbersButton );
    prepButtons.add( fewerNumbersButton );
    prepButtons.add( exitButton );
    
    runningButtons.add( resetButton );
    runningButtons.add( backButton );
    runningButtons.add( pausePlayButton );
    runningButtons.add( forwardButton );
    runningButtons.add( slowDownButton );
    runningButtons.add( speedUpButton );
    runningButtons.add( exitButton );
  }
  
  private void cycleGenerator()
  {
    //Change Generator Behavior and update button
    generatorBehaviorIndex = (generatorBehaviorIndex+1)%generatorBehaviors.length;
    generator.setBehavior( generatorBehaviors[generatorBehaviorIndex] );
    prepButtons.get( 1 ).updateText( generator.getBehaviorName() );
    
    //Update Visualizers
    //TESTING
    int [] newList = generator.getList();
    for( SortRunner runner: runners )
      runner.updateNumbers( newList.clone() );
  }
  
  //public void setSorters( int index, NumberSorter sorter )
  //{
  //  //if( index <= 0 && index < sorters.length )
  //  //  sorters[index] = sorter;
  //}
  
  public void setNumberType( NumberGenerator type )
  {
    generator = type;
  }
  
  public void beginSorts()
  {
    if( generator == null ) return;
  }
  
  public void display()
  {
    //Screen is divided into 15 horizontal blocks, screens appear centered at 3, 8, 13 
    //Screen is divided into 10 vertical blocks, screens appear centered at 3.5 and 7.5
    
    
    for( SortRunner runner: runners )
      runner.display();

    
    //Buttons
    //Not currently Running
    if( !running ) for( Button b: prepButtons ) b.display();
    //Currently Running
    else if( running ) for( Button b: runningButtons) b.display();
    
  }
  
  public void update()
  {
    //********************
    //* BUTTON RESPONSES *
    //********************
    //When sort playback is running
    if(running)
    {
      if( playing ) // AUTOMATIC PLAYBACK
      {
        for( SortRunner runner: runners )
          runner.update(replayIndex);
        replayIndex++;
      }
      
      if( resetButton.receiveActivation() ) // RESET
        resetRun();
      else if( forwardButton.receiveActivation() ) // FORWARD
      {
        for( SortRunner runner: runners )
          runner.update(replayIndex);
        replayIndex++;
      }
      else if( backButton.receiveActivation() ) // BACKWARD
      {
        replayIndex--;
        for( SortRunner runner: runners )
          runner.backUp(replayIndex);
      }
      else if( pausePlayButton.receiveActivation() ) // PAUSE / PLAY
      {
        playing = !playing;
      }
      else // SHOW SORT TYPE NAME
      {
        for(SortRunner r: runners ) if( r.receiveActivation() ) r.revealName();
      }
    }
    else //WHILE SORT PLAYBACK IS NOT RUNNING
    {
      if( startButton.receiveActivation() ) // START
        startRunning();
      else if( numberTypeButton.receiveActivation() ) // CHANGE NUMBER TYPE
        cycleGenerator();
      else if( moreNumbersButton.receiveActivation() ) // MORE NUMBERS
      {
        generatorSizeIndex = max(1,min(generatorSizeIndex+1,generatorSizes.length-1));
        generator.setParameters( generatorSizes[generatorSizeIndex] );
        int [] newNumbers = generator.getList();
        for( SortRunner runner: runners ) runner.updateNumbers( newNumbers.clone() );
      }
      else if( fewerNumbersButton.receiveActivation() ) // FEWER NUMBERS
      {
        generatorSizeIndex = max(1,min(generatorSizeIndex-1,generatorSizes.length));
        generator.setParameters( generatorSizes[generatorSizeIndex] );
        int [] newNumbers = generator.getList();
        for( SortRunner runner: runners ) runner.updateNumbers( newNumbers.clone() );
      }
      else // CHANGE SORT TYPE
      {
        for( SortRunner runner: runners )
          if( runner.receiveActivation() )
            runner.cycleSortType();
      }
    }
    
    if( exitButton.receiveActivation() ) // EXIT
      exit();
  }
  
  private void startRunning()
  {
    running = true;
    playing = false;
    for( SortRunner runner: runners )
      runner.runSort();
  }
  
  private void resetRun()
  {
    running = false;
    replayIndex = 0;
    resetRunners();
  }
  
  public void resolveClick()
  {
    if( !running )
    {
      for( Button b: prepButtons ) { if( b.underMouse() ) b.pressed = true; }
      for( SortRunner r: runners ) { if( r.underMouse() ) r.pressed = true; }
    }
    else if( running )
    {
      for( Button b: runningButtons ) { if( b.underMouse() ) b.pressed = true; }
      for( SortRunner r: runners    ) { if( r.underMouse() ) r.pressed = true; }
    }
  }
  
  public void resolveRelease()
  {
    if( !running )
    {
      for( Button b: prepButtons ) { if( b.underMouse() ) b.activate(); }
      for( SortRunner r: runners ) { if( r.underMouse() ) r.activate(); }
    }
    else if( running )
    {
      for( Button b: runningButtons ){ if( b.underMouse() ) b.activate(); }
      for( SortRunner r: runners    ){ if( r.underMouse() ) r.activate(); }
    }
    
    //Un-press
    for( Button b: prepButtons ) b.pressed = false;
    for( Button b: runningButtons ) b.pressed = false;
  }
  
  //Internal Classes
  
  class Button
  {
    float xPos, yPos;
    float size; //controls length - height is set based on screen height
    color buttonColor, pressedColor, textColor;
    String text;
    boolean pressed, activated;
    
    Button( float x, float y, float size, String text, color c1, color c2, color c3 )
    {
      this.xPos = x;
      this.yPos = y;
      this.size = size;
      this.text = text;
      this.buttonColor = c1;
      this.pressedColor = c2;
      this.textColor = c3;
    }
    
    public void display()
    {
      rectMode(CENTER);
      stroke(255); strokeWeight(5);
      if( pressed ) fill( pressedColor );
      else fill( buttonColor );
      //fill(200,0,0);
      rect(xPos, yPos, size, boxY*0.9, 5 );
      
      textSize( width/25 ); //adjust text size to width of screen
      textAlign(CENTER);
      fill(textColor);
      text(text,xPos,yPos + boxY/4);
      
    }
    
    public boolean underMouse()
    {
      return ( mouseX > xPos-size/2 && mouseX < xPos+size/2 && mouseY > yPos-boxY/2 && mouseY < yPos+boxY/2 );
    }
    
    public void activate()
    {
      activated = true;
      pressed = false;
    }
    
    //Returns the state of ACTIVATED while de-activating the button
    public boolean receiveActivation()
    {
      boolean result = activated;
      activated = false;
      return result;
    }
    
    public void updateText( String newText )
    {
      text = newText;
    }
  }
  
  //class PicButton extends Button
  //{
  //  private PImage pic;
  //  //SoundFile sound;
    
  //  PicButton( float x, float y, PImage p )
  //  {
  //    super( x, y, 1, "", color(0), color(0), color(0) );
  //    this.pic = p;
  //  }
  //}
}

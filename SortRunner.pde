//This represents a composite of the sorter, the visualizer, and the current step
class SortRunner
{
  NumberSorter sorter;
  Visualizer visualizer;
  ArrayList<SortStep> steps = new ArrayList<SortStep>();
  SortBehavior [] sortBehaviors = { new BubbleSort(),    new Cocktail(),        new BrickSort(),
                                    new CombSort(),      new SelectionSort(),   new DoubleSelectionSort(),
                                    new InsertionSort(), new BinaryInsertion(), new GnomeSort(),
                                    new ShredderSort(),  new QuickSort(),       new PreciseQuick(),
                                    new RandomQuick(),   new ShellSort() };
  int sortBehaviorIndex = 0;
  
  //Button behavior
  boolean pressed;
  boolean activated;
  
  SortRunner( NumberSorter sorter, Visualizer visualizer )
  {
    this.sorter = sorter;
    this.visualizer = visualizer;
    visualizer.setSortName( sorter.behavior.toString() );
  }
  
  public void update( int index )
  {
    if( index < 0 || index >= steps.size() )
      return;
    visualizer.update( steps.get( index ) );
  }
  
  public void backUp( int index )
  {
    if( index < 0 || index >= steps.size() )
      return;
    visualizer.backUp( steps.get( index ) );
  }
  
  public void runSort()
  {
    steps = sorter.runSort();
  }
  
  public void display()
  {
    visualizer.display();
  }
  
  public void reset( int [] numbers )
  {
    steps.clear();
    sorter.empty();
    sorter.load( numbers.clone() );
    visualizer.reset();
    visualizer.updateNumbers(numbers.clone());
  }
  
  public void updateNumbers( int [] numbers )
  {
    visualizer.updateNumbers( numbers.clone() );
    sorter.empty();
    sorter.load(numbers.clone());
  }
  
  //Updates the sorter and the visualizer's text
  private void updateSorter( SortBehavior behavior )
  {
    sorter.setSortType( behavior );
    visualizer.setSortName( behavior.toString() );
  }
  
  //For picking a secret, random sorter from the list
  private void pickRandomSorter()
  {
    sorter.setSortType( sortBehaviors[ (int)(Math.random()*sortBehaviors.length) ] );
    visualizer.setSortName( "???" );
  }
  
  public void revealName()
  {
    visualizer.setSortName( sorter.behavior.toString() );
  }
  
  public boolean underMouse()
  {
    return visualizer.underMouse();
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
  
  //Change to next sort type
  public void cycleSortType()
  {
    sortBehaviorIndex = (sortBehaviorIndex+1) % (sortBehaviors.length+1);
    if( sortBehaviorIndex == sortBehaviors.length )
      pickRandomSorter();
    else
      updateSorter( sortBehaviors[ sortBehaviorIndex ] );
  }
}

class Visualizer
{
  //Center of box
  float xPos, yPos;
  float boxW, boxH;
  
  int [] numbers;
  boolean [] sorted; //Values that have been sorted
  int compareA = -1, compareB = -1, compareC = -1; //Indices of compared values
  
  float barWidth;
  float heightMultiplier;
  
  String sortName;
  
  int comparisons, swaps, assignments;
  
  public Visualizer( float xPos, float yPos, float boxW, float boxH, int [] numbers )
  {
    this.xPos = xPos;
    this.yPos = yPos;
    
    this.boxW = boxW;
    this.boxH = boxH;
    
    this.numbers = numbers;
    setBarDimensions();
    
    this.sorted = new boolean[numbers.length];
    
    comparisons = swaps = assignments = 0;
  }
  
  public void updateNumbers( int [] numbers )
  {
    this.numbers = numbers;
    this.sorted = new boolean[numbers.length];
    setBarDimensions();
  }
  
  public void setSortName( String name )
  {
    sortName = name;
  }
  
  private void setBarDimensions()
  {
    //Find largest number
    int biggest = numbers[0];
    for( int i = 1; i < numbers.length; i++ ) if( biggest < numbers[i] ) biggest = numbers[i];
    
    //Set dimensions based on max value
    heightMultiplier = boxH / biggest;
    barWidth = boxW / numbers.length;
  }
  
  public void reset()
  {
    comparisons = swaps = assignments = 0;
    compareA = compareB = compareC = -1;
  }
  
  public void display()
  {
    push();
    strokeWeight(4);
    fill(0);
    rect(xPos,yPos,boxW+4,boxH+4);
    noStroke();
    //fill(0,200,0);
    rectMode(CORNER);
    for( int i = 0; i < numbers.length; i++ )
    {
      if(sorted[i]) fill(0,200,0);
      else          fill(200);
      
      if( i == compareA ) fill(200,0,0);
      if( i == compareB ) fill(0,0,200);
      if( i == compareC ) fill(0,0,200);
      rect(xPos-boxW/2+i*barWidth, yPos+boxH/2, barWidth, -numbers[i]*heightMultiplier );
    }
    
    //NamePlate
    fill(255);
    textSize(40);
    text( sortName, xPos, yPos-boxH/1.9 );
    
    //Actions
    textSize(20);
    textAlign(LEFT);
    text("C: " + comparisons, xPos-boxW/2, yPos+boxH/1.75);
    text("S: " + swaps,       xPos-boxW/12.5, yPos+boxH/1.75);
    text("A: " + assignments, xPos+boxW/3, yPos+boxH/1.75);
    pop();
    
  }
  
  public void readStepData( SortStep step )
  {
    //compareA = compareB = compareC = -1;
    
    if( step instanceof CompareStep )
    {
      CompareStep c = (CompareStep) step;
      if( c.sorted )
        sorted[c.prospective] = true;
      compareA = c.index;
      compareB = c.prospective;
    }
    if( step instanceof CompareSecondStep )
    {
      CompareSecondStep c = (CompareSecondStep) step;
      if( c.sorted )
        sorted[c.prospective] = true;
      compareA = c.index;
      compareC = c.prospective;
    }
    if( step instanceof SwapStep )
    {
      SwapStep s = (SwapStep) step;
      if( s.sorted )
        sorted[s.swappedIndex] = true;
        
      compareA = s.swappedIndex;
      compareB = s.index;
    }
    if( step instanceof SwapSecondStep )
    {
      SwapSecondStep s = (SwapSecondStep) step;
      if( s.sorted )
        sorted[s.swappedIndex] = true;
        
      compareA = s.swappedIndex;
      compareC = s.index;
    }
    if( step instanceof AssignStep )
    {
      AssignStep a = (AssignStep) step;
      
      if( a.sorted )
        sorted[a.index] = true;
        
      compareA = a.index;
    }
    if( step instanceof FinishedStep )
    {
      for( int i = 0; i < sorted.length; i++ )
        sorted[i] = true;
      compareA = compareB = compareC = -1;
    }
  }
  
  public void update( SortStep step )
  {
    step.perform(numbers);
    readStepData(step);
    if( step instanceof SwapStep )    swaps++;
    if( step instanceof CompareStep ) comparisons++;
    if( step instanceof AssignStep )  assignments++;
  }
  
  public void backUp( SortStep step )
  {
    step.reverse(numbers);
    if( step instanceof SwapStep )    swaps--;
    if( step instanceof CompareStep ) comparisons--;
    if( step instanceof AssignStep )  assignments--;
  }
  
  public boolean underMouse()
  {
    return mouseX > xPos-boxW/2 && mouseX < xPos+boxW/2 && mouseY > yPos-boxH/2 && mouseY < yPos+boxH/2;
  }
}

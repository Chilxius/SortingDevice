// ******************************************
// * Device that creates a list of integers *
// ******************************************
// * Values created are inclusive: *
// *    lower <= value <= upper    *
// *********************************

//********************************
// Using the STRATEGY Pattern
//*****************************************************************************************
// The Strategy design pattern is useful when you have an object that has changable
//  behaviors. Here, the NumberGenerator will always be able to create an array of numbers,
//  but based on how the device is "set" or "tuned", it will produce those numbers in
//  different ways. This could be done with methods ( getReversedList(), getRandomList() ),
//  but using Strategy simplifies the interface with other parts of the program, and for
//  some objects it might be inappropriate to have access to multiple behaviors.
//*****************************************************************************************

class NumberGenerator
{
  GeneratorBehavior behavior;
  int size;
  int lower;
  int upper;
  
  //Default to Uniform distribution
  public NumberGenerator()
  {
    this( new Uniform() );
  }
  
  //Default to 10 numbers in the range 0-10
  public NumberGenerator( GeneratorBehavior behavior )
  {
    this( behavior, 10, 0, 10 );
  }
  
  public NumberGenerator( GeneratorBehavior behavior, int size, int lower, int upper )
  {
    this.behavior = behavior;
    this.size = size;
    this.lower = lower;
    this.upper = upper;
  }
  
  public void setBehavior( GeneratorBehavior behavior )
  {
    this.behavior = behavior;
  }
  
  public void setParameters( int size )
  {
    this.size = size;
    this.lower = 1;
    this.upper = size;
  }
  
  public void setSize( int size )
  {
    this.size = size;
  }
  
  public void setRange( int lower, int upper )
  {
    this.lower = lower;
    this.upper = upper;
  }
  
  public int[] getList()
  {
    return behavior.getList(size,lower,upper);
  }
  
  public String getBehaviorName()
  {
    return behavior.toString();
  }
  
  public String toString()
  {
    return "Generator set to " + behavior.toString() + "\nList size: " + size + "\nRange: " + lower + " to " + upper;
  }
}

// *************************************
// * Behaviors used by NumberGenerator *
// *************************************

// **********************
// * Behavior Interface *
// **********************

interface GeneratorBehavior
{
  abstract public String toString();
  abstract public int[] getList( int size, int lower, int upper );
}

// ***********************
// * Concrete Strategies *
// ***********************

//Creates a list of evenly distributed random values
class Uniform implements GeneratorBehavior
{
  public String toString()
  {
    return "Uniform";
  }

  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    int [] list = new int[size];
    
    for( int i = 0; i < size; i++ )
      list[i] = (int)(Math.random()*(upper-lower+1))+lower;
      
    return list;
  }
}

//Creates a list of evenly distributed sequential values
class Unique implements GeneratorBehavior
{
  public String toString()
  {
    return "Unique";
  }

  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    int [] list = new int[min(size,upper-lower)];
    
    for( int i = 0; i < list.length; i++ ) list[i] = i;
    for( int i = 0; i < list.length; i++ )
    {
      int randIndex = (int)(Math.random()*list.length);
      int temp = list[i];
      list[i] = list[randIndex];
      list[randIndex] = temp;
    }
      
    return list;
  }
}

//Creates a list of already sorted values
class Sorted implements GeneratorBehavior
{
  public String toString()
  {
    return "Sorted";
  }

  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }

    int[] list = new Uniform().getList(size,lower,upper);
    new QuickSort().untrackedSort(list);
    
    return list;
  }
}

//Creates a list of reverse-sorted values
class Reverse implements GeneratorBehavior
{
  public String toString()
  {
    return "Reversed";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    int[] list = new Uniform().getList(size,lower,upper);
    new QuickSort().untrackedSort(list);
    
    int[] reverseList = new int[list.length];
    
    for( int i = 0; i < list.length; i++ )
      reverseList[i] = list[list.length-i-1];
    
    return reverseList;
  }
}

//Creates a list of nearly sorted values
class NearlySorted implements GeneratorBehavior
{
  public String toString()
  {
    return "Nearly Sorted";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    int[] list = new Sorted().getList(size,lower,upper);
    int middle = size/2-1;
    
    if( list.length > 1 )
    {
      int swap = middle;
      int swapDist = 1;
      
      //This is to make sure the swapped values were not the same
      while( swap < size && swap >= 0 )
      {
        if( list[swap] != list[middle] ) break;
        
        if( swapDist % 2 == 0 ) swap-=swapDist;
        else                    swap+=swapDist;
        swapDist++;
      }
      //Prevent issue if all values were identical
      if( swap < size && swap >= 0 )
      {
        int temp = list[swap];
        list[swap] = list[middle];
        list[middle] = temp;
      }
    }
    
    return list;
  }
}

//Creates a list with a few unique repeated values  //Could improve with HashMap
class HighDuplication implements GeneratorBehavior
{
  public String toString()
  {
    return "High Duplication";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    int [] list = new int[size];
    int range = upper-lower+1;
    
    //Three or fewer values
    if( range < 3 )
      return new Uniform().getList(size,lower,upper);
    
    int [] nums = {lower, (lower + upper)/2, upper};
    
    for( int i = 0; i < size; i++ )
      list[i] = nums[(int)(Math.random()*3)];
      
    return list;
  }
}

//Creates a list with a small range of values
class SmallRange implements GeneratorBehavior
{
  public String toString()
  {
    return "Small Range";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    int range = (upper-lower+1);
    
    while( range > 10 )
    {
      if( range % 2 == 0 ) upper--;
      else                 lower++;
      
      range = (upper-lower+1);
    }
      
    return new Uniform().getList( size, lower, upper );
  }
}

//Creates a list with a large range of values
class LargeRange implements GeneratorBehavior
{
  public String toString()
  {
    return "Large Range";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    while( upper-lower+1 < 1000 && upper < Integer.MAX_VALUE ) upper++;
    
    return new Uniform().getList( size, lower, upper);
  }
}

//Creates a list with values that alternate high and low
class Alternating implements GeneratorBehavior
{
  public String toString()
  {
    return "Alternating";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    int [] list = new int[size];
    
    int quarter = (upper-lower+1)/4;
    
    for( int i = 0; i < size; i++)
      if( i % 2 == 0 )
        list[i] = (int)(Math.random()*quarter+lower);
      else
        list[i] = (int)(upper-Math.random()*quarter);
    
    return list;
  }
}

//Creates a list with values in a V-shape
class VShape implements GeneratorBehavior
{
  public String toString()
  {
    return "V-Shaped";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    if( size == 1 )
      return new int[] {lower};
    
    int [] list = new int[size];
    
    float change = (upper-lower)/((float)size/2);
    
    for(int i = 0; i < size/2; i++)
      list[i] = list[list.length-i-1] = Math.round(upper-change*i);
    if( size % 2 == 1 )
      list[size/2] = lower;
      
    return list;
  }
}

//Creates a list with values in a V-shape
class AShape implements GeneratorBehavior
{
  public String toString()
  {
    return "A-Shaped";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    if( size == 1 )
      return new int[] {lower};
    
    int [] list = new int[size];
    
    float change = (upper-lower)/((float)size/2);
    
    for(int i = 0; i < size/2; i++)
      list[i] = list[list.length-i-1] = Math.round(lower+change*i);
    if( size % 2 == 1 )
      list[size/2] = upper;
      
    return list;
  }
}

//Creates a list with a sawtooth pattern
class Sawtooth implements GeneratorBehavior
{
  public String toString()
  {
    return "Sawtooth";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    while( size % 3 != 0 ) size -= 1; // <- To make the visualizer nicer
    
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    //Ensure the pattern will have at least three teeth
    int range = upper - lower + 1;
    int toothCount = max( 1, min( size/3, range ) );
    float increment = (float)range/toothCount;
    
    int[] list = new int[size];
    
    float acc = 0;
    for( int i = 0; i < size; i++ )
    {
      int value = (int)acc;
      value %= range;
      
      list[i] = lower + value;
      acc+= increment;
      
      //Avoid "modulus creep"
      if (acc >= range) acc -= range;
    }
    
    return list;
  }
}

//Creates a list with a sawtooth pattern
class Sawtooth2 implements GeneratorBehavior
{
  public String toString()
  {
    return "Finer Sawtooth";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    while( size % 10 != 0 ) size -= 1; // <- To make the visualizer nicer
    
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    //Ensure the pattern will have at least three teeth
    int range = upper - lower + 1;
    int toothCount = max( 1, min( size/10, range ) );
    float increment = (float)range/toothCount;
    
    int[] list = new int[size];
    
    float acc = 0;
    for( int i = 0; i < size; i++ )
    {
      int value = (int)acc;
      value %= range;
      
      list[i] = lower + value;
      acc+= increment;
      
      //Avoid "modulus creep"
      if (acc >= range) acc -= range;
    }
    
    return list;
  }
}

//Creates a list with a sawtooth pattern
class Sawtooth3 implements GeneratorBehavior
{
  public String toString()
  {
    return "Htootwas";
  }
  
  public int[] getList( int size, int lower, int upper )
  {
    while( size % 3 != 0 ) size -= 1; // <- To make the visualizer nicer
    
    if( upper < lower ) { int temp = lower; lower = upper; upper = temp; }
    
    //Ensure the pattern will have at least three teeth
    int range = upper - lower + 1;
    int toothCount = max( 1, min( size/3, range ) );
    float increment = (float)range/toothCount;
    
    int[] list = new int[size];
    
    float acc = 0;
    for( int i = 0; i < size; i++ )
    {
      int value = (int)acc;
      value %= range;
      
      //list[i] = lower + value;
      list[i] = upper - value;
      acc+= increment;
      
      //Avoid "modulus creep"
      if (acc >= range) acc -= range;
    }
    
    return list;
  }
}

// **************************************************
// * Device that holds and sorts a list of integers *
// **************************************************

//Cycle, 3-Way Quick

class NumberSorter
{
  SortBehavior behavior;
  NumberGenerator generator;
  
  int[] numbers = null;
  
  ArrayList<SortStep> sortSteps = new ArrayList<SortStep>();
  
  //boolean sorted = false;
  
  //Meta-data
  //String sortType;
  //int comparisons;
  //int swaps;
  
  NumberSorter( int[] numbers )
  {
    this.behavior = new BubbleSort();
    this.generator = new NumberGenerator();
    this.numbers = numbers;
  }
  
  NumberSorter( SortBehavior sortType, GeneratorBehavior genType )
  {
    this.behavior = sortType;
    this.generator = new NumberGenerator( genType );
  }
  
  public void setSortType( SortBehavior behavior )
  {
    this.behavior = behavior;
  }
  
  public void setNumberGenerator( GeneratorBehavior behavior )
  {
    this.generator.setBehavior( behavior );
  }
  
  public SortStep getStep( int index )
  {
    if( index > sortSteps.size() )
      return new FinishedStep();
    return sortSteps.get(index);
  }
  
  //Receive numbers to be sorted (as a shallow copy)
  public boolean load( int [] nums )
  {
    if( numbers != null )
    {
      System.out.println("There are still numbers in the sorter.\nPlease empty the sorter before adding new values.");
      return false;
    }
    if( nums == null )
    {
      System.out.println("Cannot load a null array.");
      return false;
    }
    
    resetData();
    numbers = nums.clone();
    return true;
  }
  
  public void generateNumbers()
  {
    numbers = generator.getList();
  }
  
  ////Generate list of 20 random numbers from 1-10
  //public boolean generateList()
  //{
  //  return generateList( 20, 1, 10 );
  //}
  
  ////Generate list of n random numbers from l to u
  //public boolean generateList( int n, int l, int u )
  //{
  //  if( numbers != null )
  //  {
  //    System.out.println("There are still numbers in the sorter.\nPlease empty the sorter before adding new values.");
  //    return false;
  //  }
    
  //  numbers = new int[n];
  //  for( int i = 0; i < n; i++ )
  //    numbers[i] = (int)(Math.random()*(u-l+1))+l;
      
  //  return true;
  //}
  
  //Give back the list (whether sorted or not) and wipe internal array
  public int[] retrieve()
  {
    if(!behavior.sorted)
      System.out.println("Numbers were not sorted.");
      
    int[] output = numbers.clone();
    
    empty();
    
    return output;
  }
  
  //Empty the numbers in the sorter
  public void empty()
  {
    numbers = null;
    behavior.sorted = false;
    resetData();
  }
  
  //Display list with sort data
  public void show()
  {
    if(behavior.sorted) showData();
    else if(numbers == null)
    {
      System.out.println("No numbers loaded.");
      return;
    }
    else System.out.println("Un-Sorted List:");
    
    for( int i = 0 ; i < numbers.length; i++ )
    {
      System.out.printf("[%2d] %d%n", i, numbers[i]);
    }
  }
  
  public ArrayList<SortStep> runSort()
  {
    sortSteps.clear();
    //for(int i = 0; i < numbers.length; i++) print(numbers[i] + " ");
    behavior.runSort(numbers,sortSteps);
    //for(int i = 0; i < numbers.length; i++) print(numbers[i] + " ");
    return sortSteps;
  }
  
  public void reviewSort()
  {
    for( SortStep s: sortSteps )
    {
      println(s);
    }
  }
  
  public boolean isSorted()
  {
    return behavior.sorted;
  }
  
  public void showData()
  {
    System.out.println("Sort Type:\t"+behavior);
    System.out.println("Comparisons:\t"+behavior.comparisons());
    System.out.println("Swaps:\t\t\t"+behavior.swaps());
  }
  
  private void resetData()
  {
    behavior.reset();
  }
}

// **********************************
// * Behaviors used by NumberSorter *
// **********************************

// **********************
// * Behavior Interface *
// **********************

abstract class SortBehavior
{
  int comparisons = 0;
  int swaps = 0;
  boolean sorted = false;
  
  abstract public String toString();
  abstract public void runSort( int[] numbers, ArrayList<SortStep> steps );
  
  public int comparisons() { return comparisons; }
  public int swaps() { return swaps; }
  
  //Run before each sort to make sure a sort can be performed
  protected boolean unsafe( int[] numbers )
  {
    if(numbers == null)
    {
      System.out.println("Please load an array of integers first.");
      return true;
    }
    if( sorted || numbers.length < 2) return true;
    
    return false;
  }
  
  public void reset()
  {
    comparisons = 0;
    swaps = 0;
    sorted = false;
  }
}

// ***********************
// * Concrete Strategies *
// ***********************
  
// ************
// *  BUBBLE  *
// ************
class BubbleSort extends SortBehavior
{
  public String toString()
  {
    return "Bubble";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    if( unsafe(numbers) ) return;
    
    //Track if no swaps were made (list is sorted)
    boolean swapped = true;
    
    //For each item, if swaps occured last time...
    for( int i = 0; i < numbers.length-1 && swapped; i++ )
    {
      swapped = false;
      
      //Check each subsequent value up to sorted items to see if a swap is needed
      for( int j = 0; j < numbers.length-i-1; j++ )
      {
        //comparisons++;
        steps.add( new CompareStep( j, j+1 ) );
        if( numbers[j] > numbers[j+1] )
        {
          swapped = true;
          //swaps++;
          steps.add( new SwapStep( j, j+1, false ) );
          int temp = numbers[j];
          numbers[j] = numbers[j+1];
          numbers[j+1] = temp;
        }
      }
      
      if( swapped == true )
        steps.get( steps.size()-1 ).markSorted();
    }

    steps.add( new FinishedStep() );
    sorted = true;
  }
}
  
// ***********
// *  BRICK  * // EVEN-ODD SORT
// ***********
class BrickSort extends SortBehavior
{
  public String toString()
  {
    return "Brick";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    if( unsafe(numbers) ) return;
    
    //Track if no swaps were made (list is sorted)
    boolean swapped = false;
    
    while( !swapped )
    {
      swapped = true;
      for( int i = 1; i < numbers.length-1; i+=2 )
      {
        steps.add( new CompareStep( i, i+1 ) );
        if( numbers[i] > numbers[i+1] ) //compare
        {
          steps.add( new SwapStep( i, i+1, false ) );
          int temp = numbers[i];
          numbers[i] = numbers[i+1];
          numbers[i+1] = temp;
          swapped = false;
        }
      }
      for( int i = 0; i < numbers.length-1; i+=2 )
      {
        steps.add( new CompareStep( i, i+1 ) );
        if( numbers[i] > numbers[i+1] )
        {
          steps.add( new SwapStep( i, i+1, false ) );
          int temp = numbers[i];
          numbers[i] = numbers[i+1];
          numbers[i+1] = temp;
          swapped = false;
        }
      }
    }

    steps.add( new FinishedStep() );
    sorted = true;
  }
}

// *********************
// *  COCKTAIL SHAKER  *
// *********************
class Cocktail extends SortBehavior
{
  public String toString()
  {
    return "Cocktail Shaker";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    if( unsafe(numbers) ) return;
    
    int start = 0, end = numbers.length-1;
    boolean swapped = true;
    
    //Continue to shake until the two ends meet or it is sorted
    while( start < end && swapped )
    {
      swapped = false;
      
      //Forward shake
      for( int i = start; i < end; i++ )
      {
        //comparisons++;
        steps.add( new CompareStep( i, i+1 ) );
        if( numbers[i] > numbers[i+1] )
        {
          swapped = true;
          //swaps++;
          steps.add( new SwapStep( i, i+1, false) );
          int temp = numbers[i];
          numbers[i] = numbers[i+1];
          numbers[i+1] = temp;
        }
      }
      steps.get( steps.size()-1 ).markSorted();
      end--;
      
      //Backward shake
      if(swapped)
      for( int i = end; i > start; i-- )
      {
        //comparisons++;
        steps.add( new CompareStep( i, i-1 ) );
        if( numbers[i] < numbers[i-1] )
        {
          swapped = true;
          //swaps++;
          steps.add( new SwapStep( i, i-1, false ) );
          int temp = numbers[i];
          numbers[i] = numbers[i-1];
          numbers[i-1] = temp;
        }
      }
      steps.get( steps.size()-1 ).markSorted();
      start++;
    }
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
}
  
// **********
// *  COMB  *
// **********
class CombSort extends SortBehavior
{
  public String toString()
  {
    return "Comb";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    if( unsafe(numbers) ) return;
    
    //FOR VISUALIZATION ONLY
    int smallest = numbers[numbers.length-1];
    for( int i = 0; i < numbers.length; i++ )
      if( smallest > numbers[i] ) smallest = numbers[i];
    
    int sm;
    int length = numbers.length;
    double shrink = 1.3;
    int gap = length;
    boolean done = false;

    while (!done)
    {
      gap = (int)Math.floor(gap/shrink);
      if (gap <= 1)
      {
        done = true;
        gap = 1;
      }

      for (int i = 0; i < length-gap; i++)
      {
        if( i == 0 && done && numbers[0] == smallest ) //NOT FOND OF THIS
          steps.add( new CompareStep( -1, 0, true ) );
          
        sm = gap + i;
        steps.add( new CompareStep( i, sm ) );
        
        if (numbers[i] > numbers[sm])
        {
          steps.add( new SwapStep( i, sm, false ) );
          //if( gap == 1 && i == 0 )
          //  steps.get( steps.size()-1 ).markSorted();
          int temp = numbers[i];
          numbers[i] = numbers[sm];
          numbers[sm] = temp;
          done = false;
        }
        if( done )
          steps.get( steps.size()-1 ).markSorted();
      }
    }

    steps.add( new FinishedStep() );
    sorted = true;
  }
}

// **************
// *  SHREDDER  * //Start by eliminating the turtles!
// ************** // Ritchie
class ShredderSort extends SortBehavior
{
  public String toString()
  {
    return "Shredder";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    if( unsafe(numbers) ) return;
    
    int sm;
    int length = numbers.length;
    double shrink = 1.3;
    int gap = length;
    boolean done = false;

    //Run Comb
    while (!done)
    {
      gap = (int)Math.floor(gap/shrink);

      //Exit when enough combing has been done
      if( gap <= 4.5 )
        break;
      
      if (gap <= 1)
      {
        done = true;
        gap = 1;
      }

      for (int i = 0; i < length-gap; i++)
      {
        sm = gap + i;
        steps.add( new CompareStep( i, sm ) );
        if (numbers[i] > numbers[sm])
        {
          steps.add( new SwapStep( i, sm, false ) );
          int temp = numbers[i];
          numbers[i] = numbers[sm];
          numbers[sm] = temp;
          done = false;
        }
      }
    }
    
    //Run Insertion
    for( int i = 1; i < numbers.length; i++ )
    { 
      //Move backward through the numbers until a smaller value is found or end is reached
      for( int j = i; j > 0; j-- )
      {
        //Swap values if previous neighbor is larger
        //comparisons++;
        steps.add( new CompareStep( j, j-1 ) );
        if( numbers[j] < numbers[j-1] )
        {
          //swaps++;
          steps.add( new SwapStep( j, j-1, false ) );
          int temp = numbers[j];
          numbers[j] = numbers[j-1];
          numbers[j-1] = temp;
        }
        else break;
      }
    }

    steps.add( new FinishedStep() );
  }
}

// ***************
// *  SELECTION  *
// ***************
class SelectionSort extends SortBehavior
{
  public String toString()
  {
    return "Selection";
  }
  
  public void runSort(int[] numbers, ArrayList<SortStep> steps)
  {
    if( unsafe(numbers) ) return;
    
    //Starting with each index...
    for( int i = 0; i < numbers.length-1; i++ )
    {
      //Assume starting value is the smallest
      int smallestIndex = i;
      
      //Go through rest of list to see if a value is smaller
      for( int j = i+1; j < numbers.length; j++ )
      {
        //Change index if a smaller is found
        //comparisons++;
        steps.add( new CompareStep( smallestIndex, j ) );
        if( numbers[j] < numbers[smallestIndex] ) smallestIndex = j;
      }
      
      //Swap position with new smallest (if needed)
      if( smallestIndex == i ) 
      {
        steps.remove( steps.size()-1 );
        steps.add( new CompareStep( i, i, true ) );
        continue;
      }
      
      steps.add( new SwapStep( smallestIndex, i, true ) );
      int temp = numbers[smallestIndex];
      numbers[smallestIndex] = numbers[i];
      numbers[i] = temp;
    }
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
}

// *********************
// * DOUBLE SELECTION  * //Shows actual behavior, not theoretical upper bound
// *********************
class DoubleSelectionSort extends SortBehavior
{
  public String toString()
  {
    return "Double Selection";
  }
  
  public void runSort(int[] numbers, ArrayList<SortStep> steps)
  {
    if( unsafe(numbers) ) return;
    
    int left = 0;
    int right = numbers.length - 1;
    
    while (left < right)
    {
      int min = left;
      int max = left;
  
      for (int j = left + 1; j <= right; j++)
      {
        steps.add( new CompareStep( j, min ) );
        if (numbers[j] < numbers[min])
          min = j;
        else if (numbers[j] > numbers[max])
        {
          steps.add( new CompareSecondStep( j, max ) );
          max = j;
        }
      }
  
      // swap min to left
      int temp = numbers[min];
      numbers[min] = numbers[left];
      numbers[left] = temp;
      steps.add( new SwapStep( min, left, true ) );
  
      // fix max index if it was swapped
      if (max == left) max = min;
  
      // swap max to right
      temp = numbers[max];
      numbers[max] = numbers[right];
      numbers[right] = temp;
      steps.add( new SwapSecondStep( max, right, true ) );
  
      left++;
      right--;
    }
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
}

// ***************
// *  INSERTION  *
// ***************
class InsertionSort extends SortBehavior
{
  public String toString()
  {
    return "Insertion";
  }
  public void runSort( int[] numbers, ArrayList<SortStep> steps)
  {
    if( unsafe(numbers) ) return;
    
    //Look at each item after the first
    for( int i = 1; i < numbers.length; i++ )
    { 
      //Move backward through the numbers until a smaller value is found or end is reached
      for( int j = i; j > 0; j-- )
      {
        //Swap values if previous neighbor is larger
        //comparisons++;
        steps.add( new CompareStep( j, j-1 ) );
        if( numbers[j] < numbers[j-1] )
        {
          //swaps++;
          steps.add( new SwapStep( j, j-1, false ) );
          int temp = numbers[j];
          numbers[j] = numbers[j-1];
          numbers[j-1] = temp;
        }
        else break;
      }
    }
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
}

// **********************
// *  BINARY INSERTION  *
// **********************
class BinaryInsertion extends SortBehavior
{
  public String toString()
  {
    return "Binary Insertion";
  }
  public void runSort( int[] numbers, ArrayList<SortStep> steps)
  {
    if( unsafe(numbers) ) return;
    
    for( int i = 1; i < numbers.length; i++ )
    {
      int value = numbers[i];
      int target = binarySearch( numbers, i, steps );
      
      for( int current = i; current > target; current-- )
      {
        steps.add( new AssignStep( current, numbers[current], numbers[current-1], false ) );
        numbers[current] = numbers[current-1];
      }
      
      steps.add( new AssignStep( target, numbers[target], value, false ) );
      numbers[target] = value;
    }
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
  
  private int binarySearch( int[] numbers, int targetIndex, ArrayList<SortStep> steps )
  {
    int low = 0, high = targetIndex;
    int target = numbers[targetIndex];
    
    //Find value's place
    while( low < high )
    {
      int mid = (low+high)/2;
      
      steps.add( new CompareStep( mid, targetIndex) );
      
      if( numbers[mid] > target )
        high = mid;
      else
        low = mid+1;
    }
    
    return low;
  }
}

// ***********
// *  GNOME  *
// ***********
class GnomeSort extends SortBehavior
{
  public String toString()
  {
    return "Gnome";
  }
  public void runSort( int[] numbers, ArrayList<SortStep> steps)
  {
    if( unsafe(numbers) ) return;
    
    int i = 0;
    
    while( i < numbers.length )
    {
      if( i == 0 ) i++;
      
      steps.add( new CompareStep( i, i-1 ) );
      if( numbers[i] >= numbers[i-1] )
        i++;
      else
      {
        steps.add( new SwapStep( i, i-1, false ) );
        int temp = numbers[i];
        numbers[i] = numbers[i - 1];
        numbers[i - 1] = temp;
        i--;
      }
    }
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
}

// ************
// *  BUCKET  * //Has some logical issues
// ************
// * Coronado *
// ************
class BucketSort extends SortBehavior
{
  public String toString()
  {
    return "Bucket";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    //int [] orderedList = new int [numbers.length];

    //INITILIZE ARRAY OF LINKED LIST
    ArrayList<Integer> [] bufferList = new ArrayList[numbers.length];
    
    //INITILIZE LINKED LISTS INSIDE EACH ARRAY
    for (int i = 0; i < numbers.length; i++)
        bufferList[i] = new ArrayList<>();
    
    //GETS LARGEST INT FOR "IMPORTATNCE" FORMULA
    int largestInt = getLargestInt(numbers);
    
    bufferList = sortIntoBuckets(numbers, largestInt);

    System.arraycopy(moveIntoList(bufferList, numbers.length), 0, numbers, 0, numbers.length);
  }
  public int getLargestInt(int [] unorderedList)
  {
    int longest = 0;
    for (int number : unorderedList)
      if (longest < number)
        longest = number;
    return longest;
  }
  public ArrayList<Integer> [] sortIntoBuckets(int [] unorderedList, int largestInt)
  {
    ArrayList<Integer> [] bufferList = new ArrayList[unorderedList.length];
    for (int i = 0; i < unorderedList.length; i++)
        bufferList[i] = new ArrayList<>();
    
    for (int number : unorderedList)
    {
        int index = (number * unorderedList.length) / (largestInt+1); 
        ArrayList<Integer> bucket = bufferList[index];
        bucket.add(number);
    }
    return bufferList;   
  }
  public int [] moveIntoList(ArrayList<Integer> [] bufferList, int size) 
  {
    int [] orderedList = new int [size];
    int counter = 0;
    
    for (ArrayList<Integer> bucket : bufferList) 
    {
      if (bucket.size() > 0) 
      {
        for (int i = 0; i < bucket.size()+i; i++) 
        {
          int smallestNum = 0;
          
          for (int j = 0; j < bucket.size(); j++) 
            if (bucket.get(smallestNum) >= bucket.get(j)) 
              smallestNum = j;

          orderedList[counter++] = bucket.get(smallestNum);
          bucket.remove(smallestNum);
        }
      }
    }
    return orderedList;
  }
}

// ***********
// *  RADIX  * //Needs to be counted differently
// ************
// * Coronado *
// ************
class RadixSort extends SortBehavior
{
  public String toString()
  {
    return "Radix";
  }
    
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    int [] orderedList = new int[numbers.length];
     
    ArrayList<String> bufferList = new ArrayList<>();
    ArrayList<String> zeroList = new ArrayList<>();
    ArrayList<String> oneList = new ArrayList<>();
    
    int longestString = 0;
    
    /* Converts unordered list into their binary value written backwards */
    for (int n = 0; n < numbers.length; n++) 
    {
      String binaryString = "";
      int binaryNum = numbers[n];
      while(binaryNum > 0)
      {
        binaryString =  binaryString + (binaryNum%2);
        binaryNum = binaryNum/2;
        }
        
        /* Finds longest number */
        if (longestString < binaryString.length())
        {
          longestString = binaryString.length();
        }
      
      bufferList.add(binaryString);
    }
    
    /* Iterates through each digit int the binary value */
    for (int l = 0; l < longestString; l++)
    { 
      for (String binaryString : bufferList)
      {
        int binaryNum = 0;
        /*if its short than we need the default value is 0; 
        becuase 101000 = 101.
        this is also why it is written backwards. Because it should start at the
        first digit from the right.*/
        try
        { 
          comparisons++;
          binaryNum = Integer.parseInt(binaryString.split("")[l]);
        }
        catch (Exception e)
        {
          swaps++;
          zeroList.add(binaryString);
          continue;
        }
        
        if ((binaryNum == 1))
        {
          swaps++;
          oneList.add(binaryString);
        } 
        else
        {
          swaps++;
          zeroList.add(binaryString);
        }
      }
      
      bufferList.clear();
      bufferList.addAll(zeroList);
      bufferList.addAll(oneList);
      oneList.clear();
      zeroList.clear();
      /* the code right above is to append both ordered list to buffer to
      itereate through again. */
    }
    
    /* turns the binary back into base 10 values */
    for (int i = 0; i < bufferList.size(); i++)
    {
      int finalNumber = 0;
      int mult = 1;
      String binaryNum = bufferList.get(i);
      
      for(int l = 0; l < binaryNum.length(); l++)
      {
        int currentNum = Integer.parseInt(""+binaryNum.charAt(l));
        if (currentNum == 1)
        {
          finalNumber+=mult;
        }
        mult*=2;
      }
      orderedList[i] = finalNumber;
    }
    
    System.arraycopy(orderedList, 0, numbers, 0, numbers.length);

    sorted = true;
  }
}

// ***********
// *  QUICK  *
// ***********
class QuickSort extends SortBehavior
{
  public String toString()
  {
    return "QuickSort";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    if( unsafe(numbers) ) return;
    
    quicksortSubarray( numbers, 0, numbers.length-1, steps );
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
  public void untrackedSort( int[] numbers ) //For running sorts that don't need to be tracked (creating number lists)
  {
    ArrayList<SortStep> blankList = new ArrayList<SortStep>();
    runSort( numbers, blankList );
  }
  
  // Quicksort helpers
  public int partition( int[] numbers, int start, int end, ArrayList<SortStep> steps )
  {
    int pivot = numbers[end];
    int left = start;
    int right = end-1;
    
    //Continue while the left and right indices have not "crossed"
    while( left <= right )
    {
      //Find next left-side value to swap
      while( left <= end && numbers[left] < pivot )
      {
        comparisons++;
        steps.add( new CompareStep( left, end ) );
        left++;
      }
      //Find next right-side value to swap
      while( right >= start && numbers[right] >= pivot )
      {
        comparisons++;
        steps.add( new CompareStep( right, start ) );
        right--;
      }
      
      //Swap values (indices have not crossed yet)
      if( left < right )
      {
        swaps++;
        steps.add( new SwapStep( left, right, false ) );
        int temp = numbers[left];
        numbers[left] = numbers[right];
        numbers[right] = temp;
      }
      //Indices have crossed - move pivot
      else
      {
        swaps++;
        steps.add( new SwapStep( left, end, false ) );
        int temp = numbers[left];
        numbers[left] = numbers[end];
        numbers[end] = temp;
      }
    }
    
    //Returns the new pivot
    return left;
  }
  public void quicksortSubarray( int[] numbers, int start, int end, ArrayList<SortStep> steps )
  {
    //The recursive branch is finished
    if( start >= end )
    {
      //steps.get( steps.size()-1 ).markSorted();
      return;
    }
    //Divide the working array in half
    int pivot = partition( numbers, start, end, steps );
    
    //Sort the two arrays on either side of the pivot (the pivot is sorted)
    quicksortSubarray( numbers, start, pivot-1, steps );
    quicksortSubarray( numbers, pivot+1, end, steps );
  }
}

// ******************
// * PRECISE QUICK  *
// ******************
class PreciseQuick extends SortBehavior
{
  public String toString()
  {
    return "Precise Quick";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    if( unsafe(numbers) ) return;
    
    quicksortSubarray( numbers, 0, numbers.length-1, steps );
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
  
  // Quicksort helpers
  private int findClosestToMean( int [] numbers, int start, int end, ArrayList<SortStep> steps )
  {
    //Find mean
    int total = 0;
    for( int i = start; i <= end; i++ )
      total += numbers[i];
    int mean = total / (end-start+1);
    
    //Find index of element closest to mean
    int closestIndex = start;
    for( int i = start+1; i <= end; i++ )
    {
      steps.add( new CompareStep( i, closestIndex ) );
      if( abs( numbers[i] - mean ) < abs( numbers[closestIndex] - mean ) )
        closestIndex = i;
    }
    return closestIndex;
  }
  public int partition( int[] numbers, int start, int end, ArrayList<SortStep> steps )
  {
    int pivot, pivotIndex;
    if (end - start + 1 < 5)
      pivot = numbers[end];
    else
    {
      pivotIndex = findClosestToMean( numbers, start, end, steps );
      steps.add(new SwapStep(pivotIndex, end, false ));
      int temp = numbers[pivotIndex];
      numbers[pivotIndex] = numbers[end];
      numbers[end] = temp;
      pivot = numbers[end];
    }
    
    int left = start;
    int right = end - 1;
    int pivotPos = end;
    pivot = numbers[pivotPos];
    
    while (true)
    {
        while (left <= right && numbers[left] < pivot)
        {
            comparisons++;
            steps.add(new CompareStep(left, pivotPos));
            left++;
        }
    
        while (left <= right && numbers[right] >= pivot)
        {
            comparisons++;
            steps.add(new CompareStep(right, pivotPos));
            right--;
        }
    
        if (left < right)
        {
            swaps++;
            steps.add(new SwapStep(left, right, false));
            int t = numbers[left];
            numbers[left] = numbers[right];
            numbers[right] = t;
    
            // crucial: force progress after a swap
            left++;
            right--;
        }
        else
        {
            break;
        }
    }
    
    // place pivot once, after scanning
    swaps++;
    steps.add(new SwapStep(left, pivotPos, false));
    int t = numbers[left];
    numbers[left] = numbers[pivotPos];
    numbers[pivotPos] = t;
    
    return left;
  }
  public void quicksortSubarray( int[] numbers, int start, int end, ArrayList<SortStep> steps )
  {
    //The recursive branch is finished
    if( start >= end ) return;
    
    //Divide the working array in half
    int pivot = partition( numbers, start, end, steps );
    
    //Sort the two arrays on either side of the pivot (the pivot is sorted)
    quicksortSubarray( numbers, start, pivot-1, steps );
    quicksortSubarray( numbers, pivot+1, end, steps );
  }
}

// *****************
// * RANDOM QUICK  *
// *****************
class RandomQuick extends SortBehavior
{
  public String toString()
  {
    return "Random Quick";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    if( unsafe(numbers) ) return;
    
    quicksortSubarray( numbers, 0, numbers.length-1, steps );
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
  
  // Quicksort helpers
  public int partition( int[] numbers, int start, int end, ArrayList<SortStep> steps )
  {
    int pivot, pivotIndex;
    if (end - start + 1 < 5)
      pivot = numbers[end];
    else
    {
      pivotIndex = int(random(start,end+1));
      steps.add(new SwapStep(pivotIndex, end, false));
      int temp = numbers[pivotIndex];
      numbers[pivotIndex] = numbers[end];
      numbers[end] = temp;
      pivot = numbers[end];
    }
    
    int left = start;
    int right = end - 1;
    int pivotPos = end;
    pivot = numbers[pivotPos];
    
    while (true)
    {
        while (left <= right && numbers[left] < pivot)
        {
            comparisons++;
            steps.add(new CompareStep(left, pivotPos));
            left++;
        }
    
        while (left <= right && numbers[right] >= pivot)
        {
            comparisons++;
            steps.add(new CompareStep(right, pivotPos));
            right--;
        }
    
        if (left < right)
        {
            swaps++;
            steps.add(new SwapStep(left, right, false));
            int t = numbers[left];
            numbers[left] = numbers[right];
            numbers[right] = t;
    
            // crucial: force progress after a swap
            left++;
            right--;
        }
        else
        {
            break;
        }
    }
    
    // place pivot once, after scanning
    swaps++;
    steps.add(new SwapStep(left, pivotPos, false));
    int t = numbers[left];
    numbers[left] = numbers[pivotPos];
    numbers[pivotPos] = t;
    
    return left;
  }
  public void quicksortSubarray( int[] numbers, int start, int end, ArrayList<SortStep> steps )
  {
    //The recursive branch is finished
    if( start >= end ) return;
    
    //Divide the working array in half
    int pivot = partition( numbers, start, end, steps );
    
    //Sort the two arrays on either side of the pivot (the pivot is sorted)
    quicksortSubarray( numbers, start, pivot-1, steps );
    quicksortSubarray( numbers, pivot+1, end, steps );
  }
}

// ***********
// *  SHELL  * //Needs documentation
// ***********
class ShellSort extends SortBehavior
{
  public String toString()
  {
    return "Shell";
  }
  
  public void runSort( int[] numbers, ArrayList<SortStep> steps )
  {
    if( unsafe(numbers) ) return;
    
    int n = numbers.length;

    for (int gap = n / 2; gap > 0; gap /= 2) 
    {
      for (int i = gap; i < n; i++) 
      {
        int key = numbers[i];
        int j = i;
        while (j >= gap)
        {
            steps.add(new CompareStep(j - gap, 0)); //replace this zero when comparisons are properly implemented
            if (numbers[j - gap] > key)
            {
                steps.add(new AssignStep(j, numbers[j], numbers[j - gap], false));
                numbers[j] = numbers[j - gap];
                j -= gap;
            }
            else
                break;
        }
        steps.add( new AssignStep( j, numbers[j], key, false ) );
        numbers[j] = key;
      }
    }
    
    steps.add( new FinishedStep() );
    sorted = true;
  }
}

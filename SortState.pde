interface SortStep
{
  public void perform( int[] list );
  public void reverse( int[] list );
  public void markSorted();
}

class CompareStep implements SortStep
{
  int index;
  int prospective;
  boolean sorted;
  
  CompareStep( int index, int prospective )
  {
    this.index = index;
    this.prospective = prospective;
  }
  
  CompareStep( int index, int prospective, boolean sorted )
  {
    this.index = index;
    this.prospective = prospective;
    this.sorted = sorted;
  }
  
  public void perform( int[] list )
  {
    //println("Compare Performed");
  }
  
  public void reverse( int[] list )
  {
    
  }
  
  public void markSorted()
  {
    sorted = true;
  }
  
  public String toString()
  {
    return "Index: " + index + "    Prospect: " + prospective;
  }
}

class CompareSecondStep implements SortStep
{
  int index;
  int prospective;
  boolean sorted;
  
  CompareSecondStep( int index, int prospective )
  {
    this.index = index;
    this.prospective = prospective;
  }
  
  public void perform( int[] list )
  {
    //println("Compare Performed");
  }
  
  public void reverse( int[] list )
  {
    
  }
  
  public void markSorted()
  {
    sorted = true;
  }
}

class SwapStep implements SortStep
{
  int index;
  int swappedIndex;
  boolean sorted;
  
  SwapStep( int index, int swappedIndex, boolean sorted )
  {
    this.index = index;
    this.swappedIndex = swappedIndex;
    this.sorted = sorted;
  }
  
  public void perform( int[] list )
  {
    int temp = list[index];
    list[index] = list[swappedIndex];
    list[swappedIndex] = temp;
  }
  
  public void reverse( int[] list )
  {
    perform(list);
  }
  
  public void markSorted()
  {
    sorted = true;
  }
  
  public String toString()
  {
    return "Index: " + index + "    Swap Index: " + swappedIndex;
  }
}

class SwapSecondStep implements SortStep
{
  int index;
  int swappedIndex;
  boolean sorted;
  
  SwapSecondStep( int index, int swappedIndex, boolean sorted )
  {
    this.index = index;
    this.swappedIndex = swappedIndex;
    this.sorted = sorted;
  }
  
  public void perform( int[] list )
  {
    int temp = list[index];
    list[index] = list[swappedIndex];
    list[swappedIndex] = temp;
  }
  
  public void reverse( int[] list )
  {
    perform(list);
  }
  
  public void markSorted()
  {
    sorted = true;
  }
  
  public String toString()
  {
    return "Index: " + index + "    Swap Index: " + swappedIndex;
  }
}

class AssignStep implements SortStep
{
  int index;
  int oldValue;
  int newValue;
  boolean sorted;
  
  AssignStep( int index, int oldValue, int newValue, boolean sorted )
  {
    this.index = index;
    this.oldValue = oldValue;
    this.newValue = newValue;
    this.sorted = sorted;
  }
  
  public void perform( int[] list )
  {
    list[index] = newValue;
  }
  
  public void reverse( int[] list )
  {
    list[index] = oldValue;
  }
  
  public void markSorted()
  {
    sorted = true;
  }
  
  public String toString()
  {
    return "Index: " + index + "    Old: " + oldValue + "     New: " + newValue;
  }
}

class FinishedStep implements SortStep
{
  public void perform( int list[] ){}
  public void reverse( int list[] ){}
  public void markSorted(){}
}

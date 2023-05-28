
import lib : assertString, DebugType, writeStack, dbgwritelnMixin, NonemptyString;


// ea1a22f8-0479-51bb-a48f-96fb08093453
struct ExecutionLocation {
  ulong arrayIndex;
  alias arrayIndex this;
  
  bool doContinue = true;
  
  this(ulong arrayIndex_) { arrayIndex = arrayIndex_; }
  
  static stop() {
    ExecutionLocation ret;
    ret.doContinue = false;
    return ret;
  }
}

// 6d89e176-da78-5b14-87d0-00e37ef842b1
alias Command(ExtraArgs...) = ExecutionLocation function(CommandLibrary!ExtraArgs, NonemptyString[] wordArray, ExecutionLocation, ExtraArgs);

// 248a6fd1-a910-501c-a78a-42f951e33362
struct CommandLibrary(ExtraArgs...) {
  Command!ExtraArgs[NonemptyString] mapForm;
  alias mapForm this;
}

// ac815fe1-ba04-5407-b09f-47d7a391bbe9
void throwNotCommandWordException(LocArrayOrEmpty, WordsOrEmpty)(NonemptyString currentWord, ExecutionLocation currentLocation, LocArrayOrEmpty prevLocations, WordsOrEmpty executedWords) {
  import std.conv;
  debug mixin(dbgwritelnMixin("currentWord", "currentLocation", "prevLocations", "executedWords"));
  throw new Exception("Word \"" ~ currentWord ~ "\" at array location " ~ currentLocation.arrayIndex.to!string ~ " is not a command word, but execution tried to use it as one, aborting...");
}
// ac815fe1-ba04-5407-b09f-47d7a391bbe9
void throwSameLocationException(LocArrayOrEmpty, WordsOrEmpty)(NonemptyString currentWord, ExecutionLocation currentLocation, LocArrayOrEmpty prevLocations, WordsOrEmpty executedWords) {
  import std.conv;
  debug mixin(dbgwritelnMixin("currentWord", "currentLocation", "prevLocations", "executedWords"));
  throw new Exception("Command word \"" ~ currentWord ~ "\" at array location " ~ currentLocation.arrayIndex.to!string ~ " executed without errors but returned the same execution position, producing an infinite loop, aborting...");
}

// ecfff4b3-d802-5d85-bb13-6c4bae4fb262
ExecutionLocation execute(ExtraArgs...)(CommandLibrary!ExtraArgs commandLibrary, NonemptyString[] wordArray, ExecutionLocation startLocation, ExtraArgs extraArgs) {
  DebugType!ExecutionLocation[] prevLocations;
  DebugType!NonemptyString[] executedWords;
  
  ExecutionLocation lastLocation = startLocation;
  ExecutionLocation currentLocation = startLocation;
  
  while(currentLocation.doContinue && currentLocation.arrayIndex < wordArray.length) {
    
    NonemptyString currentWord = wordArray[currentLocation.arrayIndex];
    
    // try getting command
    Command!(ExtraArgs)* maybeCommand = currentWord in commandLibrary;
    if(maybeCommand is null)
      throwNotCommandWordException(currentWord, currentLocation, prevLocations, executedWords);
    auto command = *maybeCommand;
    
    // call command and update location
    debug prevLocations ~= currentLocation;
    lastLocation = currentLocation;
    currentLocation = command(commandLibrary, wordArray, currentLocation, extraArgs);
    debug executedWords ~= currentWord;
    if(currentLocation == lastLocation)
      throwSameLocationException(currentWord, currentLocation, prevLocations, executedWords);
  }
  return ExecutionLocation.stop;
}

// a58a72be-7428-5a73-aeb8-c2c09a329cb5
version(assert) {
  CommandLibrary!(int*, int[]*) unittestCmdLib;
  static this() {
    unittestCmdLib = CommandLibrary!(int*, int[]*)([
    
      NonemptyString("print"): (CommandLibrary!(int*, int[]*) cmds, NonemptyString[] words, ExecutionLocation loc, int* x, int[]* array) {
        import std.stdio : writeln;
        NonemptyString nextWord = words[loc + 1];
        writeln(nextWord);
        return ExecutionLocation(loc + 2);
      },
    
      NonemptyString("printArg"): (CommandLibrary!(int*, int[]*) cmds, NonemptyString[] words, ExecutionLocation loc, int* x, int[]* array) {
        import std.stdio : writeln;
        import std.conv : parse, ConvException;
        NonemptyString nextWord = words[loc + 1];
        ulong argNumber = nextWord.parse!ulong;
        if(argNumber == 1)
          writeln(*x);
        else if(argNumber == 2)
          writeln(*array);
        return ExecutionLocation(loc + 2);
      },
      
      NonemptyString("increment"): (CommandLibrary!(int*, int[]*) cmds, NonemptyString[] words, ExecutionLocation loc, int* x, int[]* array) {
        (*x)++;
        return ExecutionLocation(loc + 1);
      },
      
      NonemptyString("reverse"): (CommandLibrary!(int*, int[]*) cmds, NonemptyString[] words, ExecutionLocation loc, int* x, int[]* array) {
        int[] oldArray = (*array).dup;
        ulong i = 0, j = array.length - 1;
        while(i < array.length) {
          (*array)[i] = oldArray[j];
          i++; j--;
        }
        return ExecutionLocation(loc + 1);
      }
      
    ]);
  }
}

unittest {
  import lib : literalAs;
  NonemptyString[] wordArray = literalAs!(NonemptyString, [
    "print", "printArg-unittest-print!",
    "increment",
    "printArg", "1",
    "reverse",
    "printArg", "2"
  ]);
  int x = 5;
  int[] array = [3, 5, 7];
  ExecutionLocation finalLocation = execute(unittestCmdLib, wordArray, ExecutionLocation(0), &x, &array);
  mixin(assertString("x == 6", "finalLocation", "finalLocation.doContinue", "x", "array"));
  mixin(assertString("array == [7, 5, 3]", "finalLocation", "finalLocation.doContinue", "x", "array"));
  mixin(assertString("!finalLocation.doContinue", "finalLocation", "finalLocation.doContinue", "x", "array"));
}
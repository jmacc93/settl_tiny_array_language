
Note: TAL stands for Tiny Array Language itc

---

`ea1a22f8-0479-51bb-a48f-96fb08093453`

`ExecutionLocation`

Represents either:

* An index in an array of command words `NonemptyString[]`
* A signal to stop execution -- when its `doContinue` property is `false`

The `arrayIndex` is considered valid when `doContinue` is `true`, otherwise the `ExecutionLocation` is considered a signal to stop

---

`6d89e176-da78-5b14-87d0-00e37ef842b1`

`Command!(ArgType1, ArgType2, ...)`

Stands for `ExecutionLocation function(CommandLibrary!ExtraArgs, NonemptyString[] wordArray, ExecutionLocation, ExtraArgs)` -- ie: a function that returns an `ExecutionLocation` (a new location to execute, or a stop signal), and takes the command library being used, the source word sequence, the current execution location (should be the location of the current `Command` itself, and any extra arguments the user of the `tiny_array_language` library want

These functions are the commands the TAL uses to function. `CommandLibrary`s map `NonemptyString`s to them. Words in a `NonemptyString[]` source word sequence are mapped by `CommandLibrary` to them

`Command!(...)` functions know they execution locations so they know where to look for their "arguments", and where to return to. A `Command` argument is just another word from a `wordArray`. If a `Command` needs that word to be a number, or whatever, it needs to convert it to that form internally

The `ExecutionLocation` returned by a `Command!(...)` should be the next command in the sequence. If this `Command!(...)` takes no arguments then that is probably `currentExecutionLocation + 1` where `currentExecutionLocation` is the `ExecutionLocation` this `Command` is called with

All `Command`s are defined by the users of this module

---

`ac815fe1-ba04-5407-b09f-47d7a391bbe9`

`CommandLibrary!(ArgType1, ...)`

Proxy for an associative array from `NonemptyString` values to `Command!(ArgType1, ...)` values (see above, a `Command!(...)` is a function in the TAL). This is the library for all the TAL commands that are recognized

---

`ecfff4b3-d802-5d85-bb13-6c4bae4fb262`

`ExecutionLocation execute(CommandLibrary!(...) commandLibrary, NonemptyString[] wordArray, ExecutionLocation startingExecutionLocation, extraArgs...)`

This is actually a `Command!(...)` that:

1. Gets the `wordArray` element at the `currentExecutionLocation`
2. Gets the corresponding `Command` from the `commandLibrary` for the current `wordArray` word
3. Calls the found `Command` and sets the `currentExecutionLocation` to its return value
4. Continues doing this until the `currentExecutionLocation` is outside the `wordArray` or its `doContinue` is false

This is the function to use when you want to actually run the TAL on a command library, and list of words

Note: the `wordArray` is a list of `string`s, so if a particular `Command` needs one of those words to be a different datatype, that command needs to interpret the word into that type

---

`a58a72be-7428-5a73-aeb8-c2c09a329cb5`

This block defines the `CommandLibrary` used for the unittests. Look at this to see how a command library should look

`9e84ee16-f095-5414-af5d-440bc82a4e86`

This block is an example usage of the above-defined unittest `CommandLibrary` in a `execute` call. Look here to see how to use `execute`






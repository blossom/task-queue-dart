# Task Queue

A queue to schedule task to run in sequence always waiting for the previous task to be completed.

## Example

    TaskQueue queue = new TaskQueue();

    Future function() {
      var completer1 = new Completer();
      Timer.run(expectAsync0(() => completer1.complete(1)));
      return completer1.future;
    }

    Future function2() {
      var completer2 = new Completer();
      Timer.run(expectAsync0(() => completer2.complete(2)));
      return completer2.future;
    }

    // function2 will only start to run after function has been completed
    Future future1 = queue.schedule(function);
    Future future2 = queue.schedule(function2);

## Further Improvments

* Allow to iterate of the items in the queue.
* Remove a specific item from the queue.
* Allow to stop the queue on error.

## Initial Requirements

* Add Task to Queue
* Execute Queue in the right order
* Execute one Task after another
* Allow to check if the queue is empty and no task is running
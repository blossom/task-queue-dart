library task_queue;

import "dart:async";
import "dart:collection";

part "src/task_queue_entry.dart";

/*
 * A [Function] returning a [Future]
 */
typedef Future Task();

/*
 * A collection to schedule [Task]s to run in sequence always waiting for the
 * previous [Task] to be completed.
 *
 * Example:
 *
 *     TaskQueue queue = new TaskQueue();
 *
 *     Future function1() {
 *       var completer = new Completer();
 *       Timer.run(() => completer.complete(1));
 *       return completer.future;
 *     }
 *
 *     Future function2() {
 *       var completer = new Completer();
 *       Timer.run(() => completer.complete(1));
 *       return completer.future;
 *     }
 *
 *     // function2 will only start to run after function1 has been completed
 *     Future future1 = queue.schedule(function);
 *     Future future2 = queue.schedule(function2);
 */
class TaskQueue {

  Queue<TaskQueueEntry> _tasks = new Queue();
  Completer _recentActiveCompleter;

  /*
   * Schedules a Task and returns a Future which will complete when the Task
   * has been finished.
   *
   * The task will be append to the queue and run after every task added before
   * has been executed.
   */
  Future schedule(Task function, {List positionalArguments,
    Map<Symbol, dynamic> namedArguments}) {
    var taskEntry = new TaskQueueEntry(function, positionalArguments,
        namedArguments, new Completer());
    _tasks.add(taskEntry);

    // Only run the just added task in case the queue hasn't been used yet or
    // the last task has been executed
    if(_recentActiveCompleter == null || _recentActiveCompleter.isCompleted) {
      _runNext();
    }
    return taskEntry.completer.future;
  }

  /*
   * Runs the next available [Task] in the queue.
   */
  void _runNext() {
    if (_tasks.isNotEmpty) {
      var taskEntry = _tasks.first;
      _recentActiveCompleter = taskEntry.completer;

      Function.apply(taskEntry.function, taskEntry.positionalArguments,
          taskEntry.namedArguments).then((value) {
        _tasks.removeFirst();
        // Already start with the next task since the current one is
        // already done.
        _runNext();
        taskEntry.completer.complete(value);
      }).catchError((error) {
        _tasks.removeFirst();
        _runNext();
        taskEntry.completer.completeError(error);
      });
    }
  }

  /*
   * Returns true if there is at least one still running [Task] in the queue.
   */
  bool get isActive {
    if (_recentActiveCompleter == null) {
      return _tasks.isNotEmpty;
    } else {
      return !(_tasks.isEmpty && _recentActiveCompleter.isCompleted);
    }
  }
}
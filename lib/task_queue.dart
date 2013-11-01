library task_queue;

import "dart:async";
import "dart:collection";

part "src/task_queue_entry.dart";

typedef Future Task();

/*
 *
 */
class TaskQueue {

  Queue<TaskQueueEntry> _tasks = new Queue();
  Completer _recentActiveCompleter;

  /*
   * Schedules a Task and returns a Future indicating when the Task has been done.
   *
   * The task will be append to the queue and run after all before
   * added tasks have been executed.
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
   * Runs the next available task in the queue
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

  bool get isActive {
    if (_recentActiveCompleter == null) {
      return _tasks.isNotEmpty;
    } else {
      return !(_tasks.isEmpty && _recentActiveCompleter.isCompleted);
    }
  }
}
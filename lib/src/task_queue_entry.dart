part of task_queue;

class TaskQueueEntry {
  Function function;
  List positionalArguments;
  Map<Symbol, dynamic> namedArguments;
  Completer completer;

  TaskQueueEntry(this.function, this.positionalArguments, this.namedArguments,
      this.completer);
}

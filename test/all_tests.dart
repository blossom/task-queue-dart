library future_chain_test;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:task_queue/task_queue.dart';

main() {
  group('TaskQueue', () {
    TaskQueue queue;
    Completer completer1;
    Completer completer2;
    Completer completer3;
    bool function1Started = false;
    bool function2Started = false;
    bool function3Started = false;

    setUp(() {
      queue = new TaskQueue();
      completer1 = new Completer();
      completer2 = new Completer();
      completer3 = new Completer();
    });

    test('should execute the function added to the queue', () {
      Future function() {
        Timer.run(expectAsync0(() => completer1.complete(1)));
        return completer1.future;
      }

      Future future1 = queue.schedule(function);
      return future1.then((value) {
        expect(value, 1);
      });
    });

    test('should be active after adding a task', () {
      Future function() {
        Timer.run(expectAsync0(() => completer1.complete(1)));
        return completer1.future;
      }

      expect(queue.isActive, isFalse);
      Future future1 = queue.schedule(function);
      expect(queue.isActive, isTrue);

      return future1.then((value) {
        expect(value, 1);
        expect(queue.isActive, isFalse);
      });
    });

    test('should run a new task in a queue which already was empty', () {
      Future function() {
        Timer.run(expectAsync0(() => completer1.complete(1)));
        return completer1.future;
      }

      Future function2() {
        Timer.run(expectAsync0(() => completer2.complete(2)));
        return completer2.future;
      }

      Future future1 = queue.schedule(function);
      future1.then((value) {
        expect(queue.isActive, isFalse);
        Future future2 = queue.schedule(function2);
        expect(future2, completes);
      });

      return Future.wait([future1, completer2.future]);
    });


    test('should execute in the order they have been added', () {
      Future function() {
        Timer.run(expectAsync0(() => completer1.complete(1)));
        return completer1.future;
      }

      Future function2() {
        function2Started = true;
        Timer.run(expectAsync0(() => completer2.complete(2)));
        return completer2.future;
      }

      Future function3() {
        function3Started = true;
        Timer.run(expectAsync0(() => completer3.complete(3)));
        return completer3.future;
      }

      Future future1 = queue.schedule(function);
      Future future2 = queue.schedule(function2);
      Future future3 = queue.schedule(function3);

      expect(function2Started, isFalse);
      expect(function3Started, isFalse);

      future1.then((value) {
        expect(value, 1);
        expect(function2Started, isTrue);
        expect(completer2.isCompleted, isFalse);
        expect(function3Started, isFalse);
        expect(completer3.isCompleted, isFalse);
      });

      future2.then((value) {
        expect(value, 2);
        expect(function2Started, isTrue);
        expect(function3Started, isTrue);
        expect(completer3.isCompleted, isFalse);
      });

      future3.then((value) {
        expect(value, 3);
      });

      expect(future1, completes);
      expect(future2, completes);
      expect(future3, completes);

      return Future.wait([future1, future2, future3]);
    });
  });
}
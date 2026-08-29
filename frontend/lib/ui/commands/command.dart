typedef CommandAction<T, U extends Record> = T Function(U);

abstract class Command<T, U extends Record> {
  CommandAction<T, U> action;
  U args;

  Command(this.action, this.args);
  T execute() {
    return action(args);
  }
}

/// [UndoableCommand]s act like [Command]s except that they allow the caller to undo their action.
abstract class UndoableCommand<T, U extends Record> extends Command<T, U> {
  UndoableCommand(super.action, super.args);
}

// abstract class UndoableAsyncCommand<T> extends UndoableCommand<Future<T>> {
//   UndoableAsyncCommand(super.ref);
// }

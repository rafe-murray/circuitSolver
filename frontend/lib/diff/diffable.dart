abstract interface class Diffable<T> {
  T applyTo(T original);
  T revertFrom(T original);
}

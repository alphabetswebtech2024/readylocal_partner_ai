/// First item matching [test], or [fallback].
///
/// Use this instead of `firstWhere(..., orElse: () => const SomeEntity())` on a
/// list of entities. Those lists really hold model subclasses, and Dart then
/// rejects the entity-returning `orElse` with a TypeError at runtime, even when
/// a match exists.
T firstOr<T>(Iterable<T> items, bool Function(T) test, T fallback) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return fallback;
}

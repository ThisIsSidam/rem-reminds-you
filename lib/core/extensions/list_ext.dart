extension ListExt<E> on List<E> {
  E? firstWhereOrNull(bool Function(E element) test, {E Function()? orElse}) {
    for (final E element in this) {
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    return null;
  }
}

import 'dart:mirrors';

import 'package:test/test.dart';

class ReflectiveMatcher<T> extends Matcher {
  final T expected;

  ReflectiveMatcher(this.expected);

  @override
  Description describe(Description description) => description.addDescriptionOf(expected);

  @override
  Description describeMismatch(Object item, Description mismatchDescription, Map matchState, bool verbose) {
    final result = super.describeMismatch(item, mismatchDescription, matchState, verbose);
    for (final key in matchState.keys) {
      result.add('\nMember $key ${matchState[key]}');
    }
    return result;
  }

  @override
  bool matches(Object item, Map matchState) {
    if ((expected == null) != (item == null)) {
      return false;
    }

    if (expected == null && item == null) {
      return true;
    }

    if (item is! T) {
      return false;
    }

    if (expected == item) {
      return true;
    }

    //Objects are same type, not null and not equals by == operator.
    return _matchReflectively(expected, item as T, matchState);
  }

  bool _matchReflectively(T expected, T actual, Map<Object, Object> matchState) {
    final reflectedExpected = reflect(expected);
    final reflectedActual = reflect(actual);

    //fields
    final publicFields = reflectedExpected.type.declarations.values
        .whereType<VariableMirror>()
        .where((v) => v.isStatic == false && v.isPrivate == false)
        .toList();
    for (var field in publicFields) {
      final expectedFieldValue = reflectedExpected.getField(field.simpleName).reflectee as Object;
      final actualFieldValue = reflectedActual.getField(field.simpleName).reflectee as Object;
      if (expectedFieldValue != actualFieldValue) {
        matchState[_nameFromSymbol(field.simpleName)] = 'expected to be $expectedFieldValue but was $actualFieldValue';
        return false;
      }
    }

    //getters
    final publicGetters = reflectedExpected.type.declarations.values
        .whereType<MethodMirror>()
        .where((m) => m.isStatic == false && m.isPrivate == false && m.isGetter)
        .where((m) => m.simpleName != const Symbol('hashCode'))
        .toList();
    for (var getter in publicGetters) {
      final expectedGetterValue = reflectedExpected.getField(getter.simpleName).reflectee as Object;
      final actualGetterValue = reflectedActual.getField(getter.simpleName).reflectee as Object;
      if (expectedGetterValue != actualGetterValue) {
        matchState[_nameFromSymbol(getter.simpleName)] =
            'expected to be $expectedGetterValue but was $actualGetterValue';
        return false;
      }
    }
    return true;
  }

  String _nameFromSymbol(Symbol symbol) => MirrorSystem.getName(symbol);
}

import 'package:test/test.dart';
import 'package:reflective_matcher/reflective_matcher.dart';

void main() {
  group('ReflectiveMatcher', () {
    group('simple cases', () {
      test('return true if both objects are nulls', () {
        final matcher = ReflectiveMatcher<int>(null);

        final isMatched = matcher.matches(null, <Object, Object>{});

        expect(isMatched, isTrue);
      });

      test('return false if objects have not same type', () {
        final matcher = ReflectiveMatcher<int>(1);

        final isMatched = matcher.matches('1', <Object, Object>{});

        expect(isMatched, isFalse);
      });

      test('return false if actual is null but expected is not null', () {
        final matcher = ReflectiveMatcher<int>(1);

        final isMatched = matcher.matches(null, <Object, Object>{});

        expect(isMatched, isFalse);
      });

      test('return false if actual is not null but expected is null', () {
        final matcher = ReflectiveMatcher<int>(null);

        final isMatched = matcher.matches(1, <Object, Object>{});

        expect(isMatched, isFalse);
      });

      test('return false if objects are different', () {
        final matcher = ReflectiveMatcher<int>(1);

        final isMatched = matcher.matches(2, <Object, Object>{});

        expect(isMatched, isFalse);
      });

      test('return true if objects are the same', () {
        final matcher = ReflectiveMatcher<int>(1);

        final isMatched = matcher.matches(1, <Object, Object>{});

        expect(isMatched, isTrue);
      });

      test('format description if objects are not same', () {
        final matcher = ReflectiveMatcher<int>(1);

        final description = matcher.describeMismatch(2, StringDescription(), <Object, Object>{}, false);

        expect(description.toString(), equals('lol'));
      });
    });

    group('for complex classes with fields', () {
      test('returns true if objects are match', () {
        final actual = A<int>(1, 2);
        final expected = A<int>(1, 2);
        final matcher = ReflectiveMatcher(expected);

        final result = matcher.matches(actual, <Object, Object>{});

        expect(result, isTrue);
      });

      test('returns false if objects are not matched', () {
        final actual = A<int>(1, 2);
        final expected = A<int>(1, 3);
        final matcher = ReflectiveMatcher(expected);

        final result = matcher.matches(actual, <Object, Object>{});

        expect(result, isFalse);
      });

      test('format description if objects are not same', () {
        final actual = A<int>(1, 2);
        final expected = A<int>(1, 3);
        final matcher = ReflectiveMatcher(expected);

        final matchState = <Object, Object>{};
        matcher.matches(actual, matchState);
        final description = matcher.describeMismatch(actual, StringDescription(), matchState, false);

        print(description);
        expect(description.toString(), equals('lol'));
      });

      test('Use test', () {
        final actual = A<int>(1, 2);
        final expected = A<int>(1, 3);

        expect(actual, ReflectiveMatcher(expected));
      });
    });

    group('for complex classes with getters', () {
      test('returns true if objects are match', () {
        final actual = B<int>(1, 2);
        final expected = B<int>(1, 2);
        final matcher = ReflectiveMatcher(expected);

        final result = matcher.matches(actual, <Object, Object>{});

        expect(result, isTrue);
      });

      test('returns false if objects are not matched', () {
        final actual = B<int>(1, 2);
        final expected = B<int>(1, 3);
        final matcher = ReflectiveMatcher(expected);

        final result = matcher.matches(actual, <Object, Object>{});

        expect(result, isFalse);
        expect(1, equals(2)); //TODO: delete
      });
    });
  });
}

class A<T> {
  final T a;
  final T b;

  A(this.a, this.b);
}

class B<T> {
  final T _a;
  final T _b;

  T get a => _a;
  T get b => _b;

  B(this._a, this._b);
}

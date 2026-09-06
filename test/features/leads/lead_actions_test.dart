import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/leads/presentation/widgets/lead_actions.dart';

void main() {
  test('Maps actions only accept web URLs with a real host', () {
    expect(LeadActions.isSafeMapsUrl('https://maps.app.goo.gl/place'), isTrue);
    expect(LeadActions.isSafeMapsUrl('http://maps.example/place'), isTrue);
    expect(LeadActions.isSafeMapsUrl('javascript:alert(1)'), isFalse);
    expect(LeadActions.isSafeMapsUrl('file:///private/place'), isFalse);
    expect(LeadActions.isSafeMapsUrl('not a link'), isFalse);
  });
}

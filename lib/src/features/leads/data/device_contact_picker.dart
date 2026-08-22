import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

/// One person the rep picked out of the phone's own address book.
class DeviceContact {
  const DeviceContact({required this.fullName, required this.phone});

  final String fullName;
  final String phone;

  bool get isEmpty => fullName.trim().isEmpty && phone.trim().isEmpty;
}

/// Reads ONE contact from the device address book through the operating
/// system's own picker.
///
/// Deliberately not a contacts-reading library: the picker runs out of process
/// (Android `ACTION_PICK`, iOS `CNContactPickerViewController`), so the app
/// never asks for the READ_CONTACTS permission and only ever receives the
/// single person the rep tapped. Nothing else in the address book is readable.
///
/// Android and iOS only. On web (the POS runs there too) and on desktop the
/// plugin has no implementation, so [isSupported] is false and [pickOne]
/// returns null rather than throwing a MissingPluginException at the user.
class DeviceContactPicker {
  const DeviceContactPicker();

  /// Whether this build can open the OS contact picker at all. Callers use it
  /// to hide the "import from phone" affordance instead of offering a button
  /// that cannot work.
  static bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Opens the OS picker and returns the chosen person, or null when the rep
  /// backed out, the platform has no picker, or the pick failed.
  Future<DeviceContact?> pickOne() async {
    if (!isSupported) return null;
    try {
      // selectPhoneNumber (not selectContact) so a contact with several
      // numbers resolves to the one the rep actually tapped.
      final contact = await FlutterNativeContactPicker().selectPhoneNumber();
      if (contact == null) return null;
      final phone =
          contact.selectedPhoneNumber ?? contact.phoneNumbers?.firstOrNull;
      final picked = DeviceContact(
        fullName: (contact.fullName ?? '').trim(),
        phone: _normalizePhone(phone ?? ''),
      );
      return picked.isEmpty ? null : picked;
    } catch (_) {
      // A missing plugin, a cancelled activity, or a device with no contacts
      // app: the rep can always type the number by hand, so never surface a
      // platform exception here.
      return null;
    }
  }

  /// Strips the spaces, dashes and parentheses the address book stores for
  /// readability but a `tel:` link and a duplicate check both trip over.
  static String _normalizePhone(String raw) {
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if (ch == '+' && buffer.isEmpty) {
        buffer.write(ch);
      } else if (ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39) {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }
}

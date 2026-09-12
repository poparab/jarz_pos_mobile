import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations_ar.dart';
import 'package:jarz_pos/l10n/app_localizations_en.dart';
import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/models/pos_models.dart';
import 'package:jarz_pos/src/features/pos/data/models/staff_customer_models.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/domain/models/delivery_slot.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

class _FakePosRepository extends PosRepository {
  _FakePosRepository() : super(Dio());

  int createInvoiceCalls = 0;
  String? lastOrderPurpose;
  Map<String, dynamic>? lastCustomer;

  @override
  Future<List<Map<String, dynamic>>> getItems(
    String posProfile, {
    String? priceList,
    String? customer,
    String? orderPurpose,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getBundles(
    String posProfile, {
    String? priceList,
    String? customer,
    String? orderPurpose,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getPosPriceLists(
    String posProfile,
  ) async => const [];

  @override
  Future<List<CommercialPolicy>> getCommercialPolicies(
    String posProfile,
  ) async => const [_employeePolicy, _samplePolicy];

  @override
  Future<List<DeliverySlot>> getDeliverySlots(String posProfile) async =>
      const [];

  @override
  Future<String?> getCustomerPriceList(
    String customer,
    String posProfile, {
    String? orderPurpose,
  }) async => null;

  @override
  Future<String?> getTerritoryPosProfile(String customerName) async => null;

  @override
  Future<Map<String, dynamic>> createInvoice({
    required String posProfile,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? customer,
    String? requiredDeliveryDatetime,
    String? deliveryEndDatetime,
    String? salesPartner,
    String? paymentType,
    bool isPickup = false,
    String? paymentMethod,
    String? priceList,
    bool zeroShippingOverride = false,
    bool posProfileOverride = false,
    double? customDeliveryIncome,
    String? orderPurpose,
    String? commercialPolicy,
    String? policyReason,
    List<String> promoCodes = const [],
  }) async {
    createInvoiceCalls += 1;
    lastOrderPurpose = orderPurpose;
    lastCustomer = customer;
    return {'invoice_name': 'INV-STAFF-001'};
  }
}

/// In-memory draft store that keeps what the notifier persisted.
class _MemoryDraftCartRepository extends DraftCartRepository {
  _MemoryDraftCartRepository([List<DraftCart>? drafts])
    : _drafts = [...?drafts];

  final List<DraftCart> _drafts;

  List<DraftCart> get drafts => List.unmodifiable(_drafts);

  @override
  Future<void> upsert(DraftCart draft) async {
    _drafts.removeWhere((existing) => existing.id == draft.id);
    _drafts.add(draft);
  }

  @override
  Future<List<DraftCart>> loadAll() async => List<DraftCart>.from(_drafts);

  @override
  Future<void> delete(String id) async =>
      _drafts.removeWhere((draft) => draft.id == id);

  @override
  Future<void> clearAll() async => _drafts.clear();
}

const _employeePolicy = CommercialPolicy(
  name: 'POL-EMPLOYEE',
  policyName: 'Employee Order',
  orderPurpose: 'Employee',
  waivesShippingIncome: true,
  noCourier: true,
  deliverAtBranch: true,
);

const _samplePolicy = CommercialPolicy(
  name: 'POL-SAMPLE',
  policyName: 'Sample',
  orderPurpose: 'Sample - Courier',
);

const _staffCustomer = <String, dynamic>{
  'name': 'CUST-STAFF-0001',
  'customer_name': 'Mona Adel',
  'employee': 'HR-EMP-00007',
  'employee_name': 'Mona Adel',
  'is_staff_customer': true,
};

const _cartLine = <String, dynamic>{
  'item_code': 'JAR-L',
  'item_name': 'Large jar',
  'quantity': 1,
  'rate': 150,
  'type': 'item',
};

PosNotifier _notifier({
  _FakePosRepository? repository,
  _MemoryDraftCartRepository? drafts,
  PosState? initial,
}) {
  final notifier = PosNotifier(
    repository ?? _FakePosRepository(),
    drafts ?? _MemoryDraftCartRepository(),
  );
  notifier.state =
      initial ??
      PosState(
        selectedProfile: const {'name': 'Heliopolis POS'},
        availableCommercialPolicies: const [_employeePolicy, _samplePolicy],
        selectedCommercialPolicy: _employeePolicy,
        cartItems: const [_cartLine],
      );
  return notifier;
}

bool _pickMona(PosNotifier notifier) => notifier.selectStaffCustomer(
  customer: Map<String, dynamic>.from(_staffCustomer),
  employee: 'HR-EMP-00007',
  employeeName: 'Mona Adel',
);

void main() {
  group('CommercialPolicy.deliverAtBranch', () {
    Map<String, dynamic> policyJson(Object? flag) => {
      'name': 'POL-EMPLOYEE',
      'policy_name': 'Employee Order',
      'order_purpose': 'Employee',
      if (flag != null) 'deliver_at_branch': flag,
    };

    test('should default to false when an older backend omits the flag', () {
      expect(
        CommercialPolicy.fromJson(policyJson(null)).deliverAtBranch,
        isFalse,
      );
    });

    test('should accept a JSON bool and a Frappe 0/1 check', () {
      expect(
        CommercialPolicy.fromJson(policyJson(true)).deliverAtBranch,
        isTrue,
      );
      expect(CommercialPolicy.fromJson(policyJson(1)).deliverAtBranch, isTrue);
      expect(CommercialPolicy.fromJson(policyJson(0)).deliverAtBranch, isFalse);
    });
  });

  group('staff member selection', () {
    test('should set the customer and the staff member for an Employee '
        'order', () {
      final notifier = _notifier();

      final applied = _pickMona(notifier);

      expect(applied, isTrue);
      expect(notifier.state.selectedCustomer?['name'], 'CUST-STAFF-0001');
      expect(notifier.state.selectedStaffEmployee, 'HR-EMP-00007');
      expect(notifier.state.selectedStaffEmployeeName, 'Mona Adel');
      expect(notifier.state.isMissingStaffEmployee, isFalse);
    });

    test('should refuse a staff pick when the order is not an Employee '
        'order', () {
      final notifier = _notifier();
      notifier.state = notifier.state.copyWith(
        selectedCommercialPolicy: _samplePolicy,
      );

      final applied = _pickMona(notifier);

      expect(applied, isFalse);
      expect(notifier.state.selectedCustomer, isNull);
      expect(notifier.state.selectedStaffEmployee, isNull);
    });

    test('should clear the staff member when a customer is picked by hand', () {
      final notifier = _notifier();
      _pickMona(notifier);

      notifier.selectCustomer(const {
        'name': 'CUST-0099',
        'customer_name': 'Walk-in regular',
      });

      expect(notifier.state.selectedCustomer?['name'], 'CUST-0099');
      expect(notifier.state.selectedStaffEmployee, isNull);
      expect(notifier.state.selectedStaffEmployeeName, isNull);
      expect(notifier.state.isMissingStaffEmployee, isTrue);
    });

    test('should clear the staff member when the customer is removed', () {
      final notifier = _notifier();
      _pickMona(notifier);

      notifier.unselectCustomer();

      expect(notifier.state.selectedStaffEmployee, isNull);
    });

    test('should clear the staff member when the purpose moves to another '
        'policy', () async {
      final notifier = _notifier();
      _pickMona(notifier);

      await notifier.setCommercialPolicy(_samplePolicy);

      expect(notifier.state.selectedCommercialPolicy?.name, 'POL-SAMPLE');
      expect(notifier.state.selectedStaffEmployee, isNull);
    });

    test('should clear the staff member when the purpose returns to '
        'Standard', () async {
      final notifier = _notifier();
      _pickMona(notifier);

      await notifier.setCommercialPolicy(null);

      expect(notifier.state.selectedStaffEmployee, isNull);
      expect(notifier.state.selectedStaffEmployeeName, isNull);
    });

    test('should keep the staff member when Employee is re-selected', () async {
      final notifier = _notifier();
      _pickMona(notifier);

      await notifier.setCommercialPolicy(_employeePolicy);

      expect(notifier.state.selectedStaffEmployee, 'HR-EMP-00007');
    });

    test('should clear the staff member when the cart is cleared', () {
      final notifier = _notifier();
      _pickMona(notifier);

      notifier.clearCart();

      expect(notifier.state.selectedStaffEmployee, isNull);
    });

    test('should clear the staff member when a new invoice starts', () {
      final notifier = _notifier();
      _pickMona(notifier);

      notifier.startNewInvoice();

      expect(notifier.state.selectedStaffEmployee, isNull);
      expect(notifier.state.selectedStaffEmployeeName, isNull);
    });

    test('should treat a deliver-at-branch policy as collected at the '
        'branch', () {
      final notifier = _notifier();

      expect(notifier.state.isPickup, isFalse);
      expect(notifier.state.collectsAtBranch, isTrue);

      notifier.state = notifier.state.copyWith(
        selectedCommercialPolicy: _samplePolicy,
      );
      expect(notifier.state.collectsAtBranch, isFalse);
    });
  });

  group('checkout guard', () {
    test('should refuse an Employee order with no staff member', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository: repository);
      notifier.selectCustomer(const {
        'name': 'CUST-0099',
        'customer_name': 'Somebody picked by hand',
      });

      await notifier.checkout(overridePosProfileName: 'Heliopolis POS');

      expect(repository.createInvoiceCalls, 0);
      expect(notifier.state.error, PosNotifier.staffEmployeeRequiredError);
      expect(notifier.state.cartItems, isNotEmpty);
    });

    test(
      'should submit an Employee order once a staff member is chosen',
      () async {
        final repository = _FakePosRepository();
        final notifier = _notifier(repository: repository);
        _pickMona(notifier);

        await notifier.checkout(overridePosProfileName: 'Heliopolis POS');

        expect(repository.createInvoiceCalls, 1);
        expect(repository.lastOrderPurpose, 'Employee');
        expect(repository.lastCustomer?['name'], 'CUST-STAFF-0001');
        expect(notifier.state.error, isNull);
        expect(notifier.state.selectedStaffEmployee, isNull);
      },
    );

    test('should not demand a staff member for a Standard order', () async {
      final repository = _FakePosRepository();
      final notifier = _notifier(repository: repository);
      notifier.state = notifier.state.copyWith(
        clearSelectedCommercialPolicy: true,
      );

      await notifier.checkout(overridePosProfileName: 'Heliopolis POS');

      expect(repository.createInvoiceCalls, 1);
    });

    test('should localize the refusal in English and Arabic', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();

      expect(
        userErrorMessageFor(en, PosNotifier.staffEmployeeRequiredError),
        en.posStaffMemberRequired,
      );
      expect(
        userErrorMessageFor(ar, PosNotifier.staffEmployeeRequiredError),
        ar.posStaffMemberRequired,
      );
    });
  });

  group('draft round-trip', () {
    DraftCart staffDraft({
      CommercialPolicy? policy = _employeePolicy,
      String? staffEmployee = 'HR-EMP-00007',
    }) => DraftCart(
      id: 'draft-staff',
      label: 'Mona Adel · 1 item',
      cartItems: const [_cartLine],
      customer: _staffCustomer,
      selectedCommercialPolicy: policy,
      staffEmployee: staffEmployee,
      staffEmployeeName: 'Mona Adel',
      isPickup: false,
      createdAt: DateTime(2026, 9, 13),
      updatedAt: DateTime(2026, 9, 13),
    );

    test('should keep the staff member through toMap/fromMap', () {
      final restored = DraftCart.fromMap(staffDraft().toMap());

      expect(restored.staffEmployee, 'HR-EMP-00007');
      expect(restored.staffEmployeeName, 'Mona Adel');
      expect(restored.selectedCommercialPolicy?.deliverAtBranch, isTrue);
    });

    test('should read a draft saved before the picker existed', () {
      final restored = DraftCart.fromMap({
        'id': 'legacy',
        'label': 'Legacy',
        'cart_items': '[]',
        'is_pickup': false,
      });

      expect(restored.staffEmployee, isNull);
      expect(restored.staffEmployeeName, isNull);
    });

    test('should persist the chosen staff member with the cart', () async {
      final drafts = _MemoryDraftCartRepository();
      final notifier = _notifier(drafts: drafts);
      _pickMona(notifier);

      await notifier.testInvokePersistCurrentCart();

      expect(drafts.drafts, hasLength(1));
      expect(drafts.drafts.single.staffEmployee, 'HR-EMP-00007');
      expect(drafts.drafts.single.staffEmployeeName, 'Mona Adel');
    });

    test(
      'should restore the staff member when switching to its draft',
      () async {
        final drafts = _MemoryDraftCartRepository([staffDraft()]);
        final notifier = _notifier(
          drafts: drafts,
          initial: PosState(
            availableCommercialPolicies: const [_employeePolicy, _samplePolicy],
          ),
        );

        await notifier.switchDraft('draft-staff');

        expect(notifier.state.selectedCustomer?['name'], 'CUST-STAFF-0001');
        expect(notifier.state.selectedStaffEmployee, 'HR-EMP-00007');
        expect(notifier.state.selectedStaffEmployeeName, 'Mona Adel');
        expect(notifier.state.isMissingStaffEmployee, isFalse);
      },
    );

    test(
      'should ignore a saved staff member on a non-Employee draft',
      () async {
        final drafts = _MemoryDraftCartRepository([
          staffDraft(policy: _samplePolicy),
        ]);
        final notifier = _notifier(drafts: drafts, initial: PosState());

        await notifier.switchDraft('draft-staff');

        expect(notifier.state.selectedStaffEmployee, isNull);
        expect(notifier.state.selectedStaffEmployeeName, isNull);
      },
    );
  });

  group('staff customer payloads', () {
    test('should parse the staff list with an HRMS flag', () {
      final list = StaffOrderEmployeeList.fromJson({
        'success': true,
        'hrms_available': true,
        'employees': [
          {
            'employee': 'HR-EMP-00007',
            'employee_name': 'Mona Adel',
            'branch': 'Heliopolis',
            'designation': 'Cashier',
            'customer': null,
            'customer_name': null,
          },
          {'employee': '', 'employee_name': 'dropped: no id'},
        ],
      });

      expect(list.hrmsAvailable, isTrue);
      expect(list.employees, hasLength(1));
      expect(list.employees.single.hasCustomer, isFalse);
    });

    test('should parse the sync report buckets', () {
      final result = StaffCustomerSyncResult.fromJson({
        'success': true,
        'created': [
          {'employee': 'HR-EMP-1', 'employee_name': 'A', 'customer': 'C-1'},
        ],
        'adopted': const [],
        'existing': ['HR-EMP-2', 'HR-EMP-3'],
        'skipped': [
          {'employee': 'HR-EMP-4', 'reason': 'inactive'},
        ],
        'conflicts': [
          {
            'employee': 'HR-EMP-5',
            'employee_name': 'Five',
            'customers': [
              'C-5a',
              {'name': 'C-5b', 'customer_name': 'Five B'},
            ],
          },
        ],
      });

      expect(result.created.single.customer, 'C-1');
      expect(result.existing, hasLength(2));
      expect(result.skipped.single.reason, 'inactive');
      expect(result.conflicts.single.customers, ['C-5a', 'Five B']);
    });
  });
}

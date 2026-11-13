import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_sync_drive/models/role_permission_model.dart';

void main() {
  group('Role-Based Access Control (RBAC) Tests', () {
    test('All 7 roles are registered with Bangla display names', () {
      expect(UserRole.values.length, equals(7));
      for (final role in UserRole.values) {
        expect(role.displayName.isNotEmpty, isTrue);
        expect(role.code, equals(role.name));
      }
    });

    test('Super Admin & Society Owner have all 28 permissions', () {
      final superAdminPermissions = AppPermissions.getPreset(UserRole.superAdmin);
      final ownerPermissions = AppPermissions.getPreset(UserRole.societyOwner);

      expect(superAdminPermissions.length, equals(28));
      expect(ownerPermissions.length, equals(28));
      expect(superAdminPermissions, equals(Set.from(AppPermissions.allPermissions)));
    });

    test('Accountant has financial ledger and cashbook view but cannot approve loans', () {
      final accountantPerms = AppPermissions.getPreset(UserRole.accountant);

      expect(accountantPerms.contains(AppPermissions.cashbookView), isTrue);
      expect(accountantPerms.contains(AppPermissions.ledgerView), isTrue);
      expect(accountantPerms.contains(AppPermissions.expenseRecord), isTrue);
      expect(accountantPerms.contains(AppPermissions.savingsDeposit), isTrue);

      // Security boundaries
      expect(accountantPerms.contains(AppPermissions.loanApprove), isFalse);
      expect(accountantPerms.contains(AppPermissions.loanDisburse), isFalse);
      expect(accountantPerms.contains(AppPermissions.memberDelete), isFalse);
      expect(accountantPerms.contains(AppPermissions.settingsManage), isFalse);
    });

    test('Field Officer can collect installments but cannot modify accounts', () {
      final fieldOfficerPerms = AppPermissions.getPreset(UserRole.fieldOfficer);

      expect(fieldOfficerPerms.contains(AppPermissions.savingsDeposit), isTrue);
      expect(fieldOfficerPerms.contains(AppPermissions.loanRepay), isTrue);
      expect(fieldOfficerPerms.contains(AppPermissions.memberView), isTrue);

      // Security restrictions
      expect(fieldOfficerPerms.contains(AppPermissions.savingsWithdraw), isFalse);
      expect(fieldOfficerPerms.contains(AppPermissions.fundTransfer), isFalse);
      expect(fieldOfficerPerms.contains(AppPermissions.loanDisburse), isFalse);
      expect(fieldOfficerPerms.contains(AppPermissions.loanApprove), isFalse);
      expect(fieldOfficerPerms.contains(AppPermissions.settingsManage), isFalse);
    });

    test('General Member has read-only passbook and statement access', () {
      final memberPerms = AppPermissions.getPreset(UserRole.member);

      expect(memberPerms.contains(AppPermissions.savingsView), isTrue);
      expect(memberPerms.contains(AppPermissions.savingsStatement), isTrue);
      expect(memberPerms.contains(AppPermissions.loanView), isTrue);

      // Strictly prohibited
      expect(memberPerms.contains(AppPermissions.memberCreate), isFalse);
      expect(memberPerms.contains(AppPermissions.expenseRecord), isFalse);
      expect(memberPerms.contains(AppPermissions.cashbookView), isFalse);
      expect(memberPerms.contains(AppPermissions.employeeManage), isFalse);
    });

    test('Every permission has a descriptive Bengali title', () {
      for (final perm in AppPermissions.allPermissions) {
        final title = AppPermissions.getPermissionTitle(perm);
        expect(title.isNotEmpty, isTrue);
        expect(title, isNot(equals(perm))); // Has translated name
      }
    });
  });
}

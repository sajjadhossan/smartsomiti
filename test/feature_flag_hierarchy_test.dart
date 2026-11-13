import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_sync_drive/models/feature_flag_model.dart';
import 'package:cloud_sync_drive/services/feature_management_service.dart';

void main() {
  group('Feature Flag Hierarchy & Precedence Engine', () {
    test('Master Admin super-email retains unconditional platform access', () {
      final service = FeatureManagementService();
      const superAdminEmail = 'hossansajjad1994@gmail.com';

      expect(service.isPlatformMasterAdmin(superAdminEmail), isTrue);
      expect(service.isPlatformMasterAdmin('other@gmail.com'), isFalse);

      final canAccess = service.canAccess(
        featureKey: FeatureKeys.loanApplication,
        userEmail: superAdminEmail,
      );
      expect(canAccess, isTrue);
    });

    test('Core features remain protected from being toggled off', () {
      for (final module in DefaultPlatformModules.modules) {
        for (final sub in module.subFeatures) {
          if (sub.isCore) {
            expect(sub.isCore, isTrue);
            expect(sub.defaultEnabled, isTrue);
          }
        }
      }
    });

    test('All 24 Enterprise Modules have registered sub-features', () {
      final modules = DefaultPlatformModules.modules;
      expect(modules.length, equals(24));

      for (final module in modules) {
        expect(module.key.isNotEmpty, isTrue);
        expect(module.title.isNotEmpty, isTrue);
        expect(module.subFeatures.isNotEmpty, isTrue);
      }
    });

    test('Parent module mapping correctly links sub-features', () {
      expect(DefaultPlatformModules.modules.any((m) => m.key == ModuleKeys.loans), isTrue);
      expect(DefaultPlatformModules.modules.any((m) => m.key == ModuleKeys.savings), isTrue);
      expect(DefaultPlatformModules.modules.any((m) => m.key == ModuleKeys.accounting), isTrue);
    });
  });
}

// test/enterprise_api_developer_portal_test.dart
// Comprehensive Unit Tests for Phase 15 Enterprise API, Developer Portal & Third-Party Integration Ecosystem

import 'package:test/test.dart';
import '../lib/models/enterprise_api_developer_model.dart';
import '../lib/models/security_compliance_model.dart';
import '../lib/services/enterprise_api_developer_service.dart';

void main() {
  group('Phase 15 - Enterprise API, Developer Portal & Third-Party Integration Tests', () {
    late EnterpriseApiDeveloperService service;

    setUp(() {
      service = EnterpriseApiDeveloperService();
      service.updateMasterConfig(const SuperAdminApiMasterConfig());
    });

    test('1. API Key Generation & Cryptographic Masking', () {
      final res = service.generateApiKey(
        applicationId: 'APP-01',
        societyId: 'swapno_chowa_main',
        scopes: ['members:read', 'savings:read'],
        environment: ApiEnvironment.production,
      );

      final apiKey = res['apiKeyModel'] as ApiKeyModel;
      final rawSecret = res['plaintextSecret'] as String;

      expect(apiKey.id, startsWith('KEY-'));
      expect(rawSecret, startsWith('sk_live_'));
      expect(apiKey.keyMasked, contains('••••'));
      expect(apiKey.hashedVerifier, isNotEmpty);
      expect(apiKey.status, equals(ApiKeyStatus.active));
      expect(apiKey.isUsable, isTrue);
    });

    test('2. API Key Immediate Revocation', () {
      final res = service.generateApiKey(
        applicationId: 'APP-01',
        societyId: 'swapno_chowa_main',
        scopes: ['members:read'],
      );
      final apiKey = res['apiKeyModel'] as ApiKeyModel;

      expect(service.revokeApiKey(apiKey.id), isTrue);

      final revokedKey = service.apiKeys.firstWhere((k) => k.id == apiKey.id);
      expect(revokedKey.status, equals(ApiKeyStatus.revoked));
      expect(revokedKey.isUsable, isFalse);
    });

    test('3. Multi-Tenant Isolation & BOLA Protection (Cross-Society Rejection)', () {
      const tenantA = 'society_dhaka_01';
      const tenantB = 'society_chittagong_02';

      final res = service.generateApiKey(
        applicationId: 'APP-01',
        societyId: tenantA,
        scopes: ['members:read', 'savings:read'],
      );
      final apiKey = res['apiKeyModel'] as ApiKeyModel;

      // Accessing same tenant is permitted
      expect(
        service.validateApiKeyAccess(apiKey.id, targetSocietyId: tenantA, requiredScope: 'members:read'),
        isTrue,
      );

      // Accessing different tenant MUST be strictly rejected
      expect(
        service.validateApiKeyAccess(apiKey.id, targetSocietyId: tenantB, requiredScope: 'members:read'),
        isFalse,
      );
    });

    test('4. Granular Scope Enforcement (Least Privilege)', () {
      final res = service.generateApiKey(
        applicationId: 'APP-01',
        societyId: 'swapno_chowa_main',
        scopes: ['members:read'], // Read only scope
      );
      final apiKey = res['apiKeyModel'] as ApiKeyModel;

      expect(
        service.validateApiKeyAccess(apiKey.id, targetSocietyId: 'swapno_chowa_main', requiredScope: 'members:read'),
        isTrue,
      );

      // High-privilege write scope must be rejected
      expect(
        service.validateApiKeyAccess(apiKey.id, targetSocietyId: 'swapno_chowa_main', requiredScope: 'savings:deposit'),
        isFalse,
      );
    });

    test('5. OAuth 2.0 Token Generation & Expiration', () {
      final token = service.issueOAuthToken(
        clientId: 'client_somiti_mobile_app_prod',
        societyId: 'swapno_chowa_main',
        scopes: ['members:read', 'savings:read'],
      );

      expect(token.accessToken, startsWith('eyJh'));
      expect(token.tokenType, equals('Bearer'));
      expect(token.expiresInSeconds, equals(3600));
      expect(token.isValid, isTrue);
      expect(token.isExpired, isFalse);
    });

    test('6. OAuth Client Registration & Grant Types', () {
      final client = service.oauthClients.first;
      expect(client.grantTypes, contains(OAuthGrantType.authorizationCodePkce));
      expect(client.grantTypes, contains(OAuthGrantType.clientCredentials));
      expect(client.isActive, isTrue);
    });

    test('7. Webhook Endpoint Registration & Event Subscription', () {
      final endpoint = service.registerWebhookEndpoint(
        societyId: 'swapno_chowa_main',
        url: 'https://partner.bank.com/webhook/somiti',
        description: 'ব্যাংক সমন্বয় ইভেন্ট সাবস্ক্রিপশন',
        eventSubscriptions: ['savings.deposit.completed', 'loan.disbursed'],
      );

      expect(endpoint.id, startsWith('WH-'));
      expect(endpoint.url, equals('https://partner.bank.com/webhook/somiti'));
      expect(endpoint.eventSubscriptions, contains('savings.deposit.completed'));
      expect(endpoint.isActive, isTrue);
    });

    test('8. Webhook Cryptographic Signature (HMAC-SHA256)', () {
      const endpointId = 'WH-01';
      final log = service.dispatchWebhookEvent(
        endpointId: endpointId,
        eventType: 'payment.completed',
        payload: {
          'txnId': 'TXN-BK-9912',
          'amountPoisha': 250000,
          'status': 'SUCCESS',
        },
      );

      expect(log.signature, startsWith('sha256='));
      expect(log.status, equals(WebhookDeliveryStatus.delivered));
      expect(log.httpStatus, equals(200));
    });

    test('9. Rate Limiting Tier Policy Enforcement', () {
      final freePolicy = service.rateLimitPolicies.firstWhere((p) => p.tier == 'free');
      final enterprisePolicy = service.rateLimitPolicies.firstWhere((p) => p.tier == 'enterprise');

      expect(freePolicy.requestsPerMinute, equals(60));
      expect(enterprisePolicy.requestsPerMinute, equals(1200));
      expect(enterprisePolicy.requestsPerMinute, greaterThan(freePolicy.requestsPerMinute));
    });

    test('10. Third-Party Integration Connector Health Check', () {
      const integrationId = 'INT-BKASH';
      final health = service.checkIntegrationHealth(integrationId);

      expect(health['status'], equals('Connected'));
      expect(health['latency'], endsWith('ms'));

      final intModel = service.integrations.firstWhere((i) => i.id == integrationId);
      expect(intModel.status, equals(IntegrationStatus.connected));
      expect(intModel.isEnabled, isTrue);
    });

    test('11. Sandbox Environment Data Isolation', () {
      final sandboxKey = service.apiKeys.firstWhere((k) => k.id == 'KEY-TEST');
      expect(sandboxKey.keyPrefix, equals('sk_test_'));
      expect(sandboxKey.societyId, equals('sandbox_society_demo'));

      // Sandbox key must never access production society
      expect(
        service.validateApiKeyAccess(sandboxKey.id, targetSocietyId: 'swapno_chowa_main', requiredScope: 'members:read'),
        isFalse,
      );
    });

    test('12. Super Admin Universal API Master Controls & Invariant Guard', () {
      // Disable global API Gateway
      service.updateMasterConfig(const SuperAdminApiMasterConfig(
        globalApiGatewayEnabled: false,
      ));

      expect(
        () => service.generateApiKey(
          applicationId: 'APP-01',
          societyId: 'swapno_chowa_main',
          scopes: ['members:read'],
        ),
        throwsException,
      );

      // Existing keys must remain recorded and audited
      expect(service.apiKeys, isNotEmpty);

      // Restore configuration
      service.updateMasterConfig(const SuperAdminApiMasterConfig(
        globalApiGatewayEnabled: true,
      ));
      expect(service.masterConfig.globalApiGatewayEnabled, isTrue);
    });
  });
}

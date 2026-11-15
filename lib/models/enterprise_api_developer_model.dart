// lib/models/enterprise_api_developer_model.dart
// Phase 15: Enterprise API, Developer Portal & Third-Party Integration Ecosystem Models

enum ApiEnvironment {
  sandbox,
  production;

  String get labelBn {
    switch (this) {
      case ApiEnvironment.sandbox: return 'স্যান্ডবক্স (টেস্ট পরিবেশ)';
      case ApiEnvironment.production: return 'প্রোডাকশন (লাইভ পরিবেশ)';
    }
  }

  String get badgeColor {
    switch (this) {
      case ApiEnvironment.sandbox: return '#D97706'; // Amber
      case ApiEnvironment.production: return '#059669'; // Emerald
    }
  }
}

enum ApiKeyStatus {
  active,
  revoked,
  expired,
  suspended;

  String get labelBn {
    switch (this) {
      case ApiKeyStatus.active: return 'সক্রিয় (Active)';
      case ApiKeyStatus.revoked: return 'বাতিলকৃত (Revoked)';
      case ApiKeyStatus.expired: return 'মেয়াদোত্তীর্ণ (Expired)';
      case ApiKeyStatus.suspended: return 'স্থগিত (Suspended)';
    }
  }
}

enum OAuthGrantType {
  clientCredentials,
  authorizationCodePkce;

  String get labelBn {
    switch (this) {
      case OAuthGrantType.clientCredentials: return 'ক্লায়েন্ট ক্রেডেনশিয়ালস (M2M)';
      case OAuthGrantType.authorizationCodePkce: return 'অথরাইজেশন কোড (PKCE)';
    }
  }
}

enum WebhookDeliveryStatus {
  delivered,
  retrying,
  failed,
  suspended;

  String get labelBn {
    switch (this) {
      case WebhookDeliveryStatus.delivered: return 'বিতরণ সম্পন্ন (Delivered)';
      case WebhookDeliveryStatus.retrying: return 'পুনরায় চেষ্টা চলছে (Retrying)';
      case WebhookDeliveryStatus.failed: return 'ব্যর্থ (Failed)';
      case WebhookDeliveryStatus.suspended: return 'স্থগিত (Suspended)';
    }
  }
}

enum IntegrationProviderType {
  paymentGateway,
  bankingH2H,
  smsGateway,
  erpAccounting,
  identityVerification;

  String get labelBn {
    switch (this) {
      case IntegrationProviderType.paymentGateway: return 'পেমেন্ট গেটওয়ে (MFS / কার্ড)';
      case IntegrationProviderType.bankingH2H: return 'কোর ব্যাংকিং হোস্ট-টু-হোস্ট (H2H)';
      case IntegrationProviderType.smsGateway: return 'টেলকো বাল্ক এসএমএস গেটওয়ে';
      case IntegrationProviderType.erpAccounting: return 'বহিরাগত ইআরপি ও একাউন্টিং';
      case IntegrationProviderType.identityVerification: return 'জাতীয় পরিচয়পত্র ও কেওয়াইসি ভেরিফিকেশন';
    }
  }
}

enum IntegrationStatus {
  connected,
  disconnected,
  degraded,
  maintenance;

  String get labelBn {
    switch (this) {
      case IntegrationStatus.connected: return 'সংযুক্ত (Connected)';
      case IntegrationStatus.disconnected: return 'বিচ্ছিন্ন (Disconnected)';
      case IntegrationStatus.degraded: return 'ধীরগতি (Degraded)';
      case IntegrationStatus.maintenance: return 'রক্ষণাবেক্ষণ (Maintenance)';
    }
  }
}

/// Developer Registered Application Model
class ApiApplicationModel {
  final String id;
  final String appName;
  final String developerId;
  final String? societyId; // null = Platform-wide developer app
  final ApiEnvironment environment;
  final List<String> allowedOrigins;
  final List<String> redirectUris;
  final bool isActive;
  final DateTime createdAt;

  const ApiApplicationModel({
    required this.id,
    required this.appName,
    required this.developerId,
    this.societyId,
    required this.environment,
    this.allowedOrigins = const [],
    this.redirectUris = const [],
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'appName': appName,
    'developerId': developerId,
    'societyId': societyId,
    'environment': environment.name,
    'allowedOrigins': allowedOrigins,
    'redirectUris': redirectUris,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ApiApplicationModel.fromMap(Map<String, dynamic> map) => ApiApplicationModel(
    id: map['id'] ?? '',
    appName: map['appName'] ?? '',
    developerId: map['developerId'] ?? '',
    societyId: map['societyId'],
    environment: ApiEnvironment.values.firstWhere((e) => e.name == map['environment'], orElse: () => ApiEnvironment.sandbox),
    allowedOrigins: List<String>.from(map['allowedOrigins'] ?? []),
    redirectUris: List<String>.from(map['redirectUris'] ?? []),
    isActive: map['isActive'] ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

/// Secure API Key Model (Masked plaintext, Hashed verifier stored)
class ApiKeyModel {
  final String id;
  final String applicationId;
  final String keyPrefix; // 'sk_live_' or 'sk_test_'
  final String keyMasked; // e.g. 'sk_live_...9f4a'
  final String hashedVerifier;
  final String societyId;
  final List<String> scopes;
  final ApiKeyStatus status;
  final int rateLimitPerMinute;
  final int totalRequests;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const ApiKeyModel({
    required this.id,
    required this.applicationId,
    required this.keyPrefix,
    required this.keyMasked,
    required this.hashedVerifier,
    required this.societyId,
    required this.scopes,
    this.status = ApiKeyStatus.active,
    this.rateLimitPerMinute = 300,
    this.totalRequests = 0,
    this.lastUsedAt,
    this.expiresAt,
    required this.createdAt,
  });

  bool get isUsable => status == ApiKeyStatus.active && (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  Map<String, dynamic> toMap() => {
    'id': id,
    'applicationId': applicationId,
    'keyPrefix': keyPrefix,
    'keyMasked': keyMasked,
    'hashedVerifier': hashedVerifier,
    'societyId': societyId,
    'scopes': scopes,
    'status': status.name,
    'rateLimitPerMinute': rateLimitPerMinute,
    'totalRequests': totalRequests,
    'lastUsedAt': lastUsedAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory ApiKeyModel.fromMap(Map<String, dynamic> map) => ApiKeyModel(
    id: map['id'] ?? '',
    applicationId: map['applicationId'] ?? '',
    keyPrefix: map['keyPrefix'] ?? 'sk_live_',
    keyMasked: map['keyMasked'] ?? '',
    hashedVerifier: map['hashedVerifier'] ?? '',
    societyId: map['societyId'] ?? '',
    scopes: List<String>.from(map['scopes'] ?? []),
    status: ApiKeyStatus.values.firstWhere((s) => s.name == map['status'], orElse: () => ApiKeyStatus.active),
    rateLimitPerMinute: map['rateLimitPerMinute'] ?? 300,
    totalRequests: map['totalRequests'] ?? 0,
    lastUsedAt: map['lastUsedAt'] != null ? DateTime.tryParse(map['lastUsedAt']) : null,
    expiresAt: map['expiresAt'] != null ? DateTime.tryParse(map['expiresAt']) : null,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

/// OAuth 2.0 Client Application Model
class OAuthClientModel {
  final String id;
  final String clientId;
  final String clientSecretMasked;
  final String hashedSecret;
  final String appName;
  final List<String> scopes;
  final List<String> redirectUris;
  final List<OAuthGrantType> grantTypes;
  final bool isActive;
  final DateTime createdAt;

  const OAuthClientModel({
    required this.id,
    required this.clientId,
    required this.clientSecretMasked,
    required this.hashedSecret,
    required this.appName,
    required this.scopes,
    required this.redirectUris,
    required this.grantTypes,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'clientId': clientId,
    'clientSecretMasked': clientSecretMasked,
    'hashedSecret': hashedSecret,
    'appName': appName,
    'scopes': scopes,
    'redirectUris': redirectUris,
    'grantTypes': grantTypes.map((g) => g.name).toList(),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OAuthClientModel.fromMap(Map<String, dynamic> map) => OAuthClientModel(
    id: map['id'] ?? '',
    clientId: map['clientId'] ?? '',
    clientSecretMasked: map['clientSecretMasked'] ?? '',
    hashedSecret: map['hashedSecret'] ?? '',
    appName: map['appName'] ?? '',
    scopes: List<String>.from(map['scopes'] ?? []),
    redirectUris: List<String>.from(map['redirectUris'] ?? []),
    grantTypes: (map['grantTypes'] as List? ?? [])
        .map((g) => OAuthGrantType.values.firstWhere((gt) => gt.name == g, orElse: () => OAuthGrantType.clientCredentials))
        .toList(),
    isActive: map['isActive'] ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

/// OAuth Token Model
class OAuthTokenModel {
  final String accessToken;
  final String? refreshToken;
  final String tokenType; // 'Bearer'
  final int expiresInSeconds; // e.g. 3600
  final List<String> scopes;
  final String clientId;
  final String? userId;
  final String societyId;
  final DateTime createdAt;
  final bool isRevoked;

  const OAuthTokenModel({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresInSeconds = 3600,
    required this.scopes,
    required this.clientId,
    this.userId,
    required this.societyId,
    required this.createdAt,
    this.isRevoked = false,
  });

  bool get isExpired => DateTime.now().isAfter(createdAt.add(Duration(seconds: expiresInSeconds)));
  bool get isValid => !isRevoked && !isExpired;

  Map<String, dynamic> toMap() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'expiresInSeconds': expiresInSeconds,
    'scopes': scopes,
    'clientId': clientId,
    'userId': userId,
    'societyId': societyId,
    'createdAt': createdAt.toIso8601String(),
    'isRevoked': isRevoked,
  };
}

/// Webhook Endpoint Subscription Model
class WebhookEndpointModel {
  final String id;
  final String societyId;
  final String url;
  final String description;
  final List<String> eventSubscriptions;
  final String secretMasked;
  final String hashedSecret;
  final bool isActive;
  final int totalDelivered;
  final int totalFailed;
  final WebhookDeliveryStatus lastDeliveryStatus;
  final DateTime createdAt;

  const WebhookEndpointModel({
    required this.id,
    required this.societyId,
    required this.url,
    required this.description,
    required this.eventSubscriptions,
    required this.secretMasked,
    required this.hashedSecret,
    this.isActive = true,
    this.totalDelivered = 0,
    this.totalFailed = 0,
    this.lastDeliveryStatus = WebhookDeliveryStatus.delivered,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'url': url,
    'description': description,
    'eventSubscriptions': eventSubscriptions,
    'secretMasked': secretMasked,
    'hashedSecret': hashedSecret,
    'isActive': isActive,
    'totalDelivered': totalDelivered,
    'totalFailed': totalFailed,
    'lastDeliveryStatus': lastDeliveryStatus.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory WebhookEndpointModel.fromMap(Map<String, dynamic> map) => WebhookEndpointModel(
    id: map['id'] ?? '',
    societyId: map['societyId'] ?? '',
    url: map['url'] ?? '',
    description: map['description'] ?? '',
    eventSubscriptions: List<String>.from(map['eventSubscriptions'] ?? []),
    secretMasked: map['secretMasked'] ?? '',
    hashedSecret: map['hashedSecret'] ?? '',
    isActive: map['isActive'] ?? true,
    totalDelivered: map['totalDelivered'] ?? 0,
    totalFailed: map['totalFailed'] ?? 0,
    lastDeliveryStatus: WebhookDeliveryStatus.values.firstWhere((s) => s.name == map['lastDeliveryStatus'], orElse: () => WebhookDeliveryStatus.delivered),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

/// Webhook Event Delivery Log Model
class WebhookEventDeliveryModel {
  final String id;
  final String endpointId;
  final String eventType;
  final Map<String, dynamic> payload;
  final String signature;
  final int httpStatus;
  final int durationMs;
  final WebhookDeliveryStatus status;
  final int attemptNumber;
  final DateTime createdAt;

  const WebhookEventDeliveryModel({
    required this.id,
    required this.endpointId,
    required this.eventType,
    required this.payload,
    required this.signature,
    required this.httpStatus,
    required this.durationMs,
    required this.status,
    this.attemptNumber = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'endpointId': endpointId,
    'eventType': eventType,
    'payload': payload,
    'signature': signature,
    'httpStatus': httpStatus,
    'durationMs': durationMs,
    'status': status.name,
    'attemptNumber': attemptNumber,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// API Rate Limit Tier Policy
class ApiRateLimitPolicy {
  final String id;
  final String name;
  final String nameBn;
  final String tier; // 'free', 'standard', 'enterprise'
  final int requestsPerMinute;
  final int burstLimit;
  final int monthlyQuota;
  final bool isEnforced;

  const ApiRateLimitPolicy({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.tier,
    required this.requestsPerMinute,
    required this.burstLimit,
    required this.monthlyQuota,
    this.isEnforced = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'nameBn': nameBn,
    'tier': tier,
    'requestsPerMinute': requestsPerMinute,
    'burstLimit': burstLimit,
    'monthlyQuota': monthlyQuota,
    'isEnforced': isEnforced,
  };
}

/// Third-Party Integration Connector Model
class ThirdPartyIntegrationModel {
  final String id;
  final String providerKey; // 'bkash', 'nagad', 'city_bank', 'sslcommerz', 'twilio'
  final String providerName;
  final String nameBn;
  final IntegrationProviderType type;
  final IntegrationStatus status;
  final ApiEnvironment environment;
  final String endpointUrl;
  final bool credentialsConfigured;
  final DateTime lastHealthCheckAt;
  final int latencyMs;
  final bool isEnabled;

  const ThirdPartyIntegrationModel({
    required this.id,
    required this.providerKey,
    required this.providerName,
    required this.nameBn,
    required this.type,
    required this.status,
    required this.environment,
    required this.endpointUrl,
    required this.credentialsConfigured,
    required this.lastHealthCheckAt,
    required this.latencyMs,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'providerKey': providerKey,
    'providerName': providerName,
    'nameBn': nameBn,
    'type': type.name,
    'status': status.name,
    'environment': environment.name,
    'endpointUrl': endpointUrl,
    'credentialsConfigured': credentialsConfigured,
    'lastHealthCheckAt': lastHealthCheckAt.toIso8601String(),
    'latencyMs': latencyMs,
    'isEnabled': isEnabled,
  };

  factory ThirdPartyIntegrationModel.fromMap(Map<String, dynamic> map) => ThirdPartyIntegrationModel(
    id: map['id'] ?? '',
    providerKey: map['providerKey'] ?? '',
    providerName: map['providerName'] ?? '',
    nameBn: map['nameBn'] ?? '',
    type: IntegrationProviderType.values.firstWhere((t) => t.name == map['type'], orElse: () => IntegrationProviderType.paymentGateway),
    status: IntegrationStatus.values.firstWhere((s) => s.name == map['status'], orElse: () => IntegrationStatus.connected),
    environment: ApiEnvironment.values.firstWhere((e) => e.name == map['environment'], orElse: () => ApiEnvironment.sandbox),
    endpointUrl: map['endpointUrl'] ?? '',
    credentialsConfigured: map['credentialsConfigured'] ?? true,
    lastHealthCheckAt: DateTime.tryParse(map['lastHealthCheckAt'] ?? '') ?? DateTime.now(),
    latencyMs: map['latencyMs'] ?? 25,
    isEnabled: map['isEnabled'] ?? true,
  );
}

/// Super Admin Universal API & Developer Master Configuration
class SuperAdminApiMasterConfig {
  final bool globalApiGatewayEnabled;
  final bool developerRegistrationEnabled;
  final bool sandboxEnabled;
  final bool webhooksEnabled;
  final bool rateLimitingEnforced;
  final bool requireHttpsOnly;
  final bool strictTenantIsolation;
  final bool allowExternalIntegrations;

  const SuperAdminApiMasterConfig({
    this.globalApiGatewayEnabled = true,
    this.developerRegistrationEnabled = true,
    this.sandboxEnabled = true,
    this.webhooksEnabled = true,
    this.rateLimitingEnforced = true,
    this.requireHttpsOnly = true,
    this.strictTenantIsolation = true,
    this.allowExternalIntegrations = true,
  });

  Map<String, dynamic> toMap() => {
    'globalApiGatewayEnabled': globalApiGatewayEnabled,
    'developerRegistrationEnabled': developerRegistrationEnabled,
    'sandboxEnabled': sandboxEnabled,
    'webhooksEnabled': webhooksEnabled,
    'rateLimitingEnforced': rateLimitingEnforced,
    'requireHttpsOnly': requireHttpsOnly,
    'strictTenantIsolation': strictTenantIsolation,
    'allowExternalIntegrations': allowExternalIntegrations,
  };

  factory SuperAdminApiMasterConfig.fromMap(Map<String, dynamic> map) => SuperAdminApiMasterConfig(
    globalApiGatewayEnabled: map['globalApiGatewayEnabled'] ?? true,
    developerRegistrationEnabled: map['developerRegistrationEnabled'] ?? true,
    sandboxEnabled: map['sandboxEnabled'] ?? true,
    webhooksEnabled: map['webhooksEnabled'] ?? true,
    rateLimitingEnforced: map['rateLimitingEnforced'] ?? true,
    requireHttpsOnly: map['requireHttpsOnly'] ?? true,
    strictTenantIsolation: map['strictTenantIsolation'] ?? true,
    allowExternalIntegrations: map['allowExternalIntegrations'] ?? true,
  );
}

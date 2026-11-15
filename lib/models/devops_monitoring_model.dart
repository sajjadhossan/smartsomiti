// lib/models/devops_monitoring_model.dart
// Phase 10: Enterprise Monitoring, DevOps, Automated Backup & Disaster Recovery Models

enum SystemHealthStatus {
  healthy,
  degraded,
  warning,
  critical,
  unavailable,
  unknown;

  String get labelBn {
    switch (this) {
      case SystemHealthStatus.healthy: return 'স্বাভাবিক (Healthy)';
      case SystemHealthStatus.degraded: return 'ধীরগতি (Degraded)';
      case SystemHealthStatus.warning: return 'সতর্কতা (Warning)';
      case SystemHealthStatus.critical: return 'সংকটাপন্ন (Critical)';
      case SystemHealthStatus.unavailable: return 'অনুপলব্ধ (Unavailable)';
      case SystemHealthStatus.unknown: return 'অজ্ঞাত (Unknown)';
    }
  }
}

enum LogLevel {
  info,
  warning,
  error,
  critical,
  security,
  audit,
  performance,
  integration,
  backup,
  deployment,
  synchronization;

  String get label {
    return name.toUpperCase();
  }
}

enum AlertSeverity {
  info,
  low,
  medium,
  high,
  critical;

  String get labelBn {
    switch (this) {
      case AlertSeverity.info: return 'তথ্য (Info)';
      case AlertSeverity.low: return 'নিম্ন (Low)';
      case AlertSeverity.medium: return 'মাঝারি (Medium)';
      case AlertSeverity.high: return 'উচ্চ (High)';
      case AlertSeverity.critical: return 'সংকটজনক (Critical)';
    }
  }
}

enum AlertStatus {
  open,
  acknowledged,
  investigating,
  resolved,
  ignored,
  escalated;

  String get labelBn {
    switch (this) {
      case AlertStatus.open: return 'উন্মুক্ত (Open)';
      case AlertStatus.acknowledged: return 'গৃহীত (Acknowledged)';
      case AlertStatus.investigating: return 'তদন্তাধীন (Investigating)';
      case AlertStatus.resolved: return 'মীমাংসিত (Resolved)';
      case AlertStatus.ignored: return 'উপেক্ষিত (Ignored)';
      case AlertStatus.escalated: return 'উত্তোলিত (Escalated)';
    }
  }
}

enum IncidentSeverity {
  sev1Critical,
  sev2High,
  sev3Medium,
  sev4Low;

  String get labelBn {
    switch (this) {
      case IncidentSeverity.sev1Critical: return 'SEV-1 (জরুরি সংকট)';
      case IncidentSeverity.sev2High: return 'SEV-2 (গুরুতর সমস্যা)';
      case IncidentSeverity.sev3Medium: return 'SEV-3 (মাঝারি বিভ্রাট)';
      case IncidentSeverity.sev4Low: return 'SEV-4 (সামান্য ত্রুটি)';
    }
  }
}

enum IncidentStatus {
  detected,
  acknowledged,
  investigating,
  contained,
  recovered,
  resolved,
  closed;

  String get labelBn {
    switch (this) {
      case IncidentStatus.detected: return 'শনাক্তকৃত (Detected)';
      case IncidentStatus.acknowledged: return 'স্বীকৃত (Acknowledged)';
      case IncidentStatus.investigating: return 'তদন্তাধীন (Investigating)';
      case IncidentStatus.contained: return 'নিয়ন্ত্রিত (Contained)';
      case IncidentStatus.recovered: return 'পুনরুদ্ধারকৃত (Recovered)';
      case IncidentStatus.resolved: return 'মীমাংসিত (Resolved)';
      case IncidentStatus.closed: return 'বন্ধ (Closed)';
    }
  }
}

enum BackupType {
  full,
  incremental,
  scheduled,
  onDemand,
  preDeployment,
  preMigration;

  String get labelBn {
    switch (this) {
      case BackupType.full: return 'সম্পূর্ণ ব্যাকআপ (Full)';
      case BackupType.incremental: return 'ইনক্রিমেন্টাল ব্যাকআপ (Incremental)';
      case BackupType.scheduled: return 'নির্ধারিত শিডিউল ব্যাকআপ (Scheduled)';
      case BackupType.onDemand: return 'তাৎক্ষণিক ব্যাকআপ (On-Demand)';
      case BackupType.preDeployment: return 'প্রাক-ডিপ্লয়মেন্ট ব্যাকআপ (Pre-Deploy)';
      case BackupType.preMigration: return 'প্রাক-মাইগ্রেশন ব্যাকআপ (Pre-Migration)';
    }
  }
}

enum BackupStatus {
  pending,
  inProgress,
  completed,
  failed,
  verified,
  corrupted;

  String get labelBn {
    switch (this) {
      case BackupStatus.pending: return 'অপেক্ষমান (Pending)';
      case BackupStatus.inProgress: return 'চলমান (In Progress)';
      case BackupStatus.completed: return 'সম্পন্ন (Completed)';
      case BackupStatus.failed: return 'ব্যর্থ (Failed)';
      case BackupStatus.verified: return 'যাচাইকৃত (Verified)';
      case BackupStatus.corrupted: return 'ত্রুটিপূর্ণ (Corrupted)';
    }
  }
}

enum DeploymentStatus {
  queued,
  building,
  testing,
  deploying,
  success,
  failed,
  rolledBack;

  String get labelBn {
    switch (this) {
      case DeploymentStatus.queued: return 'কিউতে অপেক্ষমান (Queued)';
      case DeploymentStatus.building: return 'বিল্ড হচ্ছে (Building)';
      case DeploymentStatus.testing: return 'টেস্ট চলমান (Testing)';
      case DeploymentStatus.deploying: return 'ডেপ্লয় হচ্ছে (Deploying)';
      case DeploymentStatus.success: return 'সফল (Success)';
      case DeploymentStatus.failed: return 'ব্যর্থ (Failed)';
      case DeploymentStatus.rolledBack: return 'রোলব্যাক সম্পন্ন (Rolled Back)';
    }
  }
}

/// Component Health Model
class SystemComponentHealth {
  final String componentId;
  final String componentName;
  final String componentType; // flutterApp, firestore, storage, functions, auth, paymentGateway
  final SystemHealthStatus status;
  final int latencyMs;
  final double errorRatePercent;
  final DateTime lastCheckedAt;
  final String? statusMessage;

  const SystemComponentHealth({
    required this.componentId,
    required this.componentName,
    required this.componentType,
    required this.status,
    required this.latencyMs,
    required this.errorRatePercent,
    required this.lastCheckedAt,
    this.statusMessage,
  });

  Map<String, dynamic> toMap() => {
    'componentId': componentId,
    'componentName': componentName,
    'componentType': componentType,
    'status': status.name,
    'latencyMs': latencyMs,
    'errorRatePercent': errorRatePercent,
    'lastCheckedAt': lastCheckedAt.toIso8601String(),
    'statusMessage': statusMessage,
  };

  factory SystemComponentHealth.fromMap(Map<String, dynamic> map) => SystemComponentHealth(
    componentId: map['componentId'] ?? '',
    componentName: map['componentName'] ?? '',
    componentType: map['componentType'] ?? '',
    status: SystemHealthStatus.values.firstWhere(
      (e) => e.name == map['status'],
      orElse: () => SystemHealthStatus.unknown,
    ),
    latencyMs: map['latencyMs'] ?? 0,
    errorRatePercent: (map['errorRatePercent'] as num?)?.toDouble() ?? 0.0,
    lastCheckedAt: DateTime.tryParse(map['lastCheckedAt'] ?? '') ?? DateTime.now(),
    statusMessage: map['statusMessage'],
  );
}

/// System Structured Log Entry
class SystemLogEntry {
  final String logId;
  final LogLevel level;
  final String message;
  final String serviceName;
  final String environment;
  final String? correlationId;
  final String? societyId;
  final String? userId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const SystemLogEntry({
    required this.logId,
    required this.level,
    required this.message,
    required this.serviceName,
    required this.environment,
    this.correlationId,
    this.societyId,
    this.userId,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() => {
    'logId': logId,
    'level': level.name,
    'message': message,
    'serviceName': serviceName,
    'environment': environment,
    'correlationId': correlationId,
    'societyId': societyId,
    'userId': userId,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory SystemLogEntry.fromMap(Map<String, dynamic> map) => SystemLogEntry(
    logId: map['logId'] ?? '',
    level: LogLevel.values.firstWhere(
      (e) => e.name == map['level'],
      orElse: () => LogLevel.info,
    ),
    message: map['message'] ?? '',
    serviceName: map['serviceName'] ?? '',
    environment: map['environment'] ?? 'prod',
    correlationId: map['correlationId'],
    societyId: map['societyId'],
    userId: map['userId'],
    timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
  );
}

/// Error Group Fingerprint Model
class ErrorGroupModel {
  final String errorFingerprint;
  final String errorType;
  final String messageSummary;
  final String stackTracePreview;
  final int occurrenceCount;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final AlertSeverity severity;
  final String status; // ACTIVE, RESOLVED, MUTED
  final String? assignedTo;

  const ErrorGroupModel({
    required this.errorFingerprint,
    required this.errorType,
    required this.messageSummary,
    required this.stackTracePreview,
    required this.occurrenceCount,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.severity,
    this.status = 'ACTIVE',
    this.assignedTo,
  });

  Map<String, dynamic> toMap() => {
    'errorFingerprint': errorFingerprint,
    'errorType': errorType,
    'messageSummary': messageSummary,
    'stackTracePreview': stackTracePreview,
    'occurrenceCount': occurrenceCount,
    'firstSeenAt': firstSeenAt.toIso8601String(),
    'lastSeenAt': lastSeenAt.toIso8601String(),
    'severity': severity.name,
    'status': status,
    'assignedTo': assignedTo,
  };
}

/// System Alert Model
class SystemAlertModel {
  final String alertId;
  final String title;
  final String message;
  final AlertSeverity severity;
  final AlertStatus status;
  final String category; // crash, quota, latency, security, backup, deployment
  final DateTime triggeredAt;
  final String? acknowledgedBy;
  final DateTime? resolvedAt;

  const SystemAlertModel({
    required this.alertId,
    required this.title,
    required this.message,
    required this.severity,
    required this.status,
    required this.category,
    required this.triggeredAt,
    this.acknowledgedBy,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() => {
    'alertId': alertId,
    'title': title,
    'message': message,
    'severity': severity.name,
    'status': status.name,
    'category': category,
    'triggeredAt': triggeredAt.toIso8601String(),
    'acknowledgedBy': acknowledgedBy,
    'resolvedAt': resolvedAt?.toIso8601String(),
  };
}

/// Incident Management Model
class IncidentModel {
  final String incidentId;
  final String title;
  final IncidentSeverity severity;
  final IncidentStatus status;
  final String affectedService;
  final String environment;
  final String leadResponder;
  final String? rootCauseAnalysis;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const IncidentModel({
    required this.incidentId,
    required this.title,
    required this.severity,
    required this.status,
    required this.affectedService,
    required this.environment,
    required this.leadResponder,
    this.rootCauseAnalysis,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() => {
    'incidentId': incidentId,
    'title': title,
    'severity': severity.name,
    'status': status.name,
    'affectedService': affectedService,
    'environment': environment,
    'leadResponder': leadResponder,
    'rootCauseAnalysis': rootCauseAnalysis,
    'createdAt': createdAt.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
  };
}

/// Backup Record Model
class BackupRecordModel {
  final String backupId;
  final BackupType type;
  final String environment;
  final int approximateSizeBytes;
  final String storagePath;
  final BackupStatus status;
  final bool isVerified;
  final DateTime retentionExpiresAt;
  final String initiatedBy;
  final DateTime createdAt;
  final DateTime? completedAt;

  const BackupRecordModel({
    required this.backupId,
    required this.type,
    required this.environment,
    required this.approximateSizeBytes,
    required this.storagePath,
    required this.status,
    required this.isVerified,
    required this.retentionExpiresAt,
    required this.initiatedBy,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'backupId': backupId,
    'type': type.name,
    'environment': environment,
    'approximateSizeBytes': approximateSizeBytes,
    'storagePath': storagePath,
    'status': status.name,
    'isVerified': isVerified,
    'retentionExpiresAt': retentionExpiresAt.toIso8601String(),
    'initiatedBy': initiatedBy,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };
}

/// Safe Restore Request Model (Maker-Checker Enforced)
class RestoreRequestModel {
  final String requestId;
  final String backupId;
  final String targetEnvironment; // non-prod only without dual-key
  final String requestedBy;
  final String? approvedBy; // Mandatory for production
  final String status; // SUBMITTED, APPROVED, EXECUTED, REJECTED
  final String? validationReport;
  final DateTime requestedAt;
  final DateTime? executedAt;

  const RestoreRequestModel({
    required this.requestId,
    required this.backupId,
    required this.targetEnvironment,
    required this.requestedBy,
    this.approvedBy,
    required this.status,
    this.validationReport,
    required this.requestedAt,
    this.executedAt,
  });

  Map<String, dynamic> toMap() => {
    'requestId': requestId,
    'backupId': backupId,
    'targetEnvironment': targetEnvironment,
    'requestedBy': requestedBy,
    'approvedBy': approvedBy,
    'status': status,
    'validationReport': validationReport,
    'requestedAt': requestedAt.toIso8601String(),
    'executedAt': executedAt?.toIso8601String(),
  };
}

/// Deployment Pipeline Record
class DeploymentRecordModel {
  final String deployId;
  final String version;
  final String environment;
  final String commitHash;
  final DeploymentStatus status;
  final String deployedBy;
  final String rollbackTargetVersion;
  final DateTime startedAt;
  final DateTime? completedAt;

  const DeploymentRecordModel({
    required this.deployId,
    required this.version,
    required this.environment,
    required this.commitHash,
    required this.status,
    required this.deployedBy,
    required this.rollbackTargetVersion,
    required this.startedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'deployId': deployId,
    'version': version,
    'environment': environment,
    'commitHash': commitHash,
    'status': status.name,
    'deployedBy': deployedBy,
    'rollbackTargetVersion': rollbackTargetVersion,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };
}

/// Super Admin DevOps Master Config Model
class DevOpsMasterConfigModel {
  final bool masterMonitoringEnabled;
  final bool errorTrackingEnabled;
  final bool backupAutoScheduleEnabled;
  final bool maintenanceModeActive;
  final String maintenanceBypassToken;
  final String dailyBackupTimeDhaka; // default "02:00"
  final int p95LatencyAlertThresholdMs; // default 300
  final double errorRateAlertThresholdPercent; // default 1.5

  const DevOpsMasterConfigModel({
    this.masterMonitoringEnabled = true,
    this.errorTrackingEnabled = true,
    this.backupAutoScheduleEnabled = true,
    this.maintenanceModeActive = false,
    this.maintenanceBypassToken = 'ADM-BYPASS-SEC-99881',
    this.dailyBackupTimeDhaka = '02:00',
    this.p95LatencyAlertThresholdMs = 300,
    this.errorRateAlertThresholdPercent = 1.5,
  });

  Map<String, dynamic> toMap() => {
    'masterMonitoringEnabled': masterMonitoringEnabled,
    'errorTrackingEnabled': errorTrackingEnabled,
    'backupAutoScheduleEnabled': backupAutoScheduleEnabled,
    'maintenanceModeActive': maintenanceModeActive,
    'maintenanceBypassToken': maintenanceBypassToken,
    'dailyBackupTimeDhaka': dailyBackupTimeDhaka,
    'p95LatencyAlertThresholdMs': p95LatencyAlertThresholdMs,
    'errorRateAlertThresholdPercent': errorRateAlertThresholdPercent,
  };
}

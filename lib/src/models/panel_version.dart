/// Panel version enum for Piprapay API
enum PanelVersion {
  /// Piprapay API v2 (legacy)
  v2,
  /// Piprapay API v3+ (current and recommended)
  v3plus,
}

extension PanelVersionExt on PanelVersion {
  String get displayName {
    switch (this) {
      case PanelVersion.v2:
        return 'v2';
      case PanelVersion.v3plus:
        return 'v3+';
    }
  }

  bool get isV3Plus => this == PanelVersion.v3plus;
  bool get isV2 => this == PanelVersion.v2;
}

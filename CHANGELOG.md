# Changelog

All notable changes to Velox-Q are documented here.

## [0.2.0] - 2026-09-30

### Added

- Multi-player selection in the media popup with player application identity.
- Capability-aware shuffle and repeat controls.
- Player foreground action and track metadata context actions.
- Hardware-aware WiFi and Bluetooth connectivity interactions.
- Tactile hover, press, transition, and error-state feedback across network controls.

### Changed

- Redesigned the media popup player-selection and control experience.
- Redesigned the network popup WiFi and Bluetooth interaction flows.
- Improved WiFi scanning, secure-network authentication, and connection-state feedback.
- Improved Bluetooth pairing, connection, disconnection, and adapter power-state handling.
- Improved popup tab and row transition animations.

### Fixed

- Media metadata synchronization when the active player or track changes.
- Repeated directional animation when switching network popup tabs.
- WiFi scan-status button sizing and `Scanning...` text clipping.
- Network hover and press-state visual flashes caused by overlapping interaction states.

## [0.1.0] - 2026-09-27

### Added

- System integration capability layer for hardware and backend availability.
- Hardware-aware Battery, Brightness, Bluetooth, Audio, Network, Media, Wallpaper, Session, and Caffeine handling.
- Global visual design tokens.
- Shared UI state styling.
- Trigger-relative popup positioning.
- Shared popup card component.
- Notification visual and interaction refinements.

### Changed

- Improved graceful degradation when hardware or system backends are unavailable.
- Improved popup positioning and trigger relationships.
- Improved notification toast presentation and interaction feedback.

### Fixed

- Popup positioning issues caused by trigger-pill hover expansion.
- System Monitor hover expansion behavior.
- Launcher and Session scrim opacity behavior.

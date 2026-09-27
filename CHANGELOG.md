# Changelog

All notable changes to Velox-Q are documented here.

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

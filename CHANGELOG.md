## 0.0.1

* TODO: Describe initial release.

## 0.0.2

### Added
* Complete UI/UX redesign of the example app with modern Material 3 design
* Tabbed navigation with Home, Servers, and Settings pages
* Visual connection status indicator with color-coded states
* Dedicated servers page showing all available servers from subscriptions
* Server cards with connection status, latency, and location information
* Real-time ping functionality for server latency testing
* Session statistics display with formatted data usage
* Subscription management with loading states and error handling
* Settings page with auto-connect and kill switch toggles
* Loading indicators and user feedback via snackbars
* Dark theme support
* Responsive design optimized for mobile devices

### Improved
* Better information hierarchy and user flow
* Clear separation of connection controls and server management
* Enhanced visual feedback for connection states
* Improved error handling and user notifications
* More intuitive navigation between different app sections

### Fixed
* getServerList method now returns actual servers from loaded subscriptions instead of hardcoded test data
* Server address extraction from subscription URLs with location detection
* Proper server count display matching loaded subscription data

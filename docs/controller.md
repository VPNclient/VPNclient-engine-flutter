### **Methods (API)**
1. **initialize()**
   - Initializes the VPN controller and prepares it for use.
   - Should be called before any other method.

2. **connect({required String serverAddress, required String credentials})**
   - Connects to the specified VPN server using the provided credentials.
   - Parameters:
     - `serverAddress`: The address of the VPN server.
     - `credentials`: Authentication details (e.g., username, password, or token).

3. **disconnect()**
   - Disconnects the active VPN connection.

4. **switchServer({required String newServerAddress})**
   - Switches the VPN connection to a new server.
   - Parameters:
     - `newServerAddress`: The address of the new VPN server.

5. **getConnectionStatus()**
   - Returns the current connection status (e.g., connected, disconnected, connecting, error).

6. **getServerList()**
   - Fetches the list of available VPN servers.
   - Returns a list of server addresses or server objects.

7. **pingServer({required String serverAddress})**
   - Pings a specific server to check latency.
   - Parameters:
     - `serverAddress`: The address of the server to ping.
   - Returns the latency in milliseconds.

8. **setRoutingRules({required List<RoutingRule> rules})**
   - Configures routing rules for specific apps or domains.
   - Parameters:
     - `rules`: A list of routing rules (e.g., route YouTube traffic through VPN, block ads.com).

9. **loadSubscription({required String subscriptionLink})**
   - Loads a VPN subscription from the provided link.
   - Parameters:
     - `subscriptionLink`: The link to the subscription file.

10. **updateController()**
    - Checks for and applies updates to the VPN controller (e.g., new versions of X-Ray or other dependencies).

11. **setProxy({required ProxyConfig proxyConfig})**
    - Configures a proxy for the VPN connection.
    - Parameters:
      - `proxyConfig`: Configuration for the proxy (e.g., type, address, port).

12. **getSessionStatistics()**
    - Returns statistics for the current VPN session (e.g., data usage, duration).

13. **setAutoConnect({required bool enable})**
    - Enables or disables auto-connect functionality.
    - Parameters:
      - `enable`: Whether to enable auto-connect.

14. **setKillSwitch({required bool enable})**
    - Enables or disables the kill switch (block all traffic if VPN disconnects).
    - Parameters:
      - `enable`: Whether to enable the kill switch.

15. **setLanguage({required String languageCode})**
    - Sets the language for error messages and UI localization.
    - Parameters:
      - `languageCode`: The language code (e.g., "en", "ru").

---

### **Events**
1. **onConnectionStatusChanged**
   - Fired when the VPN connection status changes.
   - Payload: `ConnectionStatus` (e.g., connected, disconnected, error).

2. **onError**
   - Fired when an error occurs (e.g., connection failed, invalid credentials).
   - Payload: `ErrorCode` and `ErrorMessage`.

3. **onServerSwitched**
   - Fired when the VPN server is successfully switched.
   - Payload: `newServerAddress`.

4. **onPingResult**
   - Fired when a ping operation completes.
   - Payload: `serverAddress` and `latencyInMs`.

5. **onSubscriptionLoaded**
   - Fired when a subscription is successfully loaded.
   - Payload: `subscriptionDetails`.

6. **onDataUsageUpdated**
   - Fired periodically with updated data usage statistics.
   - Payload: `dataUsed` and `dataRemaining`.

7. **onRoutingRulesApplied**
   - Fired when routing rules are successfully applied.
   - Payload: `List<RoutingRule>`.

8. **onControllerUpdated**
   - Fired when the VPN controller is successfully updated.
   - Payload: `newVersion`.

9. **onProxyConfigured**
   - Fired when the proxy is successfully configured.
   - Payload: `ProxyConfig`.

10. **onKillSwitchTriggered**
    - Fired when the kill switch is activated (e.g., VPN disconnects unexpectedly).
    - Payload: None.

---

### **Data Models**
1. **ConnectionStatus**
   - Enum: `connecting`, `connected`, `disconnected`, `error`.

2. **Server**
   - Properties: `address`, `latency`, `location`, `isPreferred`.

3. **RoutingRule**
   - Properties: `appName`, `domain`, `action` (e.g., `block`, `allow`, `routeThroughVPN`).

4. **ProxyConfig**
   - Properties: `type` (e.g., `socks5`, `http`), `address`, `port`, `credentials`.

5. **ErrorCode**
   - Enum: `invalidCredentials`, `serverUnavailable`, `subscriptionExpired`, `unknownError`.

6. **SubscriptionDetails**
   - Properties: `expiryDate`, `dataLimit`, `usedData`.

---

### **Example Usage**
```dart
// Initialize the controller
vpnController.initialize();

// Connect to a VPN server
vpnController.connect(
  serverAddress: "vpn.example.com",
  credentials: "user:password",
);

// Listen for connection status changes
vpnController.onConnectionStatusChanged.listen((status) {
  print("Connection status: $status");
});

// Set routing rules
vpnController.setRoutingRules(
  rules: [
    RoutingRule(appName: "YouTube", action: "routeThroughVPN"),
    RoutingRule(domain: "ads.com", action: "block"),
  ],
);

// Ping a server
vpnController.pingServer(serverAddress: "vpn.example.com");
vpnController.onPingResult.listen((result) {
  print("Ping result: ${result.latencyInMs} ms");
});
```

---

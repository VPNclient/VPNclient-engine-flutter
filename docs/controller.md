### **Methods (API)**
1. **initialize()**
   - Initializes the VPN controller and prepares it for use.
   - Should be called before any other method.

2. **connect({required Integer index})**
   - Connects to the specified VPN server.
   - Parameters:
     - `index`: The index from  from getServerList.

3. **disconnect()**
   - Disconnects the active VPN connection.

4. **getConnectionStatus()**
   - Returns the current connection status (e.g., connected, disconnected, connecting, error).

5. **getServerList()**
   - Fetches the list of available VPN servers.
   - Returns a list of server addresses or server objects.

6. **pingServer({required Integer index})**
   - Pings a specific server to check latency.
   - Parameters:
     - `index`: The index from  from getServerList.
   - Returns the latency in milliseconds.

7. **setRoutingRules({required List<RoutingRule> rules})**
   - Configures routing rules for specific apps or domains.
   - Parameters:
     - `rules`: A list of routing rules (e.g., route YouTube traffic through VPN, block ads.com).

8. **loadSubscription({required String subscriptionLink})**
   - Loads a VPN subscription from the provided link.
   - Parameters:
     - `subscriptionLink`: The link to the subscription file.

9. **getSessionStatistics()**
    - Returns statistics for the current VPN session (e.g., data usage, duration).

10. **setAutoConnect({required bool enable})**
    - Enables or disables auto-connect functionality.
    - Parameters:
      - `enable`: Whether to enable auto-connect.

11. **setKillSwitch({required bool enable})**
    - Enables or disables the kill switch (block all traffic if VPN disconnects).
    - Parameters:
      - `enable`: Whether to enable the kill switch.


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
   - Может в onConnectionStatusChanged?
   - Payload: `newServerAddress`.

4. **onPingResult**
   - Fired when a ping operation completes.
   - Payload: `serverIndex` and `latencyInMs`.

5. **onSubscriptionLoaded**
   - Fired when a subscription is successfully loaded.
   - Payload: `subscriptionDetails`.

6. **onDataUsageUpdated**
   - Fired periodically with updated data usage statistics.
   - Payload: `dataUsed` and `dataRemaining`.

7. **onRoutingRulesApplied**
   - Fired when routing rules are successfully applied.
   - Payload: `List<RoutingRule>`.

8. **onKillSwitchTriggered**
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

// load subscription
vpnController.loadSubscription(
  subscriptionLink: "https://pastebin.com/raw/ZCYiJ98W"
);

// Connect to a VPN server
vpnController.connect(
  serverAddress: 1
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
vpnController.pingServer(index: 1);
vpnController.onPingResult.listen((result) {
  print("Ping result: ${result.latencyInMs} ms");
});
```

---

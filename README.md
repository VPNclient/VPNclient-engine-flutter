# 🚀 VPN Client Controller Flutter

## 🌍 Overview

VPN Client Controller Flutter is a Flutter wrapper for managing VPN connections with an intuitive API. It provides seamless integration with various platforms, allowing developers to control VPN connections efficiently.
![VPN Client Controller](https://raw.githubusercontent.com/VPNclient/.github/refs/heads/main/assets/vpnclient_scheme2.png)

### ✅ Supported Platforms
- iOS 15+ (iPhone, iPad, MacOS M)
- Android
- 🏗️ MacOS Intel (coming soon)
- 🏗️ Windows (coming soon)
- 🏗️ Ubuntu (coming soon)

## 📥 Getting Started

To start using VPN Client Controller Flutter, ensure you have Flutter installed and set up your project accordingly.

### 📦 Installation
```sh
flutter pub add vpnclient_controller
```

## 📌 Example Usage

```dart
// Initialize the controller
vpnController.initialize();

// Load subscription
vpnController.loadSubscription(
  subscriptionLink: "https://pastebin.com/raw/ZCYiJ98W"
);

// Connect to a VPN server
vpnController.connect(index: 1);

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

## ⚙️ API Methods

### 🔹 1. initialize()
Initializes the VPN controller. This should be called before using any other method.

### 🔹 2. connect({required int index})
Connects to the specified VPN server.
- `index`: Index of the server from `getServerList()`.

### 🔹 3. disconnect()
Disconnects the active VPN connection.

### 🔹 4. getConnectionStatus()
Returns the current connection status (`connected`, `disconnected`, `connecting`, `error`).

### 🔹 5. getServerList()
Fetches the list of available VPN servers.

### 🔹 6. pingServer({required int index})
Pings a specific server to check latency.
- `index`: Index of the server from `getServerList()`.
- Returns: Latency in milliseconds.

### 🔹 7. setRoutingRules({required List<RoutingRule> rules})
Configures routing rules for apps or domains.
- `rules`: List of routing rules (e.g., route YouTube traffic through VPN, block ads.com).

### 🔹 8. loadSubscription({required String subscriptionLink})
Loads a VPN subscription from the provided link.
- `subscriptionLink`: The subscription file URL.

### 🔹 9. getSessionStatistics()
Returns statistics for the current VPN session (e.g., data usage, session duration).

### 🔹 10. setAutoConnect({required bool enable})
Enables or disables auto-connect functionality.
- `enable`: `true` to enable, `false` to disable.

### 🔹 11. setKillSwitch({required bool enable})
Enables or disables the kill switch.
- `enable`: `true` to enable, `false` to disable.

---

## 🔔 Events

### 📡 1. onConnectionStatusChanged
Triggered when VPN connection status changes.
- Payload: `ConnectionStatus` (e.g., `connected`, `disconnected`, `error`).

### ⚠️ 2. onError
Triggered when an error occurs.
- Payload: `ErrorCode` and `ErrorMessage`.

### 🔄 3. onServerSwitched
Triggered when the VPN server is switched.
- Payload: `newServerAddress`.

### 📊 4. onPingResult
Triggered when a ping operation completes.
- Payload: `serverIndex` and `latencyInMs`.

### 🔑 5. onSubscriptionLoaded
Triggered when a subscription is loaded successfully.
- Payload: `subscriptionDetails`.

### 📈 6. onDataUsageUpdated
Triggered periodically with updated data usage statistics.
- Payload: `dataUsed` and `dataRemaining`.

### 📌 7. onRoutingRulesApplied
Triggered when routing rules are applied.
- Payload: `List<RoutingRule>`.

### 🚨 8. onKillSwitchTriggered
Triggered when the kill switch is activated.

---

## 📂 Data Models

### 🔹 1. ConnectionStatus
Enum: `connecting`, `connected`, `disconnected`, `error`.

### 🔹 2. Server
- `address`
- `latency`
- `location`
- `isPreferred`

### 🔹 3. RoutingRule
- `appName`
- `domain`
- `action` (`block`, `allow`, `routeThroughVPN`).

### 🔹 4. ProxyConfig
- `type` (`socks5`, `http`)
- `address`
- `port`
- `credentials`

### 🔹 5. ErrorCode
Enum: `invalidCredentials`, `serverUnavailable`, `subscriptionExpired`, `unknownError`.

### 🔹 6. SubscriptionDetails
- `expiryDate`
- `dataLimit`
- `usedData`

---

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## 📜 License

This project is licensed under ...


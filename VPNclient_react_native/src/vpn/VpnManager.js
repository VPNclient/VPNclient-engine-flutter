import { NativeModules, NativeEventEmitter } from 'react-native';
import V2RayCore from './V2RayCore';
import WireGuardCore from './WireGuardCore';
import OpenVPNCore from './OpenVPNCore';

const { VpnClientManager } = NativeModules;

const vpnClientEmitter = new NativeEventEmitter(VpnClientManager);

class VpnManager {
  constructor() {
    this.vpnCore = null;
    this.currentUrl = '';
    this.config = null;
    this.configType = null;
    this.isConnected = false;
    this.statusListeners = [];
    this.errorListeners = [];

    this.setupEventListeners();
  }

  setupEventListeners() {
    this.statusSubscription = vpnClientEmitter.addListener(
      'onVpnStatusChanged',
      (event) => {
        this.statusListeners.forEach((listener) => listener(event.status));
        if (event.status === 'connected') {
          this.isConnected = true;
        } else if (event.status === 'disconnected') {
          this.isConnected = false;
        }
      }
    );
    this.errorSubscription = vpnClientEmitter.addListener('onVpnError', (event) => {
      this.errorListeners.forEach((listener) => listener(event.error));
      this.isConnected = false;
    });
  }

  async connect(url, config, configType = null) {
    this.currentUrl = url;
    this.config = config;
    this.configType = configType;
    this.vpnCore = this.createCore(url);
    if (!this.vpnCore) {
      throw new Error('Invalid URL');
    }
    await this.vpnCore.connect(url, config, configType);
  }

  async disconnect() {
    if (this.vpnCore) {
      await this.vpnCore.disconnect();
    }
  }

  getServerList() {
    return [
      {
        address: 'vless server',
        url: 'vless://e811a4b3-79ff-4015-b568-c8537f303c2a@vless-server.com:443?path=%2F&security=tls&encryption=none&host=vless-server.com&type=ws&sni=vless-server.com#vless-server',
      },
      {
        address: 'vmess server',
        url: 'vmess://eyJ2IjoiMiIsInBzIjoidm1lc3Mtc2VydmVyIiwiYWRkIjoidm1lc3Mtc2VydmVyLmNvbSIsImFpZCI6IjAiLCJwcnQiOjQ0MywidHlwZSI6IndzIiwidiI6IjIiLCJ0bHMiOiJ0bHMiLCJwYXRoIjoiLyIsImhvc3QiOiJ2bWVzcy1zZXJ2ZXIuY29tIiwicHMiOiJ2bWVzcy1zZXJ2ZXIiLCJpZCI6IjE4MzZhYTVjLTY3MzItNDlkNy05YmFmLTlkYTk2N2Y2NDlmYSIsIm5ldCI6IndzIn0=',
      },
      {
        address: 'wg server',
        url: 'wg://[2001:db8:1::1]:51820#wg-server',
      },
      {
        address: 'openvpn server',
        url: 'openvpn-server.ovpn',
        config:
          'client\n'+
          'dev tun\n'+
          'proto udp\n'+
          'remote openvpn-server.com 1194\n'+
          'resolv-retry infinite\n'+
          'nobind\n'+
          'persist-key\n'+
          'persist-tun\n'+
          'verb 3\n',
      },
    ];
  }

  

  async disconnect() {
    if (this.vpnCore) {
      await this.vpnCore.disconnect();
      this.isConnected = false;
    }
  }
  createCore(url) {
    if (url.startsWith('vless://') || url.startsWith('vmess://')) {
      return new V2RayCore(VpnClientManager);
    } else if (url.startsWith('wg://')) {
      return new WireGuardCore(VpnClientManager);
    } else if (url.endsWith('.ovpn')) {
      return new OpenVPNCore(VpnClientManager);
    }
    return null;
  }

  async getStatus() {
    return this.isConnected;
  }

  addStatusListener(listener) {
    this.statusListeners.push(listener);
  }

  removeStatusListener(listener) {
    this.statusListeners = this.statusListeners.filter((l) => l !== listener);
  }

  addErrorListener(listener) {
    this.errorListeners.push(listener);
  }

  removeErrorListener(listener) {
    this.errorListeners = this.errorListeners.filter((l) => l !== listener);
  }

  clearListeners() {
    this.statusSubscription.remove();
    this.errorSubscription.remove();
  }
}

export default new VpnManager();

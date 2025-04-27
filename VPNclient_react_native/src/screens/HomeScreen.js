import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TextInput, Alert } from 'react-native';
import ConnectionButton from '../components/ConnectionButton';
import ServerList from '../components/ServerList';
import VpnManager from '../vpn/VpnManager';

function HomeScreen() {
  const [isConnected, setIsConnected] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState('Disconnected');
  const [servers, setServers] = useState([]);
  const [vpnUrl, setVpnUrl] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  const handleConnect = async () => {
    try {
      setErrorMessage('');
      if (isConnected) {
        setConnectionStatus('Disconnecting...');
        await VpnManager.disconnect();
        setConnectionStatus('Disconnected');
        setIsConnected(false);
      } else {
        setConnectionStatus('Connecting...');
        await VpnManager.connect(vpnUrl, null);
        setIsConnected(true);
        setConnectionStatus('Connected');
      }
      const status = await VpnManager.getStatus();
      setIsConnected(status);
    } catch (error) {
      console.error('Connection error:', error);
      setIsConnected(false);
      setConnectionStatus('Error');
      setErrorMessage(error.message || 'Unknown error');
      Alert.alert('Error', errorMessage);
    }
  };

  useEffect(() => {
    const loadServers = async () => {
      const serverList = await VpnManager.getServerList();
      setServers(serverList);
    };

    loadServers();
    const statusSubscription = VpnManager.onStatusChanged.subscribe(
      (status) => {
        setConnectionStatus(status);
        if(status === "connected"){
          setIsConnected(true);
        }else{
          setIsConnected(false);
        }
      }
    );

    const errorSubscription = VpnManager.onError.subscribe(
      (error) => {
        setErrorMessage(error.message);
        setConnectionStatus("Error");
        setIsConnected(false);
        Alert.alert('Error', error.message);
      }
    );

    return () => {
      statusSubscription.unsubscribe();
      errorSubscription.unsubscribe();
    };
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.status}>{`Status: ${connectionStatus}`}</Text>
      <TextInput
        style={styles.input}
        placeholder="Enter VPN URL"
        onChangeText={setVpnUrl}
        value={vpnUrl}
      />
      <ConnectionButton isConnected={isConnected} onPress={handleConnect} />
      <ServerList servers={servers} onSelect={() => {}} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  input: {
    borderWidth: 1,
    borderColor: 'gray',
    width: 300,
    padding: 10,
    marginVertical: 10,
  },
  status: {
    marginBottom: 20,
    fontSize: 18,
  },
});

export default HomeScreen;
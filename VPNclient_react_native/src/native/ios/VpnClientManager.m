objectivec
#import "VpnClientManager.h"
#import <vpnclient/vpnclient.h>
#import <React/RCTLog.h>
#import <React/RCTEventEmitter.h>

@interface VpnClientManager () <VpnStatusDelegate>

@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) BOOL isDisconnecting;
@property (nonatomic, strong) RCTPromiseResolveBlock connectResolve;
@property (nonatomic, strong) RCTPromiseRejectBlock connectReject;
@end


@implementation VpnClientManager

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onVpnStatusChanged", @"onVpnError"];
}

RCT_EXPORT_METHOD(connect:(NSString *)url config:(NSString *)config
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    self.connectResolve = resolve;
    self.connectReject = reject;    
    RCTLogInfo(@"Starting VPN using url: %@", url);
    RCTLogInfo(@"Starting VPN using config: %@", config);

    if(self.isConnecting || self.isConnected){
        reject(@"connection_error", @"Already connecting", nil);
        return;
    }
    if(self.isDisconnecting){
        reject(@"disconnecting_error", @"Disconnecting...", nil);
        return;
    }
    self.isConnecting = YES;

    const char *urlChar = [url UTF8String];
    const char *configChar = [config UTF8String];

    setVpnStatusDelegate(self);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(config != (id)[NSNull null] && config.length > 0){
            startVpn(urlChar, configChar);
        }else{
            startVpn(urlChar, NULL);
        }
        
    });
}


RCT_EXPORT_METHOD(disconnect:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    if(!self.isConnected){
        reject(@"not_connected", @"Not connected", nil);
        return;
    }
    if(self.isConnecting){
        reject(@"connecting_error", @"Connecting...", nil);
        return;
    }
    if(self.isDisconnecting){
        reject(@"disconnecting_error", @"Already disconnecting...", nil);
        return;
    }
    self.isDisconnecting = YES;

     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         RCTLogInfo(@"Stopping VPN");
         stopVpn();
          dispatch_async(dispatch_get_main_queue(), ^{
              resolve(nil);
              self.isDisconnecting = NO;
         });
     });

}

//VpnStatusDelegate
-(void)onVpnStatusChanged:(const char *)status{
    NSString* statusString = [[NSString alloc] initWithUTF8String:status];

    if ([statusString isEqualToString:@"connected"]) {
        self.isConnected = YES;
        self.isConnecting = NO;
    } else if ([statusString isEqualToString:@"disconnected"]) {
        self.isConnected = NO;
        self.isConnecting = NO;
    }else if ([statusString isEqualToString:@"connecting"]) {
         self.isConnecting = YES;
    }
    
     [self sendEventWithName:@"onVpnStatusChanged" body:@{@"status": statusString}];
     NSLog(@"VPN Status: %@", statusString);
    
    if (self.connectResolve) {
         self.connectResolve(statusString);
        self.connectResolve = nil;
     }
}

-(void)onVpnError:(const char *)error{
    NSString* errorString = [[NSString alloc] initWithUTF8String:error];
     [self sendEventWithName:@"onVpnError" body:@{@"error": errorString}];
    NSLog(@"VPN Error: %@", errorString);
}
-(void)vpnConnectionError{
    if(self.connectReject){
        self.connectReject(@"vpn_error", @"VPN error", nil);
        self.connectReject = nil;
    }
}

@end
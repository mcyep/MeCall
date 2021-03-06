//
//  MeCallManager.m
//  MeCall
//
//  Created by u2systems on 13/07/2016.
//  Copyright © 2016 u2systems. All rights reserved.
//

#import "MeCallManager.h"
#import "linphonecore.h"

@implementation MeCall

NSString *const MCNotification_Registration = @"MCNotification_Registration";
NSString *const MCNotification_Call         = @"MCNotification_Call";
NSString *const kRegistrationState          = @"kRegistrationState";
NSString *const kRegistrationFailReason     = @"kRegistrationFailReason";
NSString *const kCallState                  = @"kCallState";
NSString *const kCallRemote                 = @"kCallRemote";

extern void libmssilk_init(MSFactory *factory);
extern void libmsamr_init(MSFactory *factory);
extern void libmsx264_init(MSFactory *factory);
extern void libmsopenh264_init(MSFactory *factory);
extern void libmsbcg729_init(MSFactory *factory);

static LinphoneCore* linphoneCore = nil;
static dispatch_queue_t privateQueue = nil;

+ (void)initialize
{
    linphone_core_set_log_handler(mecall_log_handler);
    linphone_core_set_log_level((OrtpLogLevel)MCLogLevelMESSAGE);
    linphoneCore = linphone_core_new(&linphonec_vtable, NULL, NULL, NULL);
    MSFactory *f = linphone_core_get_ms_factory(linphoneCore);
    libmssilk_init(f);
    libmsamr_init(f);
    libmsx264_init(f);
    libmsopenh264_init(f);
    libmsbcg729_init(f);
    linphone_core_reload_ms_plugins(linphoneCore, NULL);
    linphone_core_enable_ipv6(linphoneCore, FALSE);
    privateQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(iterate) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

+ (void)iterate
{
    dispatch_async(privateQueue, ^{
        linphone_core_iterate(linphoneCore);
    });
}

+ (void)setupProxyConfig:(NSString*)sipUsername sipPassword:(NSString*)sipPassword sipServer:(NSString*)sipServer sipIdentity:(NSString*)sipIdentity
{
    dispatch_async(privateQueue, ^{
        linphone_core_clear_proxy_config(linphoneCore);
        linphone_core_clear_all_auth_info(linphoneCore);
        linphone_core_set_primary_contact(linphoneCore, [sipIdentity UTF8String]);
        LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(linphoneCore);
        LinphoneAddress *identity = linphone_address_new([sipIdentity UTF8String]);
        linphone_proxy_config_set_identity_address(proxyCfg, identity);
        linphone_proxy_config_set_server_addr(proxyCfg, [sipServer UTF8String]);
        linphone_proxy_config_set_route(proxyCfg, [sipServer UTF8String]);
        linphone_proxy_config_set_expires(proxyCfg, 0);
        linphone_proxy_config_enable_register(proxyCfg, false);
        LinphoneAuthInfo* authInfo = linphone_auth_info_new([sipUsername UTF8String], NULL, [sipPassword UTF8String], NULL, NULL, linphone_proxy_config_get_domain(proxyCfg));
        linphone_core_add_auth_info(linphoneCore, authInfo);
        linphone_core_add_proxy_config(linphoneCore, proxyCfg);
        linphone_core_set_default_proxy_config(linphoneCore, proxyCfg);
        linphone_address_destroy(identity);
        linphone_auth_info_destroy(authInfo);
    });
}

+ (void)setupSipTransport:(MCSipTransport)sipTransport sipPort:(int)sipPort userAgentName:(NSString*)userAgentName userAgentVersion:(NSString*)userAgentVersion
{
    dispatch_async(privateQueue, ^{
        LCSipTransports sipTransports = {0,0,0,0};
        sipTransports.udp_port  = (sipTransport == MCSipTransportUDP)  ? sipPort : 0;
        sipTransports.tcp_port  = (sipTransport == MCSipTransportTCP)  ? sipPort : 0;
        sipTransports.tls_port  = (sipTransport == MCSipTransportTLS)  ? sipPort : 0;
        sipTransports.dtls_port = (sipTransport == MCSipTransportDTLS) ? sipPort : 0;
        linphone_core_set_sip_transports(linphoneCore, &sipTransports);
        linphone_core_set_user_agent(linphoneCore, [userAgentName UTF8String], [userAgentVersion UTF8String]);
    });
}

+ (void)setupMediaTransport:(MCMediaTransport)mediaTransport audioPort:(int)audioPort
{
    dispatch_async(privateQueue, ^{
        LinphoneMediaEncryption encryption = (LinphoneMediaEncryption)mediaTransport;
        linphone_core_set_media_encryption(linphoneCore, encryption);
        linphone_core_set_audio_port(linphoneCore, audioPort);
    });
}

+ (void)setupAudioCodec:(NSArray*)audioCodecs
{
    dispatch_async(privateQueue, ^{
        for (const bctbx_list_t *elem=linphone_core_get_audio_codecs(linphoneCore); elem!=NULL; elem=elem->next)
            linphone_core_enable_payload_type(linphoneCore, elem->data, FALSE);
        
        bctbx_list_t *head = bctbx_list_copy(linphone_core_get_audio_codecs(linphoneCore));
        for (NSString *codec in [audioCodecs reverseObjectEnumerator])
        {
            PayloadType *pt = linphone_core_find_payload_type(linphoneCore, [codec UTF8String], LINPHONE_FIND_PAYLOAD_IGNORE_RATE, LINPHONE_FIND_PAYLOAD_IGNORE_CHANNELS);
            if (pt != NULL)
            {
                linphone_core_enable_payload_type(linphoneCore, pt, TRUE);
                head = bctbx_list_remove(head, pt);
                head = bctbx_list_prepend(head, pt);
            }
        }
        linphone_core_set_audio_codecs(linphoneCore, head);
    });
}

+ (void)startRegistering:(int)expire
{
    dispatch_async(privateQueue, ^{
        LinphoneProxyConfig* proxyCfg = linphone_core_get_default_proxy_config(linphoneCore);
        if (proxyCfg == NULL) return;
        linphone_proxy_config_edit(proxyCfg);
        linphone_proxy_config_set_expires(proxyCfg, expire);
        linphone_proxy_config_enable_register(proxyCfg, true);
        linphone_proxy_config_done(proxyCfg);
    });
}

+ (void)stopRegistering
{
    dispatch_async(privateQueue, ^{
        LinphoneProxyConfig* proxyCfg = linphone_core_get_default_proxy_config(linphoneCore);
        if (proxyCfg == NULL) return;
        linphone_proxy_config_edit(proxyCfg);
        linphone_proxy_config_set_expires(proxyCfg, 0);
        linphone_proxy_config_enable_register(proxyCfg, false);
        linphone_proxy_config_done(proxyCfg);
    });
}

+ (void)acceptCall:(NSString*)remote
{
    dispatch_async(privateQueue, ^{
        LinphoneCall *call = [self getCallWithRemote:remote];
        if (call != NULL) {
            linphone_core_accept_call(linphoneCore, call);
        }
    });
}

+ (void)declineCall:(NSString*)remote reason:(MCReason)reason
{
    dispatch_async(privateQueue, ^{
        LinphoneCall *call = [self getCallWithRemote:remote];
        if (call != NULL) {
            linphone_core_decline_call(linphoneCore, call, (LinphoneReason)reason);
        }
    });
}

+ (void)terminateCall:(NSString*)remote
{
    dispatch_async(privateQueue, ^{
        LinphoneCall *call = [self getCallWithRemote:remote];
        if (call != NULL) {
            linphone_core_terminate_call(linphoneCore, call);
        }
    });
}

+ (void)inviteCall:(NSString*)remote
{
    dispatch_async(privateQueue, ^{
        LinphoneAddress *address = linphone_core_interpret_url(linphoneCore, [remote UTF8String]);
        if (address != NULL) {
            linphone_core_invite_address(linphoneCore, address);
        }
    });
}

+ (void)pauseCall:(NSString*)remote
{
    dispatch_async(privateQueue, ^{
        LinphoneCall *call = [self getCallWithRemote:remote];
        if (call != NULL) {
            linphone_core_pause_call(linphoneCore, call);
        }
    });
}

+ (void)resumeCall:(NSString*)remote
{
    dispatch_async(privateQueue, ^{
        LinphoneCall *call = [self getCallWithRemote:remote];
        if (call != NULL) {
            linphone_core_resume_call(linphoneCore, call);
        }
    });
}

+ (LinphoneCall*)getCallWithRemote:(NSString*)remote
{
    const bctbx_list_t *calls = linphone_core_get_calls(linphoneCore);
    while (calls != NULL)
    {
        LinphoneCall *call = (LinphoneCall*)calls->data;
        const LinphoneAddress* address = linphone_call_get_remote_address(call);
        const char* username = linphone_address_get_username(address);
        if([remote isEqualToString:[NSString stringWithUTF8String:username]]) {
            return call;
        }
        calls = calls->next;
    }
    return NULL;
}

+ (void)setLogLevel:(MCLogLevel)level
{
    dispatch_async(privateQueue, ^{
        linphone_core_set_log_level((OrtpLogLevel)level);
    });
}

+ (void)setRingTone:(NSString*)path
{
    dispatch_async(privateQueue, ^{
        linphone_core_set_ring(linphoneCore, [path UTF8String]);
    });
}

+ (void)setRingbackTone:(NSString*)path
{
    dispatch_async(privateQueue, ^{
        linphone_core_set_ringback(linphoneCore, [path UTF8String]);
    });
}

+ (void)setHoldTone:(NSString*)path
{
    dispatch_async(privateQueue, ^{
        linphone_core_set_play_file(linphoneCore, [path UTF8String]);
    });
}

+ (void)enableIPv6:(BOOL)enable
{
    dispatch_async(privateQueue, ^{
        linphone_core_enable_ipv6(linphoneCore, enable);
    });
}

+ (void)setRootCA:(NSString*)path
{
    dispatch_async(privateQueue, ^{
        linphone_core_set_root_ca(linphoneCore, [path UTF8String]);
    });
}

+ (void)printAudioCodecSequence
{
    dispatch_async(privateQueue, ^{
        NSLog(@"Print Audio Codecs Sequence:");
        for (const bctbx_list_t *elem=linphone_core_get_audio_codecs(linphoneCore); elem!=NULL; elem=elem->next)
        {
            PayloadType * pt=(PayloadType*)elem->data;
            NSLog(@"mime_type: %s | clock_rate: %d | payload_type_number: %d | desc: %s | enabled: %@",
                  pt->mime_type,
                  pt->clock_rate,
                  linphone_core_get_payload_type_number(linphoneCore, pt),
                  linphone_core_get_payload_type_description(linphoneCore, pt),
                  linphone_core_payload_type_enabled(linphoneCore, pt)?@"Yes":@"No");
        }
    });
}

+ (MCRegistrationState)sipRegistrationState
{
    __block LinphoneRegistrationState state = LinphoneRegistrationNone;
    dispatch_sync(privateQueue, ^{
        LinphoneProxyConfig* proxyCfg = linphone_core_get_default_proxy_config(linphoneCore);
        if (proxyCfg != NULL)
            state = linphone_proxy_config_get_state(proxyCfg);
    });
    return (MCRegistrationState)state;
}

+ (MCReason)sipRegistrationFailReason
{
    __block LinphoneReason reason = LinphoneReasonNone;
    dispatch_sync(privateQueue, ^{
        LinphoneProxyConfig* proxyCfg = linphone_core_get_default_proxy_config(linphoneCore);
        if (proxyCfg != NULL)
            reason = linphone_proxy_config_get_error(proxyCfg);
    });
    return (MCReason)reason;
}

static void mecall_log_handler(const char *domain, OrtpLogLevel lev, const char *fmt, va_list args)
{
    NSString *format = [[NSString alloc] initWithUTF8String:fmt];
    NSString *formatedString = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"%@", [formatedString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]);
}

static void mecall_registration_state_changed(LinphoneCore *lc, LinphoneProxyConfig *cfg, LinphoneRegistrationState state, const char *message)
{
    NSLog(@"mecall_registration_state_changed: %s (message: %s)", linphone_registration_state_to_string(state), message);
    LinphoneReason reason = linphone_proxy_config_get_error(cfg);
    NSDictionary *dict = @{kRegistrationState:[NSNumber numberWithInt:state],
                           kRegistrationFailReason:[NSNumber numberWithInt:reason]};
    [[NSNotificationCenter defaultCenter] postNotificationName:MCNotification_Registration object:nil userInfo:dict];
}

static void mecall_call_state_changed(LinphoneCore *lc, LinphoneCall *call, LinphoneCallState state, const char *message)
{
    NSLog(@"mecall_call_state_changed: %s (message: %s)", linphone_call_state_to_string(state), message);
    const LinphoneAddress *address = linphone_call_get_remote_address(call);
    const char* username = linphone_address_get_username(address);
    NSDictionary *dict = @{kCallState:[NSNumber numberWithInt:state],
                           kCallRemote:[NSString stringWithUTF8String:username]};
    [[NSNotificationCenter defaultCenter] postNotificationName:MCNotification_Call object:nil userInfo:dict];
}

static void mecall_global_state_changed(LinphoneCore *lc, LinphoneGlobalState gstate, const char *message) {
    NSLog(@"mecall_global_state_changed: %s (message: %s)", linphone_global_state_to_string(gstate), message);
}
static void mecall_auth_info_requested(LinphoneCore *lc, const char *realmC, const char *usernameC, const char *domainC) {
    NSLog(@"mecall_auth_info_requested");
}
static void mecall_configuring_status(LinphoneCore *lc, LinphoneConfiguringState status, const char *message) {
    NSLog(@"mecall_configuring_status: %s (message: %s)", linphone_configuring_state_to_string(status), message);
}
static void mecall_notify_received(LinphoneCore *lc, LinphoneEvent *lev, const char *notified_event, const LinphoneContent *body) {
    NSLog(@"mecall_notify_received: %s", notified_event);
}
static void mecall_call_encryption_changed(LinphoneCore *lc, LinphoneCall *call, bool_t on, const char *authentication_token) {
    NSLog(@"mecall_call_encryption_changed: %@", on?@"On":@"Off");
}

static LinphoneCoreVTable linphonec_vtable = {
    .global_state_changed = mecall_global_state_changed,
    .registration_state_changed = mecall_registration_state_changed,
    .call_state_changed = mecall_call_state_changed,
    .auth_info_requested = mecall_auth_info_requested,
    .configuring_status = mecall_configuring_status,
    .notify_received = mecall_notify_received,
    .call_encryption_changed = mecall_call_encryption_changed
};


@end

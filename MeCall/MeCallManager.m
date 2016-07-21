//
//  MeCallManager.m
//  MeCall
//
//  Created by u2systems on 13/07/2016.
//  Copyright © 2016 u2systems. All rights reserved.
//

#import "MeCallManager.h"
#import "linphonecore.h"

@implementation MeCallManager

NSString *const MCIncomingCallNotification = @"MCIncomingCallNotification";

static LinphoneCore* linphoneCore = nil;

extern void libmssilk_init(MSFactory *factory);
extern void libmsamr_init(MSFactory *factory);
extern void libmsx264_init(MSFactory *factory);
extern void libmsopenh264_init(MSFactory *factory);
extern void libmsbcg729_init(MSFactory *factory);
extern void libmswebrtc_init(MSFactory *factory);

struct codec_name_pref_table {
    const char *name;
    int rate;
    const char *prefname;
};
struct codec_name_pref_table codec_pref_table[] = {
    {"speex", 8000, "speex_8k_preference"},
    {"speex", 16000, "speex_16k_preference"},
    {"silk", 24000, "silk_24k_preference"},
    {"silk", 16000, "silk_16k_preference"},
    {"amr", 8000, "amr_preference"},
    {"gsm", 8000, "gsm_preference"},
    {"ilbc", 8000, "ilbc_preference"},
    {"isac", 16000, "isac_preference"},
    {"pcmu", 8000, "pcmu_preference"},
    {"pcma", 8000, "pcma_preference"},
    {"g722", 8000, "g722_preference"},
    {"g729", 8000, "g729_preference"},
    {"mp4v-es", 90000, "mp4v-es_preference"},
    {"h264", 90000, "h264_preference"},
    {"vp8", 90000, "vp8_preference"},
    {"mpeg4-generic", 16000, "aaceld_16k_preference"},
    {"mpeg4-generic", 22050, "aaceld_22k_preference"},
    {"mpeg4-generic", 32000, "aaceld_32k_preference"},
    {"mpeg4-generic", 44100, "aaceld_44k_preference"},
    {"mpeg4-generic", 48000, "aaceld_48k_preference"},
    {"opus", 48000, "opus_preference"},
    {NULL, 0, Nil}
};


static void mecall_global_state_changed(LinphoneCore *lc, LinphoneGlobalState gstate, const char *message)
{
    NSLog(@"mecall_global_state_changed: %s (message: %s)", linphone_global_state_to_string(gstate), message);
}

static void mecall_registration_state_changed(LinphoneCore *lc, LinphoneProxyConfig *cfg, LinphoneRegistrationState state, const char *message)
{
    NSLog(@"mecall_registration_state_changed: %s (message: %s)", linphone_registration_state_to_string(state), message);
}

static void mecall_call_state_changed(LinphoneCore *lc, LinphoneCall *call, LinphoneCallState state, const char *message)
{
    NSLog(@"mecall_call_state_changed: %s (message: %s)", linphone_call_state_to_string(state), message);
}

static void mecall_auth_info_requested(LinphoneCore *lc, const char *realmC, const char *usernameC, const char *domainC)
{
    NSLog(@"mecall_auth_info_requested");
}

static void mecall_configuring_status(LinphoneCore *lc, LinphoneConfiguringState status, const char *message)
{
    NSLog(@"mecall_configuring_status: %s (message: %s)", linphone_configuring_state_to_string(status), message);
}

static void mecall_notify_received(LinphoneCore *lc, LinphoneEvent *lev, const char *notified_event, const LinphoneContent *body)
{
    NSLog(@"mecall_notify_received: %s", notified_event);
}

static void mecall_call_encryption_changed(LinphoneCore *lc, LinphoneCall *call, bool_t on, const char *authentication_token)
{
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



+ (void)setup
{
    if (linphoneCore != nil) {
        return;
    }
    
    NSString *defaultConfig = [[NSBundle mainBundle] pathForResource:@"linphonerc" ofType:nil];
    NSString *factoryConfig = [[NSBundle mainBundle] pathForResource:@"linphonerc-factory" ofType:nil];
    linphoneCore = linphone_core_new(&linphonec_vtable, [defaultConfig UTF8String], [factoryConfig UTF8String], nil);
    
    MSFactory *f = linphone_core_get_ms_factory(linphoneCore);
    libmssilk_init(f);
    libmsamr_init(f);
    libmsx264_init(f);
    libmsopenh264_init(f);
    libmsbcg729_init(f);
    libmswebrtc_init(f);
    linphone_core_reload_ms_plugins(linphoneCore, NULL);
    
    
}


+ (void)setAudioCodecHighPriority:(const char*)type rate:(int)rate channels:(int)channels
{
    PayloadType *pt=linphone_core_find_payload_type(linphoneCore, type, rate, channels);
    const bctbx_list_t *list = linphone_core_get_audio_codecs(linphoneCore);
    bctbx_list_t *head = list->next->prev;
    bctbx_list_t *elem = bctbx_list_find(head, pt);
    
    if(elem && elem!=head)
    {
        if(elem->next)
            elem->next->prev = elem->prev;
        
        elem->prev->next = elem->next;
        elem->prev = NULL;
        elem->next = head;
        linphone_core_set_audio_codecs(linphoneCore, bctbx_list_copy(elem));
    }
}

+ (void)printAudioCodecSequence
{
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
}

+ (void)ResetAudioCodec
{
    [self setAudioCodecHighPriority:"g729" rate:8000 channels:-1];
    [self setAudioCodecHighPriority:"g722" rate:8000 channels:-1];
    
    int i=0;
    for (const bctbx_list_t *elem=linphone_core_get_audio_codecs(linphoneCore); elem!=NULL; elem=elem->next)
    {
        linphone_core_enable_payload_type(linphoneCore, elem->data, (i<2));
        i++;
    }
    
    [self printAudioCodecSequence];
}






@end

//
//  MeCallManager.h
//  MeCall
//
//  Created by u2systems on 13/07/2016.
//  Copyright © 2016 u2systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeCallManager : NSObject

extern NSString *const MCNotification_Registration;
extern NSString *const MCNotification_Call;

typedef enum _MCSipTransport {
    MCSipTransport_UDP,
    MCSipTransport_TCP,
    MCSipTransport_TLS,
    MCSipTransport_DTLS
} MCSipTransport;

typedef enum _MCMediaTransport {
    MCMediaTransport_RTP,
    MCMediaTransport_SRTP,
    MCMediaTransport_ZRTP,
    MCMediaTransport_DTLS
} MCMediaTransport;

typedef enum _MCRegistrationState {
    MCRegistrationNone,
    MCRegistrationProgress,
    MCRegistrationOk,
    MCRegistrationCleared,
    MCRegistrationFailed
} MCRegistrationState;

typedef enum _MCCallState{
    MCCallIdle,
    MCCallIncomingReceived,
    MCCallOutgoingInit,
    MCCallOutgoingProgress,
    MCCallOutgoingRinging,
    MCCallOutgoingEarlyMedia,
    MCCallConnected,
    MCCallStreamsRunning,
    MCCallPausing,
    MCCallPaused,
    MCCallResuming,
    MCCallRefered,
    MCCallError,
    MCCallEnd,
    MCCallPausedByRemote,
    MCCallUpdatedByRemote,
    MCCallIncomingEarlyMedia,
    MCCallUpdating,
    MCCallReleased,
    MCCallEarlyUpdatedByRemote,
    MCCallEarlyUpdating
} MCCallState;

typedef enum _MCReason{
    MCReasonNone,
    MCReasonNoResponse,
    MCReasonForbidden,
    MCReasonDeclined,
    MCReasonNotFound,
    MCReasonNotAnswered,
    MCReasonBusy,
    MCReasonUnsupportedContent,
    MCReasonIOError,
    MCReasonDoNotDisturb,
    MCReasonUnauthorized,
    MCReasonNotAcceptable,
    MCReasonNoMatch,
    MCReasonMovedPermanently,
    MCReasonGone,
    MCReasonTemporarilyUnavailable,
    MCReasonAddressIncomplete,
    MCReasonNotImplemented,
    MCReasonBadGateway,
    MCReasonServerTimeout,
    MCReasonUnknown
} MCReason;

+ (void)setupProxyConfig:(NSString*)sipUsername sipPassword:(NSString*)sipPassword sipServer:(NSString*)sipServer sipIdentity:(NSString*)sipIdentity;
+ (void)setupSipTransport:(MCSipTransport)sipTransport sipPort:(int)sipPort userAgentName:(NSString*)userAgentName userAgentVersion:(NSString*)userAgentVersion;
+ (void)setupMediaTransport:(MCMediaTransport)mediaTransport audioPort:(int)audioPort;
+ (void)setupAudioCodec:(NSArray*)audioCodecs;

+ (void)startRegistering:(int)expire;
+ (void)stopRegistering;
+ (MCRegistrationState)sipRegistrationState;
+ (MCReason)sipRegistrationFailReason;

+ (void)acceptCall:(NSString*)remote;
+ (void)declineCall:(NSString*)remote reason:(MCReason)reason;
+ (void)terminateCall:(NSString*)remote;
+ (void)inviteCall:(NSString*)remote;
+ (void)pauseCall:(NSString*)remote;
+ (void)resumeCall:(NSString*)remote;

+ (void)printAudioCodecSequence;

@end

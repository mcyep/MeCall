//
//  MeCallManager.h
//  MeCall
//
//  Created by u2systems on 13/07/2016.
//  Copyright © 2016 u2systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeCall : NSObject

extern NSString *const MCNotification_Registration;
extern NSString *const MCNotification_Call;
extern NSString *const kRegistrationState;
extern NSString *const kRegistrationFailReason;
extern NSString *const kCallState;
extern NSString *const kCallRemote;

typedef NS_ENUM(NSUInteger, MCLogLevel) {
    MCLogLevelDEBUG=1,
    MCLogLevelTRACE=1<<1,
    MCLogLevelMESSAGE=1<<2,
    MCLogLevelWARNING=1<<3,
    MCLogLevelERROR=1<<4,
    MCLogLevelFATAL=1<<5,
    MCLogLevelEND=1<<6
};

typedef NS_ENUM(NSUInteger, MCSipTransport) {
    MCSipTransportUDP,
    MCSipTransportTCP,
    MCSipTransportTLS,
    MCSipTransportDTLS
};

typedef NS_ENUM(NSUInteger, MCMediaTransport) {
    MCMediaTransportRTP,
    MCMediaTransportSRTP,
    MCMediaTransportZRTP,
    MCMediaTransportDTLS
};

typedef NS_ENUM(NSUInteger, MCRegistrationState) {
    MCRegistrationStateNone,
    MCRegistrationStateProgress,
    MCRegistrationStateOk,
    MCRegistrationStateCleared,
    MCRegistrationStateFailed
};

typedef NS_ENUM(NSUInteger, MCCallState) {
    MCCallStateIdle,
    MCCallStateIncomingReceived,
    MCCallStateOutgoingInit,
    MCCallStateOutgoingProgress,
    MCCallStateOutgoingRinging,
    MCCallStateOutgoingEarlyMedia,
    MCCallStateConnected,
    MCCallStateStreamsRunning,
    MCCallStatePausing,
    MCCallStatePaused,
    MCCallStateResuming,
    MCCallStateRefered,
    MCCallStateError,
    MCCallStateEnd,
    MCCallStatePausedByRemote,
    MCCallStateUpdatedByRemote,
    MCCallStateIncomingEarlyMedia,
    MCCallStateUpdating,
    MCCallStateReleased,
    MCCallStateEarlyUpdatedByRemote,
    MCCallStateEarlyUpdating
};

typedef NS_ENUM(NSUInteger, MCReason) {
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
};

+ (void)setupProxyConfig:(NSString*)sipUsername sipPassword:(NSString*)sipPassword sipServer:(NSString*)sipServer sipIdentity:(NSString*)sipIdentity;
+ (void)setupSipTransport:(MCSipTransport)sipTransport sipPort:(int)sipPort userAgentName:(NSString*)userAgentName userAgentVersion:(NSString*)userAgentVersion;
+ (void)setupMediaTransport:(MCMediaTransport)mediaTransport audioPort:(int)audioPort;
+ (void)setupAudioCodec:(NSArray*)audioCodecs;

+ (void)startRegistering:(int)expire;
+ (void)stopRegistering;

+ (void)acceptCall:(NSString*)remote;
+ (void)declineCall:(NSString*)remote reason:(MCReason)reason;
+ (void)terminateCall:(NSString*)remote;
+ (void)inviteCall:(NSString*)remote;
+ (void)pauseCall:(NSString*)remote;
+ (void)resumeCall:(NSString*)remote;

+ (void)setLogLevel:(MCLogLevel)level;
+ (void)setRingTone:(NSString*)path;
+ (void)setRingbackTone:(NSString*)path;
+ (void)setHoldTone:(NSString*)path;
+ (void)enableIPv6:(BOOL)enable;
+ (void)setRootCA:(NSString*)path;
+ (void)printAudioCodecSequence;

+ (MCRegistrationState)sipRegistrationState;
+ (MCReason)sipRegistrationFailReason;

@end

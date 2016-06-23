//
//  RCMessage.m
//  Bayun
//
//  Created by Preeti Gaur on 17/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "RCMessage.h"
#import "Message.h"
#import "User.h"
#import "Sender.h"
#import "Receiver.h"
#import <Bayun/BayunCore.h>


@interface RCMessage()

@property (strong, nonatomic) Message *message;
@property (strong, nonatomic) id media;
@property (assign) CGSize originalMediaSize;

@end

/**
 *
 */
@implementation RCMessage

-(id)initWithMessage:(Message *)message {
    self = [super init];
    if (self) {
        _message = message;
    }
    return self;
}

-(NSString *)text {
    NSString *peerExtension ;
    if ([self.message.direction isEqualToString:@"Outbound"]) {
        peerExtension = [[self.message.to lastObject] extension];
    } else {
        peerExtension = self.message.from.extension;
    }
    
    //Decrypt the message using Bayun library before returning it.
    __block NSString *decryptedTextMessage;
    [[BayunCore sharedInstance]decryptText:self.message.subject success:^(NSString *decryptedMessage) {
        if (decryptedMessage == nil || [decryptedMessage isEqualToString:@""]) {
            decryptedTextMessage = self.message.subject;
        } else {
            decryptedTextMessage = decryptedMessage;
        }
    } failure:^(BayunError errorCode) {
        //error code might be BayunErrorUserInActive (if user is not active or cancelled by admin),
        //BayunErrorDecryptionFailed (if decryption could not be done)
        //In the sample app,the message is being returned as is in case of decryption failure
        decryptedTextMessage = self.message.subject;
    }];

    return decryptedTextMessage;
}

-(NSString *)senderId {
    return  self.message.from.extension;
}

-(BOOL) isOutgoing {
    return [self.message.from.extension isEqualToString:[[RCUtilities appUser] extension]];
}

-(NSString *) senderDisplayName {
   return  self.message.from.name;
}

-(BOOL)showSender {
    return NO;
}

-(id)media {
    return nil;
}

-(NSDate *)date {
    return self.message.creationTime;
}

-(Message *)message {
    return _message;
}

- (NSUInteger)hash {
    NSUInteger contentHash;
    contentHash = self.text.hash;
    return self.senderId.hash ^ self.date.hash ^ contentHash;
}

-(BOOL) isMediaMessage {
    return NO;
}

@end

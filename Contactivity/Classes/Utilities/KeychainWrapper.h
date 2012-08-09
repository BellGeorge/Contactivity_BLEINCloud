//
//  KeychainWrapper.h
//  Contactivity
//
//  Created by Erik Solis on 6/26/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface KeychainWrapper : NSObject {
    NSString *inst;
    NSString *token;
    NSString *orgId;
    NSString *userId;
}

@property (nonatomic, retain) NSString *inst;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *orgId;
@property (nonatomic, retain) NSString *userId;

+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;
+ (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier;
+ (void)deleteKeychainValue:(NSString *)identifier;
+ (NSString *)searchKeychain:(NSString *)identifier;
+ (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;

@end

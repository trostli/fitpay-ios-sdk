//
//  OpenSSLHelper.h
//  SwiftLibWithC
//
//  Created by Igor Kravchenko on 5/6/16.
//  Copyright © 2016 Igor Kravchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct AESGCM_EncryptionResult {
    unsigned char * cipher_text;
    int cipher_text_size;
    
    unsigned char * auth_tag;
    int auth_tag_size;
} AESGCM_EncryptionResult;

typedef struct AESGCM_DecryptionResult {
    unsigned char * plain_text;
    int plain_text_size;
} AESGCM_DecryptionResult;

@interface OpenSSLHelper : NSObject

+ (instancetype)sharedInstance;

- (void)AES_GSM_encrypt:(unsigned char *)key
                keySize:(int)keySize
                     iv:(unsigned char *)iv
                 ivSize:(int)ivSize
                    aad:(unsigned char *)aad
                aadSize:(int)aadSize
              plainText:(unsigned char *)plainText
          plainTextSize:(int)plainTextSize
                 result:(AESGCM_EncryptionResult *)result;

- (void)AES_GSM_freeEncryptionResult:(AESGCM_EncryptionResult *)encryptionResult;

- (BOOL)AES_GSM_decrypt:(unsigned char *)key
                keySize:(int)keySize
                     iv:(unsigned char *)iv
                 ivSize:(int)ivSize
                    aad:(unsigned char *)aad
                aadSize:(int)aadSize
             cipherText:(unsigned char *)cipherText
         cipherTextSize:(int)cipherTextSize
                authTag:(unsigned char *)authTag
            authTagSize:(int)authTagSize
                 result:(AESGCM_DecryptionResult *)result;

- (void)AES_GSM_freeDecryptionResult:(AESGCM_DecryptionResult *)decryptionResult;

- (BOOL)simpleSHA1:(const void *)input length:(unsigned long)length output:(char *)output;

- (NSInteger)shaDigestLength;

@end

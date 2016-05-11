
#import <Foundation/Foundation.h>

@interface SECP256R1KeyPairContainer : NSObject

@property (nonatomic, readonly) NSString * publicKey;
@property (nonatomic, readonly) NSString * privateKey;


- (NSData *)generateSecretForPublicKey:(NSString *)publicKey;

@end

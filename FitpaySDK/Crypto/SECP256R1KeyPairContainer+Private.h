//
//  SECP256R1KeyPairContainer+Private.h
//  SwiftLibWithC
//
//  Created by Igor Kravchenko on 5/6/16.
//  Copyright © 2016 Igor Kravchenko. All rights reserved.
//

#include <openssl/ec.h>
#import "SECP256R1KeyPairContainer.h"

struct SECP256R1_KeyPair
{
    char public_key[1024];
    char private_key[1024];
    EC_KEY * key;
};

typedef struct SECP256R1_KeyPair SECP256R1_KeyPair;

@interface SECP256R1KeyPairContainer()

@property (nonatomic, readonly) SECP256R1_KeyPair keyPair;

@end

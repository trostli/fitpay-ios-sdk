//
//  SHA1.h
//  FitpaySDK
//
//  Created by admin on 11.03.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

#ifndef SHA1_h
#define SHA1_h

#include <string.h>
#include <openssl/sha.h>



static bool simpleSHA1(const void* input, unsigned long length, char* output)
{
    unsigned char md[SHA_DIGEST_LENGTH];
    
    SHA_CTX context;
    if (!SHA1_Init(&context))
        return false;
    
    if (!SHA1_Update(&context, (unsigned char*)input, length))
        return false;
    
    if (!SHA1_Final(md, &context))
        return false;
    
    for (int i = 0; i < SHA_DIGEST_LENGTH; i++)
        sprintf(&output[i*2], "%02x", (unsigned int)md[i]);
    
    return true;
}

#endif /* SHA1_h */

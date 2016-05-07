
#import <Foundation/Foundation.h>

#include <openssl/ec.h>
#include <openssl/evp.h>
#include <openssl/bn.h>
#include <openssl/obj_mac.h>
#include <string.h>

// structure holds public/private keys and EC_KEY key to be used by other functions
// Note: EC_KEY key must be freed manually using EC_KEY_free()
struct SECP256R1_KeyPair
{
    char public_key[1024];
    char private_key[1024];
    EC_KEY * key;
};

typedef struct SECP256R1_KeyPair SECP256R1_KeyPair;

static void SECP256R1_GenerateKeyPair(SECP256R1_KeyPair *key_pair)
{
    static char ans1PubKeyEncoding[] = "3059301306072a8648ce3d020106082a8648ce3d03010703420004\0";
    
    BN_CTX * bn_ctx;
    BIGNUM* client_publicK_x = NULL;
    BIGNUM* client_publicK_y = NULL;

    bn_ctx = BN_CTX_new();
    BN_CTX_start(bn_ctx);

    client_publicK_x = BN_CTX_get(bn_ctx);
    client_publicK_y = BN_CTX_get(bn_ctx);

    EC_KEY *  client_key_curve = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);

    if (client_key_curve  == NULL)
    {
        BN_CTX_free(bn_ctx);
        return;
    }

    const EC_GROUP * client_key_group = EC_KEY_get0_group(client_key_curve);

    if (client_key_group == NULL)
    {
        BN_CTX_free(bn_ctx);
        EC_KEY_free(client_key_curve);
        return;
    }

    if (EC_KEY_generate_key(client_key_curve) != 1)
    {
        BN_CTX_free(bn_ctx);
        EC_KEY_free(client_key_curve);
        return;
    }

    const EC_POINT * client_publicKey = EC_KEY_get0_public_key(client_key_curve);

    if (client_publicKey == NULL)
    {
        BN_CTX_free(bn_ctx);
        EC_KEY_free(client_key_curve);
        return;
    }

    if (EC_KEY_check_key(client_key_curve) != 1)
    {
        BN_CTX_free(bn_ctx);
        EC_KEY_free(client_key_curve);
        return;
    }

    const BIGNUM * client_privateKey = EC_KEY_get0_private_key(client_key_curve);
    char * client_public_key = NULL;

    char * client_private_key = BN_bn2hex(client_privateKey);
    BIGNUM *bigNumX = BN_CTX_get(bn_ctx);
    BIGNUM *bigNumY = BN_CTX_get(bn_ctx);

    if (EC_POINT_get_affine_coordinates_GFp(client_key_group, client_publicKey, bigNumX, bigNumY, NULL))
    {

        char * strX = BN_bn2hex(bigNumX);
        char * strY = BN_bn2hex(bigNumY);

        if ((client_public_key = malloc(strlen(ans1PubKeyEncoding) + strlen(strX) + strlen(strY) + 1)) != NULL)
        {
            client_public_key[0] = '\0';
            strcat(client_public_key, ans1PubKeyEncoding);
            strcat(client_public_key, strX);
            strcat(client_public_key, strY);
        }

        free(strX);
        free(strY);
    }

    key_pair->key = EC_KEY_new();
    EC_KEY_copy(key_pair->key, client_key_curve);

    memcpy(key_pair->public_key, client_public_key, strlen(client_public_key) + 1);
    memcpy(key_pair->private_key, client_private_key, strlen(client_private_key) + 1);

    // cleanup
    free(client_public_key);
    free(client_private_key);
    EC_POINT_free((EC_POINT *)client_publicKey);
    EC_GROUP_free((EC_GROUP *)client_key_group);

    BN_free(client_publicK_x);
    BN_free(client_publicK_y);
    BN_free((BIGNUM *)client_privateKey);
    BN_CTX_free(bn_ctx);
}

struct SECP256R1_SharedSecret {
    unsigned char secret[256];
    int secret_size;
};

typedef struct SECP256R1_SharedSecret SECP256R1_SharedSecret;

 static void secp256r1_generate_secret(SECP256R1_KeyPair * key_pair, char * public_key, SECP256R1_SharedSecret * secret)
{
    static char ans1PubKeyEncoding[] = "3059301306072a8648ce3d020106082a8648ce3d03010703420004\0";
    
    unsigned long keySize = strlen(public_key);
    unsigned long ans1Size = strlen(ans1PubKeyEncoding);
    unsigned long bigNumSize = (keySize - ans1Size) / 2;
    
    char * xHex = malloc((bigNumSize + 1) * sizeof(char));
    memcpy(xHex, public_key+ans1Size, bigNumSize);
    xHex[bigNumSize] = '\0';
    
    char * yHex = malloc((bigNumSize + 1) * sizeof(char));
    memcpy(yHex, public_key + ans1Size + bigNumSize, bigNumSize);
    yHex[bigNumSize] = '\0';
    
    BN_CTX* bn_ctx;
    
    EC_KEY*   server_key_curve = NULL;
    EC_GROUP* server_key_group = NULL;
    EC_POINT* server_publicKey = NULL;
    
    BIGNUM* server_publicK_x = NULL;
    BIGNUM* server_publicK_y = NULL;
    
    bn_ctx = BN_CTX_new();
    BN_CTX_start(bn_ctx);
    
    server_publicK_x = BN_CTX_get(bn_ctx);
    server_publicK_y = BN_CTX_get(bn_ctx);
    
    BN_hex2bn(&server_publicK_x, xHex);
    BN_hex2bn(&server_publicK_y, yHex);
    
    free(xHex);
    free(yHex);
    
    if ((server_key_curve = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1)) == NULL)
    {
        BN_CTX_free(bn_ctx);
        return;
    }
    
    if ((server_key_group = (EC_GROUP *)EC_KEY_get0_group(server_key_curve)) == NULL)
    {
        BN_CTX_free(bn_ctx);
        EC_KEY_free(server_key_curve);
        return;
    }
    
    if (EC_KEY_generate_key(server_key_curve) != 1)
    {
        BN_CTX_free(bn_ctx);
        EC_KEY_free(server_key_curve);
        return;
    }
    
    if ((server_publicKey = EC_POINT_new(server_key_group)) == NULL)
    {
        BN_CTX_free(bn_ctx);
        EC_KEY_free(server_key_curve);
        return;
    }
    
    if (EC_POINT_set_affine_coordinates_GFp(server_key_group, server_publicKey, server_publicK_x, server_publicK_y, bn_ctx) != 1)
    {
        EC_POINT_free(server_publicKey);
        BN_CTX_free(bn_ctx);
        EC_KEY_free(server_key_curve);
        return;
    }
    
    if (EC_KEY_check_key(server_key_curve) != 1)
    {
        EC_POINT_free(server_publicKey);
        BN_CTX_free(bn_ctx);
        EC_KEY_free(server_key_curve);
        return;
    }
    
    int field_size = EC_GROUP_get_degree(server_key_group);
    size_t len = (field_size + 7) / 8;
    unsigned char *key_agreement = NULL;
    key_agreement = (unsigned char *)OPENSSL_malloc(len);
    
    if (ECDH_compute_key(key_agreement, len, server_publicKey, key_pair->key, 0) == 0)
    {
        EC_POINT_free(server_publicKey);
        BN_CTX_free(bn_ctx);
        EC_KEY_free(server_key_curve);
        free(key_agreement);
        return;
    }
    
    memcpy(secret->secret, key_agreement, len);
    secret->secret_size = (int)len;
    
    EC_POINT_free(server_publicKey);
    EC_KEY_free(server_key_curve);
    BN_CTX_free(bn_ctx);
    
    free(key_agreement);
}

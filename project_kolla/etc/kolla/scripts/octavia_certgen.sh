#!/bin/bash
#* ca_01.pem is a certificate authority file
#* server.pem combines a key and a cert from this certificate authority
#* client.key the client key
#* client.pem the client certificate
## Create CA
# Create directories
CERT_DIR=$1
OPEN_SSL_CONF=$2
VALIDITY_DAYS=${3:-18250}
echo "Certifcate directory: $CERT_DIR"
mkdir -p $CERT_DIR
cd $CERT_DIR
mkdir newcerts private
chmod 700 private
# prepare files
touch index.txt
echo 02 > serial
echo "Create the CA's private and public keypair (2k long)"
openssl genrsa -passout pass:4fT1WRVZ9fkI2P7nGX7C6DgUWYhyVBNidSAPrhoq -des3 -out private/cakey.pem 2048
echo "You will be asked to enter some information about the certificate."
openssl req -x509 -passin pass:4fT1WRVZ9fkI2P7nGX7C6DgUWYhyVBNidSAPrhoq -new -nodes -key private/cakey.pem \
        -config $OPEN_SSL_CONF \
        -subj "/C=AU/ST=Sydney/L=Sydney/O=GGOpenstack/CN=osp.home.gatwards.org" \
        -days $VALIDITY_DAYS \
        -out ca_01.pem
echo "Here is the certificate"
openssl x509 -in ca_01.pem -text -noout
## Create Server/Client CSR
echo "Generate a server key and a CSR"
openssl req \
       -newkey rsa:2048 -nodes -keyout client.key \
       -subj "/C=AU/ST=Sydney/L=Sydney/O=GGOpenstack/CN=osp.home.gatwards.org" \
       -out client.csr
echo "Sign request"
openssl ca -passin pass:4fT1WRVZ9fkI2P7nGX7C6DgUWYhyVBNidSAPrhoq -config $OPEN_SSL_CONF -in client.csr \
           -days $VALIDITY_DAYS -out client-.pem -batch
echo "Generate single pem client.pem"
cat client-.pem client.key > client.pem

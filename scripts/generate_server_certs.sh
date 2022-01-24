#!/bin/bash

ARGS=()

SERVER_DIR="~/"
CA_KEY="~/ca.key"
CA_CERT="~/ca.crt"
SUBJECT="/CN=metavac.ac/OU=Infra/O=Server"
EXPIRY=365

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            SERVER_DIR=$2
            shift
            shift
        ;;
        -s|--subject)
            SUBJECT=$2
            shift
            shift
        ;;
        -e|--expiry)
            EXPIRY=$2
            shift
            shift
        ;;
        -k|--ca-key)
            CA_KEY=$2
            shift
            shift
        ;;
        -c|--ca-cert)
            CA_CERT=$2
            shift
            shift
        ;;
        *)
            ARGS+=("$1")
            shift
        ;;
    esac
done

function check_errors () {
    local exit=$?
    [[ $exit != 0 ]] && echo $1 && exit $exit
}

openssl version > /dev/null
check_errors "Error with OpenSSL installation, please ensure it is correctly installed."

if [[ ! -d $SERVER_DIR ]]; then
    echo "Error with Output Directory: Path $SERVER_DIR does not exist."
    exit 1
fi

if [[ ! -f $CA_KEY ]]; then
    echo "Error with CA Key: Path $CA_KEY does not exist."
    exit 1
fi

if [[ ! -f $CA_CERT ]]; then
    echo "Error with CA Cert: Path $CA_CERT does not exist."
    exit 1
fi

echo "Generating Server keys/certificates for metavac infrastructure deployment..."

openssl genrsa -out $SERVER_DIR/server.key 2048
check_errors
openssl req -new -nodes -key $SERVER_DIR/server.key -subj $SUBJECT -out $SERVER_DIR/server.csr
check_errors

echo "Signing CSR at $SERVER_DIR/server.csr with CA '$CA_CERT' '$CA_KEY'"
openssl x509 -req -in $SERVER_DIR/server.csr -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $SERVER_DIR/server.crt -days $EXPIRY
check_errors

echo "Generated Server certificates at $SERVER_DIR/server.key and $SERVER_DIR/server.crt"

exit 0
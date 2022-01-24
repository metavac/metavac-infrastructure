#!/bin/bash

ARGS=()

CA_DIR="~/"
SUBJECT="/CN=metavac.ac/OU=Infra/O=Metavac"
EXPIRY=365

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            CA_DIR=$2
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

[[ -d $CA_DIR ]]
check_errors "Path $CA_DIR is not a valid directory."

if [[ ${CA_DIR: -1} == "/" ]]; then
    $CA_DIR=${CA_DIR:: -1}
fi

echo "Generating CA certificates for metavac infrastructure deployment..."
echo "Using directory '${CA_DIR}'"

openssl genrsa -out $CA_DIR/ca.key 2048
check_errors
openssl req -x509 -new -nodes -key $CA_DIR/ca.key -subj $SUBJECT -days $EXPIRY -out $CA_DIR/ca.crt
check_errors

echo "Generated CA certificates at $CA_DIR/ca.key and $CA_DIR/ca.crt"

exit 0
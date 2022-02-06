#!/bin/bash

OUTPUT_DIR="../charts/metavac_db/certs"
DOMAIN="db.dev.metavac.ac"
CA_KEY="/home/sophie/ca.key"
CA_CERT="/home/sophie/ca.crt"
EXPIRY=365

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            OUTPUT_DIR=$2
            shift
            shift
        ;;
        -s|--domain)
            DOMAIN=$2
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
        -e|--expiry)
            EXPIRY=$2
            shift
            shift
        ;;
    esac
done

function check_errors () {
    local exit=$?
    [[ $exit != 0 ]] && echo $1 && exit $exit
}

echo "Generating keys/certificates for metavac_db mongo chart deployment..."

[[ -d $OUTPUT_DIR ]] && echo "Using output directory ${OUTPUT_DIR}" || mkdir -p $OUTPUT_DIR

./keygen/generate_server_certs.sh --dir $OUTPUT_DIR --subject "/CN=configsvr.${DOMAIN}/OU=Database/O=Metavac" --expiry $EXPIRY --ca-key $CA_KEY --ca-cert $CA_CERT
mv $OUTPUT_DIR/server.key $OUTPUT_DIR/configsvr.key
mv $OUTPUT_DIR/server.crt $OUTPUT_DIR/configsvr.crt
check_errors
./keygen/generate_server_certs.sh --dir $OUTPUT_DIR --subject "/CN=mongos.${DOMAIN}/OU=Database/O=Metavac" --expiry $EXPIRY --ca-key $CA_KEY --ca-cert $CA_CERT
mv $OUTPUT_DIR/server.key $OUTPUT_DIR/mongos.key
mv $OUTPUT_DIR/server.crt $OUTPUT_DIR/mongos.crt
check_errors
./keygen/generate_server_certs.sh --dir $OUTPUT_DIR --subject "/CN=shardsvr.${DOMAIN}/OU=Database/O=Metavac" --expiry $EXPIRY --ca-key $CA_KEY --ca-cert $CA_CERT
mv $OUTPUT_DIR/server.key $OUTPUT_DIR/shardsvr.key
mv $OUTPUT_DIR/server.crt $OUTPUT_DIR/shardsvr.crt
check_errors

rm $OUTPUT_DIR/server.csr
check_errors
cp $CA_CERT $OUTPUT_DIR
check_errors

echo "Generated certificates for Mongo deployment:"
ls $OUTPUT_DIR

exit 0
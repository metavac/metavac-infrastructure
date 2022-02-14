#!/bin/bash

OUTPUT_DIR="../charts/metavac_db/certs"
DOMAIN="db.dev.metavac.ac"
CA_KEY="/home/sophie/ca.key"
CA_CERT="/home/sophie/ca.crt"
EXPIRY=365

CONFIGSVR_COUNT=1
SHARDSVR_COUNT=1
MONGOS_COUNT=1

function cleanup () {
    local exit=$?
    [[ -d $OUTPUT_DIR ]] || exit $exit

    echo "Cleaning up output directory..."
    find $OUTPUT_DIR -name "*.crt" -o -name "*.key" -o -name "*.pem" | xargs rm
}

function check_errors () {
    local exit=$?
    [[ $exit != 0 ]] && echo $1 && cleanup && exit $exit
}

function validate_number () {
    [[ $2 =~ ^[0-9]+$ ]]
    check_errors "Error in arg ${1}: ${2} is not a valid number!"
}

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
            validate_number $1 $2
            EXPIRY=$2
            shift
            shift
        ;;
        --configsvr-count)
            validate_number $1 $2
            CONFIGSVR_COUNT=$2
            shift
            shift
        ;;
        --shardsvr-count)
            validate_number $1 $2
            SHARDSVR_COUNT=$2
            shift
            shift
        ;;
        --mongos-count)
            validate_number $1 $2
            MONGOS_COUNT=$2
            shift
            shift
        ;;
    esac
done

echo "Generating keys/certificates for metavac_db mongo chart deployment..."

[[ -d $OUTPUT_DIR ]] && echo "Using output directory ${OUTPUT_DIR}" || mkdir -p $OUTPUT_DIR
check_errors

cleanup

metavac_dev_ips=$(nslookup dev.metavac.ac | awk '/[[:alnum:]]+(\.|:+)[[:alnum:]]+(\.|:+)/ {print $2}' | tail +3)
sn_suffix="OU=Database/O=Metavac/DC=dev/DC=metavac/DC=ac"

./keygen/generate_server_certs.sh --dir $OUTPUT_DIR --subject "/CN=*.${DOMAIN}/${sn_suffix}" --expiry $EXPIRY --ca-key $CA_KEY --ca-cert $CA_CERT
check_errors

# Generate Database CA Key/Cert
mv $OUTPUT_DIR/server.crt $OUTPUT_DIR/ca.crt
mv $OUTPUT_DIR/server.key $OUTPUT_DIR/ca.key
check_errors

for i in $(seq 0 $CONFIGSVR_COUNT);
do
    ./keygen/generate_server_certs.sh --dir $OUTPUT_DIR --subject "/CN=configsvr-${i}.${DOMAIN}/${sn_suffix}" --expiry $EXPIRY --ca-key $OUTPUT_DIR/ca.key --ca-cert $OUTPUT_DIR/ca.crt
    cat $OUTPUT_DIR/server.key $OUTPUT_DIR/server.crt > $OUTPUT_DIR/configsvr-${i}.pem
    check_errors
done

for j in $(seq 0 $MONGOS_COUNT);
do
    ./keygen/generate_server_certs.sh --dir $OUTPUT_DIR --subject "/CN=mongos-${j}.${DOMAIN}/${sn_suffix}" --expiry $EXPIRY --ca-key $OUTPUT_DIR/ca.key --ca-cert $OUTPUT_DIR/ca.crt
    cat $OUTPUT_DIR/server.key $OUTPUT_DIR/server.crt > $OUTPUT_DIR/mongos-${j}.pem
    check_errors
done

for k in $(seq 0 $SHARDSVR_COUNT);
do
    ./keygen/generate_server_certs.sh --dir $OUTPUT_DIR --subject "/CN=shardsvr-${k}-data-0.${DOMAIN}/${sn_suffix}" --expiry $EXPIRY --ca-key $OUTPUT_DIR/ca.key --ca-cert $OUTPUT_DIR/ca.crt
    cat $OUTPUT_DIR/server.key $OUTPUT_DIR/server.crt > $OUTPUT_DIR/shardsvr-${k}-data-0.pem
    check_errors
done

rm $OUTPUT_DIR/server.csr $OUTPUT_DIR/server.key $OUTPUT_DIR/server.crt $OUTPUT_DIR/ca.srl
check_errors

echo "Generated certificates for Mongo deployment:"
ls $OUTPUT_DIR

exit 0
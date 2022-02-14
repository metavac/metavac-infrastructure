{{- define "metavac-common.webhook.ca.python.code" -}}
import json
import argparse
import cryptography
import logging
import logging.config
import enum
import traceback

from jsonpatch import JsonPatch
from copy import copy, deepcopy
from base64 import b64encode
from http import HTTPStatus
from pathlib import Path

from flask import Flask, jsonify, request, Response

APP_NAME='ca_webhook'

class ExitCodes(enum.IntEnum):
    SUCCESS = 0
    INVALID_TLS_CERT_PATH = 1
    INVALID_TLS_KEY_PATH = 2
    FLASK_FAILURE = 3

log_config = {
    'version': 1,
    'formatters': {
        'default': {
            'format': '[%(asctime)s] %(name)s: %(levelname)s - %(message)s'
        }
    },
    'filters': {},
    'handlers': {
        'error_handler': {
            'class': 'logging.StreamHandler',
            'level': 'ERROR',
            'formatter': 'default',
            'stream': 'ext://sys.stderr'
        },
        'debug_handler': {
            'class': 'logging.StreamHandler',
            'level': 'DEBUG',
            'formatter': 'default',
            'stream': 'ext://sys.stdout'
        }
    },
    'loggers': {
        APP_NAME: {
            'level': 'ERROR',
            'handlers': ['debug_handler', 'error_handler']
        }
    }
}


log = logging.getLogger(APP_NAME)
app = Flask(__name__)

#def generate_validate_reponse(uid: str, allowed: bool, response_code: HTTPStatus, message: str):
#    return jsonify(
#        {
#            "response": {
#                "allowed": allowed,
#                "uid": uid,
#                "status": {
#                    "code": response_code.value,
#                    "message": message
#                }
#            }
#        }
#    )


#@app.route("/validate", methods=["POST"])
#def validate():
#    kube_object = request.json["request"]["object"]
#    uid = request.json["request"]["uid"]

#    if not kube_object:
#        return generate_validate_reponse(uid, False, HTTPStatus.FORBIDDEN, "Invalid object request, no Kubernetes object provided")
#
#    return generate_validate_reponse(uid, True, HTTPStatus.OK, "")

def generate_mutate_reponse(uid: str, allowed: bool, response_code: HTTPStatus, message: str = "", patch: JsonPatch = None):
    response = {
        "apiVersion": "admission.k8s.io/v1",
        "kind": "AdmissionReview",
        "response": {
            "allowed": allowed,
            "uid": uid,
            "status": {
                "code": response_code.value,
                "message": message
            }
        }
    }

    if patch:
        response['response']['patchType'] = 'JSONPatch'
        response['response']['patch'] = b64encode(patch.to_string().encode()).decode()

    return jsonify(response), response_code.value


@app.route("/mutate", methods=["POST"])
def mutate():
    if not request.json or 'request' not in request.json:
        return generate_mutate_reponse("0", False, HTTPStatus.BAD_REQUEST, "Not a valid Kubernetes API request")
    
    kube_request = request.json["request"]
    uid = kube_request["uid"]

    log.debug(f"Received request from Kubernetes API Server:\n{json.dumps(kube_request, indent=4)}")

    if not kube_request["kind"]["kind"] == "Pod":
        return generate_mutate_reponse(uid, False, HTTPStatus.UNPROCESSABLE_ENTITY, f"Unable to process entity kind {kube_request['kind']['kind']}")
    
    if not kube_request["operation"] == "CREATE":
        return generate_mutate_reponse(uid, False, HTTPStatus.UNPROCESSABLE_ENTITY, f"Unable to process Kubernetes request type {kube_request['operation']}")
    
    log.debug(kube_request)

    spec = kube_request["object"]
    modified_spec = deepcopy(spec)

    patch = JsonPatch.from_diff(spec, modified_spec)

    return generate_mutate_reponse(uid, True, HTTPStatus.OK, "", patch)


@app.route("/health", methods=["GET"])
def health():
    return ("", HTTPStatus.NO_CONTENT)


@app.route("/status", methods=["GET"])
def status():
    return ("", HTTPStatus.NO_CONTENT)


def main():
    parser = argparse.ArgumentParser(description='Webhook for signing and injecting new certificates into Kubernetes pods.')

    parser.add_argument('-i', '--interface', type=str, default='0.0.0.0', help='The interface to bind the webserver to, default 0.0.0.0')
    parser.add_argument('-p', '--port', type=int, default=443, help='The port to serve the webserver on, default 443')
    parser.add_argument('-c', '--tls-cert', type=Path, default=Path('/tls/ca.crt'), help='Path to the TLS Cert file to use, default /tls/ca.crt')
    parser.add_argument('-k', '--tls-key', type=Path, default=Path('/tls/ca.key'), help='Path to the TLS Key file to use, default /tls/ca.key')
    parser.add_argument('-d', '--debug', action='store_true', help='Turn on debug logs for the webserver')

    args = parser.parse_args()

    log_config['loggers'][APP_NAME]['level'] = "DEBUG" if args.debug else "ERROR"
    logging.config.dictConfig(log_config)
    log = logging.getLogger(APP_NAME)

    if not args.tls_cert.exists():
        log.error(f"Invalid TLS Cert path specified: {args.tls_cert}")
        exit(ExitCodes.INVALID_TLS_CERT_PATH)
    if not args.tls_key.exists():
        log.error(f"Invalid TLS Key path specified: {args.tls_key}")
        exit(ExitCodes.INVALID_TLS_KEY_PATH)
    
    tls_context = (args.tls_cert, args.tls_key)

    log.debug(f"Deploying with TLS Context {tls_context}")
    
    try:
        # TODO: validate IP, Port range
        app.run(host=args.interface, port=args.port, debug=args.debug, ssl_context=tls_context)
    except Exception as e:
        log.error(traceback.format_exc())
        exit(ExitCodes.FLASK_FAILURE)

    exit(ExitCodes.SUCCESS)

if __name__ == "__main__":
    main()
{{- end -}}
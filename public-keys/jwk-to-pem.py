# This script converts JWK (JSON Web Key) to PEM (Privacy Enhanced Mail) format.

import base64
import json
import sys

from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa


def convert(jwk):
    n = int.from_bytes(base64.urlsafe_b64decode(jwk["n"] + "==="), "big")
    e = int.from_bytes(base64.urlsafe_b64decode(jwk["e"] + "==="), "big")
    key = rsa.RSAPublicNumbers(e, n).public_key(default_backend())

    pem = key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo,
    )

    return pem.decode()


if __name__ == "__main__":
    try:
        raw = json.load(sys.stdin)
        data = json.loads(raw.get("data", {}))
        jwks = data.get("keys", [])
    except json.JSONDecodeError:
        print("Invalid JSON input")
        sys.exit(1)

    pems = [convert(jwk) for jwk in jwks]

    output = {"pem": json.dumps(pems)}
    output = json.dumps(output)

    print(output)
    sys.stdout.flush()
    sys.exit(0)

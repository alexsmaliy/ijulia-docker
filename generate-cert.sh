#! /usr/bin/env bash

set -o errexit

pushd "$(dirname "$0")" 1> /dev/null || return

mkdir -p security/cert

CA_PWD_FILE="security/ca_pwd"

CA_KEY_FILE="security/local-ca.key"
CA_CERT_FILE="security/local-ca.pem"

KEY_FILE="security/cert/localhost.key"
CERT_FILE="security/cert/localhost.crt"

CSR_FILE="security/localhost.csr"
CNF_FILE="security/req.cnf"

function cleanup() {
  # with -f does not fail even if the file does not exist
  rm -f "$CA_PWD_FILE" "$CERT_PWD_FILE" "$CSR_FILE" "$CNF_FILE"
  popd 1> /dev/null
}

trap cleanup EXIT

if [ ! -f "$CA_KEY_FILE" ] || [ ! -f "$CA_CERT_FILE" ]; then
  cat 1>&2 -e <<EOF
  Type in a pass phrase for the root CA private key and press ENTER.\n
  Take note of the pass phrase, as you will not be able to reuse the CA key without it!
EOF
  read -r CA_PWD
  echo "$CA_PWD" > "$CA_PWD_FILE"

  # Private key for root CA.
  openssl genrsa \
    -aes256 \
    -out "$CA_KEY_FILE" \
    -passout file:"$CA_PWD_FILE" \
    2048

  # Make root cert.
  openssl req \
    -x509 \
    -new \
    -nodes \
    -key "$CA_KEY_FILE" \
    -sha256 \
    -days $((365*5)) \
    -out "$CA_CERT_FILE" \
    -subj "/CN=localhost/C=US/ST=CA" \
    -passin file:"$CA_PWD_FILE"
fi

# Private key for cert. Unencrypted private key without a pass phrase,
# because I can't figure out how to set the pass phrase in Jupyter. It
# comes with configurable-http-proxy@1.3.0, and setting CONFIGPROXY_SSL_KEY_PASSPHRASE
# did not arrive until 4.0.0. I have no idea how configurable-http-proxy
# shows up in the notebook image, and upgrading it globally via npm does
# not work. WTF?!?
openssl genrsa \
  -out "$KEY_FILE" \
  2048
#  -aes256 \
#  -passout file:cert_pwd \

# Make CSR.
openssl req \
  -new \
  -nodes \
  -key "$KEY_FILE" \
  -out "$CSR_FILE" \
  -subj "/CN=localhost/C=US/ST=CA" 
#  -passin file:cert_pwd # no pwd, because signing key is unencrypted...

cat << EOF > "$CNF_FILE"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = US
ST = CA
CN = localhost
[v3_req]
keyUsage = critical, digitalSignature, keyAgreement, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:localhost,IP:127.0.0.1,IP:0.0.0.0
EOF

# Create signed cert.
COMMAND=(
  "openssl"
  "x509"
  "-req"
  "-extfile"
  "$CNF_FILE"
  "-in"
  "$CSR_FILE"
  "-CA"
  "$CA_CERT_FILE"
  "-CAkey"
  "$CA_KEY_FILE"
  $([ -f local-ca.srl ] && echo "-CAserial local-ca.srl" || echo "-CAcreateserial")
  "-out"
  "$CERT_FILE"
  "-days"
  "$((365*5))"
  "-sha256"
)

"${COMMAND[@]}"

#!/bin/bash
tmpdir=cert
mkdir -p $tmpdir

ATT=$tmpdir/atte.DER
ROOT=$tmpdir/root.DER
tmp_att_file=$tmpdir/e.ext

echo "authorityKeyIdentifier=keyid,issuer" > $tmp_att_file
echo "basicConstraints=CA:FALSE,pathlen:0" >> $tmp_att_file
echo "keyUsage=digitalSignature" >> $tmp_att_file


issuer="/C=US/ST=California/CN=Generated Test Attestation CA/O=SecTools/L=San Diego"
subj="/C=US/CN=SecTools Test User/L=San Diego/O=SecTools/ST=California/OU=01 000000000000000A SW_ID/OU=02 0000000000000000 HW_ID/OU=04 0000 OEM_ID/OU=05 000000A8 SW_SIZE/OU=06 0000 MODEL_ID/OU=07 0001 SHA256/OU=03 0000000000000002 DEBUG"

# gen root cert
openssl req -new -x509 -keyout $tmpdir/root_key.PEM -nodes -newkey rsa:2048 -days 7300 -set_serial 1 -sha256 -subj "$issuer" -out $tmpdir/root_certificate.PEM

# gen att cert 
openssl genpkey -algorithm RSA -outform PEM -pkeyopt rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:3 -out $tmpdir/atte_key.PEM  2>/dev/null
openssl req -new -key $tmpdir/atte_key.PEM -subj "$subj" -days 7300 -out $tmpdir/atte_csr.PEM
openssl x509 -req -in $tmpdir/atte_csr.PEM -CAkey $tmpdir/root_key.PEM -CA $tmpdir/root_certificate.PEM -days 7300 -set_serial 1 -extfile $tmp_att_file -sha256 -out $tmpdir/atte_cert.PEM -extfile mycrl.cnf

# get public keys
openssl x509 -in $tmpdir/root_certificate.PEM -inform PEM -outform DER -out $ROOT
openssl x509 -in $tmpdir/atte_cert.PEM -inform PEM -outform DER -out $ATT

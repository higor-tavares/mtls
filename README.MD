
# How to use mTLS with AWS Api Gateway and terraform
## What is mTLS?
mTLS or mutual TLS is an tecnique, that provides secure comunication between two peers where the server and the client
can use tls handshake to validate the identiti of each one, is verry userfull in machine to machine integration 
## Before start
You need an AWS Account, and AWS cli and terraform instaled on your machine
## Configure Root Certificate Authority
First create a to store the certificates  
`mkdir certificates && cd certificates`  
Hhen create a private key with command   
`openssl genrsa -out RootCA.key 4096`  
With your private key, create your root certificate with  
`openssl req -new -x509 -days 365 -key RootCA.key -out RootCA.pem`
## Configure Client certificate request
First create the client private key  
`openssl genrsa -out Client.key 2048`  
Then create an Certificate Sign Request (CSR) using client key  
`openssl req -new -key Client.key -out Client.csr`  
## Sign Client certificate using Root CA
Run the command bellow  
```openssl x509 -req -in Client.csr -CA RootCA.pem -CAkey RootCA.key -set_serial 01 -out Client.pem -days 365 -sha256```
## Create resources on AWS
Create client credentials from AWS user and login using aws cli
with  
`aws configure`  
Run the command bellow to see what will be created  
`terraform plan` 

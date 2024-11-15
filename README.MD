
# How to use mTLS with AWS Api Gateway and terraform :lock:
## What is mTLS? 
mTLS or mutual TLS is an tecnique, that provides secure comunication between two peers where the server and the client
can use tls handshake to validate the identiti of each one, is verry userfull in machine to machine integration 
## Before start
* You need an AWS Account, and AWS cli, openssl and terraform instaled on your machine
* You need a Valid domain name in your control
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
## Configure ACM
In your AWS account go to public certificates and request an ACM certificate. Then you should put an cname entry in your domain service.
## Configure truststore
Create a bucket in your AWS account and store the RootCA.pem file
## Create prod.tfvars file
Create a file with your environment variables like this
```
domain_name     = "your_custom_domain"
truststore_uri  = "uri_for_your_root_ca"
certificate_arn = "your_certificate_arn"
```
## Create resources on AWS
Create client credentials from AWS user and login using aws cli
with  
`aws configure`  
Initialize terraform  
`terraform init --var-file prod.tfvars`   
Inside src folder run the command bellow to see what will be created  
`terraform plan --var-file prod.tfvars`  
Finaly run the command bellow to create your resources  
`terraform apply --var-file prod.tfvars`  
confirm when the propt asks typing  
 `yes`
## Configure your domain
In your domain create an cname that points to your API gateway custom domain endpoint.
## Testing the API
First. test if you domain name already is configured (can take several minutes) with the command  
`dig yourdomain.com`  
If you see the address of your api gateway in cname you can run the curl to test your access.
```
curl -v --location 'https://www.yourdomain.com/hook' \
--header 'Content-Type: application/json' \
--data '{
    "event":"AWAIT"
}'
```  
And you should receive and error like this  
`curl: (56) Recv failure: Connection reset by peer`   
Now test passing your client certificate
```
curl -v --key certificates/Client.key --cert certificates/Client.pem --location 'https://www.yourdomain.com/hook' \
--header 'Content-Type: application/json' \
--data '{
    "event":"AWAIT"
}'
```
You shold see this response  
`{"statusCode": 200, "message": "Success"}`
##  
**Congratulations you successfully configured mTLS with API Gateway!** :trophy:
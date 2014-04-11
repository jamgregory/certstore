## Synopsis

Certificate Storage and Reporting

## Motivation

A system for recording and reporting on information about SSL Public Keys. This project does not attempt to do anything with private keys.

## Installation

Use the standard process for deploying a rails application

## Rake Tasks

There are a few useful rake tasks for managing certificates.

    $ rake ssl:scanhost[<hostname>:<port]

Scans a host to find out details of it's certificate. If the certificate does not exist, then it will be added to the database. The service record for host:port combination will be recorded against that certificate.

    $ rake ssl:compromise < certificate.crt

Marks a certificate as compromised. Pass in a certificate in PEM format to stdin and it will be found in the database and marked as compromised

## Contributors

I would very much welcome contributions to the project

## License

GPL version 3

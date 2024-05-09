# Certbot DNS OCI Docker Image

![Build Status](https://github.com/damithkothalawala/certbot-dns-oci-manager/actions/workflows/docker-image.yml/badge.svg)

This Dockerfile sets up a Docker image based on Ubuntu 24.04 with Certbot and the Certbot DNS OCI plugin installed, ready for automated certificate management on Oracle Cloud Infrastructure (OCI) using Certbot.

> **Disclaimer:** It's worth noting that certain security experts advise against storing private keys in object stores, even when encrypted with CSP Keys or Customer Master Keys. Therefore, we highly recommend consulting your security team before implementing this method in a production environment.


## What to expect

1. This will help you to create and renew Certbot certificates centrally not limited to a Kubernates / VM or on a Baremetal Server. And prevent getting API rate-limits from Certbot.
2. You will be able to get access to generated certificates using a PAR request towards OCI OSS or via any CLI / SDK or even same S3 Compatibale API Method like I used. You are welcome to provide use-cases as a PR to this repo and credits will be added.
3. Generated files will be like follows on your OCI Console
<img width="1402" alt="image" src="https://github.com/damithkothalawala/certbot-dns-oci-manager/assets/8252891/2635b3b1-eb0a-46a7-9307-feb690bf1d03">

## Usage

**DNS Should be configured at the tenancy as a zone. Docker / Kubernates Node should have proper permission with Instance Principals (To add and Modify DNS Zone).**

### Docker
To use this Docker image, you can build it locally or pull it from Docker Hub:

```bash
docker pull damithkothalawala/certbot-dns-oci-manager
```
Then, you can run the image:

```bash
docker run -e S3_ACCESS_KEY=<OCI_CUSTOMER_SECRET_KEYS_ACCESS_KEY> -e S3_SECRET_KEY=<OCI_CUSTOMER_SECRET_KEYS_SECRECT_KEY> \
           -e OCI_BUCKET=<YOUR_OCI_BUCKET_NAME> -e OCI_REGION=<YOUR_OCI_REGION> \
           -e OCI_NAMESPACE=<YOUR_OCI_NAMESPACE> -e DOMAIN=<YOUR_DOMAIN> \
           --privileged \
           damithkothalawala/certbot-dns-oci-manager
```

### Kubernates CronJob

Example Schedule to run every Monday at 6 PM (This will renew *any available certificate* creating action only aplicable for provided domain on env)

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
metadata:
  name: certbot-dns-oci-cronjob
spec:
  schedule: "0 18 * * 1"  
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: certbot-dns-oci-container
            image: damithkothalawala/certbot-dns-oci-manager
            env:
              - name: S3_ACCESS_KEY
                value: <OCI_CUSTOMER_SECRET_KEYS_ACCESS_KEY>
              - name: S3_SECRET_KEY
                value: <OCI_CUSTOMER_SECRET_KEYS_SECRECT_KEY>
              - name: OCI_BUCKET
                value: <OCI_BUCKET_NAME>
              - name: OCI_REGION
                value: <OCI_REGION>
              - name: OCI_NAMESPACE
                value: <OCI_OBJECT_STORAGE_NAMESPACE>
              - name: DOMAIN
                value: <DOMAIN>
            securityContext:
              privileged: true
          restartPolicy: OnFailure
```

Make sure to replace placeholders like `<YOUR_ACCESS_KEY>`, `<YOUR_SECRET_KEY>`, etc., with your actual OCI credentials and domain information.

## About the Owner

This project is maintained by [Damith Kothalawala](https://github.com/damithkothalawala). Feel free to reach out if you have any questions or suggestions!

## Contributing

Contributions are welcome! If you find any issues or have ideas for improvements, please open an issue or submit a pull request. Make sure to follow the contribution guidelines.

We welcome contributions in the form of bug reports, feature requests, code improvements, or documentation enhancements. Please ensure that any code contributions are accompanied by appropriate tests.

### How to Contribute

1. Fork the repository. (`https://github.com/damithkothalawala/certbot-dns-oci-manager.git`).
2. Create a new branch (`git checkout -b feature/improvement`).
3. Make your changes and commit them (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature/improvement`).
5. Create a new Pull Request.

Please make sure to follow the [Contributing Guidelines](CONTRIBUTING.md).

## License

This project is licensed under the [MIT License](LICENSE).

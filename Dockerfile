# Use Ubuntu 24.04 as base image
# (C) Damith Rushika Kothalawala 2024 May 6th
# Use Ubuntu 24.04 as base image
FROM ubuntu:24.04 AS BASE

# Install necessary packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    python3 \
    python3-venv \
    git \
#    build-essential \
#    libfuse-dev \
#    libcurl4-openssl-dev \
#    libxml2-dev \
#    automake \
#    libtool \
#    pkg-config \
    wget \
    openssl \
    fuse \
#    libssl-dev \
#    libcrypto++-dev \
#    libxml2-dev \
#    libcurl4-openssl-dev \
    s3fs

# Create and activate a virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Clone certbot-dns-oci repository
RUN git clone https://github.com/damithkothalawala/certbot-dns-oci.git -b feature-02-InstancePrincipal && \
    cd certbot-dns-oci && \
    /venv/bin/pip install .

# Install certbot within the virtual environment
RUN /venv/bin/pip install certbot

#Trying to Make Image Smaller
RUN apt autoremove -y

FROM scratch
COPY --from=BASE / /


# Run mount command using environment variables
CMD /bin/bash -c '\
if [ -z "$OCI_BUCKET" ] || [ -z "$OCI_REGION" ] || [ -z "$OCI_NAMESPACE" ] || [ -z "$S3_ACCESS_KEY" ] || [ -z "$S3_SECRET_KEY" ] || [ -z "$DOMAIN" ]; then \
    echo "Error: One or more required environment variables are missing:"; \
    [ -z "$OCI_BUCKET" ] && echo "OCI_BUCKET"; \
    [ -z "$OCI_REGION" ] && echo "OCI_REGION"; \
    [ -z "$OCI_NAMESPACE" ] && echo "OCI_NAMESPACE"; \
    [ -z "$S3_ACCESS_KEY" ] && echo "S3_ACCESS_KEY"; \
    [ -z "$S3_SECRET_KEY" ] && echo "S3_SECRET_KEY"; \
    [ -z "$DOMAIN" ] && echo "DOMAIN"; \
    exit 1; \
else \
    echo "All required environment variables are present." && \
    echo "$S3_ACCESS_KEY:$S3_SECRET_KEY" > /etc/passwd-s3fs && \
    chmod 600 /etc/passwd-s3fs && \
    echo "Please wait until initial setup completes. This would take around 60s - 80s (may differ if you manually set --dns-oci-propagation-seconds which is 60s by default)" && \
    s3fs "$OCI_BUCKET" /opt -o endpoint="$OCI_REGION" -o passwd_file=/etc/passwd-s3fs -o url="https://$OCI_NAMESPACE.compat.objectstorage.$OCI_REGION.oraclecloud.com/" -onomultipart -o use_path_request_style && \
    if [ -f /opt/config/renewal/"$DOMAIN".conf ]; then \
        /venv/bin/certbot renew --config-dir /opt/config; \
    else \
        /venv/bin/certbot certonly --logs-dir /opt/logs --work-dir /opt/work --config-dir /opt/config --authenticator dns-oci -d "$DOMAIN" --dns-oci-instance-principal=y --register-unsafely-without-email --agree-tos --cert-path /opt/certs; \
    fi \
fi \
'

FROM harness/delegate:26.04.88902

USER root

RUN microdnf install -y unzip git tar gzip && \
    curl -L https://releases.hashicorp.com/terraform/1.14.8/terraform_1.14.8_linux_amd64.zip -o terraform.zip && \
    unzip -q terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip && \
    microdnf clean all

RUN curl -XGET -L https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz -o gitleaks_8.30.1_linux_x64.tar.gz && \
    tar -zxf gitleaks_8.30.1_linux_x64.tar.gz && \
    mv gitleaks /usr/local/bin/ && \
    rm gitleaks_8.30.1_linux_x64.tar.gz

USER harness

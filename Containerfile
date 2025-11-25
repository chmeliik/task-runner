FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1@sha256:28ec2f4662bdc4b0d4893ef0d8aebf36a5165dfb1d1dc9f46319bd8a03ed3365

RUN microdnf -y --setopt install_weak_deps=0 reinstall bash && \
    microdnf clean all

FROM registry.access.redhat.com/ubi10/go-toolset:1.26.3@sha256:d5d48915a31c7c774caf7568f7fbe3b25275e042f9f4de73d13fba39f9b2a987 AS go-build

USER 0

WORKDIR /deps/golang/tools
COPY deps/go-tools/ .
RUN GOBIN=/deps/golang/bin ./install-tools.sh

# Have to copy the whole repo including .git now, because that's
# where submodule tags are stored (and we need those for versioning)
WORKDIR /repo
COPY . .
RUN cd deps/go-submodules && \
    GOBIN=/deps/golang/bin ./install-submodules.sh


FROM registry.access.redhat.com/ubi10/ubi-minimal:10.2-1780550715@sha256:2c20ac20ca1ecbbbd583603feabd9cc51e7e8ea5a82e5088e20a9494794b2574

COPY --from=go-build /deps/golang/bin/ /usr/local/bin/

COPY deps/rpm/ /tmp/rpm-installation/
RUN cd /tmp/rpm-installation && \
    ./install-rpms.sh && \
    rm -r /tmp/rpm-installation

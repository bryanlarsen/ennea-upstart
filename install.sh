#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"

: ${TEMPLATE_DIR:=${DIR}/templates}
: ${CONSUL_TEMPLATE_EXEC:=$(which consul-template) -consul consul.service.consul:8500}

mkdir -p "${TEMPLATE_DIR}"
mkdir -p /var/run/docker
rm -f "${TEMPLATE_DIR}/*"  # force consul-template to rewrite them in case the source changed

SED_ARGS=(-e "s!%CONSUL_TEMPLATE_EXEC%!${CONSUL_TEMPLATE_EXEC}!g" -e "s:%TEMPLATE_DIR%:${TEMPLATE_DIR}:g")

sed "${SED_ARGS[@]}" < upstart-docker.outer-ctmpl > "${TEMPLATE_DIR}/upstart-docker.outer-ctmpl"
sed "${SED_ARGS[@]}" < consul-template-upstart-docker-0.upstart > /etc/init/consul-template-upstart-docker-0.conf
sed "${SED_ARGS[@]}" < consul-template-upstart-docker-1.upstart.ctmpl > "${TEMPLATE_DIR}/consul-template-upstart-docker-1.upstart.ctmpl"
sed "${SED_ARGS[@]}" < consul-template-upstart-docker-2.upstart.ctmpl > "${TEMPLATE_DIR}/consul-template-upstart-docker-2.upstart.ctmpl"

service consul-template-upstart-docker-0 restart

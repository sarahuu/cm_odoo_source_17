FROM ubuntu:jammy
LABEL maintainer="Sarah Unokerieghan <sarahunoke@gmail.com>"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]
ENV LANG=en_US.UTF-8
ARG TARGETARCH
ARG ODOO_UID=1001
ARG ODOO_GID=1001

RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.edge.kernel.org/ubuntu/|g' /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --fix-missing \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-magic \
        python3-pip \
        python3-dev \
        libxml2-dev \
        libxslt-dev \
        libldap2-dev \
        libsasl2-dev \
        libjpeg-dev \
        libpq-dev \
        git \
        gosu \
        fontconfig \
        libfreetype6 \
        libpng16-16 \
        libx11-6 \
        libxcb1 \
        libxext6 \
        libxrender1 \
        xfonts-75dpi \
        xfonts-base \
        gcc \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN if [ -z "${TARGETARCH}" ]; then \
        TARGETARCH="$(dpkg --print-architecture)"; \
    fi && \
    curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${TARGETARCH}.deb && \
    apt-get install -y --no-install-recommends ./wkhtmltox.deb && \
    rm wkhtmltox.deb

RUN groupadd -r -g ${ODOO_GID} odoo && \
    useradd -m -d /home/odoo -u ${ODOO_UID} -g odoo -s /bin/bash odoo

RUN mkdir -p /etc/odoo /var/lib/odoo /mnt/extra-addons && \
    chown ${ODOO_UID}:${ODOO_GID} /etc/odoo /var/lib/odoo /mnt/extra-addons

COPY requirements.txt ./
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir -r requirements.txt && \
    pip3 install --no-cache-dir \
        psycopg2-binary \
        gevent==22.10.2 \
        python-ldap

COPY --chown=${ODOO_UID}:${ODOO_GID} . /odoo
WORKDIR /odoo

COPY ./odoo.conf /etc/odoo/odoo.conf
COPY ./entrypoint.sh /entrypoint.sh
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py
RUN chmod +x /entrypoint.sh /usr/local/bin/wait-for-psql.py

RUN chown -R ${ODOO_UID}:${ODOO_GID} /mnt/extra-addons /var/lib/odoo && \
    chmod 750 /etc/odoo /var/lib/odoo /mnt/extra-addons

VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]
EXPOSE 8069 8071 8072
ENV ODOO_RC=/etc/odoo/odoo.conf

USER ${ODOO_UID}:${ODOO_GID}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
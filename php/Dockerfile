#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM debian:buster-slim

# prevent Debian's PHP packages from being installed
# https://github.com/docker-library/php/pull/542
RUN set -eux; \
	{ \
		echo 'Package: php*'; \
		echo 'Pin: release *'; \
		echo 'Pin-Priority: -1'; \
	} > /etc/apt/preferences.d/no-debian-php

# dependencies required for running "phpize"
# (see persistent deps below)
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkg-config \
		re2c

# persistent / runtime deps
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		$PHPIZE_DEPS \
		ca-certificates \
		curl \
		xz-utils \
	 ; \
	 rm -rf /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
	[ ! -d /var/www/html ]; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; \
	chmod 777 /var/www/html

ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --disable-cgi

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

#ENV GPG_KEYS 1729F83938DA44E27BA0F4D3DBDB397470D12172 BFDDD28642824F8118EF77909B67A5C12229118F

#ENV PHP_VERSION 8.0.0
#ENV PHP_URL="https://www.php.net/distributions/php-8.0.0.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-8.0.0.tar.xz.asc"
#ENV PHP_SHA256="b5278b3eef584f0c075d15666da4e952fa3859ee509d6b0cc2ed13df13f65ebb"

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends gnupg dirmngr git; \
	rm -rf /var/lib/apt/lists/*; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	#curl -fsSL -o php.tar.xz "$PHP_URL"; \
	#\
	#if [ -n "$PHP_SHA256" ]; then \
	#	echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	#fi; \
	#\
	#if [ -n "$PHP_ASC_URL" ]; then \
	#	curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
	#	export GNUPGHOME="$(mktemp -d)"; \
	#	for key in $GPG_KEYS; do \
	#		gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	#	done; \
	#	gpg --batch --verify php.tar.xz.asc php.tar.xz; \
	#	gpgconf --kill all; \
	#	rm -rf "$GNUPGHOME"; \
	#fi; \
	git clone https://github.com/php/php-src php; \
	cd php; \
	git checkout "$( \
		git for-each-ref --format='%(refname)' refs/tags \
		| grep -E 'refs/tags/php-8[.0-9]+$' \
		| sed 's|.*tags/||g' \
		| sort -V \
		| tail -1 \
	)"; \
	./buildconf --force; \
	rm -rf .git; \
	cd /usr/src; \
	tar -cJf php.tar.xz php; \
	rm -rf php; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY data/docker-php-source /usr/local/bin/

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bison \
		libargon2-dev \
		libcurl4-openssl-dev \
		libedit-dev \
		libffi-dev \
		libonig-dev \
		libsodium-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		zlib1g-dev \
		${PHP_EXTRA_BUILD_DEPS:-} \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	export \
		CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
# https://bugs.php.net/bug.php?id=74125
	if [ ! -d /usr/include/curl ]; then \
		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
	fi; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors instead of just warnings
		--enable-option-checking=fatal \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# https://github.com/docker-library/php/issues/822
		--with-pic \
		\
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
		--enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# https://wiki.php.net/rfc/argon2_password_hash (7.2+)
		--with-password-argon2 \
# https://wiki.php.net/rfc/libsodium
		--with-sodium=shared \
# always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
		--with-pdo-sqlite=/usr \
		--with-sqlite3=/usr \
		# Build FFI into it
		--with-ffi \
		\
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		\
		--with-pear \
		\
		$(test "$gnuArch" = 's390x-linux-gnu' && echo '--without-pcre-jit') \
		--with-libdir="lib/$debMultiarch" \
		\
		${PHP_EXTRA_CONFIGURE_ARGS:-} \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; \
	make clean; \
	\
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
	cp -v php.ini-* "$PHP_INI_DIR/"; \
	\
	cd /; \
	docker-php-source delete; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
# update pecl channel definitions https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
	\
# smoke test
	php --version

COPY data/docker-php-ext-* data/docker-php-entrypoint /usr/local/bin/

# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
RUN docker-php-ext-enable sodium

ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /var/www/html

RUN set -eux; \
	cd /usr/local/etc; \
	if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi; \
	{ \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; echo '; https://github.com/docker-library/php/pull/725#issuecomment-443540114'; echo 'log_limit = 8192'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
		echo 'decorate_workers_output = no'; \
	} | tee php-fpm.d/docker.conf; \
	{ \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = 9000'; \
	} | tee php-fpm.d/zz-docker.conf

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT


RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/
##Janus
RUN apt update
RUN apt install -y libmicrohttpd-dev libjansson-dev libssl-dev wget libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev libusrsctp-dev doxygen graphviz git cmake python3-pip libconfig-dev gengetopt libtool automake pkg-config nano libzip-dev libpq-dev

RUN docker-php-ext-install zip
#RUN docker-php-ext-install pdo
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install pdo_pgsql

RUN pip3 install --user meson
RUN pip3 install ninja

RUN cd /tmp; \
	git clone https://gitlab.freedesktop.org/libnice/libnice; \
	cd libnice; \
	/root/.local/bin/meson --prefix=/usr build && ninja -C build && ninja -C build install; \



RUN cd /tmp; \
	wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz; \
	tar xfv v2.2.0.tar.gz; \
	cd libsrtp-2.2.0; \
	./configure --prefix=/usr --enable-openssl; \
	make shared_library && make install
	

RUN cd /tmp; \
	git clone https://libwebsockets.org/repo/libwebsockets; \
	cd libwebsockets; \
	mkdir build && cd build;\
	cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..; \
	make && make install; \

RUN cd /tmp; \
	git clone https://github.com/alanxz/rabbitmq-c; \
	cd rabbitmq-c; \
	git submodule init; \
	git submodule update; \
	mkdir build && cd build; \
	cmake -DCMAKE_INSTALL_PREFIX=/usr ..; \
	make && make install

RUN cd /tmp; \
	git clone https://github.com/eclipse/paho.mqtt.c.git; \
	cd paho.mqtt.c; \
	make && make install

RUN cd /tmp; \
	git clone https://github.com/meetecho/janus-gateway.git; \
	cd janus-gateway; \
	sh autogen.sh; \
	./configure --prefix=/opt/janus; \
	make; \
	make install; \
	make configs
	
RUN sed -i "s/localhost:1883/rabbitmq:1883/g" /opt/janus/etc/janus/janus.transport.mqtt.jcfg

###
### Verify
###
RUN set -x \
	&& php -v | grep -oE 'PHP\s[.0-9]+' | grep -oE '[.0-9]+' | grep '^8.0' \
	&& /usr/local/sbin/php-fpm --test \
	&& PHP_ERROR="$( php -v 2>&1 1>/dev/null )" \
	&& if [ -n "${PHP_ERROR}" ]; then echo "${PHP_ERROR}"; false; fi



RUN mkdir -p /home/www-data; \
	chown -R www-data:www-data /home/www-data; \
	touch /home/www-data/.bashrc; \
	usermod -u 1000 www-data && usermod -d /home/www-data www-data && groupmod -g 1000 www-data
	

RUN echo 'alias l="ls -CF"' >> ~/.bashrc
RUN echo 'alias la="ls -A"' >> ~/.bashrc
RUN echo 'alias ll="ls -alF"' >> ~/.bashrc
RUN echo 'alias ls="ls --color=auto"' >> ~/.bashrc
RUN echo 'alias l="ls -CF"' >> /home/www-data/.bashrc
RUN echo 'alias la="ls -A"' >> /home/www-data/.bashrc
RUN echo 'alias ll="ls -alF"' >> /home/www-data/.bashrc
RUN echo 'alias ls="ls --color=auto"' >> /home/www-data/.bashrc

EXPOSE 9000
USER www-data
CMD ["php-fpm"]

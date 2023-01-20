export MC="-j$(nproc)"

#
# Install extension from package file(.tgz),
# For example:
#
# installExtensionFromTgz redis-5.2.2
#
# Param 1: Package name with version
# Param 2: enable options
#
installExtensionFromTgz()
{
    tgzName=$1
    extensionName="${tgzName%%-*}"

    mkdir ${extensionName}
    tar -xf ${tgzName}.tgz -C ${extensionName} --strip-components=1
    ( cd ${extensionName} && phpize && ./configure && make ${MC} && make install )

    docker-php-ext-enable ${extensionName} $2
}

echo "---------- Install pdo_mysql ----------" 
docker-php-ext-install ${MC} pdo_mysql 

echo "---------- Install mysqli ----------" 
docker-php-ext-install ${MC} mysqli 

echo "---------- Install pcntl ----------" 
docker-php-ext-install ${MC} pcntl 

echo "---------- Install exif ----------" 
docker-php-ext-install ${MC} exif 

echo "---------- Install bcmath ----------" 
docker-php-ext-install ${MC} bcmath 

echo "---------- Install opcache ----------" 
docker-php-ext-install opcache 

echo "---------- Install sockets ----------" 
docker-php-ext-install ${MC} sockets 

echo "---------- Install gd ----------" 
options="--with-freetype --with-jpeg --with-webp" 
apk add --no-cache \
			freetype \
			freetype-dev \
			libpng \
			libpng-dev \
			libjpeg-turbo \
			libjpeg-turbo-dev \
libwebp-dev \
	&& docker-php-ext-configure gd ${options} \
	&& docker-php-ext-install ${MC} gd \
	&& apk del \
			freetype-dev \
			libpng-dev \
			libjpeg-turbo-dev

echo "---------- Install redis ----------"
installExtensionFromTgz redis-5.3.7

echo "---------- Install zip ----------"
# Fix: https://github.com/docker-library/php/issues/797
apk add --no-cache libzip-dev
docker-php-ext-configure zip --with-libzip=/usr/include
docker-php-ext-install ${MC} zip
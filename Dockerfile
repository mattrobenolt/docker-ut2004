FROM debian:jessie

RUN dpkg --add-architecture i386 \
        && apt-get update && apt-get install -y --no-install-recommends  \
            ca-certificates \
            lib32gcc1 \
            libstdc++5:i386 \
            libstdc++6:i386 \
            libsdl1.2debian \
        && rm -rf /var/lib/apt/lists/*

# Install envtpl
RUN apt-get update && apt-get install -y --no-install-recommends curl \
        && rm -rf /var/lib/apt/lists/* \
        && curl -sSL https://github.com/mattrobenolt/envtpl/releases/download/0.1.0/envtpl-linux-amd64 -o envtpl \
        && sha1sum envtpl \
        && echo "90c40d624e0ce40d62a0ac132767bcd6c267ed55 envtpl" | sha1sum -c - \
        && chmod +x envtpl \
        && mv envtpl /usr/local/bin/ \
        && apt-get purge -y --auto-remove curl

ENV UT2004_DOWNLOAD_URL http://gameservermanagers.com/files/ut2004/dedicatedserver3339-bonuspack.zip
ENV UT2004_DOWNLOAD_SHA1 e1eda562d99e66a7e5972f05bbf0de8733bf60c9
ENV UT2004_PATCH_DOWNLOAD_URL http://gameservermanagers.com/files/ut2004/ut2004-lnxpatch3369-2.tar.bz2
ENV UT2004_PATCH_DOWNLOAD_SHA1 a8cc33877a02a0a09c288b5fc248efde282f7bdf

RUN buildDeps='curl bzip2 unzip' \
        && set -x \
        && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* \
        && mkdir -p /usr/src/ut2004 \
        && curl -sSL "$UT2004_DOWNLOAD_URL" -o ut2004.zip \
        && echo "$UT2004_DOWNLOAD_SHA1 ut2004.zip" | sha1sum -c - \
        && curl -sSL "$UT2004_PATCH_DOWNLOAD_URL" -o ut2004_patch.tar.bz2 \
        && echo "$UT2004_PATCH_DOWNLOAD_SHA1 ut2004_patch.tar.bz2" | sha1sum -c - \
        && unzip ut2004.zip -d /usr/src/ut2004 \
        && tar -xvjf ut2004_patch.tar.bz2 -C /usr/src/ut2004 UT2004-Patch/ --strip-components=1 \
        && rm ut2004.zip ut2004_patch.tar.bz2 \
        # Fix broken CSS
        # See: http://forums.tripwireinteractive.com/showpost.php?p=585435&postcount=13
        && sed -i 's/none}/none;/g' "/usr/src/ut2004/Web/ServerAdmin/ut2003.css" \
        && sed -i 's/underline}/underline;/g' "/usr/src/ut2004/Web/ServerAdmin/ut2003.css" \
        # Remove the included ini config
        && rm /usr/src/ut2004/System/UT2004.ini \
        && apt-get purge -y --auto-remove $buildDeps

# Add in our config template
COPY UT2004.ini.tpl /usr/src/ut2004/System/

WORKDIR /usr/src/ut2004/System
ENV PATH=$PATH:/usr/src/ut2004/System

COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 7777/udp 7778/udp 7787/udp 28902 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ucc-bin", "server", "DM-Morpheus3?game=XGame.xDeathMatch", "ini=UT2004.ini", "-nohomedir"]

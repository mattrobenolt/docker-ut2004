FROM debian:jessie

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
        curl \
        ca-certificates \
        lib32gcc1 \
        libstdc++5:i386 \
        libstdc++6:i386 \
        libsdl1.2debian \
        bzip2 \
        unzip \
    && rm -rf /var/lib/apt/lists/*

ENV UT2004_DOWNLOAD_URL http://gameservermanagers.com/files/ut2004/dedicatedserver3339-bonuspack.zip
ENV UT2004_DOWNLOAD_SHA1 e1eda562d99e66a7e5972f05bbf0de8733bf60c9
ENV UT2004_PATCH_DOWNLOAD_URL http://gameservermanagers.com/files/ut2004/ut2004-lnxpatch3369-2.tar.bz2
ENV UT2004_PATCH_DOWNLOAD_SHA1 a8cc33877a02a0a09c288b5fc248efde282f7bdf

RUN mkdir -p /usr/src/ut2004 \
    && curl -SL "$UT2004_DOWNLOAD_URL" -o ut2004.zip \
    && echo "$UT2004_DOWNLOAD_SHA1 ut2004.zip" | sha1sum -c - \
    && curl -SL "$UT2004_PATCH_DOWNLOAD_URL" -o ut2004_patch.tar.bz2 \
    && echo "$UT2004_PATCH_DOWNLOAD_SHA1 ut2004_patch.tar.bz2" | sha1sum -c - \
    && unzip ut2004.zip -d /usr/src/ut2004 \
    && tar -xvjf ut2004_patch.tar.bz2 -C /usr/src/ut2004 UT2004-Patch/ --strip-components=1 \
    && rm ut2004.zip ut2004_patch.tar.bz2 \
    # Fix broken CSS
    # See: http://forums.tripwireinteractive.com/showpost.php?p=585435&postcount=13
    && sed -i 's/none}/none;/g' "/usr/src/ut2004/Web/ServerAdmin/ut2003.css" \
    && sed -i 's/underline}/underline;/g' "/usr/src/ut2004/Web/ServerAdmin/ut2003.css" \
    # Enable the admin
    && sed -i 's/bEnabled=False/bEnabled=True\r\nMaxConnections=500/g' "/usr/src/ut2004/System/UT2004.ini"

WORKDIR /usr/src/ut2004/System
ENV PATH=$PATH:/usr/src/ut2004/System

COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 7777/udp 7778/udp 7787/udp 28902 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ucc-bin", "server", "DM-Morpheus3?game=XGame.xDeathMatch?AdminName=myname?AdminPassword=mypass", "ini=UT2004.ini", "-nohomedir"]

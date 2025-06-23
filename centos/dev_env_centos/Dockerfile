FROM registry.cn-hangzhou.aliyuncs.com/curried/centos:centos7.9.2009
COPY scripts /opt/scripts
COPY Python-3.10.17.tar.xz /tmp/code/Python-3.10.17.tar.xz

RUN bash /opt/scripts/setup.sh

# 将 devtoolset-11 自动启用，写入 /etc/profile.d 中使每次登录都能加载
RUN echo "source /opt/rh/devtoolset-11/enable" > /etc/profile.d/devtoolset.sh
# 将 rh-git227 自动启用，写入 /etc/profile.d 中使每次登录都能加载
RUN echo "source /opt/rh/rh-git227/enable" > /etc/profile.d/rh-git227.sh

ENV USE_HARD_LINKS=false \
    LANG=en_US.UTF-8 \
    PATH=/root/.local/bin:/opt/rh/rh-git227/root/usr/bin:/opt/rh/devtoolset-11/root/usr/bin:/opt/rh/rh-maven35/root/usr/bin:${PATH} \
    PERL5LIB=/opt/rh/rh-git227/root/usr/share/perl5/vendor_perl${PERL5LIB:+:${PERL5LIB}} \
    LD_LIBRARY_PATH=/opt/rh/httpd24/root/usr/lib64:${LD_LIBRARY_PATH}


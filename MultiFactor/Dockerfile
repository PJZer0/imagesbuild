# 使用官方的Anaconda3镜像作为基础镜像
# FROM continuumio/anaconda3:latest
FROM registry.cn-hangzhou.aliyuncs.com/curried/anaconda3:2020.11

# 设置国内pip源
# RUN pip config --user set global.index https://mirrors.huaweicloud.com/repository/pypi; \
#     pip config --user set global.index-url https://mirrors.huaweicloud.com/repository/pypi/simple; \
#     pip config --user set global.trusted-host mirrors.huaweicloud.com 
RUN pip config --user set global.index http://mirrors.aliyun.com/pypi; \
    pip config --user set global.index-url http://mirrors.aliyun.com/pypi/simple/; \
    pip config --user set global.trusted-host mirrors.aliyun.com 

# 设置工作目录
WORKDIR /MultiFactor

# # 克隆MultiFactor项目
# RUN git clone https://github.com/etccapital/MultiFactor.git
# 提前下载
COPY _MultiFactor /app/MultiFactor

# 切换到MultiFactor项目目录
WORKDIR /app/MultiFactor

# 安装项目依赖
RUN conda env create --file=environment.yml 
RUN conda activate multifactor  

WORKDIR /app/workspace

# 设置启动命令
# 由于我们可能会在docker-compose中覆盖CMD，这里可以留空或设置为一个交互式shell
CMD ["bash"]
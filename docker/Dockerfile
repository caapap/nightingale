FROM --platform=linux/amd64 docker.rainbond.cc/python:3-slim


WORKDIR /app
ADD n9e /app/
ADD etc /app/etc/
ADD integrations /app/integrations/
RUN pip install requests -i https://pypi.mirrors.ustc.edu.cn/simple

EXPOSE 17000

CMD ["/app/n9e", "-h"]

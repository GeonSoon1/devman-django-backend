# alpine 3.19 버전의 리눅스를 구축하는데, 파이썬 버전은 3.11로 설치된 이미지를 불러와줘
# alpine -  경량화된 리눅스 버전 => 가볍다 => 빌드가 계속 반복이되는데, 이미지 자체가 무거우면 빌드 속도가 느려짐.

FROM python:3.11-alpine3.19

#도커아이디
LABEL maintainer='rjstns23'

# python 0:1 = False:True
# 컨테이너에 찍히는 로그를 볼 수 있도록 허용한다.
# 도커 컨테이너에서 어떤 일이 벌어지고 있는지 알아야지 디버깅을 하겠죠?
# 실시간으로 볼 수 있기 때문에 관리가 편해진다.
ENV PYTHONUNBUFFERED 1

# 컨테이너 안에다가 requirements.txt등을 복사해준것이다.
# tmp에다가 넣은건 최대한 컨테이너를 경량화해주기 위해서(tmp는 일시적, 나중에 build되면 삭제 예정)
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app
# 장고가 8000포트라서 8000포트를 열어준다.
EXPOSE 8000

ARG DEV=false

# && \: ENTER
# 가상환경만들기 -> 설치 -> 삭제 ->장고에 접근할 유저 만들기(패스워드없이, 홈에 만들지 말고, 그녀석에 이름은 장고유저)
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    if [ $DEV = 'true']; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

#파이썬이 전역에서 실행될수있게끔?
ENV PATH="/py/bin:$PATH"
USER django-user


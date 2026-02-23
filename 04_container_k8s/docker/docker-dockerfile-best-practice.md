# Dockerfile Best Practice

## 1. 개요 및 비유
**Dockerfile**은 컨테이너 이미지를 빌드하기 위한 스크립트입니다. 올바른 방법(Best Practice)으로 Dockerfile을 작성해야 이미지 용량을 줄이고 빌드 속도를 높이며, 보안 취약점을 최소화할 수 있습니다.

💡 **비유하자면 '여행용 트렁크 짐 싸기 테트리스'와 같습니다.**
무겁고 모양이 안 변하는 책(OS, 라이브러리)은 가방 맨 아래에 넣고, 자주 꺼내 입는 옷과 세면도구(애플리케이션 소스코드)는 가방 맨 위에 넣어야 합니다. 그래야 나중에 옷 하나만 갈아입을 때(코드 수정 후 재빌드) 가방을 처음부터 다 뒤집어엎지 않고 맨 위만 살짝 열어 빠르게 꺼낼 수 있습니다. (도커의 **레이어 캐싱** 원리)

## 2. 핵심 설명
* **멀티 스테이지 빌드 (Multi-stage Build):** 빌드용 환경과 실행용 환경을 분리합니다. 소스코드를 컴파일할 때 썼던 무거운 빌드 툴(JDK, GCC 등)은 버리고, 최종 실행 파일만 얇은 베이스 이미지(Alpine 등)에 복사하여 용량을 획기적으로 줄입니다.
* **명령어 최소화 (Layer 감소):** `RUN` 명령어 하나당 이미지 레이어가 하나씩 생깁니다. 연관된 명령어들은 `&&`로 묶어서 하나의 `RUN`으로 실행해야 레이어가 줄어듭니다.
* **코드 복사는 마지막에:** `package.json`이나 `requirements.txt`처럼 변동이 적은 패키지 파일을 먼저 복사하여 종속성을 설치하고, 자주 바뀌는 소스코드는 가장 마지막에 복사(`COPY . .`)해야 빌드 캐시를 최대한 활용할 수 있습니다.

## 3. YAML 적용 예시 (멀티 스테이지 Dockerfile + K8s Deployment)
Dockerfile 자체는 YAML이 아니지만, 이렇게 최적화된 이미지를 빌드하여 쿠버네티스(YAML)에서 배포할 때 시작 속도가 극적으로 단축됩니다.

```yaml
# [참고용: 최적화된 Dockerfile 예시]
# FROM golang:1.19 AS builder
# WORKDIR /app
# COPY go.mod go.sum ./
# RUN go mod download
# COPY . .
# RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .
#
# FROM alpine:latest  <-- 실행용 초경량 베이스 이미지
# RUN apk --no-cache add ca-certificates
# WORKDIR /root/
# COPY --from=builder /app/main .  <-- 빌더에서 실행 파일만 복사
# CMD ["./main"]

# ------------------------------------------------------------------

# [적용 예시: K8s Deployment YAML]
# 최적화된 초경량 이미지를 사용하여 파드 시작(Pull) 속도가 매우 빠름
apiVersion: apps/v1
kind: Deployment
metadata:
  name: optimized-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: optimized-go
  template:
    metadata:
      labels:
        app: optimized-go
    spec:
      containers:
      - name: app-container
        # 1GB짜리 이미지가 멀티스테이지 적용 후 20MB로 줄어들었다고 가정
        image: my-registry/optimized-app:v1.0.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
```

## 4. 트러블 슈팅
* **이미지 재빌드 속도가 너무 느림 (캐시 미스):**
  * `COPY . .` (전체 소스코드 복사) 명령어를 `RUN npm install`이나 `RUN pip install` 보다 '앞줄에' 배치한 경우, 코드 한 줄만 바꿔도 전체 의존성을 다시 다운로드하는 참사가 발생합니다. 항상 패키지 명세서 복사 $\rightarrow$ 패키지 설치 $\rightarrow$ 전체 소스코드 복사 순서로 작성하세요.
* **파드 내부에서 쉘(Shell) 접속이 안 됨:**
  * 보안과 경량화를 위해 `scratch`나 `alpine` 베이스 이미지를 사용하면 내부에 `/bin/bash`가 없을 수 있습니다. 접속이 꼭 필요하다면 `kubectl exec -it <pod-name> -- /bin/sh` 명령어를 시도해 보세요.
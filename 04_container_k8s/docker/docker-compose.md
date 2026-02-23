# Docker Compose

## 1. 개요 및 비유
**Docker Compose**는 여러 개의 컨테이너로 구성된 복잡한 애플리케이션을 하나의 YAML 파일로 정의하고, 한 번의 명령어로 동시에 실행하고 관리할 수 있게 해주는 도구입니다.

💡 **비유하자면 '오케스트라 지휘자의 악보'와 같습니다.**
피아노, 바이올린, 첼로(각각의 컨테이너)가 제멋대로 연주하면 불협화음이 납니다. "피아노는 웹 서버 역할을 하고, 바이올린은 DB 역할을 하며 서로 같은 박자(네트워크)로 연주해라"라고 적어둔 악보(docker-compose.yml)를 지휘자(명령어)가 읽고 동시에 훌륭한 음악(애플리케이션)을 만들어냅니다.

## 2. 핵심 설명
* **단일 파일 정의:** `docker-compose.yml` 하나에 웹 애플리케이션, 데이터베이스, 캐시 서버 등을 모두 정의합니다.
* **의존성 관리:** `depends_on` 옵션을 통해 DB 컨테이너가 먼저 켜진 후에 웹 서버 컨테이너가 켜지도록 실행 순서를 보장할 수 있습니다.
* **네트워크 자동 구성:** Compose로 띄운 컨테이너들은 자동으로 동일한 가상 네트워크(`default` 네트워크)로 묶여, 컨테이너 이름(예: `http://db:3306`)만으로 서로 통신할 수 있습니다.

## 3. YAML 적용 예시 (WordPress & MySQL 구성)
웹 프론트엔드와 백엔드 DB를 한 번에 띄우는 전형적인 `docker-compose.yml` 예시입니다.

```yaml
version: '3.8'

services:
  # 웹 프론트엔드 컨테이너
  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD: wp_password
    depends_on:
      - db

  # 백엔드 데이터베이스 컨테이너
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wp_user
      MYSQL_PASSWORD: wp_password

volumes:
  db_data: # 데이터 영구 보존을 위한 볼륨
```

## 4. 트러블 슈팅
* **`depends_on`을 썼는데도 DB 연결 에러가 날 때:**
  * `depends_on`은 컨테이너가 '시작'되는 순서만 제어할 뿐, MySQL 내부 프로세스가 쿼리를 받을 '준비(Ready)'가 끝날 때까지 기다려주지 않습니다.
  * 애플리케이션 코드 내부에 DB 연결 재시도(Retry/Backoff) 로직을 구현하거나, Compose 파일 내에서 `healthcheck` 설정을 추가하여 DB가 완벽히 레디 상태가 된 후 웹 서버를 띄우도록 수정해야 합니다.
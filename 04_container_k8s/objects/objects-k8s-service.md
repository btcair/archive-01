# Objects: K8s Service

## 1. 개요 및 비유
**Service(서비스)**는 동적으로 변하는 파드들의 IP 주소를 신경 쓰지 않고, 파드 그룹에 안정적으로 접근할 수 있도록 고정된 단일 진입점(IP 및 DNS)을 제공하는 네트워크 리소스입니다.

💡 **비유하자면 '콜센터의 대표 전화번호'와 같습니다.**
콜센터 상담원(파드)들은 출퇴근도 하고 자리(IP 주소)도 수시로 바뀝니다. 고객이 상담원의 직통 번호를 일일이 외울 수는 없죠. 대신 고객은 '1588-0000(Service)'이라는 고정된 대표 번호로 전화를 걸고, 콜센터 시스템이 현재 일하고 있는 상담원 중 한 명에게 전화를 고르게 연결(로드 밸런싱)해 주는 원리입니다.



## 2. 핵심 설명
* **Label Selector:** Service는 어떤 파드들에게 트래픽을 보낼지를 **Label(라벨)** 매칭을 통해 결정합니다. (예: `app: frontend` 라벨을 가진 모든 파드 묶기)
* **Endpoint (엔드포인트):** Service가 셀렉터를 통해 파드들을 찾으면, 그 파드들의 실제 IP 주소 목록을 `Endpoints`라는 숨겨진 객체에 지속적으로 업데이트합니다.
* **서비스 타입 3가지:**
  1. `ClusterIP` (기본값): 클러스터 내부에서만 접근 가능한 내부 IP.
  2. `NodePort`: 워커 노드의 특정 포트(30000~32767)를 열어 외부 트래픽을 허용.
  3. `LoadBalancer`: 클라우드 제공자(AWS 등)의 물리적 로드 밸런서(ELB, NLB)를 자동으로 프로비저닝하여 연결.

## 3. YAML 적용 예시 (ClusterIP 서비스)
클러스터 내부의 프론트엔드 파드가 백엔드 파드(`app: backend`)를 호출할 때 사용할 고정 경로를 만들어주는 예시입니다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-svc # 클러스터 내부에서 이 이름(DNS)으로 통신 가능
spec:
  type: ClusterIP
  selector:
    app: backend # 이 라벨을 가진 파드들로 트래픽을 로드 밸런싱
  ports:
    - protocol: TCP
      port: 80         # Service가 외부(다른 파드)에 노출하는 포트
      targetPort: 8080 # 트래픽을 전달받을 실제 파드 컨테이너의 포트
```

## 4. 트러블 슈팅
* **Service 이름으로 핑(Ping)이나 통신이 전혀 되지 않음:**
  * 가장 흔한 원인은 Service의 `selector` 라벨과 실제 파드(Deployment)의 라벨이 스펠링이나 대소문자가 달라서 매칭되지 않은 경우입니다.
  * 해결책: `kubectl get endpoints backend-svc`를 입력했을 때, IP 주소 목록이 비어있다면 라벨 셀렉터가 잘못된 것입니다. `TargetPort`와 파드의 `containerPort`가 일치하는지도 확인하세요.
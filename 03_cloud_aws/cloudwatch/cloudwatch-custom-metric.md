cloudwatch agent로 메트릭을 수집하지 않는 경우(e.g. nvidia-smi 명령어로 GPU 상태 확인시),
서버 자체에서 custom metric sh를 생성하여, crontab을 등록해야한다. 

**TIP.** 
aws cloudwatch put-metric-data를 많이 생성해서 넘기는 것 보다는 json으로 한번에 보내야한다..
API 요청대로 요금이 발생하고, for문을 돌면서 계속해서 연결을 맺는 과정이 필요하기 때문에 속도도 느리다.

```bash
#!/bin/bash
REGION="ap-northeast-2"
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
GPU_COUNT=$(nvidia-smi -L | wc -l)

# 메트릭 데이터를 담을 배열 초기화
METRICS_JSON="[]"

for (( i=0; i<$GPU_COUNT; i++ ))
do
    # [최적화 1] 단 한 번의 호출로 해당 GPU의 모든 텍스트를 변수에 저장
    GPU_INFO=$(nvidia-smi -i $i -q)

    # [최적화 2] 변수 내에서 텍스트 파싱 (추가 프로세스 실행 없음)
    UNCORR_VAL=$(echo "$GPU_INFO" | sed -n '/Aggregate/,/Retired/p' | grep "DRAM Uncorrectable" | awk '{print $NF}' | tr -dc '0-9')
    CORR_VAL=$(echo "$GPU_INFO" | sed -n '/Aggregate/,/Retired/p' | grep "DRAM Correctable" | awk '{print $NF}' | tr -dc '0-9')
    RETIRED_DBE=$(echo "$GPU_INFO" | grep -A 5 "Retired Pages" | grep "Double Bit ECC" | awk '{print $NF}' | tr -dc '0-9')

    # 빈 값 처리
    : ${UNCORR_VAL:=0}; : ${CORR_VAL:=0}; : ${RETIRED_DBE:=0}

    # [최적화 3] JSON 데이터 구조 생성 (메모리 내 누적)
    METRIC_DATA=$(cat <<EOF
[
  {"MetricName": "GPU_Aggregate_Uncorrectable_Errors", "Value": $UNCORR_VAL, "Unit": "Count", "Dimensions": [{"Name": "InstanceId", "Value": "$INSTANCE_ID"}, {"Name": "GPUIndex", "Value": "$i"}]},
  {"MetricName": "GPU_Aggregate_Correctable_Errors", "Value": $CORR_VAL, "Unit": "Count", "Dimensions": [{"Name": "InstanceId", "Value": "$INSTANCE_ID"}, {"Name": "GPUIndex", "Value": "$i"}]},
  {"MetricName": "GPU_Retired_Double_Bit_ECC", "Value": $RETIRED_DBE, "Unit": "Count", "Dimensions": [{"Name": "InstanceId", "Value": "$INSTANCE_ID"}, {"Name": "GPUIndex", "Value": "$i"}]}
]
EOF
)
    # 기존 JSON 배열에 합치기
    METRICS_JSON=$(echo "$METRICS_JSON" "$METRIC_DATA" | jq -s 'add')
done

# [최적화 4] 단 한 번의 네트워크 통신으로 모든 데이터 전송
aws cloudwatch put-metric-data --namespace "Custom/GPU_Health" --metric-data "$METRICS_JSON" --region "$REGION"

echo "모든 GPU($GPU_COUNT대)의 지표 전송 완료."

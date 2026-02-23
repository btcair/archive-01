promql을 잘 활용하면, 모니터링이나 원하는 지표값에 대한 절차를 줄일 수 있다(e.g. 결과값을 0과 1로 만드는 작업(?))
- **[참고]https://prometheus.io/docs/prometheus/latest/querying/functions/**

자주 사용하는 function 예시
- rate(): 1초당 얼마나 요청이 들어오는지 계산 (Counter 지표용)
```
rate(aws_alb_request_count_sum{job="money-printing-press"}[5m])
```

- increase(): 특정 기간 동안 총 얼마나 증가했는지 정수로 표기
```
increase(aws_lambda_invocations_sum{job="serverless-warrior"}[1h])
```

- histogram_quantile(): 상위 %의 응답 속도를 계산
```
histogram_quantile(0.99, sum by (le) (rate(aws_alb_target_response_time_seconds_bucket{job="vip-lounge"}[5m])))
```

- predict_linear(): 현재 추세로 볼 때 미래의 특정 시점에 값이 뭐가 될지 예측
```bash
predict_linear(aws_rds_free_storage_space_average{job="bottomless-pit-db"}[4h], 86400) < 0
```

- absent(): 지표가 아예 안 들어오면 "1"을 뱉음 (서버 다운 감지)
```
absent(up{job="ghost-api"})
```

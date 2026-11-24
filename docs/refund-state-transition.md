# Refund API State Transition Validation

개인 학습용 Flask + SQLite 환경에서 환불 요청 API의 응답과 DB 상태 변경을 함께 검증한 기록입니다.

## RF-01. 정상 환불 요청 시 DB 상태 변경 확인

### 사전조건
- 주문번호: ORD-API-001
- 주문 상태: CANCELLED
- 결제 상태: PAID
- 환불 상태: NULL

### 테스트 절차
1. DB에서 ORD-API-001의 refund_status가 NULL인지 확인한다.
2. POST /orders/ORD-API-001/refund-request 요청을 전송한다.
3. API 응답 메시지와 refund_status 값을 확인한다.
4. DB에서 동일 주문의 refund_status가 REQUESTED로 변경됐는지 조회한다.

### 기대 결과
### 기대 결과

- API 응답: HTTP 200, 
`"message": "환불 요청이 완료되었습니다."`, `"refund_status": "REQUESTED"`
- DB 상태: `refund_status`가 `NULL`에서 `REQUESTED`로 변경된다.

- DB 상태: refund_status: requested

### 실제 결과

- API 응답:
  - HTTP 200
  - "환불 요청이 완료되었습니다."
  - refund_status: REQUESTED

- DB 상태:
  - refund_status: NULL → REQUESTED

### 판정

PASS

## RF-02. 동일 주문 재요청 확인

### 사전조건
- 주문번호: ORD-API-001
- 주문 상태: CANCELLED
- 결제 상태: PAID
- 환불 상태: REQUESTED

### 테스트 절차
1. DB에서 ORD-API-001의 refund_status가 REQUESTED인지 확인한다.
2. POST /orders/ORD-API-001/refund-request 요청을 전송한다.
3. API 응답 메시지가 “이미 환불 요청 또는 처리가 된 주문입니다.”인지 확인한다.
4. DB에서 동일 주문의 refund_status가 REQUESTED로 유지되는지 조회한다.

### 기대 결과
- API 응답:  "message": "이미 환불 요청 또는 처리가 된 주문입니다."
- DB 상태: refund_status: requested

### 실제 결과

- API 응답:
  - HTTP 200
  - "이미 환불 요청 또는 처리가 된 주문입니다."

- DB 상태:
  - refund_status: REQUESTED 유지

### 판정

PASS
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
- HTTP 200
- API 메시지: 환불 요청이 완료되었습니다.
- API refund_status: REQUESTED
- DB refund_status: NULL → REQUESTED

### 실제 결과
- HTTP 200
- API 메시지 및 refund_status 기대 결과 일치
- DB refund_status: NULL → REQUESTED

### 판정
PASS

## RF-02. 동일 주문 재요청 확인

### 사전조건
- 주문번호: ORD-API-001
- 주문 상태: CANCELLED
- 결제 상태: PAID
- 환불 상태: REQUESTED

### 테스트 절차
1. DB에서 refund_status가 REQUESTED인지 확인한다.
2. 동일 주문에 대해 환불 요청 API를 다시 호출한다.
3. API 응답 메시지를 확인한다.
4. DB에서 refund_status가 유지되는지 확인한다.

### 기대 결과
- HTTP 200
- API 메시지: 이미 환불 요청 또는 처리가 된 주문입니다.
- DB refund_status: REQUESTED 유지

### 실제 결과
- HTTP 200
- API 메시지 기대 결과 일치
- DB refund_status: REQUESTED 유지

### 판정
PASS

## RF-03. 존재하지 않는 주문의 환불 요청

### 사전조건
- 주문번호: ORD-999
- orders 테이블에 해당 주문 없음

### 테스트 절차
1. DB에서 해당 주문의 존재 여부를 확인한다.
2. POST /orders/ORD-999/refund-request 요청을 전송한다.
3. API 응답을 확인한다.
4. DB에서 해당 주문의 존재 여부를 재확인한다.

### 기대 결과
- HTTP 200
- API 메시지: 주문을 찾을 수 없습니다.
- DB 조회 결과: 0행 유지

### 실제 결과
- HTTP 200
- API 메시지 기대 결과 일치
- 요청 전후 해당 주문 조회 결과 0행

### 판정
PASS

## RF-04. 취소되지 않은 주문의 환불 요청

### 사전조건
- 주문번호: ORD-003
- 주문 상태: PAID
- 결제 상태: PAID
- 환불 상태: NULL

### 테스트 절차
1. DB에서 주문, 결제, 환불 상태를 확인한다.
2. POST /orders/ORD-003/refund-request 요청을 전송한다.
3. API 응답을 확인한다.
4. 요청 전후 DB 상태를 비교한다.

### 기대 결과
- HTTP 200
- API 메시지: 취소 완료 주문만 환불 요청할 수 있습니다.
- 기존 DB 상태 유지

### 실제 결과
- API 응답 기대 결과 일치
- order_status: PAID 유지
- payment_status: PAID 유지
- refund_status: NULL 유지

### 판정
PASS

## RF-05. 결제 상태 조건을 충족하지 않는 주문의 환불 요청

### 사전조건
- 주문번호: ORD-001
- 주문 상태: CANCELLED
- orders.payment_status: REFUNDED
- payments.payment_status: REFUNDED
- 환불 상태: COMPLETED

### 테스트 절차
1. INNER JOIN으로 두 테이블의 결제 상태를 확인한다.
2. POST /orders/ORD-001/refund-request 요청을 전송한다.
3. API 응답을 확인한다.
4. 요청 전후 DB 상태를 비교한다.

### 기대 결과
- HTTP 200
- API 메시지: 결제 완료 상태가 아니므로 환불 요청할 수 없습니다.
- 기존 DB 상태 유지

### 실제 결과
- API 응답 기대 결과 일치
- 두 테이블의 payment_status: REFUNDED 유지
- refund_status: COMPLETED 유지

### 판정
PASS

### 참고 사항
해당 주문은 결제 상태와 환불 상태 모두 환불 요청 조건을 충족하지 않는다.
현재 코드에서는 결제 상태 조건을 먼저 판단하므로 결제 상태 관련 메시지가 반환된다.

## RF-06. 연결된 결제 데이터가 없는 주문의 환불 요청

### 사전조건
- 주문번호: ORD-TEST-005
- 주문 상태: CANCELLED
- orders.payment_status: PAID
- 환불 상태: NULL
- payments 테이블에 연결된 결제 데이터 없음

### 테스트 절차
1. LEFT JOIN으로 주문 존재 여부와 결제 데이터 누락 여부를 확인한다.
2. POST /orders/ORD-TEST-005/refund-request 요청을 전송한다.
3. API 응답을 확인한다.
4. LEFT JOIN으로 요청 전후 DB 상태를 비교한다.

### 기대 결과 (현재 구현 기준)
- HTTP 200
- API 메시지: 주문을 찾을 수 없습니다.
- 기존 주문 상태 유지
- 연결된 결제 데이터 없음

### 실제 결과
- HTTP 200
- API 메시지 기대 결과 일치
- order_status: CANCELLED 유지
- orders.payment_status: PAID 유지
- 연결된 결제 데이터 없음
- refund_status: NULL 유지

### 판정
PASS (현재 구현 기준)

### 관찰 사항
orders 테이블에는 주문이 존재하지만 payments 테이블에 연결된 결제 데이터가 없어 백엔드의 INNER JOIN 조회 결과가 반환되지 않는다.

fetchone()의 결과가 None이므로 주문을 찾을 수 없다는 메시지가 반환된다.

주문 자체가 없는 경우와 결제 데이터가 없는 경우에 동일한 메시지가 반환되는 것을 확인했다.

메시지의 적절성은 별도 정책이 정의되지 않아 결함으로 확정하지 않았다.

## DB 연결 관리 코드 개선

### 개선 전
환불 요청 조건을 충족하지 않아 중간에 return이 실행되는 경우, 함수 마지막의 conn.close()가 실행되지 않는 구조였다.

### 개선 내용
try-finally를 적용하여 DB 연결 성공 이후 정상 처리, 조건 불충족에 따른 반환 및 예외 발생 시에도 DB 연결 종료 코드가 실행되도록 수정했다.

기존 SELECT, UPDATE, 조건 판단 및 반환 메시지는 변경하지 않았다.

### 개선 후 검증
- python3 -m py_compile refund_service.py 실행: 문법 오류 없음
- RF-01~06 회귀 테스트 수행
- 기존 API 응답 및 DB 상태 변경·유지 결과 확인

### 회귀 테스트 결과 (2026-11-26)

| ID | 검증 조건 | 결과 |
|---|---|---|
| RF-01 | 정상 환불 요청 | PASS |
| RF-02 | 중복 환불 요청 | PASS |
| RF-03 | 존재하지 않는 주문 | PASS |
| RF-04 | 취소되지 않은 주문 | PASS |
| RF-05 | 결제 상태 조건 불충족 | PASS |
| RF-06 | 연결된 결제 데이터 없음 | PASS (현재 구현 기준) |

DB 연결 종료 여부를 직접 측정한 것은 아니며,
코드 구조 검토 및 기존 기능에 대한 회귀 테스트를 수행했다.
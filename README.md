# Refund API DB Validation Practice

Flask와 SQLite를 사용하여 환불 요청 API의 응답과 실제 DB 상태 변경 및 유지 여부를 함께 검증하는 개인 학습 프로젝트입니다.

## What I tested

- 정상 환불 요청 시 API 응답과 DB 환불 상태 변경 확인
- 동일 주문 재요청 시 중복 요청 제한 및 기존 상태 유지 확인
- 주문·결제·환불 상태 조건에 따른 예외 처리 검증
- INNER JOIN, LEFT JOIN을 활용한 주문·결제 데이터 비교 및 연관 데이터 누락 확인
- DB 연결 관리 코드 개선 후 기존 기능 회귀 테스트

## Test Scenarios

| ID | 검증 조건 | DB 검증 항목 | 결과 |
|---|---|---|---|
| RF-01 | 정상 환불 요청 | NULL → REQUESTED | PASS |
| RF-02 | 중복 환불 요청 | REQUESTED 유지 | PASS |
| RF-03 | 존재하지 않는 주문 | 해당 주문 미생성 | PASS |
| RF-04 | 취소되지 않은 주문 | 기존 상태 유지 | PASS |
| RF-05 | 결제 상태 조건 불충족 | 기존 상태 유지 | PASS |
| RF-06 | 연결된 결제 데이터 없음 | 기존 주문 상태 유지 | PASS (현재 구현 기준) |

## Key Findings

- API 응답과 실제 DB 상태를 함께 확인하여 요청 처리 결과를 검증했다.
- INNER JOIN과 LEFT JOIN의 조회 결과 차이를 통해 연결된 결제 데이터가 없는 주문을 확인했다.
- 주문은 존재하지만 결제 데이터가 없는 경우, 현재 백엔드의 INNER JOIN 조회 방식으로 인해 주문을 찾을 수 없다는 메시지가 반환되는 것을 확인했다.
- try-finally를 적용하여 DB 연결 종료 코드를 개선하고, 기존 6개 테스트 케이스에 대한 회귀 테스트를 수행했다.

## Project Structure

| 파일 | 역할 |
|---|---|
| `01_setup.sql` | 주문·결제 테이블 생성 및 테스트 데이터 설정 |
| `02_order_cancellation_validation.sql` | 주문 취소 관련 데이터 검증 |
| `03_select_practice.sql` | SQL 조회 연습 |
| `refund_api.py` | Flask 기반 환불 요청 API |
| `refund_service.py` | 주문·결제 상태 조회 및 환불 요청 처리 로직 |
| `docs/refund-state-transition.md` | 테스트 케이스 및 검증 결과 기록 |

## How to Run

### 1. Flask 설치

```bash
python3 -m pip install flask
```

### 2. 테스트 DB 초기화

```bash
sqlite3 commerce1_qa.db < 01_setup.sql
```

기존 학습용 테이블을 삭제하고 초기 테스트 데이터를 생성합니다.
초기화 시 기존 테스트 결과 데이터는 삭제됩니다.

### 3. Flask 서버 실행

```bash
python3 refund_api.py
```

### 4. API 요청 전 DB 상태 확인

별도의 터미널에서 SQLite에 접속합니다.

```bash
sqlite3 commerce1_qa.db
```

```sql
SELECT order_no, order_status, payment_status, refund_status
FROM orders
WHERE order_no = 'ORD-API-001';
```

초기 refund_status가 NULL인지 확인합니다.

### 5. Postman에서 API 요청

- Method: POST
- URL: `http://127.0.0.1:5000/orders/ORD-API-001/refund-request`
- Request Body: 없음 (주문번호는 URL의 Path Parameter로 전달)

### 6. API 요청 후 DB 상태 확인

```sql
SELECT order_no, order_status, payment_status, refund_status
FROM orders
WHERE order_no = 'ORD-API-001';
```

API 응답과 DB 조회 결과를 비교하여 refund_status가 NULL에서 REQUESTED로 변경되었는지 확인합니다.

## Test Document

- [환불 상태 전이 및 예외 조건 검증 기록](docs/refund-state-transition.md)

상세 테스트 절차, 기대 결과, 실제 결과, 관찰 사항 및 회귀 테스트 결과를 확인할 수 있습니다.
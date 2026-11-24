# Refund API DB Validation Practice

Flask와 SQLite를 사용해 환불 요청 API를 호출하고, API 응답과 주문의 환불 상태가 함께 맞게 변경되는지 확인하는 개인 학습 프로젝트입니다.

## What I tested

- 정상 환불 요청 시 API 응답을 확인했다.
- 요청 전후 `orders.refund_status` 값을 SQL로 조회했다.
- 동일 주문을 다시 요청했을 때, 중복 요청 안내 메시지가 반환되고 DB 상태가 `REQUESTED`로 유지되는지 확인했다.

## Test document

- [환불 상태 전이 검증 기록](docs/refund-state-transition.md)
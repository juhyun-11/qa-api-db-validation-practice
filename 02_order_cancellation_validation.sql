.headers on
.mode column

-- 1. 특정 주문이 취소 처리됐는지 확인
SELECT order_no, order_status, payment_status, refund_status, cancelled_at
FROM orders
WHERE order_no = 'ORD-001';


-- 2. 주문은 취소됐는데 결제 상태가 아직 PAID인 건 찾기
-- QA 확인 목적:
-- 취소 화면 노출과 실제 결제/환불 처리 상태가 불일치하는 건이 있는지 확인
SELECT order_no, order_status, payment_status, refund_status, cancelled_at
FROM orders
WHERE order_status = 'CANCELLED'
  AND payment_status = 'PAID';


-- 3. 취소 주문인데 환불 상태가 없는 건 찾기
SELECT order_no, order_status, payment_status, refund_status
FROM orders
WHERE order_status = 'CANCELLED'
  AND refund_status IS NULL;

-- 4. 취소 후 결제 또는 환불 처리가 비정상으로 보이는 주문을 한 번에 찾기
SELECT order_no, order_status, payment_status, refund_status
FROM orders
WHERE order_status = 'CANCELLED'
  AND (
      payment_status = 'PAID'
      OR refund_status IS NULL
  );
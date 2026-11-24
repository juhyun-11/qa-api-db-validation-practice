.headers on
.mode column

-- orders 테이블의 모든 컬럼과 모든 주문을 조회
SELECT *
FROM orders;

SELECT order_no, member_id, order_status
FROM orders
WHERE member_id = 101;

SELECT order_no, member_id, order_status, payment_status
FROM orders
WHERE member_id = 101 AND payment_status = 'REFUNDED';

SELECT order_no, member_id, order_status, payment_status, refund_status
FROM orders
WHERE order_status = 'CANCELLED' AND (payment_status = 'PAID' 
                                             OR refund_status = 'REQUESTED');

-- 취소 주문 중 환불 상태가 아직 생성되지 않은 주문 조회
SELECT order_no, member_id, order_status, payment_status, refund_status
FROM orders
WHERE order_status = 'CANCELLED'
  AND refund_status IS NULL;
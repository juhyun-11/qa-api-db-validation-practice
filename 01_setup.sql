-- 기존 학습용 테이블이 있으면 삭제 (자식 테이블 먼저)
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS orders;

-- 주문 상태를 저장할 테이블 생성
CREATE TABLE orders (
    order_no TEXT PRIMARY KEY,
    member_id INTEGER,
    order_status TEXT,
    payment_status TEXT,
    refund_status TEXT,
    cancelled_at TEXT
);

-- 학습용 주문 데이터 삽입
INSERT INTO orders (
    order_no,
    member_id,
    order_status,
    payment_status,
    refund_status,
    cancelled_at
)
VALUES
    ('ORD-001', 101, 'CANCELLED', 'REFUNDED', 'COMPLETED', '2026-10-30 14:00:00'),
    ('ORD-002', 101, 'CANCELLED', 'PAID', NULL, '2026-10-30 14:10:00'),
    ('ORD-003', 102, 'PAID', 'PAID', NULL, NULL),
    ('ORD-004', 103, 'CANCELLED', 'REFUNDED', 'REQUESTED', '2026-10-30 14:20:00');

CREATE TABLE payments (
    payment_no TEXT PRIMARY KEY,
    order_no TEXT NOT NULL,
    payment_status TEXT NOT NULL,
    paid_at TEXT,
    refunded_at TEXT,
    FOREIGN KEY (order_no) REFERENCES orders(order_no)
);

INSERT INTO payments (
    payment_no,
    order_no,
    payment_status,
    paid_at,
    refunded_at
)
VALUES
    ('PAY-001', 'ORD-001', 'REFUNDED', '2026-10-30 13:50:00', '2026-10-30 14:00:00'),
    ('PAY-002', 'ORD-002', 'PAID',     '2026-10-30 13:55:00', NULL),
    ('PAY-003', 'ORD-003', 'PAID',     '2026-10-30 14:30:00', NULL),
    ('PAY-004', 'ORD-004', 'PAID',     '2026-10-30 13:40:00', NULL);

SELECT *
FROM payments;

-- 환불 요청 API 상태 전이 검증용 테스트 데이터
INSERT INTO orders (
    order_no,
    member_id,
    order_status,
    payment_status,
    refund_status,
    cancelled_at
)
VALUES (
    'ORD-API-001',
    201,
    'CANCELLED',
    'PAID',
    NULL,
    '2026-11-24 13:00:00'
);

INSERT INTO payments (
    payment_no,
    order_no,
    payment_status,
    paid_at,
    refunded_at
)
VALUES (
    'PAY-API-001',
    'ORD-API-001',
    'PAID',
    '2026-11-24 12:50:00',
    NULL
);
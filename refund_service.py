import sqlite3
from pathlib import Path

DB_PATH = str(Path(__file__).resolve().parent / "commerce1_qa.db")


def request_refund(order_no):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    order = cursor.execute(
        """
        SELECT
            o.order_no,
            o.order_status,
            o.refund_status,
            p.payment_status
        FROM orders o
        INNER JOIN payments p
            ON o.order_no = p.order_no
        WHERE o.order_no = ?
        """,
        (order_no,)
    ).fetchone()

    if order is None:
        return {"message": "주문을 찾을 수 없습니다."}

    order_no, order_status, refund_status, payment_status = order

    if order_status != "CANCELLED":
        return {"message": "취소 완료 주문만 환불 요청할 수 있습니다."}

    if payment_status != "PAID":
        return {"message": "결제 완료 상태가 아니므로 환불 요청할 수 없습니다."}

    if refund_status is not None:
        return {"message": "이미 환불 요청 또는 처리가 된 주문입니다."}

    cursor.execute(
        """
        UPDATE orders
        SET refund_status = 'REQUESTED'
        WHERE order_no = ?
        """,
        (order_no,)
    )
    conn.commit()
    conn.close()

    return {
        "order_no": order_no,
        "refund_status": "REQUESTED",
        "message": "환불 요청이 완료되었습니다."
    }


if __name__ == "__main__":
    result = request_refund("ORD-002")
    print(result)
# Accounting Flow (Simple) — COD vs Online + Pickup + Partners

## Main Diagram
```mermaid
flowchart TB
    START([Start]) --> CREATE["1) Create and submit Sales Invoice | Also creates GL Entry | If update_stock=1 then creates Stock Ledger Entry"]

    CREATE --> TYPE{"2) Order type?"}
    TYPE --> COD["A) Delivery - COD (not paid yet)"]
    TYPE --> ONLINE["B) Delivery - Online payment (already paid)"]
    TYPE --> PICKUP["C) Pickup"]
    TYPE --> PARTNER["D) Sales Partner"]

    COD --> COD1["3) Move to Out for Delivery"]
    COD1 --> CODMODE{"4) Out for Delivery mode"}
    CODMODE --> CODNOW["now"]
    CODMODE --> CODLATER["later"]
    CODNOW --> CODN1["5) Same time: create Payment Entry (to cash) | create Journal Entry (shipping expense and cash) | create Courier Transaction (Settled) | create and submit Delivery Note"]
    CODLATER --> CODL1["5) Same time: create Payment Entry (to courier outstanding) | create Journal Entry (shipping expense and creditors) | create Courier Transaction (Unsettled) | create and submit Delivery Note"]
    CODN1 --> CODDONE["6) Final state: Delivered"]
    CODL1 --> CODL2["6) Later settlement Journal Entry (settle_courier_collected_payment): Case A DR Cash + DR Creditors and CR Courier Outstanding | Case B DR Creditors and CR Courier Outstanding + CR Cash"]
    CODL2 --> CODDONE["7) Final state: Delivered"]

    ONLINE --> ON1["3) Online Payment Entry already exists from payment step"]
    ON1 --> ON2["4) Move to Out for Delivery"]
    ON2 --> ONMODE{"5) Out for Delivery mode"}
    ONMODE --> ONNOW["now"]
    ONMODE --> ONLATER["later"]
    ONNOW --> ONN1["6) Same time: create Journal Entry (shipping expense and cash) | create Courier Transaction (Settled) | create and submit Delivery Note"]
    ONLATER --> ONL1["6) Same time: create Journal Entry (shipping expense and creditors) | create Courier Transaction (Unsettled) | create and submit Delivery Note"]
    ONN1 --> ONDONE["7) Final state: Delivered"]
    ONL1 --> ONL2["7) Later settlement Journal Entry (settle_single_invoice_paid): DR Creditors and CR Cash (shipping-only mode) | outstanding mode uses DR Cash + DR Creditors and CR Courier Outstanding"]
    ONL2 --> ONDONE["8) Final state: Delivered"]

    PICKUP --> P1["3) Move directly to Delivered | No Delivery Note | No Courier Transaction | No Journal Entry for shipping"]

    PARTNER --> SP1["3) Move to Out for Delivery"]
    SP1 --> SP2["4) Same time: create Payment Entry to branch cash | create Sales Partner Transactions (Unsettled) | no Courier Transaction | no shipping Journal Entry"]
    SP2 --> SP3["5) Create and submit Delivery Note"]
    SP3 --> SP4["6) Settlement step: settle Sales Partner Transactions in partner settlement flow"]
    SP4 --> SP5["7) Final state: Delivered"]
```

## Written Summary

### A) Delivery - COD
1. Invoice is created (customer still owes money).
2. At Out for Delivery, choose mode:
    - now: immediate settlement path.
    - later: deferred settlement path.
3. COD now path creates together:
    - Payment Entry (to cash).
    - Journal Entry (shipping expense and cash).
    - Courier Transaction (Settled).
    - Delivery Note.
4. COD later path creates together:
    - Payment Entry (to courier outstanding).
    - Journal Entry (shipping expense and creditors).
    - Courier Transaction (Unsettled).
    - Delivery Note.
5. Settlement step exists only in later branch: `settle_courier_collected_payment` creates a settlement Journal Entry with these account outputs:
    - Case A: DR Cash + DR Creditors and CR Courier Outstanding.
    - Case B: DR Creditors and CR Courier Outstanding + CR Cash.
   Then Courier Transaction becomes Settled.

### B) Delivery - Online Payment
1. Invoice is already paid at order time.
2. At Out for Delivery, choose mode:
    - now: immediate settlement path.
    - later: deferred settlement path.
3. Online now path creates together:
    - Journal Entry (shipping expense and cash).
    - Courier Transaction (Settled).
    - Delivery Note.
4. Online later path creates together:
    - Journal Entry (shipping expense and creditors).
    - Courier Transaction (Unsettled).
    - Delivery Note.
5. Settlement step exists only in later branch: `settle_single_invoice_paid` creates a settlement Journal Entry with these account outputs:
    - Shipping-only mode: DR Creditors and CR Cash.
    - Outstanding mode: DR Cash + DR Creditors and CR Courier Outstanding.
   Then Courier Transaction becomes Settled.

### C) Pickup
1. Order goes directly to Delivered.
2. No courier transaction, no shipping journal, and no delivery note in pickup path.

### D) Sales Partner
1. On Out for Delivery, system creates together:
    - Payment entry to branch cash.
    - Sales partner transaction (Unsettled).
2. No courier transaction and no shipping journal in this path.
3. Delivery note is created.
4. Settlement step is handled in the sales partner settlement flow.
5. Then order is Delivered.

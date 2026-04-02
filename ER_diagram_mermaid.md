# Bank Database ER Diagram (Mermaid Compatible)

```mermaid
erDiagram
    CUSTOMERS {
        BIGINT customer_id PK
        TEXT first_name
        TEXT middle_name
        TEXT last_name
        VARCHAR email UK
        DATE date_of_birth
        TIMESTAMPTZ created_at
    }

    CUSTOMER_PHONE {
        BIGINT customer_id FK
        VARCHAR phone_no
    }

    ACCOUNTS {
        BIGINT account_id PK
        VARCHAR account_number UK
        BIGINT customer_id FK
        VARCHAR account_type
        VARCHAR status
        NUMERIC balance
        TIMESTAMPTZ opened_at
    }

    BRANCHES {
        BIGINT branch_id PK
        VARCHAR branch_code UK
        VARCHAR branch_name
        VARCHAR location
        TIMESTAMPTZ created_at
    }

    ACCOUNT_BRANCHES {
        BIGINT account_id PK, FK
        BIGINT branch_id PK, FK
        TIMESTAMPTZ assigned_at
    }

    LOANS {
        BIGINT loan_id PK
        BIGINT customer_id FK
        VARCHAR loan_type
        NUMERIC principal_amount
        NUMERIC interest_rate
        VARCHAR status
        DATE issued_date
        DATE due_date
        TIMESTAMPTZ created_at
    }

    LOAN_PAYMENTS {
        BIGINT loan_id PK, FK
        INT payment_no PK
        NUMERIC amount_paid
        TIMESTAMPTZ payment_date
    }

    TRANSFERS {
        BIGINT transfer_id PK
        BIGINT from_account_id FK
        BIGINT to_account_id FK
        NUMERIC amount
        TIMESTAMPTZ transfer_date
        TEXT reference_note
    }

    TRANSACTIONS {
        BIGINT transaction_id PK
        BIGINT account_id FK
        VARCHAR transaction_type
        NUMERIC amount
        TIMESTAMPTZ transaction_date
        TEXT description
        BIGINT transfer_id FK
    }

    CUSTOMERS ||--|{ ACCOUNTS : "owns (1,N)-(1,1)"
    CUSTOMERS ||--o{ LOANS : "borrows (0,N)-(1,1)"
    CUSTOMERS ||--o{ CUSTOMER_PHONE : "has phone numbers (0,N)"

    ACCOUNTS ||--o{ TRANSACTIONS : "records (0,N)-(1,1)"
    ACCOUNTS ||--|{ ACCOUNT_BRANCHES : "mapped in junction"
    BRANCHES ||--|{ ACCOUNT_BRANCHES : "mapped in junction"

    ACCOUNTS ||--o{ TRANSFERS : "sends (0,N)"
    ACCOUNTS ||--o{ TRANSFERS : "receives (0,N)"

    TRANSFERS ||--o{ TRANSACTIONS : "reflected by transfer txns (1,N)-(0,1)"
    LOANS ||--|{ LOAN_PAYMENTS : "has payments (weak-style key: loan_id + payment_no)"
```

## Notes

- This file is fully Mermaid-compatible for Markdown preview.
- Mermaid `erDiagram` does not support full Chen symbols (double oval, double rectangle, dashed underline) directly.
- `LOAN_PAYMENTS` is modeled with composite key `(loan_id, payment_no)` to reflect weak-entity behavior logically.

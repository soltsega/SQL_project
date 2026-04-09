# Bank Database ER Diagram

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

    CUSTOMERS ||--|{ ACCOUNTS : owns
    CUSTOMERS ||--o{ LOANS : borrows
    CUSTOMERS ||--o{ CUSTOMER_PHONE : has

    ACCOUNTS ||--o{ TRANSACTIONS : records
    ACCOUNTS ||--|{ ACCOUNT_BRANCHES : assigned_to
    BRANCHES ||--|{ ACCOUNT_BRANCHES : contains

    ACCOUNTS ||--o{ TRANSFERS : sends
    ACCOUNTS ||--o{ TRANSFERS : receives

    TRANSFERS ||--o{ TRANSACTIONS : links_to
    LOANS ||--|{ LOAN_PAYMENTS : paid_by
```

## Notes

- Mermaid keeps this version lightweight for Markdown preview.
- Use `ER_diagram_chen.svg` or `ER_diagram_chen_strict.svg` when you need full Chen/EER notation.
- `LOAN_PAYMENTS` uses the composite key `(loan_id, payment_no)` to represent weak-entity behavior.

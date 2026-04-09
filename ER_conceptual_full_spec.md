# Bank Database Conceptual ERD (Full Chen/EER Specification)

Use this as the source of truth to draw the final ER diagram with full conventional symbols.

## 1) Required Notation and How To Draw It

- Strong entity: single rectangle
- Weak entity: double rectangle
- Relationship: single diamond
- Weak (identifying) relationship: double diamond
- Key attribute: underlined oval label
- Partial key (for weak entity): dashed underline oval label
- Single-valued attribute: single oval
- Multivalued attribute: double oval
- Derived attribute: dashed oval
- Composite attribute: parent oval connected to component ovals
- Participation:
- total participation: double line between entity and relationship
- partial participation: single line
- Cardinality ratio + min-max: show `1:1`, `1:N`, `M:N` and also side labels `(min,max)`

## 2) Entities and Attributes

### CUSTOMER (strong)

- `customer_id` (key)
- `name` (composite): `first_name`, `middle_name`, `last_name`
- `address` (composite): `street`, `city`, `state`, `postal_code`
- `email` (single-valued)
- `phone_no` (multivalued)
- `date_of_birth` (single-valued)
- `age` (derived from `date_of_birth`)
- `created_at` (single-valued)

### ACCOUNT (strong)

- `account_id` (key)
- `account_number` (candidate key)
- `account_type`
- `status`
- `balance`
- `opened_at`

### BRANCH (strong)

- `branch_id` (key)
- `branch_code` (candidate key)
- `branch_name`
- `location`

### LOAN (strong)

- `loan_id` (key)
- `loan_type`
- `principal_amount`
- `interest_rate`
- `status`
- `issued_date`
- `due_date`

### TRANSFER (strong)

- `transfer_id` (key)
- `amount`
- `transfer_date`
- `reference_note`

### TRANSACTION (strong)

- `transaction_id` (key)
- `transaction_type`
- `amount`
- `transaction_date`
- `description`

### LOAN_PAYMENT (weak entity)

- `payment_no` (partial key)
- `payment_date`
- `amount_paid`

Owner entity: `LOAN`

Identifying key at logical level: (`loan_id`, `payment_no`)

## 3) Relationships With Cardinality Ratio and Min-Max

### OWNS (CUSTOMER - ACCOUNT)

- ratio: `1:N`
- CUSTOMER side min-max: `(1,N)` (a customer owns one or many accounts)
- ACCOUNT side min-max: `(1,1)` (an account belongs to exactly one customer)
- participation:
- ACCOUNT total in OWNS
- CUSTOMER total in OWNS for this project assumption

### LINKED_AT (ACCOUNT - BRANCH)

- ratio: `M:N`
- ACCOUNT side min-max: `(0,N)` (an account may belong to zero or many branches)
- BRANCH side min-max: `(0,N)` (a branch may manage zero or many accounts)
- participation:
- optional on both sides unless branch-assignment is mandatory in policy
- implemented using the junction entity `ACCOUNT_BRANCHES`

### BORROWS (CUSTOMER - LOAN)

- ratio: `1:N`
- CUSTOMER side min-max: `(0,N)` (a customer may have no loans or many loans)
- LOAN side min-max: `(1,1)` (each loan must belong to one customer)
- participation:
- LOAN total in BORROWS
- CUSTOMER partial in BORROWS

### RECORDS (ACCOUNT - TRANSACTION)

- ratio: `1:N`
- ACCOUNT side min-max: `(0,N)` (an account may have no transactions yet)
- TRANSACTION side min-max: `(1,1)` (each transaction must belong to one account)
- participation:
- TRANSACTION total in RECORDS
- ACCOUNT partial in RECORDS

### SENDS (ACCOUNT - TRANSFER)

- ratio: `1:N`
- ACCOUNT side min-max: `(0,N)` (an account may send zero or many transfers)
- TRANSFER side min-max: `(1,1)` for the sender role
- participation:
- TRANSFER total in SENDS

### RECEIVES (ACCOUNT - TRANSFER)

- ratio: `1:N`
- ACCOUNT side min-max: `(0,N)` (an account may receive zero or many transfers)
- TRANSFER side min-max: `(1,1)` for the receiver role
- participation:
- TRANSFER total in RECEIVES

### REFLECTS (TRANSFER - TRANSACTION)

- ratio: `1:N` (one transfer typically maps to one or more transaction rows)
- TRANSFER side min-max: `(1,N)`
- TRANSACTION side min-max: `(0,1)` (only transfer-related transactions link to a transfer)
- participation:
- TRANSACTION partial in REFLECTS

### HAS_PAYMENT (LOAN - LOAN_PAYMENT) [Identifying / weak relationship]

- ratio: `1:N`
- LOAN side min-max: `(1,N)`
- LOAN_PAYMENT side min-max: `(1,1)`
- relationship type: weak (double diamond)
- participation:
- LOAN_PAYMENT total participation in HAS_PAYMENT

## 4) What Must Appear Visually In Final Diagram

- Double rectangle around `LOAN_PAYMENT`
- Double diamond for `HAS_PAYMENT`
- Dashed underline for the partial key attribute `payment_no`
- Double oval for the multivalued attribute `phone_no`
- Composite ovals for `name` and `address` with their component attributes
- Dashed oval for the derived attribute `age`
- Underlined key attributes for all strong entities
- Min-max labels on both ends of every relationship line
- Explicit `1:N` / `M:N` notation near relationship diamonds
- Double lines for total participation and single lines for partial participation

## 5) How This Model Meets Phase One Requirements

- The conceptual model includes all required entities, attributes, and relationships.
- Primary keys and foreign keys are identified for every table.
- Composite, multivalued, weak, and derived attributes are documented.
- Relationship cardinality and participation are defined using Crow's Foot and min-max conventions.
- The final diagram file uses Chen/EER notation and can be exported to PDF for submission.



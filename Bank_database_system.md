Bank Database System — Final Project Description

Project Title
Bank Database System

Overview
The Bank Database System is a relational database project that simulates a real-world banking environment. It models customer relationships, account management, transactions, transfers, branch assignments, loans, and loan payments while enforcing strong data integrity and realistic business rules.

Narrative Analysis
This document describes the entities, attributes, and relationships used to design the bank database project.

Entities and rationale:
- Customer: Individuals who own accounts, apply for loans, and maintain contact details.
- Account: Bank accounts with defined balances, types, statuses, and ownership.
- Transaction: Records account activities including deposits, withdrawals, and transfer-related entries.
- Transfer: Represents money movement between accounts using sender and receiver roles.
- Branch: Physical bank locations that may manage multiple accounts.
- Loan: Credit agreements issued to customers.
- Loan_Payment: A weak entity that tracks individual installments for a loan.

Relationship logic:
- A customer may own one or many accounts; each account belongs to exactly one customer.
- An account may record zero or many transactions; each transaction belongs to one account.
- A customer may have zero or many loans; each loan is issued to one customer.
- An account may be linked to multiple branches and a branch may manage multiple accounts.
- A transfer connects a source account and a destination account, enforcing distinct account IDs.
- Loan payments are uniquely identified by the composite key (`loan_id`, `payment_no`).

Final Set of Tables
1. Customer
   - customer_id (PK)
   - first_name, middle_name, last_name
   - email
   - street, city, state, postal_code
   - date_of_birth
   - created_at
2. Customer_Phone
   - customer_id (FK)
   - phone_no (multivalued)
3. Account
   - account_id (PK)
   - account_number (UK)
   - customer_id (FK)
   - account_type
   - status
   - balance
   - opened_at
4. Branch
   - branch_id (PK)
   - branch_name
   - branch_code (UK)
   - location
   - created_at
5. Account_Branch
   - account_id (FK)
   - branch_id (FK)
   - assigned_at
6. Transaction
   - transaction_id (PK)
   - account_id (FK)
   - transaction_type
   - amount
   - transaction_date
   - description
   - transfer_id (FK)
7. Transfer
   - transfer_id (PK)
   - from_account_id (FK)
   - to_account_id (FK)
   - amount
   - transfer_date
   - reference_note
8. Loan
   - loan_id (PK)
   - customer_id (FK)
   - loan_type
   - principal_amount
   - interest_rate
   - status
   - issued_date
   - due_date
   - created_at
9. Loan_Payment
   - loan_id (FK)
   - payment_no (partial key)
   - amount_paid
   - payment_date

Key Relationships with Min–Max
- Customer → Account : (1,N) : (1,1)
- Account → Transaction : (0,N) : (1,1)
- Customer → Loan : (0,N) : (1,1)
- Account ↔ Branch : (0,N) : (0,N)
- Account → Transfer (sender) : (0,N) : (1,1)
- Account → Transfer (receiver) : (0,N) : (1,1)
- Loan → Loan_Payment : (1,N) : (1,1)

Business Rules & Constraints
- Account balances cannot fall below zero.
- Transaction and transfer amounts must be positive.
- Transfers must occur between two distinct accounts.
- Referential integrity is enforced across all foreign keys.
- Loan due dates must be valid relative to issue dates.
- Enum types ensure valid account, transaction, and loan states.

Analytical Capabilities
The design supports queries for:
- Identifying high-value customers by total balance.
- Analyzing monthly transaction trends.
- Evaluating branch account coverage.
- Summarizing loan status and payment history.
- Detecting inactive or anomalous accounts.
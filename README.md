# Bank Database System

This project is a PostgreSQL-based banking database design that models core banking operations such as customer management, accounts, transactions, transfers, branches, loans, and loan payments. It combines an executable SQL schema with ER design documents that explain the conceptual model and diagram choices.

## Project Overview

The database is designed to support:

- Customer records with composite name and address details
- Multiple phone numbers per customer
- Customer-owned bank accounts
- Account transactions including deposits, withdrawals, and transfers
- Branch-to-account associations through a junction table
- Customer loans and loan payment tracking
- Data integrity through foreign keys, checks, enums, and indexes

This makes the project useful for learning relational modeling, ER-to-relational mapping, and PostgreSQL schema design for a realistic business domain.

## Database Features

- PostgreSQL enum types for account, transaction, and loan states
- Strong referential integrity with foreign key constraints
- Business rules enforced with `CHECK` constraints
- Weak-entity-style modeling for `loan_payments`
- Junction table for the many-to-many relationship between accounts and branches
- Indexes added for common lookup and reporting paths

## Main Entities

- `customers`
- `customer_phone`
- `accounts`
- `branches`
- `account_branches`
- `transactions`
- `transfers`
- `loans`
- `loan_payments`

## Relationships

- One customer can own many accounts
- One customer can have zero or many loans
- One account can have many transactions
- Accounts and branches have a many-to-many relationship
- Transfers connect one source account to one destination account
- One loan can have many loan payments

## Project Structure

- `schema.sql`  
  PostgreSQL schema for creating the database objects, constraints, and indexes.

- `Bank_database_system.md`  
  High-level project description, modeling goals, and analytical use cases.

- `ER_conceptual_full_spec.md`  
  Full conceptual ER/EER specification using Chen-style notation guidance.

- `ER_diagram_mermaid.md`  
  Mermaid-compatible ER diagram version for Markdown preview.

- `ER_diagram_chen.svg`  
  Visual ER diagram asset.

- `ER_chen_style.md`  
  Supporting ER notation/design material.

## Requirements

- PostgreSQL
- A database named `bank_database` if you want to load the schema exactly as intended

## How To Run

1. Create the database:

```sql
CREATE DATABASE bank_database;
```

2. Run the schema file:

```powershell
psql -d bank_database -f schema.sql
```

If needed, you can also connect first and run:

```powershell
psql -d bank_database
```

Then inside `psql`:

```sql
\i schema.sql
```

## Schema Highlights

- `customers` stores personal and contact information
- `customer_phone` supports multiple phone numbers per customer
- `accounts` stores account ownership, type, status, and balance
- `transactions` records activity per account
- `transfers` models account-to-account fund movement
- `branches` stores bank branch information
- `account_branches` resolves the account/branch many-to-many relationship
- `loans` stores lending data including status and dates
- `loan_payments` uses a composite primary key to model repeated payments per loan

## Constraints and Business Rules

- Account balances cannot be negative
- Transfer amounts and transaction amounts must be positive
- Loan principal must be greater than zero
- Transfers must occur between different accounts
- Loan due dates cannot be earlier than issued dates
- Transfer-type transactions must reference a transfer record

## Design Notes

This project includes both logical and conceptual modeling artifacts:

- The SQL schema reflects the relational implementation in PostgreSQL
- The Mermaid ERD provides a lightweight diagram for documentation
- The conceptual ER specification documents classical Chen/EER details such as weak entities, multivalued attributes, and participation constraints

## Suggested Next Steps

- Add sample seed data
- Add reporting queries for analytics
- Add views or stored procedures for common banking operations
- Add triggers for more advanced balance validation workflows

## License

No license file is currently included in this repository.

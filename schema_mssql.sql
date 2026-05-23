-- Bank Database System schema
-- Target database name: bank_database
--
-- This script creates the core tables and indexes for a bank system.
-- It uses IF OBJECT_ID(...) IS NULL checks so it can be run safely without
-- recreating objects that already exist.

IF DB_ID('bank_database') IS NULL
BEGIN
    CREATE DATABASE bank_database;
END;
GO

USE bank_database;
GO

BEGIN TRANSACTION;

-- =========================
-- 1) Core entities
-- =========================
-- The following section creates the main tables required for the bank.
-- Each table has keys, constraints, and default values that help maintain
-- data integrity and business rules.

-- Create the customers table if it does not already exist.
IF OBJECT_ID('dbo.customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.customers (
        customer_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            -- customer_id: surrogate key, auto-increments for each new customer.
        first_name VARCHAR(100) NOT NULL,
            -- Customer first name; cannot be NULL.
        middle_name VARCHAR(100) NULL,
            -- Optional middle name.
        last_name VARCHAR(100) NOT NULL,
            -- Customer last name; cannot be NULL.
        email VARCHAR(255) NOT NULL UNIQUE,
            -- Email address must be unique across customers.
        street VARCHAR(255) NULL,
            -- Street address; optional.
        city VARCHAR(100) NULL,
            -- City name; optional.
        state VARCHAR(100) NULL,
            -- State or province; optional.
        postal_code VARCHAR(20) NULL,
            -- Postal code / ZIP code; optional.
        date_of_birth DATE NULL,
            -- Customer birthday; optional.
        created_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_customers_created_at DEFAULT SYSDATETIMEOFFSET()
            -- created_at defaults to current date and time with timezone.
    );
END;

-- The customer_phone table stores one or more phone numbers per customer.
-- This models a one-to-many relationship, where each customer may have many phones.
IF OBJECT_ID('dbo.customer_phone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.customer_phone (
        customer_id BIGINT NOT NULL,
            -- Foreign key to the customers table.
        phone_no VARCHAR(20) NOT NULL,
            -- Phone number value.
        CONSTRAINT PK_customer_phone PRIMARY KEY (customer_id, phone_no),
            -- Composite primary key prevents duplicate phone numbers for the same customer.
        CONSTRAINT FK_customer_phone_customer
            FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id)
            ON DELETE CASCADE
            -- If a customer is deleted, their phone records are deleted too.
    );
END;

-- Create branches table to represent physical bank branches or locations.
IF OBJECT_ID('dbo.branches', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.branches (
        branch_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            -- Branch identifier, auto-generated.
        branch_name VARCHAR(150) NOT NULL,
            -- User-friendly branch name.
        location VARCHAR(255) NULL,
            -- Optional detailed location.
        branch_code VARCHAR(30) NOT NULL UNIQUE,
            -- Unique code for each branch.
        created_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_branches_created_at DEFAULT SYSDATETIMEOFFSET()
            -- Automatically set creation timestamp.
    );
END;

-- Create accounts table to hold bank account details for customers.
IF OBJECT_ID('dbo.accounts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.accounts (
        account_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            -- Primary key for the account.
        account_number VARCHAR(34) NOT NULL UNIQUE,
            -- Unique account number.
        customer_id BIGINT NOT NULL,
            -- Link to the customer who owns the account.
        account_type VARCHAR(20) NOT NULL,
            -- Type of account (such as savings or current).
        status VARCHAR(20) NOT NULL
            CONSTRAINT DF_accounts_status DEFAULT 'active',
            -- Account status defaults to active.
        balance DECIMAL(14,2) NOT NULL
            CONSTRAINT DF_accounts_balance DEFAULT 0.00,
            -- Account balance defaults to 0.00 and cannot be negative.
        opened_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_accounts_opened_at DEFAULT SYSDATETIMEOFFSET(),
            -- Timestamp when the account was opened.
        CONSTRAINT FK_accounts_customer
            FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id)
            ON DELETE NO ACTION,
            -- Do not automatically delete accounts when a customer is removed.
        CONSTRAINT CK_accounts_account_type
            CHECK (account_type IN ('savings', 'current')),
            -- Only allow the defined account types.
        CONSTRAINT CK_accounts_status
            CHECK (status IN ('active', 'frozen', 'closed')),
            -- Only valid status values are permitted.
        CONSTRAINT CK_accounts_balance
            CHECK (balance >= 0)
            -- Prevent negative balances in this table.
    );
END;

-- account_branches links accounts to the branches where they are managed.
-- This is a many-to-many relationship table between accounts and branches.
IF OBJECT_ID('dbo.account_branches', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.account_branches (
        account_id BIGINT NOT NULL,
            -- Foreign key to the accounts table.
        branch_id BIGINT NOT NULL,
            -- Foreign key to the branches table.
        assigned_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_account_branches_assigned_at DEFAULT SYSDATETIMEOFFSET(),
            -- When the account was assigned to the branch.
        CONSTRAINT PK_account_branches PRIMARY KEY (account_id, branch_id),
            -- Composite key ensures each account-branch pairing is unique.
        CONSTRAINT FK_account_branches_account
            FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id)
            ON DELETE CASCADE,
            -- Deleting an account removes its branch assignment.
        CONSTRAINT FK_account_branches_branch
            FOREIGN KEY (branch_id) REFERENCES dbo.branches(branch_id)
            ON DELETE NO ACTION
            -- Do not delete branch assignment records when a branch is removed.
    );
END;

-- loans table holds loan records for customers.
IF OBJECT_ID('dbo.loans', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.loans (
        loan_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            -- Unique loan identifier.
        customer_id BIGINT NOT NULL,
            -- Customer who owns the loan.
        loan_type VARCHAR(20) NOT NULL,
            -- Type of loan (personal, business, mortgage, auto).
        principal_amount DECIMAL(14,2) NOT NULL,
            -- Original amount borrowed.
        interest_rate DECIMAL(5,2) NOT NULL,
            -- Annual interest rate.
        status VARCHAR(20) NOT NULL
            CONSTRAINT DF_loans_status DEFAULT 'pending',
            -- Loan status defaults to pending.
        issued_date DATE NULL,
            -- Date the loan was issued.
        due_date DATE NULL,
            -- Date the loan must be paid by.
        created_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_loans_created_at DEFAULT SYSDATETIMEOFFSET(),
            -- Time the loan record was created.
        CONSTRAINT FK_loans_customer
            FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id)
            ON DELETE NO ACTION,
            -- Preserve loan records even if customer row is removed.
        CONSTRAINT CK_loans_loan_type
            CHECK (loan_type IN ('personal', 'business', 'mortgage', 'auto')),
            -- Only allow defined loan types.
        CONSTRAINT CK_loans_principal_amount
            CHECK (principal_amount > 0),
            -- Principal must be greater than zero.
        CONSTRAINT CK_loans_interest_rate
            CHECK (interest_rate >= 0),
            -- Interest rate cannot be negative.
        CONSTRAINT CK_loans_status
            CHECK (status IN ('pending', 'approved', 'rejected', 'closed')),
            -- Only allow the defined status values.
        CONSTRAINT CK_loans_dates_valid
            CHECK (due_date IS NULL OR issued_date IS NULL OR due_date >= issued_date)
            -- Due date must come on or after the issue date, if both exist.
    );
END;

-- transfers table stores money transfer records between two accounts.
IF OBJECT_ID('dbo.transfers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.transfers (
        transfer_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            -- Unique transfer identifier.
        from_account_id BIGINT NOT NULL,
            -- Source account for the transfer.
        to_account_id BIGINT NOT NULL,
            -- Destination account for the transfer.
        amount DECIMAL(14,2) NOT NULL,
            -- Transfer amount must be positive.
        transfer_date DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_transfers_transfer_date DEFAULT SYSDATETIMEOFFSET(),
            -- Timestamp of the transfer.
        reference_note VARCHAR(MAX) NULL,
            -- Optional notes or comments about the transfer.
        CONSTRAINT FK_transfers_from_account
            FOREIGN KEY (from_account_id) REFERENCES dbo.accounts(account_id)
            ON DELETE NO ACTION,
            -- Do not delete transfers when the source account is deleted.
        CONSTRAINT FK_transfers_to_account
            FOREIGN KEY (to_account_id) REFERENCES dbo.accounts(account_id)
            ON DELETE NO ACTION,
            -- Do not delete transfers when the destination account is deleted.
        CONSTRAINT CK_transfers_amount
            CHECK (amount > 0),
            -- Transfer amount must be greater than zero.
        CONSTRAINT CK_transfers_accounts_different
            CHECK (from_account_id <> to_account_id)
            -- Prevent transfers from an account to itself.
    );
END;

-- transactions records all account activity, including deposits, withdrawals, and transfers.
IF OBJECT_ID('dbo.transactions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.transactions (
        transaction_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            -- Unique transaction record.
        account_id BIGINT NOT NULL,
            -- Account affected by the transaction.
        transaction_type VARCHAR(20) NOT NULL,
            -- Type of transaction: deposit, withdrawal, or transfer.
        amount DECIMAL(14,2) NOT NULL,
            -- Transaction amount; must be positive.
        transaction_date DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_transactions_transaction_date DEFAULT SYSDATETIMEOFFSET(),
            -- Timestamp when the transaction occurred.
        description VARCHAR(MAX) NULL,
            -- Optional text description.
        transfer_id BIGINT NULL,
            -- Optional reference to a transfer record for transfer transactions.
        CONSTRAINT FK_transactions_account
            FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id)
            ON DELETE NO ACTION,
            -- Keep transactions even if the account is removed.
        CONSTRAINT FK_transactions_transfer
            FOREIGN KEY (transfer_id) REFERENCES dbo.transfers(transfer_id)
            ON DELETE SET NULL,
            -- If the transfer is deleted, keep the transaction record but null the transfer link.
        CONSTRAINT CK_transactions_type
            CHECK (transaction_type IN ('deposit', 'withdrawal', 'transfer')),
            -- Only allow the defined transaction types.
        CONSTRAINT CK_transactions_amount
            CHECK (amount > 0),
            -- Amount must be positive.
        CONSTRAINT CK_transactions_transfer_link
            CHECK (
                (transaction_type = 'transfer' AND transfer_id IS NOT NULL)
                OR (transaction_type <> 'transfer')
            )
            -- Only transfer transactions are allowed to reference a transfer record.
    );
END;

-- loan_payments is a weak entity tied to loans, using a composite primary key.
IF OBJECT_ID('dbo.loan_payments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.loan_payments (
        loan_id BIGINT NOT NULL,
            -- Foreign key to the loans table.
        payment_no INT NOT NULL,
            -- Sequential payment number for this loan.
        amount_paid DECIMAL(14,2) NOT NULL,
            -- Amount paid in this payment.
        payment_date DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_loan_payments_payment_date DEFAULT SYSDATETIMEOFFSET(),
            -- Timestamp of the payment.
        CONSTRAINT PK_loan_payments PRIMARY KEY (loan_id, payment_no),
            -- Composite key ensures each payment number is unique per loan.
        CONSTRAINT FK_loan_payments_loan
            FOREIGN KEY (loan_id) REFERENCES dbo.loans(loan_id)
            ON DELETE CASCADE,
            -- Deleting a loan also deletes its payments.
        CONSTRAINT CK_loan_payments_payment_no
            CHECK (payment_no > 0),
            -- Payment number must be positive.
        CONSTRAINT CK_loan_payments_amount_paid
            CHECK (amount_paid > 0)
            -- Payment amount must be greater than zero.
    );
END;

-- =========================
-- 2) Performance indexes
-- =========================
-- Indexes improve query performance by allowing the database to locate rows faster.
-- Each index is only created if it does not already exist.

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'idx_accounts_customer_id'
      AND object_id = OBJECT_ID('dbo.accounts')
)
BEGIN
    CREATE INDEX idx_accounts_customer_id
        ON dbo.accounts(customer_id);
        -- Supports lookups of accounts by customer_id.
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'idx_transactions_account_date'
      AND object_id = OBJECT_ID('dbo.transactions')
)
BEGIN
    CREATE INDEX idx_transactions_account_date
        ON dbo.transactions(account_id, transaction_date);
        -- Supports queries that filter or sort transactions by account and date.
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'idx_transactions_transfer_id'
      AND object_id = OBJECT_ID('dbo.transactions')
)
BEGIN
    CREATE INDEX idx_transactions_transfer_id
        ON dbo.transactions(transfer_id);
        -- Supports fast lookup of transactions related to a transfer.
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'idx_transfers_from_account_date'
      AND object_id = OBJECT_ID('dbo.transfers')
)
BEGIN
    CREATE INDEX idx_transfers_from_account_date
        ON dbo.transfers(from_account_id, transfer_date);
        -- Supports queries for transfers sent from an account.
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'idx_transfers_to_account_date'
      AND object_id = OBJECT_ID('dbo.transfers')
)
BEGIN
    CREATE INDEX idx_transfers_to_account_date
        ON dbo.transfers(to_account_id, transfer_date);
        -- Supports queries for transfers received by an account.
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'idx_loans_customer_status'
      AND object_id = OBJECT_ID('dbo.loans')
)
BEGIN
    CREATE INDEX idx_loans_customer_status
        ON dbo.loans(customer_id, status);
        -- Supports fast filtering of loans by customer and loan status.
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'idx_loan_payments_loan_date'
      AND object_id = OBJECT_ID('dbo.loan_payments')
)
BEGIN
    CREATE INDEX idx_loan_payments_loan_date
        ON dbo.loan_payments(loan_id, payment_date);
        -- Supports looking up payments for a loan in date order.
END;

COMMIT TRANSACTION;

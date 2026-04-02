-- Bank Database System schema (PostgreSQL)
-- Target database name: bank_database

BEGIN;

-- =========================
-- 1) Domain types (enums)
-- =========================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type_enum') THEN
        CREATE TYPE account_type_enum AS ENUM ('savings', 'current');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_status_enum') THEN
        CREATE TYPE account_status_enum AS ENUM ('active', 'frozen', 'closed');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transaction_type_enum') THEN
        CREATE TYPE transaction_type_enum AS ENUM ('deposit', 'withdrawal', 'transfer');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'loan_type_enum') THEN
        CREATE TYPE loan_type_enum AS ENUM ('personal', 'business', 'mortgage', 'auto');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'loan_status_enum') THEN
        CREATE TYPE loan_status_enum AS ENUM ('pending', 'approved', 'rejected', 'closed');
    END IF;
END $$;

-- =========================
-- 2) Core entities
-- =========================
CREATE TABLE IF NOT EXISTS customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    date_of_birth DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Multivalued customer phone attribute represented as separate table (1:N)
CREATE TABLE IF NOT EXISTS customer_phone (
    customer_id BIGINT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    phone_no VARCHAR(20) NOT NULL,
    PRIMARY KEY (customer_id, phone_no)
);

CREATE TABLE IF NOT EXISTS branches (
    branch_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_name VARCHAR(150) NOT NULL,
    location VARCHAR(255),
    branch_code VARCHAR(30) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS accounts (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_number VARCHAR(34) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    account_type account_type_enum NOT NULL,
    status account_status_enum NOT NULL DEFAULT 'active',
    balance NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    opened_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS account_branches (
    account_id BIGINT NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    branch_id BIGINT NOT NULL REFERENCES branches(branch_id) ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (account_id, branch_id)
);

CREATE TABLE IF NOT EXISTS loans (
    loan_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    loan_type loan_type_enum NOT NULL,
    principal_amount NUMERIC(14,2) NOT NULL CHECK (principal_amount > 0),
    interest_rate NUMERIC(5,2) NOT NULL CHECK (interest_rate >= 0),
    status loan_status_enum NOT NULL DEFAULT 'pending',
    issued_date DATE,
    due_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_loans_dates_valid
        CHECK (due_date IS NULL OR issued_date IS NULL OR due_date >= issued_date)
);

CREATE TABLE IF NOT EXISTS transfers (
    transfer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    from_account_id BIGINT NOT NULL REFERENCES accounts(account_id) ON DELETE RESTRICT,
    to_account_id BIGINT NOT NULL REFERENCES accounts(account_id) ON DELETE RESTRICT,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    transfer_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reference_note TEXT,
    CONSTRAINT ck_transfers_accounts_different CHECK (from_account_id <> to_account_id)
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES accounts(account_id) ON DELETE RESTRICT,
    transaction_type transaction_type_enum NOT NULL,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    transfer_id BIGINT REFERENCES transfers(transfer_id) ON DELETE SET NULL,
    CONSTRAINT ck_transactions_transfer_link
        CHECK (
            (transaction_type = 'transfer' AND transfer_id IS NOT NULL)
            OR (transaction_type <> 'transfer')
        )
);

-- Weak-style entity implementation using composite key (loan_id, payment_no)
CREATE TABLE IF NOT EXISTS loan_payments (
    loan_id BIGINT NOT NULL REFERENCES loans(loan_id) ON DELETE CASCADE,
    payment_no INT NOT NULL CHECK (payment_no > 0),
    amount_paid NUMERIC(14,2) NOT NULL CHECK (amount_paid > 0),
    payment_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (loan_id, payment_no)
);

-- =========================
-- 3) Performance indexes
-- =========================
CREATE INDEX IF NOT EXISTS idx_accounts_customer_id
    ON accounts(customer_id);

CREATE INDEX IF NOT EXISTS idx_transactions_account_date
    ON transactions(account_id, transaction_date);

CREATE INDEX IF NOT EXISTS idx_transactions_transfer_id
    ON transactions(transfer_id);

CREATE INDEX IF NOT EXISTS idx_transfers_from_account_date
    ON transfers(from_account_id, transfer_date);

CREATE INDEX IF NOT EXISTS idx_transfers_to_account_date
    ON transfers(to_account_id, transfer_date);

CREATE INDEX IF NOT EXISTS idx_loans_customer_status
    ON loans(customer_id, status);

CREATE INDEX IF NOT EXISTS idx_loan_payments_loan_date
    ON loan_payments(loan_id, payment_date);

COMMIT;


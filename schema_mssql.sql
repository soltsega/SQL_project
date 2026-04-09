-- Bank Database System schema 
-- Target database name: bank_database

BEGIN TRANSACTION;

-- =========================
-- 1) Core entities
-- =========================
IF OBJECT_ID('dbo.customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.customers (
        customer_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        middle_name VARCHAR(100) NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        street VARCHAR(255) NULL,
        city VARCHAR(100) NULL,
        state VARCHAR(100) NULL,
        postal_code VARCHAR(20) NULL,
        date_of_birth DATE NULL,
        created_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_customers_created_at DEFAULT SYSDATETIMEOFFSET()
    );
END;

-- Multivalued customer phone attribute represented as separate table (1:N)
IF OBJECT_ID('dbo.customer_phone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.customer_phone (
        customer_id BIGINT NOT NULL,
        phone_no VARCHAR(20) NOT NULL,
        CONSTRAINT PK_customer_phone PRIMARY KEY (customer_id, phone_no),
        CONSTRAINT FK_customer_phone_customer
            FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id)
            ON DELETE CASCADE
    );
END;

IF OBJECT_ID('dbo.branches', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.branches (
        branch_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        branch_name VARCHAR(150) NOT NULL,
        location VARCHAR(255) NULL,
        branch_code VARCHAR(30) NOT NULL UNIQUE,
        created_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_branches_created_at DEFAULT SYSDATETIMEOFFSET()
    );
END;

IF OBJECT_ID('dbo.accounts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.accounts (
        account_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        account_number VARCHAR(34) NOT NULL UNIQUE,
        customer_id BIGINT NOT NULL,
        account_type VARCHAR(20) NOT NULL,
        status VARCHAR(20) NOT NULL
            CONSTRAINT DF_accounts_status DEFAULT 'active',
        balance DECIMAL(14,2) NOT NULL
            CONSTRAINT DF_accounts_balance DEFAULT 0.00,
        opened_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_accounts_opened_at DEFAULT SYSDATETIMEOFFSET(),
        CONSTRAINT FK_accounts_customer
            FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_accounts_account_type
            CHECK (account_type IN ('savings', 'current')),
        CONSTRAINT CK_accounts_status
            CHECK (status IN ('active', 'frozen', 'closed')),
        CONSTRAINT CK_accounts_balance
            CHECK (balance >= 0)
    );
END;

IF OBJECT_ID('dbo.account_branches', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.account_branches (
        account_id BIGINT NOT NULL,
        branch_id BIGINT NOT NULL,
        assigned_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_account_branches_assigned_at DEFAULT SYSDATETIMEOFFSET(),
        CONSTRAINT PK_account_branches PRIMARY KEY (account_id, branch_id),
        CONSTRAINT FK_account_branches_account
            FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id)
            ON DELETE CASCADE,
        CONSTRAINT FK_account_branches_branch
            FOREIGN KEY (branch_id) REFERENCES dbo.branches(branch_id)
            ON DELETE NO ACTION
    );
END;

IF OBJECT_ID('dbo.loans', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.loans (
        loan_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        customer_id BIGINT NOT NULL,
        loan_type VARCHAR(20) NOT NULL,
        principal_amount DECIMAL(14,2) NOT NULL,
        interest_rate DECIMAL(5,2) NOT NULL,
        status VARCHAR(20) NOT NULL
            CONSTRAINT DF_loans_status DEFAULT 'pending',
        issued_date DATE NULL,
        due_date DATE NULL,
        created_at DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_loans_created_at DEFAULT SYSDATETIMEOFFSET(),
        CONSTRAINT FK_loans_customer
            FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_loans_loan_type
            CHECK (loan_type IN ('personal', 'business', 'mortgage', 'auto')),
        CONSTRAINT CK_loans_principal_amount
            CHECK (principal_amount > 0),
        CONSTRAINT CK_loans_interest_rate
            CHECK (interest_rate >= 0),
        CONSTRAINT CK_loans_status
            CHECK (status IN ('pending', 'approved', 'rejected', 'closed')),
        CONSTRAINT CK_loans_dates_valid
            CHECK (due_date IS NULL OR issued_date IS NULL OR due_date >= issued_date)
    );
END;

IF OBJECT_ID('dbo.transfers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.transfers (
        transfer_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        from_account_id BIGINT NOT NULL,
        to_account_id BIGINT NOT NULL,
        amount DECIMAL(14,2) NOT NULL,
        transfer_date DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_transfers_transfer_date DEFAULT SYSDATETIMEOFFSET(),
        reference_note VARCHAR(MAX) NULL,
        CONSTRAINT FK_transfers_from_account
            FOREIGN KEY (from_account_id) REFERENCES dbo.accounts(account_id)
            ON DELETE NO ACTION,
        CONSTRAINT FK_transfers_to_account
            FOREIGN KEY (to_account_id) REFERENCES dbo.accounts(account_id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_transfers_amount
            CHECK (amount > 0),
        CONSTRAINT CK_transfers_accounts_different
            CHECK (from_account_id <> to_account_id)
    );
END;

IF OBJECT_ID('dbo.transactions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.transactions (
        transaction_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        account_id BIGINT NOT NULL,
        transaction_type VARCHAR(20) NOT NULL,
        amount DECIMAL(14,2) NOT NULL,
        transaction_date DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_transactions_transaction_date DEFAULT SYSDATETIMEOFFSET(),
        description VARCHAR(MAX) NULL,
        transfer_id BIGINT NULL,
        CONSTRAINT FK_transactions_account
            FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id)
            ON DELETE NO ACTION,
        CONSTRAINT FK_transactions_transfer
            FOREIGN KEY (transfer_id) REFERENCES dbo.transfers(transfer_id)
            ON DELETE SET NULL,
        CONSTRAINT CK_transactions_type
            CHECK (transaction_type IN ('deposit', 'withdrawal', 'transfer')),
        CONSTRAINT CK_transactions_amount
            CHECK (amount > 0),
        CONSTRAINT CK_transactions_transfer_link
            CHECK (
                (transaction_type = 'transfer' AND transfer_id IS NOT NULL)
                OR (transaction_type <> 'transfer')
            )
    );
END;

-- Weak-style entity implementation using composite key (loan_id, payment_no)
IF OBJECT_ID('dbo.loan_payments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.loan_payments (
        loan_id BIGINT NOT NULL,
        payment_no INT NOT NULL,
        amount_paid DECIMAL(14,2) NOT NULL,
        payment_date DATETIMEOFFSET NOT NULL
            CONSTRAINT DF_loan_payments_payment_date DEFAULT SYSDATETIMEOFFSET(),
        CONSTRAINT PK_loan_payments PRIMARY KEY (loan_id, payment_no),
        CONSTRAINT FK_loan_payments_loan
            FOREIGN KEY (loan_id) REFERENCES dbo.loans(loan_id)
            ON DELETE CASCADE,
        CONSTRAINT CK_loan_payments_payment_no
            CHECK (payment_no > 0),
        CONSTRAINT CK_loan_payments_amount_paid
            CHECK (amount_paid > 0)
    );
END;

-- =========================
-- 2) Performance indexes
-- =========================
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'idx_accounts_customer_id'
      AND object_id = OBJECT_ID('dbo.accounts')
)
BEGIN
    CREATE INDEX idx_accounts_customer_id
        ON dbo.accounts(customer_id);
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
END;

COMMIT TRANSACTION;

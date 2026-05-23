-- We wil be inserting 5 records into each table for demonstration.

USE bank_database;
GO

-- 1) customers
SET IDENTITY_INSERT dbo.customers ON;

INSERT INTO dbo.customers (
    customer_id, first_name, middle_name, last_name, email,
    street, city, state, postal_code, date_of_birth
)
VALUES
(1, 'Abebe', NULL, 'Girma', 'abebe.girma@example.com', 'Bole Road', 'Addis Ababa', 'Addis Ababa', '1000', '1995-04-12'),
(2, 'Hanna', 'Mekdes', 'Bekele', 'hanna.bekele@example.com', 'Piassa Street', 'Addis Ababa', 'Addis Ababa', '1000', '1998-09-23'),
(3, 'Dawit', NULL, 'Tesfaye', 'dawit.tesfaye@example.com', 'Kazanchis Avenue', 'Addis Ababa', 'Addis Ababa', '1000', '1989-01-18'),
(4, 'Marta', NULL, 'Kebede', 'marta.kebede@example.com', 'Hawassa Lake Road', 'Hawassa', 'Sidama', '2000', '1992-11-05'),
(5, 'Samuel', 'Yonas', 'Alemu', 'samuel.alemu@example.com', 'Mekelle Main Road', 'Mekelle', 'Tigray', '3000', '1985-07-29');

SET IDENTITY_INSERT dbo.customers OFF;
GO

-- 2) customer_phone
INSERT INTO dbo.customer_phone (customer_id, phone_no)
VALUES
(1, '+251911000001'),
(2, '+251911000002'),
(3, '+251911000003'),
(4, '+251911000004'),
(5, '+251911000005');
GO

-- 3) branches
SET IDENTITY_INSERT dbo.branches ON;

INSERT INTO dbo.branches (branch_id, branch_name, location, branch_code)
VALUES
(1, 'Bole Main Branch', 'Bole, Addis Ababa', 'BOLE001'),
(2, 'Piassa Branch', 'Piassa, Addis Ababa', 'PIAS002'),
(3, 'Kazanchis Branch', 'Kazanchis, Addis Ababa', 'KAZ003'),
(4, 'Hawassa Branch', 'Hawassa City Center', 'HAW004'),
(5, 'Mekelle Branch', 'Mekelle Main Road', 'MEK005');

SET IDENTITY_INSERT dbo.branches OFF;
GO

-- 4) accounts
SET IDENTITY_INSERT dbo.accounts ON;

INSERT INTO dbo.accounts (
    account_id, account_number, customer_id, account_type, status, balance, opened_at
)
VALUES
(1, 'ET001000000001', 1, 'savings', 'active', 18500.00, '2024-01-10 09:00:00 +03:00'),
(2, 'ET001000000002', 2, 'current', 'active', 42200.50, '2024-02-14 10:30:00 +03:00'),
(3, 'ET001000000003', 3, 'savings', 'frozen', 7300.75, '2024-03-20 14:15:00 +03:00'),
(4, 'ET001000000004', 4, 'current', 'active', 96500.00, '2024-04-11 08:45:00 +03:00'),
(5, 'ET001000000005', 5, 'savings', 'closed', 1200.00, '2024-05-05 12:00:00 +03:00');

SET IDENTITY_INSERT dbo.accounts OFF;
GO

-- 5) account_branches
INSERT INTO dbo.account_branches (account_id, branch_id, assigned_at)
VALUES
(1, 1, '2024-01-10 09:05:00 +03:00'),
(2, 2, '2024-02-14 10:35:00 +03:00'),
(3, 3, '2024-03-20 14:20:00 +03:00'),
(4, 4, '2024-04-11 08:50:00 +03:00'),
(5, 5, '2024-05-05 12:05:00 +03:00');
GO

-- 6) loans
SET IDENTITY_INSERT dbo.loans ON;

INSERT INTO dbo.loans (
    loan_id, customer_id, loan_type, principal_amount,
    interest_rate, status, issued_date, due_date
)
VALUES
(1, 1, 'personal', 50000.00, 12.50, 'approved', '2024-01-15', '2026-01-15'),
(2, 2, 'business', 250000.00, 10.75, 'approved', '2024-02-20', '2027-02-20'),
(3, 3, 'auto', 180000.00, 9.25, 'pending', NULL, NULL),
(4, 4, 'mortgage', 900000.00, 8.50, 'approved', '2024-03-01', '2034-03-01'),
(5, 5, 'personal', 30000.00, 13.00, 'closed', '2023-06-10', '2025-06-10');

SET IDENTITY_INSERT dbo.loans OFF;
GO

-- 7) transfers
SET IDENTITY_INSERT dbo.transfers ON;

INSERT INTO dbo.transfers (
    transfer_id, from_account_id, to_account_id, amount, transfer_date, reference_note
)
VALUES
(1, 1, 2, 1500.00, '2024-06-01 09:10:00 +03:00', 'Rent support'),
(2, 2, 4, 3200.00, '2024-06-03 11:25:00 +03:00', 'Supplier payment'),
(3, 4, 1, 800.00, '2024-06-05 15:45:00 +03:00', 'Family transfer'),
(4, 5, 3, 1200.00, '2024-06-07 10:05:00 +03:00', 'Loan support'),
(5, 4, 5, 2750.00, '2024-06-09 13:30:00 +03:00', 'Invoice settlement');

SET IDENTITY_INSERT dbo.transfers OFF;
GO

-- 8) transactions
SET IDENTITY_INSERT dbo.transactions ON;

INSERT INTO dbo.transactions (
    transaction_id, account_id, transaction_type, amount,
    transaction_date, description, transfer_id
)
VALUES
(1, 1, 'deposit', 5000.00, '2024-06-01 08:30:00 +03:00', 'Cash deposit', NULL),
(2, 2, 'withdrawal', 750.00, '2024-06-02 12:00:00 +03:00', 'ATM withdrawal', NULL),
(3, 1, 'transfer', 1500.00, '2024-06-01 09:10:00 +03:00', 'Outgoing transfer', 1),
(4, 2, 'transfer', 3200.00, '2024-06-03 11:25:00 +03:00', 'Outgoing transfer', 2),
(5, 4, 'deposit', 10000.00, '2024-06-10 16:20:00 +03:00', 'Business income deposit', NULL);

SET IDENTITY_INSERT dbo.transactions OFF;
GO

-- 9) loan_payments
INSERT INTO dbo.loan_payments (loan_id, payment_no, amount_paid, payment_date)
VALUES
(1, 1, 5000.00, '2024-07-01 09:00:00 +03:00'),
(2, 1, 15000.00, '2024-07-05 10:30:00 +03:00'),
(4, 1, 20000.00, '2024-07-10 11:45:00 +03:00'),
(1, 2, 4500.00, '2024-08-01 09:15:00 +03:00'),
(5, 1, 30000.00, '2023-09-15 14:00:00 +03:00');
GO


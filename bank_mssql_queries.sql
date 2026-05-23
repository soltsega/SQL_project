USE bank_database;
GO

-- 1) Customers with their phone numbers and total number of accounts.
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    cp.phone_no,
    COUNT(a.account_id) AS total_accounts
FROM dbo.customers AS c
LEFT JOIN dbo.customer_phone AS cp
    ON cp.customer_id = c.customer_id
LEFT JOIN dbo.accounts AS a
    ON a.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    cp.phone_no
ORDER BY customer_name;
GO

-- 2) Accounts with owner name, branch, status, and balance.
SELECT
    a.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.account_type,
    a.status,
    a.balance,
    b.branch_name,
    b.location
FROM dbo.accounts AS a
JOIN dbo.customers AS c
    ON c.customer_id = a.customer_id
JOIN dbo.account_branches AS ab
    ON ab.account_id = a.account_id
JOIN dbo.branches AS b
    ON b.branch_id = ab.branch_id
WHERE a.balance >= 5000.00
ORDER BY a.balance DESC;
GO

-- 3) Branch summary: number of accounts and total/average balance per branch.
SELECT
    b.branch_code,
    b.branch_name,
    COUNT(a.account_id) AS total_accounts,
    SUM(a.balance) AS total_branch_balance,
    AVG(a.balance) AS average_account_balance
FROM dbo.branches AS b
JOIN dbo.account_branches AS ab
    ON ab.branch_id = b.branch_id
JOIN dbo.accounts AS a
    ON a.account_id = ab.account_id
GROUP BY b.branch_code, b.branch_name
HAVING SUM(a.balance) > 10000.00
ORDER BY total_branch_balance DESC;
GO

-- 4) Transaction activity by account and transaction type.
SELECT
    a.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    t.transaction_type,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_amount,
    MIN(t.transaction_date) AS first_transaction_date,
    MAX(t.transaction_date) AS last_transaction_date
FROM dbo.transactions AS t
JOIN dbo.accounts AS a
    ON a.account_id = t.account_id
JOIN dbo.customers AS c
    ON c.customer_id = a.customer_id
GROUP BY
    a.account_number,
    c.first_name,
    c.last_name,
    t.transaction_type
HAVING SUM(t.amount) >= 1000.00
ORDER BY total_amount DESC;
GO

-- 5) Transfer report showing sender, receiver, branch names, and amount.
SELECT
    tr.transfer_id,
    tr.transfer_date,
    sender.account_number AS from_account_number,
    CONCAT(sender_customer.first_name, ' ', sender_customer.last_name) AS sender_name,
    sender_branch.branch_name AS sender_branch,
    receiver.account_number AS to_account_number,
    CONCAT(receiver_customer.first_name, ' ', receiver_customer.last_name) AS receiver_name,
    receiver_branch.branch_name AS receiver_branch,
    tr.amount,
    tr.reference_note
FROM dbo.transfers AS tr
JOIN dbo.accounts AS sender
    ON sender.account_id = tr.from_account_id
JOIN dbo.customers AS sender_customer
    ON sender_customer.customer_id = sender.customer_id
JOIN dbo.account_branches AS sender_ab
    ON sender_ab.account_id = sender.account_id
JOIN dbo.branches AS sender_branch
    ON sender_branch.branch_id = sender_ab.branch_id
JOIN dbo.accounts AS receiver
    ON receiver.account_id = tr.to_account_id
JOIN dbo.customers AS receiver_customer
    ON receiver_customer.customer_id = receiver.customer_id
JOIN dbo.account_branches AS receiver_ab
    ON receiver_ab.account_id = receiver.account_id
JOIN dbo.branches AS receiver_branch
    ON receiver_branch.branch_id = receiver_ab.branch_id
WHERE tr.amount BETWEEN 1000.00 AND 5000.00
ORDER BY tr.transfer_date DESC;
GO

-- 6) Loan balances: principal, amount paid, and remaining amount.
SELECT
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    l.loan_type,
    l.status,
    l.principal_amount,
    COALESCE(SUM(lp.amount_paid), 0.00) AS total_paid,
    l.principal_amount - COALESCE(SUM(lp.amount_paid), 0.00) AS remaining_principal,
    COUNT(lp.payment_no) AS number_of_payments
FROM dbo.loans AS l
JOIN dbo.customers AS c
    ON c.customer_id = l.customer_id
LEFT JOIN dbo.loan_payments AS lp
    ON lp.loan_id = l.loan_id
GROUP BY
    l.loan_id,
    c.first_name,
    c.last_name,
    l.loan_type,
    l.status,
    l.principal_amount
HAVING l.principal_amount - COALESCE(SUM(lp.amount_paid), 0.00) > 0
ORDER BY remaining_principal DESC;
GO

-- 7) Loan type summary with aggregation and HAVING.
SELECT
    loan_type,
    status,
    COUNT(*) AS loan_count,
    SUM(principal_amount) AS total_principal,
    AVG(interest_rate) AS average_interest_rate,
    MIN(issued_date) AS earliest_issued_date,
    MAX(due_date) AS latest_due_date
FROM dbo.loans
GROUP BY loan_type, status
HAVING SUM(principal_amount) >= 30000.00
ORDER BY total_principal DESC;
GO

-- 8) Customers with both account and loan information.
WITH account_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS total_accounts,
        SUM(balance) AS total_account_balance
    FROM dbo.accounts
    GROUP BY customer_id
),
loan_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS total_loans,
        SUM(CASE WHEN status = 'approved' THEN principal_amount ELSE 0 END) AS approved_loan_amount
    FROM dbo.loans
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COALESCE(a.total_accounts, 0) AS total_accounts,
    COALESCE(a.total_account_balance, 0.00) AS total_account_balance,
    COALESCE(l.total_loans, 0) AS total_loans,
    COALESCE(l.approved_loan_amount, 0.00) AS approved_loan_amount
FROM dbo.customers AS c
LEFT JOIN account_summary AS a
    ON a.customer_id = c.customer_id
LEFT JOIN loan_summary AS l
    ON l.customer_id = c.customer_id
WHERE COALESCE(a.total_accounts, 0) > 0
ORDER BY total_account_balance DESC;
GO

-- 9) Rank accounts by balance using a SQL Server window function.
SELECT
    a.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.account_type,
    a.status,
    a.balance,
    RANK() OVER (ORDER BY a.balance DESC) AS balance_rank
FROM dbo.accounts AS a
JOIN dbo.customers AS c
    ON c.customer_id = a.customer_id
ORDER BY balance_rank;
GO

-- 10) Monthly transaction totals.
SELECT
    YEAR(t.transaction_date) AS transaction_year,
    MONTH(t.transaction_date) AS transaction_month,
    t.transaction_type,
    COUNT(*) AS transaction_count,
    SUM(t.amount) AS total_amount
FROM dbo.transactions AS t
GROUP BY
    YEAR(t.transaction_date),
    MONTH(t.transaction_date),
    t.transaction_type
HAVING COUNT(*) >= 1
ORDER BY transaction_year, transaction_month, total_amount DESC;
GO

-- 11) Customers whose outgoing transfer total is above 1000.
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(tr.transfer_id) AS outgoing_transfer_count,
    SUM(tr.amount) AS total_outgoing_transfer
FROM dbo.customers AS c
JOIN dbo.accounts AS a
    ON a.customer_id = c.customer_id
JOIN dbo.transfers AS tr
    ON tr.from_account_id = a.account_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(tr.amount) > 1000.00
ORDER BY total_outgoing_transfer DESC;
GO

-- 12) Accounts that have no recorded transactions.
SELECT
    a.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.account_type,
    a.status,
    a.balance
FROM dbo.accounts AS a
JOIN dbo.customers AS c
    ON c.customer_id = a.customer_id
LEFT JOIN dbo.transactions AS t
    ON t.account_id = a.account_id
WHERE t.transaction_id IS NULL
ORDER BY a.account_number;
GO

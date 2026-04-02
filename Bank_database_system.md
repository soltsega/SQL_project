Bank Database System — Final Project Description
Overview
The Bank Database System is a relational database project designed to simulate the operations of a real-world banking environment. The system focuses on managing customers, accounts, transactions, transfers, loans, and branch associations while enforcing realistic business rules and maintaining strong data integrity.
System Design
The database is structured around several key entities:
Customers represent individuals interacting with the bank
Accounts store financial balances and are owned by customers
Transactions track all financial activities (deposit, withdrawal)
Transfers model money movement between accounts (recursive relationship)
Branches represent organizational units of the bank
Loans capture lending operations between the bank and customers
Relationships & Data Modeling
The system incorporates multiple types of relationships to reflect real-world scenarios:
Customer → Account (1:N)
Each customer can own multiple accounts, while each account belongs to exactly one customer.
Account → Transaction (1:N)
Each account maintains a history of many transactions.
Customer → Loan (0:N)
A customer may have zero or multiple loans.
Account ↔ Branch (M:N)
Accounts can be associated with one or more branches, and branches manage multiple accounts.
Account → Transfer (Recursive Relationship)
Transfers connect accounts to other accounts, modeling fund movement within the system.



Final Set of Tables
1. Customer
customer_id (PK)
full_name
phone
email
address
2. Account
account_id (PK)
customer_id (FK)
account_type (Savings, Current)
balance
created_at
Relationship: Customer → Account = (1, N)
3. Transaction
transaction_id (PK)
account_id (FK)
type (Deposit, Withdraw, Transfer)
amount
transaction_date
Relationship: Account → Transaction = (1, N)
4. Transfer 
transfer_id (PK)
from_account_id (FK)
to_account_id (FK)
amount
date
5. Branch
branch_id (PK)
name
location
6. Account_Branch
account_id (FK)
branch_id (FK)
Relationship: Account ↔ Branch = M:N
7. Loan (optional but good i guess)
loan_id (PK)
customer_id (FK)
amount
interest_rate
status
Key Relationships with Min–Max
Relationship
Min–Max
Customer → Account
(1, N)
Account → Transaction
(1, N)
Customer → Loan
(0, N)
Account ↔ Branch
(0, N) : (0, N)
Account → Transfer
(0, N)



Business Rules & Constraints
To ensure realism, the system enforces several important constraints:
Account balances cannot fall below zero
Transaction and transfer amounts must be positive
Transfers must occur between distinct accounts
Referential integrity is maintained across all foreign keys
These rules simulate real banking restrictions and ensure data consistency.
Analytical Capabilities
Beyond transactional operations, the system supports advanced querying for insights, including:
Identifying high-value customers based on total balance
Analyzing monthly transaction trends
Evaluating branch performance
Summarizing loan distributions and statuses
Detecting inactive accounts or unusual activity patterns
These queries leverage SQL features such as:
JOIN operations across multiple tables
Aggregations (GROUP BY, HAVING)
Subqueries
Conditional logic (CASE statements)
Summary
This Bank Database System goes beyond basic CRUD operations by integrating realistic constraints, diverse relationship types, and analytical 
capabilities, resulting in a practical and portfolio-ready project that reflects real-world banking scenarios.



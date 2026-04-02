# Bank Database ER Diagram (Chen Style)

```mermaid
flowchart LR
    %% Entities
    CUSTOMER[Customer]
    ACCOUNT[Account]
    BRANCH[Branch]
    LOAN[Loan]
    TRANSFER[Transfer]
    TRANSACTION[Transaction]
    LOAN_PAYMENT[Loan_Payment]

    %% Relationship diamonds
    OWNS{Owns}
    LINKED_AT{Linked_At}
    BORROWS{Borrows}
    RECORDS{Records}
    SENDS{Sends}
    RECEIVES{Receives}
    PAYS{Pays}

    %% Customer attributes
    cust_id((customer_id))
    full_name((full_name))
    phone((phone))
    email((email))
    address((address))
    dob((date_of_birth))

    %% Account attributes
    account_id((account_id))
    account_no((account_number))
    account_type((account_type))
    acc_status((status))
    balance((balance))

    %% Branch attributes
    branch_id((branch_id))
    branch_name((branch_name))
    branch_code((branch_code))
    location((location))

    %% Loan attributes
    loan_id((loan_id))
    loan_type((loan_type))
    loan_amount((amount))
    interest_rate((interest_rate))
    loan_status((status))
    issued_date((issued_date))
    due_date((due_date))

    %% Transfer attributes
    transfer_id((transfer_id))
    transfer_amount((amount))
    transfer_date((transfer_date))

    %% Transaction attributes
    txn_id((transaction_id))
    txn_type((transaction_type))
    txn_amount((amount))
    txn_date((transaction_date))

    %% Loan payment attributes
    payment_id((payment_id))
    amount_paid((amount_paid))
    payment_date((payment_date))

    %% Entity-relationship links
    CUSTOMER --- OWNS --- ACCOUNT
    ACCOUNT --- LINKED_AT --- BRANCH
    CUSTOMER --- BORROWS --- LOAN
    ACCOUNT --- RECORDS --- TRANSACTION
    ACCOUNT --- SENDS --- TRANSFER
    ACCOUNT --- RECEIVES --- TRANSFER
    LOAN --- PAYS --- LOAN_PAYMENT

    %% Attribute links
    CUSTOMER --- cust_id
    CUSTOMER --- full_name
    CUSTOMER --- phone
    CUSTOMER --- email
    CUSTOMER --- address
    CUSTOMER --- dob

    ACCOUNT --- account_id
    ACCOUNT --- account_no
    ACCOUNT --- account_type
    ACCOUNT --- acc_status
    ACCOUNT --- balance

    BRANCH --- branch_id
    BRANCH --- branch_name
    BRANCH --- branch_code
    BRANCH --- location

    LOAN --- loan_id
    LOAN --- loan_type
    LOAN --- loan_amount
    LOAN --- interest_rate
    LOAN --- loan_status
    LOAN --- issued_date
    LOAN --- due_date

    TRANSFER --- transfer_id
    TRANSFER --- transfer_amount
    TRANSFER --- transfer_date

    TRANSACTION --- txn_id
    TRANSACTION --- txn_type
    TRANSACTION --- txn_amount
    TRANSACTION --- txn_date

    LOAN_PAYMENT --- payment_id
    LOAN_PAYMENT --- amount_paid
    LOAN_PAYMENT --- payment_date
```

## Notes

- This is a Chen-style visual layout to match your example.
- For implementation, keep using the normalized relational design in `Bank_database_system.md`.

CREATE TABLE [fact_transactions] (
	[id] int IDENTITY(1,1) NOT NULL UNIQUE,
	[category_id] int NOT NULL,
	[transaction_type_id] int NOT NULL,
	[transaction_date] date NOT NULL,
	[transaction_code_id] int NOT NULL,
	[amount] decimal(18,0) NOT NULL,
	[amount_currency_id] int NOT NULL,
	[balance] decimal(18,0) NOT NULL,
	[balance_currency_id] int NOT NULL,
	[account_name_id] int NOT NULL,
	[bank_name_id] int NOT NULL,
	[create_date] date NOT NULL,
	PRIMARY KEY ([id])
);

CREATE TABLE [dim_categories] (
	[id] int IDENTITY(1,1) NOT NULL UNIQUE,
	[category] nvarchar(max) NOT NULL,
	PRIMARY KEY ([id])
);

CREATE TABLE [dim_transaction_types] (
	[id] int IDENTITY(1,1) NOT NULL UNIQUE,
	[transaction_type] nvarchar(max) NOT NULL,
	PRIMARY KEY ([id])
);

CREATE TABLE [dim_transaction_codes] (
	[id] int IDENTITY(1,1) NOT NULL UNIQUE,
	[transaction_code] nvarchar(max) NOT NULL,
	PRIMARY KEY ([id])
);

CREATE TABLE [dim_currencies] (
	[id] int IDENTITY(1,1) NOT NULL UNIQUE,
	[currency] nvarchar(max) NOT NULL,
	PRIMARY KEY ([id])
);

CREATE TABLE [dim_accounts] (
	[id] int IDENTITY(1,1) NOT NULL UNIQUE,
	[account_name] nvarchar(max) NOT NULL,
	PRIMARY KEY ([id])
);

CREATE TABLE [dim_banks] (
	[id] int IDENTITY(1,1) NOT NULL UNIQUE,
	[bank_name] nvarchar(max) NOT NULL,
	PRIMARY KEY ([id])
);

ALTER TABLE [fact_transactions] ADD CONSTRAINT [fact_transactions_fk1] FOREIGN KEY ([category_id]) REFERENCES [dim_categories]([id]);

ALTER TABLE [fact_transactions] ADD CONSTRAINT [fact_transactions_fk2] FOREIGN KEY ([transaction_type_id]) REFERENCES [dim_transaction_types]([id]);

ALTER TABLE [fact_transactions] ADD CONSTRAINT [fact_transactions_fk4] FOREIGN KEY ([transaction_code_id]) REFERENCES [dim_transaction_codes]([id]);

ALTER TABLE [fact_transactions] ADD CONSTRAINT [fact_transactions_fk6] FOREIGN KEY ([amount_currency_id]) REFERENCES [dim_currencies]([id]);

ALTER TABLE [fact_transactions] ADD CONSTRAINT [fact_transactions_fk8] FOREIGN KEY ([balance_currency_id]) REFERENCES [dim_currencies]([id]);

ALTER TABLE [fact_transactions] ADD CONSTRAINT [fact_transactions_fk9] FOREIGN KEY ([account_name_id]) REFERENCES [dim_accounts]([id]);

ALTER TABLE [fact_transactions] ADD CONSTRAINT [fact_transactions_fk10] FOREIGN KEY ([bank_name_id]) REFERENCES [dim_banks]([id]);






CREATE TABLE [FactTransactions] (
	[id] int IDENTITY(1,1) NOT NULL UNIQUE,
	[TransactionCode] nvarchar(255) NOT NULL,
	[TransactionCategoryID] int NOT NULL,
	[TransactionTypeID] int NOT NULL,
	[AmountCurrencyID] int NOT NULL,
	[BalanceCurrencyID] int NOT NULL,
	[Amount] float(53) NOT NULL,
	[DateInsertedDW] datetime NOT NULL,
	[ParentID] int NOT NULL,
	[TransactionDate] datetime NOT NULL,
	[AccountID] int NOT NULL,
	[Balance] float(53) NOT NULL,
	[StageCreateDate] datetime NOT NULL,
	PRIMARY KEY ([ParentID])
);

CREATE TABLE [DimTransactionCategory] (
	[ID] int IDENTITY(1,1) NOT NULL UNIQUE,
	[CategoryName] nvarchar(255) NOT NULL,
	PRIMARY KEY ([ID])
);

CREATE TABLE [DimTransactionType] (
	[ID] int IDENTITY(1,1) NOT NULL UNIQUE,
	[TypeName] nvarchar(255) NOT NULL,
	PRIMARY KEY ([ID])
);

CREATE TABLE [DimCurrency] (
	[ID] int IDENTITY(1,1) NOT NULL UNIQUE,
	[CurrencyName] nvarchar(3) NOT NULL,
	PRIMARY KEY ([ID])
);

CREATE TABLE [DimBank] (
	[ID] int IDENTITY(1,1) NOT NULL UNIQUE,
	[BankName] nvarchar(255) NOT NULL,
	PRIMARY KEY ([ID])
);

CREATE TABLE [DimAccounts] (
	[ID] int IDENTITY(1,1) NOT NULL UNIQUE,
	[AccountName] nvarchar(255) NOT NULL,
	[BankID] int NOT NULL,
	PRIMARY KEY ([ID])
);

ALTER TABLE [FactTransactions] ADD CONSTRAINT [FactTransactions_fk2] FOREIGN KEY ([TransactionCategoryID]) REFERENCES [DimTransactionCategory]([ID]);

ALTER TABLE [FactTransactions] ADD CONSTRAINT [FactTransactions_fk3] FOREIGN KEY ([TransactionTypeID]) REFERENCES [DimTransactionType]([ID]);

ALTER TABLE [FactTransactions] ADD CONSTRAINT [FactTransactions_fk4] FOREIGN KEY ([AmountCurrencyID]) REFERENCES [DimCurrency]([ID]);

ALTER TABLE [FactTransactions] ADD CONSTRAINT [FactTransactions_fk5] FOREIGN KEY ([BalanceCurrencyID]) REFERENCES [DimCurrency]([ID]);

ALTER TABLE [FactTransactions] ADD CONSTRAINT [FactTransactions_fk10] FOREIGN KEY ([AccountID]) REFERENCES [DimAccounts]([ID]);




ALTER TABLE [DimAccounts] ADD CONSTRAINT [DimAccounts_fk2] FOREIGN KEY ([BankID]) REFERENCES [DimBank]([ID]);
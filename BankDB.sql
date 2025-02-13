USE [master]
GO
/****** Object:  Database [BankDB]    Script Date: 09/11/1402 07:40:06 ب.ظ ******/
CREATE DATABASE [BankDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BankDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\BankDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'BankDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\BankDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [BankDB] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BankDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BankDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BankDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BankDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BankDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BankDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [BankDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BankDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BankDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BankDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BankDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BankDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BankDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BankDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BankDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BankDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BankDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BankDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BankDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BankDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BankDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BankDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BankDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BankDB] SET RECOVERY FULL 
GO
ALTER DATABASE [BankDB] SET  MULTI_USER 
GO
ALTER DATABASE [BankDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BankDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BankDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BankDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BankDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BankDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'BankDB', N'ON'
GO
ALTER DATABASE [BankDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [BankDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [BankDB]
GO
/****** Object:  UserDefinedFunction [dbo].[GetUserPassword]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetUserPassword] (@username VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @password VARCHAR(50);
    IF EXISTS (SELECT * FROM Users WHERE username = @username)
    BEGIN
        SELECT @password = password FROM Users WHERE username = @username;
    END
    RETURN @password;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetUserPasswordHash]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetUserPasswordHash] (@username VARCHAR(255))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @password NVARCHAR(MAX);
    IF EXISTS (SELECT * FROM Userstable WHERE username = @username)
    BEGIN
        SELECT @password = password FROM Userstable WHERE username = @username;
    END
    RETURN @password;
END;
GO
/****** Object:  Table [dbo].[transactionstable]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transactionstable](
	[trackingcode] [varchar](255) NOT NULL,
	[source] [int] NOT NULL,
	[destination] [int] NOT NULL,
	[amount] [decimal](10, 2) NULL,
	[type] [varchar](20) NOT NULL,
	[time] [time](7) NOT NULL,
	[data] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[trackingcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[get_last_n_transactions]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[get_last_n_transactions] (
    @n INT,
    @card_number VARCHAR(16)
)
RETURNS TABLE
AS
RETURN (
    SELECT TOP (@n) *
    FROM transactionstable
    WHERE source = @card_number OR destination = @card_number
    ORDER BY time DESC
);
GO
/****** Object:  UserDefinedFunction [dbo].[validate_transaction]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[validate_transaction] (
    @trackingcode VARCHAR(255)
)
RETURNS TABLE
AS
RETURN (
    SELECT *
    FROM transactionstable
    WHERE trackingcode = @trackingcode
);

GO
/****** Object:  Table [dbo].[accountstable]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountstable](
	[account_id] [int] NOT NULL,
	[card_number] [varchar](16) NOT NULL,
	[sheba_number] [varchar](24) NOT NULL,
	[balance] [decimal](10, 2) NULL,
	[username] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[account_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tranasactionsLimitTable]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranasactionsLimitTable](
	[account_id] [int] NOT NULL,
	[transaction_type] [varchar](10) NOT NULL,
	[today_transaction_amount] [decimal](10, 2) NULL,
	[limit] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[account_id] ASC,
	[transaction_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Userstable]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Userstable](
	[username] [varchar](10) NOT NULL,
	[firstname] [varchar](50) NULL,
	[lastname] [varchar](50) NULL,
	[nationalcode] [varchar](10) NULL,
	[password] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nationalcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[accountstable]  WITH CHECK ADD FOREIGN KEY([username])
REFERENCES [dbo].[Userstable] ([username])
GO
ALTER TABLE [dbo].[tranasactionsLimitTable]  WITH CHECK ADD FOREIGN KEY([account_id])
REFERENCES [dbo].[accountstable] ([account_id])
GO
ALTER TABLE [dbo].[transactionstable]  WITH CHECK ADD FOREIGN KEY([destination])
REFERENCES [dbo].[accountstable] ([account_id])
GO
ALTER TABLE [dbo].[transactionstable]  WITH CHECK ADD FOREIGN KEY([source])
REFERENCES [dbo].[accountstable] ([account_id])
GO
/****** Object:  StoredProcedure [dbo].[insert_account]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[insert_account]
    @username VARCHAR(10),
    @initial_balance DECIMAL(10, 2)
AS
BEGIN
    DECLARE @num_accounts INT;
    DECLARE @new_account_id INT;
    DECLARE @card_number VARCHAR(16);
    DECLARE @sheba_number VARCHAR(24);
    SELECT @num_accounts = COUNT(*) FROM accounts WHERE username = @username;
    SET @new_account_id = @num_accounts + 1;
    WHILE 1=1
    BEGIN
        SET @card_number = CONCAT('1234', RIGHT(CONVERT(VARCHAR(12), RAND()*1000000000000), 12));
        SET @sheba_number = CONCAT('IR', RIGHT(CONVERT(VARCHAR(22), RAND()*1000000000000000000000), 22));
        IF NOT EXISTS (SELECT * FROM accounts WHERE card_number = @card_number OR shaba_number = @sheba_number)
            BREAK;
    END;
    INSERT INTO accounts (account_id, username, card_number, shaba_number, balance) VALUES (@new_account_id, @username, @card_number, @sheba_number, @initial_balance);
END;

GO
/****** Object:  StoredProcedure [dbo].[transfer_funds]    Script Date: 09/11/1402 07:40:07 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[transfer_funds] (
    @source_account_id INT,
    @destination_account_id INT,
    @source_card_number VARCHAR(16),
    @destination_number VARCHAR(16),
    @amount DECIMAL(10, 2)
)
AS
BEGIN
    DECLARE @trackingcode VARCHAR(255);
    DECLARE @type VARCHAR(20) = 'debit, paya, satna';
    DECLARE @time TIME(7) = GETDATE();
    DECLARE @data DATE = GETDATE();

    -- Check if the source account has enough balance
    IF (SELECT balance FROM accountstable WHERE account_id = @source_account_id) < @amount
    BEGIN
        RAISERROR('Insufficient balance in source account', 16, 1);
        RETURN;
    END

    -- Update the source account balance
    UPDATE accountstable SET balance = balance - @amount WHERE account_id = @source_account_id;

    -- Update the destination account balance
    UPDATE accountstable SET balance = balance + @amount WHERE account_id = @destination_account_id;

END;
GO
USE [master]
GO
ALTER DATABASE [BankDB] SET  READ_WRITE 
GO

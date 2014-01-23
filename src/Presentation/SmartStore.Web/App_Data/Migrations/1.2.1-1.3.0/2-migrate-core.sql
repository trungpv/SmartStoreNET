IF EXISTS (SELECT 1 FROM [Setting] WHERE [name] = N'seosettings.reservedurlrecordslugs')
BEGIN
	DECLARE @ReservedSlugs nvarchar(4000)
	SELECT @ReservedSlugs = [Value] FROM [Setting] WHERE [name] = N'seosettings.reservedurlrecordslugs'
	
	IF (CHARINDEX(N'api', @ReservedSlugs) = 0)
	BEGIN
		UPDATE [Setting] SET [Value] = @ReservedSlugs + ',api' WHERE [name] = N'seosettings.reservedurlrecordslugs'
	END	
END
GO

IF EXISTS (SELECT 1 FROM [Setting] WHERE [name] = N'seosettings.reservedurlrecordslugs')
BEGIN
	DECLARE @ReservedSlugs nvarchar(4000)
	SELECT @ReservedSlugs = [Value] FROM [Setting] WHERE [name] = N'seosettings.reservedurlrecordslugs'
	
	IF (CHARINDEX(N'odata', @ReservedSlugs) = 0)
	BEGIN
		UPDATE [Setting] SET [Value] = @ReservedSlugs + ',odata' WHERE [name] = N'seosettings.reservedurlrecordslugs'
	END	
END
GO

IF EXISTS (SELECT 1 FROM [Setting] WHERE [name] = N'themesettings.csscacheenabled')
BEGIN
	DELETE FROM [Setting] WHERE [name] = N'themesettings.csscacheenabled'
END
GO

IF EXISTS (SELECT 1 FROM [Setting] WHERE [name] = N'themesettings.cssminifyenabled')
BEGIN
	DELETE FROM [Setting] WHERE [Name] = N'themesettings.cssminifyenabled'
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[ShippingMethod]') and NAME='IgnoreCharges')
BEGIN
	EXEC ('ALTER TABLE [ShippingMethod] ADD [IgnoreCharges] bit NULL')
	EXEC ('UPDATE [ShippingMethod] SET [IgnoreCharges] = 0 WHERE [IgnoreCharges] IS NULL')
	EXEC ('ALTER TABLE [ShippingMethod] ALTER COLUMN [IgnoreCharges] bit NOT NULL')
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[Log]') and NAME='UpdatedOnUtc')
BEGIN
	ALTER TABLE [Log] ADD [UpdatedOnUtc] datetime NULL
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[Log]') and NAME='Frequency')
BEGIN
	EXEC ('ALTER TABLE [Log] ADD [Frequency] int NULL')
	EXEC ('UPDATE [Log] SET [Frequency] = 1 WHERE [Frequency] IS NULL')
	EXEC ('ALTER TABLE [Log] ALTER COLUMN [Frequency] int NOT NULL')
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[Log]') and NAME='ContentHash')
BEGIN
	ALTER TABLE [Log] ADD [ContentHash] nvarchar(40) NULL
END
GO

IF NOT EXISTS (SELECT 1 from sys.indexes WHERE [NAME]=N'IX_Log_ContentHash' and object_id=object_id(N'[Log]'))
BEGIN
	CREATE NONCLUSTERED INDEX [IX_Log_ContentHash] ON [Log] ([ContentHash] ASC)
END
GO

--'Delete logs' schedule task (enabled by default)
IF NOT EXISTS (
		SELECT 1
		FROM [dbo].[ScheduleTask]
		WHERE [Name] = N'Delete logs')
BEGIN
	INSERT [dbo].[ScheduleTask] ([Name], [Seconds], [Type], [Enabled], [StopOnError])
	VALUES (N'Delete logs', 86400, N'SmartStore.Services.Logging.DeleteLogsTask, SmartStore.Services', 1, 0)
END
GO

-- AdminAreaSettings.RichEditorFlavor
IF NOT EXISTS (SELECT 1 FROM [Setting] WHERE [Name] = N'AdminAreaSettings.RichEditorFlavor')
BEGIN
	INSERT [Setting] ([Name], [Value], [StoreId])
	VALUES (N'AdminAreaSettings.RichEditorFlavor', N'RichEditor', 0)
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[Currency]') and NAME='DomainEndings')
BEGIN
	ALTER TABLE [Currency] ADD [DomainEndings] nvarchar(1000) NULL
END
GO
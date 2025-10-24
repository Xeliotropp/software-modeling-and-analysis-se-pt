CREATE DATABASE XDW;
GO

USE XDW;
GO

---------1) Drop if exists---------
IF OBJECT_ID('dbo.factSavedPosts') IS NOT NULL DROP TABLE dbo.factSavedPosts;
IF OBJECT_ID('dbo.factMessages') IS NOT NULL DROP TABLE dbo.factMessages;
IF OBJECT_ID('dbo.factComments') IS NOT NULL DROP TABLE dbo.factComments;
IF OBJECT_ID('dbo.factPosts') IS NOT NULL DROP TABLE dbo.factPosts;
IF OBJECT_ID('dbo.dimContentItem') IS NOT NULL DROP TABLE dbo.dimContentItem;
IF OBJECT_ID('dbo.dimPost') IS NOT NULL DROP TABLE dbo.dimPost;
IF OBJECT_ID('dbo.dimCommunity') IS NOT NULL DROP TABLE dbo.dimCommunity;
IF OBJECT_ID('dbo.dimPostType') IS NOT NULL DROP TABLE dbo.dimPostType;
IF OBJECT_ID('dbo.dimUser') IS NOT NULL DROP TABLE dbo.dimUser;
IF OBJECT_ID('dbo.dimDate') IS NOT NULL DROP TABLE dbo.dimDate;
GO
---------1) Drop if exists---------

---------2) Dimensions---------
---------dimDate---------
CREATE TABLE dbo.dimDate
(
  date_key INT NOT NULL PRIMARY KEY,
  full_date DATE NOT NULL,
  [year] INT NOT NULL,
  [quarter] TINYINT NOT NULL,
  [month] TINYINT NOT NULL,
  month_name NVARCHAR(20) NOT NULL,
  [day] TINYINT NOT NULL,
  day_of_week TINYINT NOT NULL,
  week_of_year TINYINT NOT NULL,
  is_weekend BIT NOT NULL 
);
GO
---------dimDate---------

---------dimUser---------
CREATE TABLE dbo.dimUser
(
  user_key INT IDENTITY(1,1) PRIMARY KEY,
  source_user_id INT NOT NULL UNIQUE,
  username NVARCHAR(100) NOT NULL,
  gender NVARCHAR(20) NULL
);
GO
---------dimUser---------

---------dimPostType---------
CREATE TABLE dbo.dimPostType
(
  post_type_key INT IDENTITY(1,1) PRIMARY KEY,
  source_post_type_id INT NOT NULL UNIQUE,
  type_name NVARCHAR(50) NOT NULL
);
GO
---------dimPostType---------

---------dimCommunity---------
CREATE TABLE dbo.dimCommunity
(
  community_key INT IDENTITY(1,1) PRIMARY KEY,
  source_community_id INT NOT NULL UNIQUE,
  [name] NVARCHAR(100) NOT NULL
);
GO
---------dimCommunity---------

---------dimPost---------
CREATE TABLE dbo.dimPost
(
  post_key INT IDENTITY(1,1) PRIMARY KEY,
  source_post_id INT NOT NULL UNIQUE,
  author_user_key INT NOT NULL REFERENCES dbo.dimUser(user_key),
  post_type_key INT NOT NULL REFERENCES dbo.dimPostType(post_type_key),
  created_date_key INT NOT NULL REFERENCES dbo.dimDate(date_key),
  content_len INT NULL
);
GO
---------dimPost---------

---------dimContentItem---------
CREATE TABLE dbo.dimContentItem
(
  content_key INT IDENTITY(1,1) PRIMARY KEY,
  content_type NVARCHAR(20) NOT NULL,  -- 'Article' | 'Image' | 'Stream'
  source_item_id INT NOT NULL,
  owner_user_key INT NOT NULL REFERENCES dbo.dimUser(user_key),
  published_date_key INT NOT NULL REFERENCES dbo.dimDate(date_key),
  title_or_alt NVARCHAR(200) NULL,
  CONSTRAINT UQ_dimContentItem UNIQUE (content_type, source_item_id)
);
GO
---------dimContentItem---------
---------2) Dimensions---------

---------3) Facts---------
---------factPosts---------
CREATE TABLE dbo.factPosts
(
  fact_post_id BIGINT IDENTITY(1,1) PRIMARY KEY,
  post_key INT NOT NULL REFERENCES dbo.dimPost(post_key),
  author_user_key INT NOT NULL REFERENCES dbo.dimUser(user_key),
  post_type_key INT NOT NULL REFERENCES dbo.dimPostType(post_type_key),
  created_date_key INT NOT NULL REFERENCES dbo.dimDate(date_key),
  post_count INT NOT NULL DEFAULT 1,
  post_len INT NULL
);
GO
---------factPosts---------

---------factComments---------
CREATE TABLE dbo.factComments
(
  fact_comment_id BIGINT IDENTITY(1,1) PRIMARY KEY,
  post_key INT NOT NULL REFERENCES dbo.dimPost(post_key),
  comment_author_key INT NOT NULL REFERENCES dbo.dimUser(user_key),
  comment_date_key INT NOT NULL REFERENCES dbo.dimDate(date_key),
  comment_count INT NOT NULL DEFAULT 1,
  comment_len INT NULL
);
GO
---------factComments---------

---------factMessages---------
CREATE TABLE dbo.factMessages
(
  fact_message_id BIGINT IDENTITY(1,1) PRIMARY KEY,
  sender_user_key INT NOT NULL REFERENCES dbo.dimUser(user_key),
  receiver_user_key INT NOT NULL REFERENCES dbo.dimUser(user_key),
  sent_date_key INT NOT NULL REFERENCES dbo.dimDate(date_key),
  message_count INT NOT NULL DEFAULT 1,
  message_len INT NULL
);
GO
---------factMessages---------

---------factSavedPosts---------
CREATE TABLE dbo.factSavedPosts
(
  fact_save_id BIGINT IDENTITY(1,1) PRIMARY KEY,
  saver_user_key INT NOT NULL REFERENCES dbo.dimUser(user_key),
  post_key INT NOT NULL REFERENCES dbo.dimPost(post_key),
  saved_date_key INT NOT NULL REFERENCES dbo.dimDate(date_key),
  save_count INT NOT NULL DEFAULT 1
);
GO
---------factSavedPosts---------
---------3) Facts---------

---------4) Populate dimDate---------
SET DATEFIRST 1;

DECLARE @start_date DATE = '2019-01-01';
DECLARE @end_date   DATE = DATEADD(DAY, 365, CAST(GETDATE() AS DATE));

;WITH d AS (
  SELECT @start_date AS d
  UNION ALL
  SELECT DATEADD(DAY, 1, d)
  FROM d
  WHERE d < @end_date
)
INSERT INTO dbo.dimDate
  (date_key, full_date, [year], [quarter], [month], month_name, [day], day_of_week, week_of_year, is_weekend)
SELECT
  (YEAR(d.d) * 10000) + (MONTH(d.d) * 100) + DAY(d.d)          AS date_key,     -- по-бързо и без FORMAT()
  d.d                                                          AS full_date,
  YEAR(d.d)                                                    AS [year],
  DATEPART(QUARTER, d.d)                                       AS [quarter],
  MONTH(d.d)                                                   AS [month],
  DATENAME(MONTH, d.d)                                         AS month_name,
  DAY(d.d)                                                     AS [day],
  ((DATEPART(WEEKDAY, d.d) + 6) % 7) + 1                       AS day_of_week,   -- 1..7 (Mon..Sun)
  DATEPART(ISO_WEEK, d.d)                                      AS week_of_year,  -- ISO седмица
  CASE WHEN ((DATEPART(WEEKDAY, d.d) + 6) % 7) + 1 IN (6, 7) THEN 1 ELSE 0 END AS is_weekend
FROM d
OPTION (MAXRECURSION 0);
GO
---------4) Populate dimDate---------

---------5) Full reload for dims/facts---------
BEGIN TRY
  BEGIN TRAN;

  TRUNCATE TABLE dbo.factSavedPosts;
  TRUNCATE TABLE dbo.factMessages;
  TRUNCATE TABLE dbo.factComments;
  TRUNCATE TABLE dbo.factPosts;

  DELETE FROM dbo.dimPost;
  DELETE FROM dbo.dimContentItem;
  DELETE FROM dbo.dimUser;
  DELETE FROM dbo.dimPostType;
  DELETE FROM dbo.dimCommunity;

  DBCC CHECKIDENT ('dbo.dimUser',       RESEED, 0);
  DBCC CHECKIDENT ('dbo.dimPostType',   RESEED, 0);
  DBCC CHECKIDENT ('dbo.dimCommunity',  RESEED, 0);
  DBCC CHECKIDENT ('dbo.dimPost',       RESEED, 0);
  DBCC CHECKIDENT ('dbo.dimContentItem',RESEED, 0);

---------Re-load dims---------
  INSERT INTO dbo.dimUser (source_user_id, username, gender)
  SELECT u.UserID, u.Username, u.Gender
  FROM XDB.Core.Users u;

  INSERT INTO dbo.dimPostType (source_post_type_id, type_name)
  SELECT pt.PostTypeID, pt.TypeName
  FROM XDB.Ref.PostTypes pt;

  INSERT INTO dbo.dimCommunity (source_community_id, [name])
  SELECT c.CommunityID, c.[Name]
  FROM XDB.Social.Communities c;

  INSERT INTO dbo.dimPost (source_post_id, author_user_key, post_type_key, created_date_key, content_len)
  SELECT
    p.PostID,
    du.user_key,
    dpt.post_type_key,
    dd.date_key,
    LEN(p.Content)
  FROM XDB.Core.Posts p
  JOIN dbo.dimUser du ON du.source_user_id = p.UserID
  JOIN dbo.dimPostType dpt ON dpt.source_post_type_id = p.PostTypeID
  JOIN dbo.dimDate dd ON dd.full_date = CAST(p.CreatedAt AS DATE);

  INSERT INTO dbo.dimContentItem
    (content_type, source_item_id, owner_user_key, published_date_key, title_or_alt)
  SELECT
    ci.ItemType,
    ci.ItemID,
    du.user_key,
    dd.date_key,
    ci.TitleOrAlt
  FROM XDB.Content.vw_ContentItems AS ci
  JOIN dbo.dimUser du ON du.source_user_id = ci.OwnerID
  JOIN dbo.dimDate dd ON dd.full_date     = ci.EventDate;
  
  ---------Re-load dims---------

  ---------Re-load facts---------
  INSERT INTO dbo.factPosts (post_key, author_user_key, post_type_key, created_date_key, post_count, post_len)
  SELECT
    dp.post_key,
    dp.author_user_key,
    dp.post_type_key,
    dp.created_date_key,
    1,
    dp.content_len
  FROM dbo.dimPost dp;

  INSERT INTO dbo.factComments (post_key, comment_author_key, comment_date_key, comment_count, comment_len)
  SELECT
    dp.post_key,
    du.user_key,
    dd.date_key,
    1,
    LEN(c.Content)
  FROM XDB.Core.Comments c
  JOIN dbo.dimPost dp ON dp.source_post_id = c.PostID
  JOIN dbo.dimUser du ON du.source_user_id = c.UserID
  JOIN dbo.dimDate dd ON dd.full_date = CAST(c.CreatedAt AS DATE);

  INSERT INTO dbo.factMessages (sender_user_key, receiver_user_key, sent_date_key, message_count, message_len)
  SELECT
    dus.user_key,
    dur.user_key,
    dd.date_key,
    1,
    LEN(m.Content)
  FROM XDB.Core.Messages m
  JOIN dbo.dimUser dus ON dus.source_user_id = m.SenderID
  JOIN dbo.dimUser dur ON dur.source_user_id = m.ReceiverID
  JOIN dbo.dimDate dd  ON dd.full_date = CAST(m.SentAt AS DATE);

  INSERT INTO dbo.factSavedPosts (saver_user_key, post_key, saved_date_key, save_count)
  SELECT
    du.user_key,
    dp.post_key,
    dp.created_date_key,
    1
  FROM XDB.Social.SavedPosts sp
  JOIN dbo.dimUser du ON du.source_user_id = sp.UserID
  JOIN dbo.dimPost dp ON dp.source_post_id = sp.PostID;

  COMMIT TRAN;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRAN;
  THROW;
END CATCH;
---------5) Full reload for dims/facts---------

---------6) Quick sanity checks---------
PRINT '=== Row counts ===';
SELECT 'dimDate' AS [table], COUNT(*) AS cnt FROM dbo.dimDate UNION ALL
SELECT 'dimUser', COUNT(*) FROM dbo.dimUser UNION ALL
SELECT 'dimPostType', COUNT(*) FROM dbo.dimPostType UNION ALL
SELECT 'dimCommunity', COUNT(*) FROM dbo.dimCommunity UNION ALL
SELECT 'dimPost', COUNT(*) FROM dbo.dimPost UNION ALL
SELECT 'dimContentItem', COUNT(*) FROM dbo.dimContentItem UNION ALL
SELECT 'factPosts', COUNT(*) FROM dbo.factPosts UNION ALL
SELECT 'factComments', COUNT(*) FROM dbo.factComments UNION ALL
SELECT 'factMessages', COUNT(*) FROM dbo.factMessages UNION ALL
SELECT 'factSavedPosts', COUNT(*) FROM dbo.factSavedPosts;
PRINT 'XDW build & load complete.';
---------6)Quick sanity checks---------

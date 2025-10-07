USE XDB
GO

---------PROCEDURES---------
---------Core.AddPosts---------
CREATE OR ALTER PROCEDURE Core.AddPost
  @UserID INT,
  @PostTypeID INT,
  @Content NVARCHAR(MAX),
  @NewPostID INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  IF NOT EXISTS (SELECT 1 FROM Core.Users WHERE UserID = @UserID)
    THROW 50001, 'Invalid UserID', 1;
  IF NOT EXISTS (SELECT 1 FROM Ref.PostTypes WHERE PostTypeID = @PostTypeID)
    THROW 50002, 'Invalid PostTypeID', 1;
  IF (@Content IS NULL OR LEN(@Content) = 0)
    THROW 50003, 'Content cannot be empty', 1;
  INSERT INTO Core.Posts (Content, UserID, PostTypeID)
  VALUES (@Content, @UserID, @PostTypeID);
  SET @NewPostID = SCOPE_IDENTITY();
END;
GO
---------Core.AddPosts---------

---------Core.AddComment---------
CREATE OR ALTER PROCEDURE Core.AddComment
  @PostID INT,
  @UserID INT,
  @Content NVARCHAR(MAX),
  @NewCommentID INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  IF NOT EXISTS (SELECT 1 FROM Core.Posts WHERE PostID = @PostID)
    THROW 50010, 'Invalid PostID', 1;
  IF NOT EXISTS (SELECT 1 FROM Core.Users WHERE UserID = @UserID)
    THROW 50011, 'Invalid UserID', 1;
  IF (@Content IS NULL OR LEN(@Content) = 0)
    THROW 50012, 'Content cannot be empty', 1;
  INSERT INTO Core.Comments (Content, PostID, UserID)
  VALUES (@Content, @PostID, @UserID);
  SET @NewCommentID = SCOPE_IDENTITY();
END;
GO
---------Core.AddComment---------

---------Social.ToggleSavedPost---------
CREATE OR ALTER PROCEDURE Social.ToggleSavedPost
  @UserID INT,
  @PostID INT,
  @Action NVARCHAR(10) OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  IF NOT EXISTS (SELECT 1 FROM Core.Users WHERE UserID = @UserID)
    THROW 50020, 'Invalid UserID', 1;
  IF NOT EXISTS (SELECT 1 FROM Core.Posts WHERE PostID = @PostID)
    THROW 50021, 'Invalid PostID', 1;
  IF EXISTS (SELECT 1 FROM Social.SavedPosts WHERE UserID=@UserID AND PostID=@PostID)
  BEGIN
    DELETE FROM Social.SavedPosts WHERE UserID=@UserID AND PostID=@PostID;
    SET @Action = N'Removed';
  END
  ELSE
  BEGIN
    INSERT INTO Social.SavedPosts (UserID, PostID)
    VALUES (@UserID, @PostID);
    SET @Action = N'Added';
  END
END;
GO
---------Social.ToggleSavedPost---------
---------PROCEDURES---------

---------FUNCTIONS---------
---------Core.fn_PostSummary--------- (skalarna funkziq)
CREATE OR ALTER FUNCTION Core.fn_PostSummary(@PostID INT)
RETURNS NVARCHAR(200)
AS
BEGIN
  DECLARE @Result NVARCHAR(200);
  SELECT @Result = T.TypeName + N': ' + LEFT(P.Content, 50)
  FROM Core.Posts P
  JOIN Ref.PostTypes T ON P.PostTypeID = T.PostTypeID
  WHERE P.PostID = @PostID;
  RETURN @Result;
END;
GO
---------Core.fn_PostSummary--------- (skalarna funkziq)

---------Social.fn_UserSavedPosts--------- (tablichna funkziq)
CREATE OR ALTER FUNCTION Social.fn_UserSavedPosts(@UserID INT)
RETURNS TABLE
AS
RETURN
(
  SELECT P.PostID, P.Content, P.CreatedAt
  FROM Social.SavedPosts S
  JOIN Core.Posts P ON S.PostID = P.PostID
  WHERE S.UserID = @UserID
);
GO
---------Social.fn_UserSavedPosts--------- (tablichna funkziq)

---------Core.fn_UserPostCount--------- (skalarna funkziq)
CREATE OR ALTER FUNCTION Core.fn_UserPostCount(@UserID INT)
RETURNS INT
AS
BEGIN
  DECLARE @Count INT;
  SELECT @Count = COUNT(*)
  FROM Core.Posts
  WHERE UserID = @UserID;
  RETURN ISNULL(@Count,0);
END;
GO
---------Core.fn_UserPostCount--------- (skalarna funkziq)
---------FUNCTIONS---------

---------TRIGGERS---------
---------Core.tr_NoSelfMessage---------
CREATE OR ALTER TRIGGER Core.tr_NoSelfMessage
ON Core.Messages
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS (
    SELECT 1
    FROM Inserted
    WHERE SenderID = ReceiverID
  )
  BEGIN
  ROLLBACK TRANSACTION;
  THROW 50011, 'User cannot send message to themselves', 1;
  END
END;
GO
---------Core.tr_NoSelfMessage---------

---------Core.tr_LogComment---------
IF OBJECT_ID('Core.CommentLogs','U') IS NULL
BEGIN
  CREATE TABLE Core.CommentLogs
  (
    LogID INT IDENTITY PRIMARY KEY,
    CommentID INT,
    UserID INT,
    CreatedAt DATETIME2 DEFAULT GETDATE()
  );
END;
GO

CREATE OR ALTER TRIGGER Core.tr_LogComment
ON Core.Comments
AFTER INSERT
AS
BEGIN
  INSERT INTO Core.CommentLogs (CommentID, UserID)
  SELECT i.CommentID, i.UserID
  FROM Inserted i;
END;
GO
---------Core.tr_LogComment---------

---------Core.tr_NoEmptyContent---------
CREATE OR ALTER TRIGGER Core.tr_NoEmptyContent
ON Core.Posts
FOR INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS (
    SELECT 1
    FROM Inserted
    WHERE (Content IS NULL OR LTRIM(RTRIM(Content)) = '')
  )
  BEGIN
    ROLLBACK TRANSACTION;
    THROW 50012, 'Post content cannot be empty', 1;
    END
  END;
GO
---------Core.tr_NoEmptyContent---------
---------TRIGGERS---------

---------TEST---------
---------Core.AddPosts---------
DECLARE @newPostID INT;
EXEC Core.AddPost 
    @UserID = 1,
    @PostTypeID = 1,
    @Content = N'This is my new test post',
    @NewPostID = @newPostID OUTPUT;
SELECT @newPostID AS NewPostID;
---------Core.AddPosts---------

---------Core.AddComment---------
DECLARE @newCommentID INT;
EXEC Core.AddComment 
    @PostID = 1,
    @UserID = 2,
    @Content = N'Great post!',
    @NewCommentID = @newCommentID OUTPUT;
SELECT @newCommentID AS NewCommentID;
---------Core.AddComment---------

---------Social.ToggleSavedPost---------
DECLARE @action NVARCHAR(10);
EXEC Social.ToggleSavedPost 
    @UserID = 2, 
    @PostID = 1, 
    @Action = @action OUTPUT;
SELECT @action AS ActionTaken;
---------Social.ToggleSavedPost---------

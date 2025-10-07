USE XDB
GO

----------Detailed Posts----------
CREATE OR ALTER VIEW Core.vw_PostsDetailed AS
SELECT
  p.PostID,
  p.UserID,
  u.Username,
  p.PostTypeID,
  t.TypeName,
  p.CreatedAt,
  CAST(p.CreatedAt AS date) AS CreatedDate,
  p.Content,
  LEFT(p.Content,120) AS ContentPreview,
  LEN(p.Content) AS PostLen
FROM Core.Posts p
JOIN Core.Users u ON u.UserID = p.UserID
JOIN Ref.PostTypes t ON t.PostTypeID = p.PostTypeID
GO
----------Detailed Posts----------

----------Detailed Comments----------
CREATE OR ALTER VIEW Core.vw_CommentsDetailed AS
SELECT
  c.CommentID,
  c.PostID,
  p.UserID AS PostOwnerID,
  uPost.Username AS PostOwner,
  c.UserID AS CommentAuthorID,
  uComment.Username AS CommentAuthor,
  c.CreatedAt,
  CAST(c.CreatedAt AS date) AS CreatedDate,
  c.Content
FROM Core.Comments c
JOIN Core.Posts p ON p.PostID = c.PostID
JOIN Core.Users uPost ON uPost.UserID = p.UserID
JOIN Core.Users uComment ON uComment.UserID = c.UserID;
GO
----------Detailed Comments----------

----------User Engagement----------
CREATE OR ALTER VIEW Core.vw_UserEngagement AS
SELECT
  u.UserID,
  u.Username,
  ISNULL(p.PostsCnt,0) AS PostCnt,
  ISNULL(c.CommentsCnt,0) AS CommentsCnt,
  ISNULL(s.SavedCnt,0) AS SavedCnt
FROM Core.Users u
LEFT JOIN (
  SELECT UserID, COUNT(*) AS PostsCnt
  FROM Core.Posts GROUP BY UserID
) p ON p.UserID = u.UserID
LEFT JOIN (
  SELECT UserID, Count(*) AS CommentsCnt
  FROM Core.Comments GROUP BY UserID
) c ON c.UserID = u.UserID
LEFT JOIN (
  SELECT UserID, COUNT(*) AS SavedCnt
  FROM Social.SavedPosts GROUP BY UserID
) s ON s.UserID = u.UserID
GO
----------User Engagement----------

----------Saved Posts----------
CREATE OR ALTER VIEW Social.vw_SavedPostsDetailed AS
SELECT
  s.UserID,
  u.Username,
  s.PostID,
  p.CreatedAt AS PostCreatedAt,
  CAST(p.CreatedAt AS date) PostCreatedDate,
  p.Content,
  t.TypeName AS PostType
FROM Social.SavedPosts s
JOIN Core.Users u ON u.UserID = s.UserID
JOIN Core.Posts p ON p.PostID = s.PostID
JOIN Ref.PostTypes t ON t.PostTypeID = p.PostTypeID
GO
----------Saved Posts----------

----------Communities----------
CREATE OR ALTER VIEW Social.vw_CommunityStats AS
SELECT
  c.CommunityID,
  c.Name,
  c.CreatedAt,
  CAST(c.CreatedAt AS date) AS CreatedDate,
  COUNT(cm.UserID) AS MemberCount
FROM Social.Communities c
LEFT JOIN Social.CommunityMembers cm ON cm.CommunityID = c.CommunityID
GROUP BY c.CommunityID, c.Name, c.CreatedAt;
GO
----------Communities----------

----------Messages----------
CREATE OR ALTER VIEW Core.vw_MessagesDetailed AS
SELECT
  m.MessageID,
  m.SentAt,
  CAST(m.SentAt AS date) AS SentDate,
  m.Content,
  m.SenderID,
  us.Username AS SenderUsername,
  m.ReceiverID,
  ur.Username AS ReceiverUsername
FROM Core.Messages m
JOIN Core.Users us ON us.UserID = m.SenderID
JOIN Core.Users ur ON ur.UserID = m.ReceiverID;
GO
----------Messages----------

----------Content----------
CREATE OR ALTER VIEW Content.vw_ContentItems AS
SELECT
  'Article' AS ItemType,
  a.ArticleID AS ItemID,
  a.Title AS TitleOrAlt,
  a.PublishedAt AS EventAt,
  CAST(a.PublishedAt AS date) AS EventDate,
  a.AuthorID AS OwnerID,
  u.Username as OwnerUsername
FROM Content.Articles a
JOIN Core.Users u ON u.UserID = a.AuthorID
UNION ALL
SELECT
  'Image',
  i.ImageID,
  i.AltText,
  i.PublishedAt,
  CAST(i.PublishedAt AS date),
  i.PublisherID,
  u.Username
FROM Content.Images i
JOIN Core.Users u ON u.UserID = i.PublisherID
UNION ALL
SELECT
  'Stream',
  s.StreamID,
  s.Title,
  s.StartedAt,
  CAST(s.StartedAt AS date),
  s.UserID,
  u.Username
FROM Content.Streams s
JOIN Core.Users u ON u.UserID = s.UserID;
GO
----------Content----------

USE XDB;
GO

--------TopUsers--------
SELECT
  ue.UserID,
  ue.Username,
  ue.PostCnt,
  ue.CommentsCnt,
  ue.SavedCnt,
  (ue.PostCnt*1.0 + ue.CommentsCnt*0.8 + ue.SavedCnt*0.5) AS EngagementScore
FROM Core.vw_UserEngagement ue
ORDER BY EngagementScore DESC, ue.PostCnt DESC;
GO
--------TopUsers--------

--------PostsByTypeAndMonth--------
SELECT
  DATEFROMPARTS(YEAR(p.CreatedDate),MONTH(p.CreatedDate), 1) AS MonthStart,
  p.TypeName,
  COUNT(*) AS PostsCount
FROM Core.vw_PostsDetailed p
GROUP BY DATEFROMPARTS(YEAR(p.CreatedDate), MONTH(p.CreatedDate), 1), p.TypeName
ORDER BY MonthStart, TypeName;
GO
--------PostsByTypeAndMonth--------

--------MostSavedPosts--------
SELECT TOP(10)
  sp.PostID,
  LEFT(sp.Content, 120) AS ContentPreview,
  sp.PostType,
  COUNT(*) AS SavedTimes
FROM Social.vw_SavedPostsDetailed sp
GROUP BY sp.PostID, sp.Content, sp.PostType
ORDER BY SavedTimes DESC, sp.PostID;
GO
--------MostSavedPosts--------

--------CommentsInTheLastThirtyDays--------
SELECT
  cd.CommentID,
  cd.CreatedAt,
  cd.PostID,
  cd.PostOwner AS PostAuthor,
  cd.CommentAuthor,
  cd.Content
FROM Core.vw_CommentsDetailed cd
WHERE cd.CreatedAt >= DATEADD(DAY, -30, GETDATE())
ORDER BY cd.CreatedAt DESC;
GO
--------CommentsInTheLastThirtyDays--------

--------SelfSavedPosts--------
SELECT
  u.UserID,
  u.Username,
  COALESCE(SUM(CASE WHEN s.UserID = p.UserID THEN 1 ELSE 0 END), 0) AS SelfSavedCount
FROM Core.Users u
LEFT JOIN Core.Posts p ON p.UserID = u.UserID
LEFT JOIN Social.SavedPosts s ON s.PostID = p.PostID
GROUP BY u.UserID, u.Username
ORDER BY SelfSavedCount DESC, u.Username;
GO 
--------SelfSavedPosts--------

--------Top3LongestPostsPerUser--------
WITH PostsByLen AS (
  SELECT
    p.UserID,
    u.Username,
    p.PostID,
    LEN(p.Content) as PostLen,
    ROW_NUMBER() OVER (PARTITION BY p.UserID ORDER BY LEN(p.Content) DESC, p.PostID) AS rn
  FROM Core.Posts p
  JOIN Core.Users u ON u.UserID = p.UserID
)
SELECT
  UserID,
  Username,
  PostID,
  PostLen
FROM PostsByLen
WHERE rn <= 3
ORDER BY Username, rn;
GO
--------Top3LongestPostsPerUser--------

--------WhoIsTextingWho--------
SELECT
  md.SenderUsername,
  md.ReceiverUsername,
  COUNT(*) AS MessagesCount
FROM Core.vw_MessagesDetailed md
GROUP BY md.SenderUsername, md.ReceiverUsername
ORDER BY MessagesCount DESC;
GO
--------WhoIsTextingWho--------

CREATE DATABASE XDB;
GO
USE XDB;
GO

CREATE SCHEMA Core;
GO
CREATE SCHEMA Content;
GO
CREATE SCHEMA Social;
GO
CREATE Schema Ref;
GO

-----------Core.Users-----------
CREATE TABLE Core.Users
(
  UserID INT IDENTITY PRIMARY KEY,
  Username NVARCHAR(50) NOT NULL UNIQUE,
  Email NVARCHAR(100) NOT NULL UNIQUE,
  PasswordHash NVARCHAR(255) NOT NULL,
  DateJoined DATETIME2 NOT NULL DEFAULT GETDATE(),
  Gender NVARCHAR(10)
);
-----------Core.Users-----------

-----------Ref.PostTypes-----------
CREATE TABLE Ref.PostTypes
(
  PostTypeID INT IDENTITY PRIMARY KEY,
  TypeName NVARCHAR(20) NOT NULL
);
-----------Ref.PostTypes-----------

-----------Core.Posts-----------
CREATE TABLE Core.Posts 
(
  PostID INT IDENTITY PRIMARY KEY,
  Content NVARCHAR(MAX) NOT NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
  UserID INT NOT NULL,
  PostTypeID INT NOT NULL,
  CONSTRAINT FK_Posts_UserID FOREIGN KEY (UserID) REFERENCES Core.Users(UserID),
  CONSTRAINT FK_Posts_PostTypeID FOREIGN KEY (PostTypeID) REFERENCES Ref.PostTypes(PostTypeID)
);
-----------Core.Posts-----------

-----------Core.Comments-----------
CREATE TABLE Core.Comments
(
  CommentID INT IDENTITY PRIMARY KEY,
  Content NVARCHAR(MAX) NOT NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
  PostID INT NOT NULL,
  UserID INT NOT NULL,
  CONSTRAINT FK_Comments_PostID FOREIGN KEY (PostID) REFERENCES Core.Posts(PostID),
  CONSTRAINT FK_Comments_UserID FOREIGN KEY (UserID) REFERENCES Core.Users(UserID)
);
-----------Core.Comments-----------

-----------Core.Messages-----------
CREATE TABLE Core.Messages 
(
  MessageID INT IDENTITY PRIMARY KEY,
  Content NVARCHAR(MAX) NOT NULL,
  SentAt DATETIME2 NOT NULL DEFAULT GETDATE(),
  SenderID INT NOT NULL,
  ReceiverID INT NOT NULL,
  CONSTRAINT FK_Messages_SenderID FOREIGN KEY (SenderID) REFERENCES Core.Users(UserID),
  CONSTRAINT FK_Messages_ReceiverID FOREIGN KEY (ReceiverID) REFERENCES Core.Users(UserID)
);
-----------Core.Messages-----------

-----------Social.SavedPosts-----------
CREATE TABLE Social.SavedPosts
(
  UserID INT NOT NULL,
  PostID INT NOT NULL,
  CONSTRAINT FK_SavedPosts_UserID FOREIGN KEY (UserID) REFERENCES Core.Users(UserID),
  CONSTRAINT FK_SavedPosts_PostID FOREIGN KEY (PostID) REFERENCES Core.Posts(PostID),
  PRIMARY KEY (UserID, PostID)
);
-----------Social.SavedPosts-----------

-----------Content.Articles-----------
CREATE TABLE Content.Articles 
(
  ArticleID INT IDENTITY PRIMARY KEY,
  Title NVARCHAR(200) NOT NULL,
  Body NVARCHAR(MAX) NOT NULL,
  PublishedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
  AuthorID INT NOT NULL,
  CONSTRAINT FK_Articles_AuthorID FOREIGN KEY (AuthorID) REFERENCES Core.Users(UserID)
);
-----------Content.Articles-----------

-----------Content.Images-----------
CREATE TABLE Content.Images 
(
  ImageID INT IDENTITY PRIMARY KEY,
  AltText NVARCHAR(200) NOT NULL,
  PublishedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
  PublisherID INT NOT NULL,
  CONSTRAINT FK_Images_PublisherID FOREIGN KEY (PublisherID) REFERENCES Core.Users(UserID)
);
-----------Content.Images-----------

-----------Content.Streams-----------
CREATE TABLE Content.Streams
(
  StreamID INT IDENTITY PRIMARY KEY,
  Title NVARCHAR(100) NOT NULL,
  StartedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
  EndedAt DATETIME2,
  UserID INT NOT NULL,
  CONSTRAINT FK_Streams_UserID FOREIGN KEY (UserID) REFERENCES Core.Users(UserID)
);
-----------Content.Streams-----------

-----------Social.Communities-----------
CREATE TABLE Social.Communities
(
  CommunityID INT IDENTITY PRIMARY KEY,
  Name NVARCHAR(100) NOT NULL UNIQUE,
  [Description] NVARCHAR(255),
  CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
);
-----------Social.Communities-----------

-----------Social.CommunityMembers-----------
CREATE TABLE Social.CommunityMembers
(
  CommunityID INT NOT NULL,
  UserID INT NOT NULL,
  CONSTRAINT FK_CommunityMembers_CommunityID FOREIGN KEY (CommunityID) REFERENCES Social.Communities(CommunityID),
  CONSTRAINT FK_CommunityMembers_UserID FOREIGN KEY (UserID) REFERENCES Core.Users(UserID),
  PRIMARY KEY (CommunityID, UserID)
);
-----------Social.CommunityMembers-----------

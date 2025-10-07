USE XDB
GO

---------Ref.PostTypes---------
INSERT INTO Ref.PostTypes (TypeName) VALUES
(N'Text'),
(N'Image'),
(N'Video'),
(N'Article'),
(N'Stream');
---------Ref.PostTypes---------

---------Core.Users---------
INSERT INTO Core.Users (Username, Email, PasswordHash, Gender)
VALUES
(N'ivan123', N'ivan@example.com', N'hash1', N'Male'),
(N'maria_s', N'maria@example.com', N'hash2', N'Female'),
(N'gosho98', N'gosho@example.com', N'hash3', N'Male'),
(N'ani_p', N'ani@example.com', N'hash4', N'Female'),
(N'petar_dev', N'petar@example.com', N'hash5', N'Male');
---------Core.Users---------

---------Core.Posts---------
INSERT INTO Core.Posts (Content, UserID, PostTypeID)
VALUES
(N'Hello SQL World!', 1, 1),
(N'Check out my first photo!', 2, 2),
(N'Here is a short video clip.', 3, 3),
(N'My first article is up!', 4, 4),
(N'Live stream tonight at 20:00', 5, 5);
---------Core.Posts---------

---------Core.Comments---------
INSERT INTO Core.Comments (Content, PostID, UserID)
VALUES
(N'Cool post!', 1, 2),
(N'Nice shot!', 2, 1),
(N'Can’t wait for the stream!', 5, 3),
(N'Interesting article.', 4, 2),
(N'Great video!', 3, 4);
---------Core.Comments---------

---------Core.Messages---------
INSERT INTO Core.Messages (Content, SenderID, ReceiverID)
VALUES
(N'Hi Maria, how are you?', 1, 2),
(N'All good, thanks!', 2, 1),
(N'Petar, did you finish the code?', 3, 5),
(N'Yes, I’ll push it tonight.', 5, 3);
---------Core.Messages---------

---------Social.SavedPosts---------
INSERT INTO Social.SavedPosts (UserID, PostID)
VALUES
(1, 2), -- Ivan saved Maria’s photo
(2, 1), -- Maria saved Ivan’s post
(3, 5), -- Gosho saved Petar’s stream
(4, 3); -- Ani saved Gosho’s video
---------Social.SavedPosts---------

---------Content.Articles---------
INSERT INTO Content.Articles (Title, Body, AuthorID)
VALUES
(N'Getting started with SQL', N'A beginner guide to SQL basics.', 4),
(N'Top 5 travel tips', N'Always plan ahead.', 2);
---------Content.Articles---------

---------Content.Images---------
INSERT INTO Content.Images (AltText, PublisherID)
VALUES
(N'Sunset at the beach', 2),
(N'My dog playing outside', 1),
(N'Mountain hike selfie', 4);
---------Content.Images---------

---------Content.Streams---------
INSERT INTO Content.Streams (Title, UserID)
VALUES
(N'Gaming night with friends', 5),
(N'Q&A session live', 1);
---------Content.Streams---------

---------Social.Communities-----------
INSERT INTO Social.Communities (Name, [Description])
VALUES
(N'DevsBG', N'Bulgarian developers community'),
(N'TravelLovers', N'People who love traveling'),
(N'GamersClub', N'All about gaming');
---------Social.Communities-----------

---------Social.CommunityMembers-----------
INSERT INTO Social.CommunityMembers (CommunityID, UserID)
VALUES
(1,1), (1,3), (1,5),   -- Ivan, Gosho, Petar in DevsBG
(2,2), (2,4),          -- Maria, Ani in TravelLovers
(3,1), (3,2), (3,3), (3,4), (3,5); -- Everyone in GamersClub
---------Social.CommunityMembers-----------

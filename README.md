# X(Twitter) Platform Database Project
## Факултетни номера: 2301322014 и 2301322012
## Описание:
Проектът представлява модел на социалната мрежа X(Twitter), реализиран като база данни в MSSQL Server.
Съдържа структура от таблици, референтни данни, програмни обекти и изгледи за интеграция с PowerBI инструменти.
## Инструкции за изпълнение: 
1. Стартирай `01_schema.sql`, за създаване на структурата на базата.
2. Стартирай `02_seed.sql`, за да се заредят данните.
3. Стартирай `03_procs_funcs_triggers.sql`, за да се добавят процедурите, функциите и тригерите.
4. Стартирай `04_views.sql`, за да се създадат View-тата
5. Стартирай `05_queries.sql`, за примерни заявки
## Таблици(11)
### Core: `Users` `Posts` `Comments` `Messages` `SavedPosts`
### Ref: `PostTypes`
### Content: `Articles` `Images` `Streams`
### Social: `Communities` `CommunityMembers`
## Views(7)
- Core.vw_PostsDetailed
- Core.vw_CommentsDetailed
- Social.vw_CommunityStats
- Core.vw_UserEngagement
- Core.vw_UserSavedPosts
- Core.vw_MessagesDetailed
- Content.vw_ContentItems
## Програмни обекти:
### Съхранени процедури: `AddPost` `AddComment` `ToggleSavedPost`
### Функции: `fn_PostSummary` `fn_UserSavedPosts` `fn_UserPostCount`
### Тригери: `tr_NoSelfMessage` `tr_LogComment` `tr_NoEmptyContent`
## Примерни заявки:
- **TopUsers** - класация по EngagementScore
- **PostsByTypeAndMonth** - обем постове по тип във времето
- **MostSavedPosts** - най-запазвани постове
- **CommentsInTheLastThirtyDays** - активност по коментари
- **SelfSavedPosts** - брой случаи, когато потребител е запазил собствен пост
- **WhoIsTextingWho** - матрица Sender->Receiver
- **Top3LongestPostsPerUser** - ранк на постовете по дължина
## Data Warehouse (XDW)
Data Warehouse слоят осигурява аналитична структура, базирана на данните от OLTP базата XDB. Създаден е по звездна схема (Star Schema), съдържаща 6 измерения и 4 факта.
### Измерения
- **dimDate** - Календарна таблица (година, месец, седмица, ден, уикенд).
- **dimUser** - Потребители от платформата (ключ, име, пол).
- **dimPostType** - Типове постове (текст, снимка, видео и др.).
- **dimCommunity** - Общности и групи на потребителите.
- **dimPost** - Публикации, свързани с потребител, тип и дата.
- **dimContentItem** - Обединено измерение за съдържание (Article, Image, Stream).
### Факти
- **factPosts** - Един ред на пост — съдържа дължина, дата и тип.
- **factComments** - Един ред на коментар — брой и дължина.
- **factMessages** - Един ред на съобщение между потребители.
- **factSavedPosts** - Един ред на запазване на пост (Save), с ключове към потребител и публикация.
### Зареждане (ETL)
1. Изпълнява се чрез скрипт 06_data_warehouse.sql
2. Прилага Full Reload стратегия (изтриване и повторно зареждане на данните).
3. Данните се извличат от OLTP схемите Core, Content и Social.
4. Процесът използва транзакции и защита от непълно зареждане.
5. Заредената база XDW е готова за свързване към Power BI.
## Концептуален модел (Chen notation)
Проектът включва концептуален модел, изграден по нотацията на Chen, който представя основните обекти и връзките между тях в платформата. Диаграмата съдържа:
- 8 entities
- Връзки между обектите
- Кардиналности (1:N, M:N) са ясно обозначени
- Включена е задължителната връзка много към много (User – belongs to – Community)
- .png и .drawio файловете се намират в папка diagrams
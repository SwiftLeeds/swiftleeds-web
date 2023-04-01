TRUNCATE TABLE "users" CASCADE;
INSERT INTO "users" ("id", "name", "password_hash", "email", "user_role") VALUES 
('7fd44e3e-44e9-4f5d-b440-74e99710a060', 'Test', '$2b$12$vjV9QYnEa/CtXovhSH9GnecpN5ddJWfRr6j747puqzFDeqUbBVNzC', 'test@test.com', 'admin');

TRUNCATE TABLE "events" CASCADE;
INSERT INTO "events" ("id", "name", "event_date", "location", "is_current") VALUES
('005a548b-9ebe-4742-8de5-8a37acaabab8', 'SwiftLeeds 2022', '2022-10-20', 'The Playhouse, Leeds', 'f'),
('a6b202de-6135-4e71-bdb0-290ecff798a8', 'SwiftLeeds 2023', '2023-10-18', 'The Playhouse, Leeds', 't');

TRUNCATE TABLE "sponsors" CASCADE;
INSERT INTO "sponsors" ("id", "name", "image", "url", "sponsor_level", "event_id") VALUES
('14b78287-6fed-4f1a-af56-b15abfff619b', 'RevenueCat', '1B6DDD64-3DCE-46BD-9EFB-75444654ADBE-revenuecat-logo-red.png', 'https://www.revenuecat.com/', 'gold', '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('3e77790c-9af5-4974-bf3c-9e6de79fb714', 'Bitrise', '806F78F2-734A-439A-838E-0B814894BFBD-bitrise.png', 'https://www.bitrise.io/', 'gold', '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('59497528-7795-4992-9a8d-0e5e3d90951d', 'Stream', 'D1EE069D-ABA4-4B50-9FE5-4DC443DE54A9-stream.png', 'https://getstream.io/chat/sdk/swiftui/?utm_source=SwiftLeeds&utm_medium=Whole_Event_L&utm_content=Developer&utm_campaign=SwiftLeeds_Oct2022', 'platinum', '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('6ca34a1e-d53e-4bc8-ac96-292d8ede1929', 'Xdesign', 'FC7899D1-D0B9-4834-9D5F-6616AE99CBFF-xdesign.png', 'https://www.xdesign.com/', 'gold', '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('aba7c468-4ce8-4188-9a4d-15480b0a6b39', 'AND Digital', '0C88E580-6814-47A0-B2F4-3EC78DC1B82B-and.png', 'https://www.and.digital/join/open-roles', 'gold', '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('c4948a85-96a1-47c2-9628-108e05cabec4', 'mkodo', '632CCBD3-1E2B-47A6-98D3-F3BAF6EDB641-mkodo.png', 'https://www.mkodo.com/s/careers', 'gold', '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('c648a09f-2bed-475f-8100-9bc9d2b14c9c', 'Codemagic', '0216EFFD-EFEA-4325-880C-CB74B1B16264-codemagic.png', 'https://codemagic.io/', 'platinum', '005a548b-9ebe-4742-8de5-8a37acaabab8');

TRUNCATE TABLE "speakers" CASCADE;
INSERT INTO "speakers" ("id", "name", "biography", "twitter", "organisation", "profile_image") VALUES
('019064d6-1f2f-4e3b-9243-831309a12030', 'Ibrahima Ciss', 'UI Designer converted to iOS Software Engineer. Love exploring iOS APIs and sharing my discoveries. Love everything about software design, testing, app architecture, and accessibility.', 'bionik6', 'iOS Consultant', '3bcb-0o0o0-YSidXenfoC6NqUT72UYZxk.jpeg-E57870EC-AF67-40B5-9129-F50F8B3CC937'),
('0373fc98-50d9-428c-a87d-bb012d5f9d29', 'Florian Schweizer', 'My name is Florian Schweizer, but I am probably better known as “Flo writes Code”, which is the name of my Twitter and Youtube accounts - places where I share what I have learned, how my indie development efforts are going and other things related to Apple platform development. 

Funnily enough, I have never been to a conference (of any type, really) myself, but both Jordi Bruin and Peter Friese have mentioned me in their talks over the past year. While submitting this proposal I am still working on my master’s thesis in Informatics: Games Engineering, which is about the social impact on children and adolescents of an AR iOS game that I have developed over the last year.', 'FloWritesCode', 'Flowritesco.de', 'a2a4-0o0o0-awzqF1dNUjg3839Hfhn696.jpeg-D0E76C3D-6F98-4669-9E71-B978AB8BBFD1'),
('06d1ecb6-f714-4d3a-8ceb-7f5817930218', 'Allison McEntire', 'Allison McEntire taught creative writing at Seattle Central College for almost a decade before transitioning to mobile software development in 2015. She consulted on projects for Apple, Toyota, and American Family Insurance with Deloitte Digital before joining the engineering team at Urban Outfitters in 2021.', 'allisonmcentire', 'Urban Outfitters', '903e-0o0o0-pbgsewjgWk2uVjeE3XjJsv.jpeg-CC87D9E1-93EF-40F5-858B-164440E1DBD6'),
('4d75f00d-314e-4398-ae06-8c1e3ab5d04b', 'Sanaa Shahzadi', 'Currently, an iOS Engineer at Sky Betting and Gaming previously worked as a Software Engineer in Test (SEiT).', 'SanaaShahzadi', 'Sky Betting & Gaming', '5b00-0o0o0-nwCWuRFWhXd8QZVQBSB5G2.jpeg-3A19F66F-6A15-44E7-810E-EDF37463B537'),
('a5a35b31-d5a5-4246-884e-f90958d1cc7d', 'Anna Beltrami', 'Originally a (pretty bad) bioscientist, I decided to take the plunge and do an MSc in Computer Science and Mobile Application Development and fell in love with the world of apps.

Since then, I have been blessed with a fun career full of variety and different challenges. I am currently working at Spotify as an iOS Engineer. When I am not tinkering away with Swift, I am an avid skier and a weightlifter.', 'acbdev', 'Spotify', '37c2-0o0o0-awpMnNnrk2WEgeyp6qB7iz.png-D25334F5-748F-4370-8433-FF6A9A3D8552'),
('bbbf970a-d96c-47bf-9da2-f347945b0344', 'Vincent Pradeilles', 'Vincent started working on iOS apps back in 2011. After a few years spent on building great apps for major European banks, he''s now part of the team at @photoroom_app: an app to remove backgrounds automatically and create professional images.

He loves Swift and enjoys talking about it on the Internet. In 2020, he started a YouTube channel to share his knowledge of Swift and iOS. He''s also the one behind the Twitter account @ios_memes', 'v_pradeilles', 'Photoroom', '7b07-0o0o0-8c-64c9-4601-893e-089cd7633424.db087b8e-30bf-4e74-ab5d-e4833f2f30d1.jpg-258E9B11-5540-4C9E-9DE1-9A96DEBE0DED'),
('da59e75c-27a0-40bf-8b48-469d5204fa1d', 'Atanas Chanev', 'Atanas Chanev is a Senior Engineer with a background in academia and 14+ years of commercial experience in consulting, web, mobile, and DevOps. Currently, he''s a Solutions Architect at Bitrise, helping customers based in the UK and Europe adopt Bitrise for their mobile CI/CD and overcome their DevOps challenges. He is based in London.', '', 'Bitrise', 'Atanas_events.jpg-18B3BE5D-CB35-44DB-8CA1-91FBD63AB16F'),
('e170bcc8-dc6a-442f-949b-6bb29e9aa752', 'Poornima Suraj', '16 years of experience in IT with more than 14 years working exclusively on Automation testing.', '', 'Sky Betting & Gaming', '4769-0o0o0-YroTPVoSrXCZvVwZXEvMUt.png-0DCB39D9-EA7C-4DCA-B4B2-B4712D2A8FCE'),
('f6957656-03d0-42c0-8b90-b424d3e13bac', 'Aviel Gross', 'I am working as an iOS engineer since 2013. In 2017 I started working at Facebook (Meta) and in March 2021 I moved to work at Adobe. I now lead the Behance iOS app at Adobe.', 'avielgr', 'Bēhance, Adobe', '0737-0o0o0-MJ9uuKpZGvd26aiShLes28.jpeg-0778BC3B-0A6B-43C8-85DB-A6F54BB97105'),
('ff672e21-c27d-44da-84aa-e9a368eae29e', 'Donny Wals', 'I am a passionate, iOS developer that loves learning and sharing knowledge. I started doing iOS roughly when Swift was announced and immediately fell in love with it. I wrote three books on iOS development for a publisher and self-published books on Combine and Core Data.', 'donnywals', 'DonnyWals.com', 'jOaeQ1Og_400x400.jpeg-AEAB9C2A-9572-4E6A-A63E-C3534EE5C321');

TRUNCATE TABLE "slots" CASCADE;
INSERT INTO "slots" ("id", "start_date", "duration", "event_id") VALUES
('032782bd-0985-40f1-8f27-1c21b8253884', '15:20', 30, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('12fe25cd-a131-4415-b1b4-672ba5dc2a9c', '14:00', 40, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('19fd48d9-06eb-4a84-80e0-7645365b7aa5', '09:20', 20, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('3229d814-7d86-4ad3-9eda-2f08029b8369', '09:40', 40, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('4e2cb73a-30ae-4e8f-b1c4-fcf92135e69a', '16:40', 40, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('5acc3d3e-62e7-4168-8659-d09e76529036', '16:00', 40, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('71f6d14b-e41f-4beb-866b-5ed71da52cc8', '14:40', 40, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('79e03740-8aa5-438a-8648-ee4f8b899f8f', '12:10', 40, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('96b03d1f-14b8-445b-9c21-7b0dfe662313', '10:20', 40, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('9afd1020-8020-49f8-8843-9dae6d3b7586', '15:50', 10, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('a3a16d1c-4ef4-460d-a3b8-076d2053568d', '11:30', 40, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('cc8af7bb-9403-4ae1-9735-1bb702c7d403', '12:50', 70, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('ce03ade2-ffb7-4b55-ac25-0395e869b1d0', '11:00', 30, '005a548b-9ebe-4742-8de5-8a37acaabab8'),
('ffdf8fe1-fee3-45f0-b0a3-b414d766bd25', '08:30', 30, '005a548b-9ebe-4742-8de5-8a37acaabab8');

TRUNCATE TABLE "activity" CASCADE;
INSERT INTO "activity" ("id", "title", "subtitle", "description", "url", "image", "event_id", "slot_id") VALUES
('1a128d61-930e-4d1b-935d-8153c99810cc', 'Refreshment Break ☕️', 'You might like to drink ☕️ or 🫖', 'It''s time to take a well-deserved break; there will be coffee, tea, water and more. You can take time to network, meet new people or relax and absorb all that information you have listened to.', '', 'IMG_1257%202.JPG-C5948967-9B86-4993-9EA1-E89624F1AA7A', '005a548b-9ebe-4742-8de5-8a37acaabab8', '032782bd-0985-40f1-8f27-1c21b8253884'),
('7603ab5a-e816-4fbc-a838-d104eca9fcbb', 'Introduction to SwiftLeeds', 'A welcome introduction from your SwiftLeeds host, Adam Rush!', 'Adam Rush will be hosting this year''s SwiftLeeds and will be welcoming you all in true SwiftLeeds fashion. Adam will try to be funny at times and really inject lots of motivation, ready for some fantastic talks ahead.', '', 'adam.jpg-A5B77EEF-07F8-4EB9-A160-795CB42D814E', '005a548b-9ebe-4742-8de5-8a37acaabab8', '19fd48d9-06eb-4a84-80e0-7645365b7aa5'),
('8fccab70-2f96-4896-9321-77fbb65235b8', 'Refreshment Break ☕️', 'You might like to drink ☕️ or 🫖', 'It''s time to take a well-deserved break; there will be coffee, tea, water and more. You can take time to network, meet new people or relax and absorb all that information you have listened to.', '', 'IMG_1257%202.JPG-F5EFA13C-AEA4-4A04-ACFC-493D6BC9D613', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'ce03ade2-ffb7-4b55-ac25-0395e869b1d0'),
('bca02346-6fe5-49bc-bdfa-4b66fb6adda9', 'Registration', 'Time to check in 🎟', 'The doors at The Playhouse will open prompt at 8:30 AM and it''s time to register and collect your things. Please bring along your QR code ticket for prompt entry and nothing else is required. The SwiftLeeds team will greet you along with a fresh breakfast to start the day.', '', '3893D677-2CA2-4BD5-AE1D-F9F69CE85139-LP_BuildingProgress_Aug2019-7-David-Lindsay-Photographer-scaled.jpeg', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'ffdf8fe1-fee3-45f0-b0a3-b414d766bd25'),
('f4fb0c62-b3c8-4c46-bdc4-7fdadc71861d', 'Lunch 🍕', 'It''s time for some well deserved food', 'We have partnered with the venue to provide us with handmade food. The venue has an incredible chef who will produce food to cater to everyone. They have access to a stone-baked pizza oven to provide fresh pizza slices and handmade buffet food with a vast selection. Don''t forget your handmade brownie or Bakewell slice 😋', '', 'IMG_6298.jpg-93D1F0E2-6F47-4149-944B-FB824EFB2549', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'cc8af7bb-9403-4ae1-9735-1bb702c7d403');

TRUNCATE TABLE "presentations" CASCADE;
INSERT INTO "presentations" ("id", "title", "synopsis", "speaker_id", "event_id", "is_tba", "slot_id", "speaker_two_id", "slido_url") VALUES
('262c1083-ba7d-49b5-b1dc-60cd917396c8', 'Building (and testing) custom property wrappers for SwiftUI', 'In this talk, you will learn everything you need to know about using DynamicProperty to build custom property wrappers that integrate with SwiftUI’s view lifecycle and environment beautifully. And more importantly, you will learn how you can write unit tests for your custom property wrappers as well.

* Watch recording on [YouTube](https://youtube.com)
* Read slides [here](https:/example.com)', 'ff672e21-c27d-44da-84aa-e9a368eae29e', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'f', '3229d814-7d86-4ad3-9eda-2f08029b8369', NULL, 'https://app.sli.do/event/kUqN77GxRVR9Tu1QYbwTe8'),
('45cfd91e-2945-4c5e-9c20-58f298f76298', 'SwiftUI Performance for Demanding Apps', 'SwiftUI is powerful and flexible, but sometimes confusing. Things like modifiers order, inline views, `body` complexity, and POD views, can all seriously affect our performance. In this talk, we will learn the best ways to use SwiftUI for resource-heavy and dynamic UIs, while maintaining the golden 60fps.

In 2022, we (Adobe Bēhance) rebuilt our navigation infra, and our main Feed, in SwiftUI. We also insisted the app must run great on the worst phone we support - iPhone 6S Plus. Getting there was a journey.

We will start by comparing SwiftUI to UIKit: We know there’s no more `View Controller`, and views are mere “function of their state”, but what does it mean?
Next, we will dive into specific scenarios and see how this new way of thinking is critical for achieving great performance. We will learn things like:

- Avoiding redundant view diffing
- Controlling view update lifecycle
- How to “hide” complex states to improve performance
- Avoiding SwiftUI’s pitfalls, like nested publishers and iOS 14 vs 15 behaviour
- And more…', 'f6957656-03d0-42c0-8b90-b424d3e13bac', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'f', 'a3a16d1c-4ef4-460d-a3b8-076d2053568d', NULL, 'https://app.sli.do/event/15gNhA8ht2f26apL82JSTK'),
('5d3114e8-573c-47bf-a33b-9aabac649f7c', 'SwiftUI, async / await, AsyncAlgorithms: How does it fit?', 'What''s the easiest way to deal with asynchronous code? A couple of years ago, the answer would have been Combine.

But in 2021, async / await was integrated into Swift, making dealing with simple asynchronous use cases much more straightforward and intuitive.

Then in 2022, the Swift team released their new AsyncAlgorithms module, which clearly seems like a fully-fledged alternative to Combine!

So in this talk, I want to discuss the current state of asynchronous code management as of October 2022 and provide examples of how we can build apps using SwiftUI, async / await and AsyncAlgorithms.', 'bbbf970a-d96c-47bf-9da2-f347945b0344', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'f', '12fe25cd-a131-4415-b1b4-672ba5dc2a9c', NULL, 'https://app.sli.do/event/sxRC7CV4i5LqNCu93n2wUq'),
('6bc2fdd9-c6c4-4a65-bd8e-234cb1638893', 'Test Plan Sharding with Pipelines', 'Atanas, will be providing a very brief overview of using Test Plan Sharding with Pipelines', 'da59e75c-27a0-40bf-8b48-469d5204fa1d', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'f', '9afd1020-8020-49f8-8843-9dae6d3b7586', NULL, ''),
('927daf47-c081-4e12-ac40-e78f3f41250f', 'UI automation with XCUItest', 'n this duo talk with Poornima and Sanaa, we''ll be exploring how to create the most efficient UI automation using Apple''s UI automation frameworks. We''ll be covering:

- What is UI automation testing
- Setting up the framework
- BDD
- Base Class
- Page Object Model
- Data mocking
- Execution: Test Plans/test schemes
- Test Results: Reporting
- Debugging - breakpoints, prints, etc
- CI
- Pros and cons', 'e170bcc8-dc6a-442f-949b-6bb29e9aa752', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'f', '79e03740-8aa5-438a-8648-ee4f8b899f8f', '4d75f00d-314e-4398-ae06-8c1e3ab5d04b', 'https://app.sli.do/event/rLYYtqtBZ22z6vDL1BJPfx'),
('9549cc8d-62de-4cdf-83be-ced63a5fd027', 'Spark your creativity: the power of iPad Playgrounds', 'Perfectionism is the enemy of creativity. Or at least, it has been for me.

Spending years working in big teams with millions of users, I had forgotten how to play and experiment with iOS development. When iPad playgrounds were released, I took the opportunity to play around. Thanks to the software''s simplicity, I could re-ignite my creativity and - for the first time in years - not abandon my side projects.

In this session, I want to help people get past their blocks and embrace a more playful development style.', 'a5a35b31-d5a5-4246-884e-f90958d1cc7d', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'f', '71f6d14b-e41f-4beb-866b-5ed71da52cc8', NULL, 'https://app.sli.do/event/pEq6uGm2irgHncoUGAM5s8'),
('a330bcad-219d-4e37-98fa-9602042c0131', 'CI/CD (Continuous Improvement, Continuous Discovery)', 'The Apple ecosystem is known to outsiders for its simplicity and ease of use.

From a developers'' point of view,, that is a different story - with WWDC introducing incredible amounts of new features and APIs each year, new devices are coming out, and new hardware features are added to existing devices. People developing in this ecosystem for a while will know that learning and learning about new features, frameworks, and tools are just as crucial as writing actual code.

Over the past years, I have tried out many different approaches, and in this talk, I share those approaches, highlight what worked for me and give concrete examples to motivate listeners to expand their knowledge and try new ways to learn. The talk also covers how you can reflect on your own code and how sharing can make you a better developer, whether you’re an indie or working in a company.', '0373fc98-50d9-428c-a87d-bb012d5f9d29', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'f', '4e2cb73a-30ae-4e8f-b1c4-fcf92135e69a', NULL, 'https://app.sli.do/event/cDj274MLgxzR3j1hGvoN8P'),
('c0ffddcf-c148-4d1b-8cc5-4efa3e705327', 'Testing Asynchronous Code in Swift 5.5', 'Swift''s modern concurrency APIs allow for greater flexibility and future-proofing in unit testing.

In this session, I will demonstrate how we updated our unit testing strategy as we adopted `async`/`await` in our Combine-based applications at Urban Outfitters.

Additionally, I will demonstrate how to use `AsyncStream` to mock networking calls, how to update Combine tests with `AsyncSequence`, and how to optimize tests by implementing Task functions and phasing out `waitForExpectations`.', '06d1ecb6-f714-4d3a-8ceb-7f5817930218', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'f', '5acc3d3e-62e7-4168-8659-d09e76529036', NULL, 'https://app.sli.do/event/i4ovARujc5DK72vKnmzKJM'),
('f298d006-52d7-4cf9-8d9e-147e58e20753', 'Modularization Techniques: from Monolithic to Multi Packages App', 'Designing for modularity can be pretty challenging, especially if we didn''t start earlier in the process. This can lead to longer build time, tightly coupled code, and hard to maintain, extend and test your app.

In this talk, I''ll show you how to design your app in a loosely-coupled way and then break your monolithic app into independent modules via Swift Package Manager, each doing precisely just one thing.', '019064d6-1f2f-4e3b-9243-831309a12030', '005a548b-9ebe-4742-8de5-8a37acaabab8', 'f', '96b03d1f-14b8-445b-9c21-7b0dfe662313', NULL, 'https://app.sli.do/event/7RKA8rn98qhGhLwHTte944');


TRUNCATE TABLE "locationCategories" CASCADE;
INSERT INTO "locationCategories" ("id", "name", "symbol_name") VALUES
('D5B5B6C9-D1BF-4B33-B77D-29C5C1DDB560', 'SwiftLeeds', 'building.2.fill'),
('0E46F4B7-0844-4C5B-8457-16A8C966BF58', 'Places to Work', 'laptopcomputer'),
('3087653E-E10E-41C8-B321-D16A68FA9A88', 'Things to do', 'theatermasks.fill'),
('3078D29D-CD3C-4BE6-BA3A-AE3ED0901335', 'Food', 'takeoutbag.and.cup.and.straw.fill'),
('3327F9D0-B38B-4743-8EE0-F3188ABA60D7', 'Drinking Spots', 'wineglass.fill'),
('DD19C880-1723-4AF2-8005-B4CEFFCBD6E2', 'Coffee', 'cup.and.saucer.fill');

TRUNCATE TABLE "locations" CASCADE;
INSERT INTO "locations" ("id", "name", "url", "lat", "lon", "category_id") VALUES
('8b423641-3d9b-45c5-b785-0187eaa401a1', 'Wizu Workspace', 'http://www.wizuworkspace.com/the-leeming-building', 53.799173655248964, -1.5401714417101833, '0e46f4b7-0844-4c5b-8457-16a8c966bf58'),
('b24a7c31-ed7f-4b53-9d21-dbd15c3f4d7f', 'Victoria Leeds', 'http://www.victorialeeds.co.uk/', 53.79818232029677, -1.5405197760056504, '3087653e-e10e-41c8-b321-d16a68fa9a88'),
('85843a21-d18f-4261-a52b-c59d7098316f', 'Trinity Leeds', 'http://www.trinityleeds.com/', 53.79679603071404, -1.5440971686466118, '3087653e-e10e-41c8-b321-d16a68fa9a88'),
('ac471e53-c120-4fe2-8965-1d6585d20e78', 'Trinity Kitchen', 'https://trinityleeds.com/shops/trinity-kitchen', 53.797378, -1.545209, '3078d29d-cd3c-4be6-ba3a-ae3ed0901335'),
('4064f003-4044-4f12-b48d-12c938cdb290', 'The Lost & Found', 'http://www.the-lostandfound.co.uk/restaurant/leeds-greek-street', 53.79843036094402, -1.5471689293777409, '3327f9d0-b38b-4743-8ee0-f3188aba60d7'),
('6317bb63-2742-4d74-8713-ad9e7ed9f654', 'The Alchemist', 'https://thealchemist.uk.com/menus/', 53.798701696550935, -1.5479613581811973, '3327f9d0-b38b-4743-8ee0-f3188aba60d7'),
('8c02af4a-0466-4a5a-9ccb-2caf7f08bcbf', 'Tattu', 'http://tattu.co.uk/leeds/', 53.79824212814524, -1.54885001971015, '3078d29d-cd3c-4be6-ba3a-ae3ed0901335'),
('e81d3f01-e326-473d-a757-1703b0a41797', 'Stuzzi', 'http://www.stuzzi.co.uk/', 53.80046608786117, -1.539799428835741, '3078d29d-cd3c-4be6-ba3a-ae3ed0901335'),
('aae02cae-15c2-43da-9282-4ca89f6aadd1', 'Royal Armouries', 'https://royalarmouries.org/visit-us/leeds', 53.791989038708735, -1.531337542186456, '3087653e-e10e-41c8-b321-d16a68fa9a88'),
('85c117e9-dfbd-4249-9639-83e9b1a343e4', 'Playhouse Theatre', 'https://leedsplayhouse.org.uk', 53.798228, -1.535243, 'd5b5b6c9-d1bf-4b33-b77d-29c5c1ddb560'),
('4b093b5e-24d5-4a18-826b-d9b5db30aaa2', 'Pizza Fella', 'https://www.pizzafella.com/menu', 53.799904427924844, -1.5386023102900523, '3078d29d-cd3c-4be6-ba3a-ae3ed0901335'),
('f506ec86-c363-447e-8775-86627d76be86', 'Park House by Spacemade', 'https://www.spacemade.co/locations/london/park-house/', 53.798857519062445, -1.5527801945845137, '0e46f4b7-0844-4c5b-8457-16a8c966bf58'),
('a165fdef-0b48-475f-b66f-445563d90bca', 'North Star', 'https://www.northstarroast.com/cafe/', 53.79391081831077, -1.5314760279758834, 'dd19c880-1723-4af2-8005-b4ceffcbd6e2'),
('c584d44e-c7e7-4649-8fc4-bcb775a20427', 'Manahatta', 'https://www.manahatta.co.uk/bars/greek-street', 53.79835740292875, -1.5486636084718148, '3327f9d0-b38b-4743-8ee0-f3188aba60d7'),
('53acdb93-5415-48dd-b34d-54288098d363', 'Leeds Art Gallery', 'https://museumsandgalleries.leeds.gov.uk/leeds-art-gallery/', 53.800223537676416, -1.5478176533022505, '3087653e-e10e-41c8-b321-d16a68fa9a88'),
('72ba7e4d-8892-4d75-9bbe-db20c7aa0797', 'Laynes Espresso', 'http://www.laynesespresso.co.uk/', 53.79532138579969, -1.5450768520447067, 'dd19c880-1723-4af2-8005-b4ceffcbd6e2'),
('c15b4231-6b85-4c4b-88f3-8161f71c37bd', 'Kapow', 'https://www.kapowcoffee.co.uk/', 53.798800736285486, -1.5427554652058615, 'dd19c880-1723-4af2-8005-b4ceffcbd6e2'),
('d9c13011-7147-4d51-a6d3-c087eb5b1e1f', 'House of Fu', 'http://www.hellohouseoffu.com/', 53.7990542317147, -1.5409765306859269, '3078d29d-cd3c-4be6-ba3a-ae3ed0901335'),
('e1a700db-8872-4e12-8b88-4a1322d4fc73', 'Duke Studios', 'http://www.duke-studios.com/', 53.7913022408058, -1.538100284323885, '0e46f4b7-0844-4c5b-8457-16a8c966bf58'),
('ff2be354-bf17-4883-9eaa-b8afc0d13e05', 'Brew Society', 'https://www.brewsociety.co.uk/', 53.79584058588689, -1.550339186509128, '3327f9d0-b38b-4743-8ee0-f3188aba60d7'),
('7b8a4bbd-b8ce-4171-8289-651ad9d1b00a', 'Brew Dog', 'https://www.brewdog.com/uk/bars/uk/brewdog-north-street-leeds', 53.80187943492715, -1.5379835403514934, '3327f9d0-b38b-4743-8ee0-f3188aba60d7'),
('1e2122c3-3d8a-4aec-831a-54d113feaace', 'Belgrave', 'http://www.belgravemusichall.com/', 53.80099082308206, -1.5407517502542225, '3078d29d-cd3c-4be6-ba3a-ae3ed0901335'),
('823b754c-d551-4234-baf1-9ae444fdc5f5', 'Avenue HQ', 'https://www.avenue-hq.com/', 53.79885392247382, -1.548977202363078, '0e46f4b7-0844-4c5b-8457-16a8c966bf58'),
('4967f863-4941-4e47-8034-c81c6557cc9e', 'Assembly Underground', 'http://www.assemblyunderground.com/', 53.80082340535508, -1.5485263386179835, '3327f9d0-b38b-4743-8ee0-f3188aba60d7'),
('e97d70f7-2124-4aca-868c-54c8ddec7e81', 'Apple', 'https://www.apple.com/uk/retail/trinityleeds/?cid=aos-gb-seo-maps', 53.79685991942918, -1.543359837957889, '3087653e-e10e-41c8-b321-d16a68fa9a88'),
('09a8ddac-7dca-4f99-80ba-66750571cbf9', '200 Degrees', 'http://www.200degs.com/leeds-bond-street', 53.79760107211073, -1.5459528678505592, 'dd19c880-1723-4af2-8005-b4ceffcbd6e2');

TRUNCATE TABLE "dropin_sessions" CASCADE;
INSERT INTO "dropin_sessions" ("id", "title", "description", "owner", "owner_image_url", "owner_link", "event_id") VALUES
('175fd73b-28a7-4f94-a4c0-e62478140f2f', 'App Accessibility Review', 'todo', 'Daniel Devesa Derksen-Staats', 'O87Gvgjg_400x400.jpeg', 'https://twitter.com/dadederk', 'a6b202de-6135-4e71-bdb0-290ecff798a8'),
('7077ef86-9212-46a6-97e4-bda99822a0a9', 'App Store Optimization Review', 'We are excited to have Ariel from AppFigures available to provide a full App Store Optimization review of your app.

You will be allocated a timeslot throughout the day of the conference, and you can sit down, ask questions and get the opinion of an ASO expert.', 'Ariel from Appfigures', 'y4oh0Nb__400x400.jpeg', 'https://twitter.com/arielmichaeli', 'a6b202de-6135-4e71-bdb0-290ecff798a8'),
('813dee8f-89cb-4480-8e04-f28ad36554d6', 'App Design Review', 'We are excited to have Hidde van der Ploeg available to provide a design review of your iOS application.

You will be allocated a timeslot throughout the day of the conference, and you can sit down, ask questions and get the opinion of a design expert.', 'Hidde van der Ploeg', 'Zpow22F5_400x400.jpeg', 'https://twitter.com/hiddevdploeg', 'a6b202de-6135-4e71-bdb0-290ecff798a8'),
('b544d903-795c-42aa-97d7-e2af44a505c4', 'Indie Developer App Review', 'Do you have an Indie App you would like to get **FREE** advice about?

Jordi Bruin will be onsite, ready to answer your questions about your app and help you with anything that you might be struggling with, code or otherwise.

Jordi Bruin is a world-class Indie app developer and was recently nominated for an Apple Design Award. Slots will be limited and on a first-come, first-serve basis. By opting for this in your ticket, you''ll be provided with a set day and time for meeting Jordi Bruin in a 1-1 meeting.

**Please note;** you must only opt for this if your app is built by you independently and isn''t a company application.', 'Jordi Bruin', 'Tp9T2p2C_400x400.jpeg', 'https://twitter.com/jordibruin', 'a6b202de-6135-4e71-bdb0-290ecff798a8');

TRUNCATE TABLE "dropin_session_slots" CASCADE;
INSERT INTO "dropin_session_slots" ("id", "session_id", "date", "ticket", "ticket_owner") VALUES
('6400c626-1b90-4a03-81cc-76d5bb494d87', '175fd73b-28a7-4f94-a4c0-e62478140f2f', '2023-10-18 14:00:00+01', NULL, NULL),
('8740803d-a4f0-4d6b-b15c-4c7c29e7f75d', '175fd73b-28a7-4f94-a4c0-e62478140f2f', '2023-10-19 13:00:00+01', NULL, NULL),
('bf5d89aa-8ae9-4c06-b79f-56a36c8d3eb9', '175fd73b-28a7-4f94-a4c0-e62478140f2f', '2023-10-18 17:15:00+01', NULL, NULL),
('c1bb2aed-cef1-452d-8503-db13596cbc37', '175fd73b-28a7-4f94-a4c0-e62478140f2f', '2023-10-18 16:45:00+01', 'reserved', 'Adam Rush'),
('dc146ae5-607b-4e07-8c3d-7db0a10c20d6', '175fd73b-28a7-4f94-a4c0-e62478140f2f', '2023-10-18 16:30:00+01', 'ti_test_p05Ch95xJS5AStInfa8whFA', 'James Sherlock'),
('f9bc67a4-10e9-4dac-8ede-561f0d9826d3', '175fd73b-28a7-4f94-a4c0-e62478140f2f', '2023-10-18 17:00:00+01', NULL, NULL);

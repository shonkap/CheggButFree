-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: classmysql.engr.oregonstate.edu:3306
-- Generation Time: Jun 09, 2019 at 03:47 PM
-- Server version: 10.3.13-MariaDB-log
-- PHP Version: 7.0.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cs340_shonkap`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`cs340_shonkap`@`%` PROCEDURE `updateAllSailorStats` ()  NO SQL
BEGIN
DELETE From SailorStats;

INSERT into SailorStats (sid, totalRentals, amountDue)
SELECT s.sid, COUNT(*), SUM(b.price) from Sailors s, Reserves r, Boats b where (b.bid = r.bid) and (r.sid = s.sid) GROUP BY s.sid HAVING COUNT(*)>0;
END$$

CREATE DEFINER=`cs340_shonkap`@`%` PROCEDURE `updateCollegeStats` (IN `dName` VARCHAR(20))  BEGIN

UPDATE CollegeStats 
SET appCount = (SELECT COUNT(*) from Apply a, Student s where(s.sID = a.sID) and (dName = a.cName) GROUP by a.cName HAVING COUNT(*)>0),

maxGPA = (SELECT MAX(s.GPA) from Apply a, Student s where(s.sID = a.sID) and (dName = a.cName) GROUP by a.cName),

minGPA = (SELECT MIN(s.GPA) from Apply a, Student s where(s.sID = a.sID) and (dName = a.cName) GROUP by a.cName)

WHERE cName= dName;

END$$

CREATE DEFINER=`cs340_shonkap`@`%` PROCEDURE `updateCollegeStatsAll` ()  BEGIN
DELETE From CollegeStats;

INSERT INTO CollegeStats (cName, appCount, minGPA, maxGPA)
SELECT a.cname as cName, COUNT(*) as appCount, MIN(s.GPA), MAX(s.GPA) from Apply a, Student s where(s.sID = a.sID) GROUP by a.cName HAVING COUNT(*)>0;

END$$

CREATE DEFINER=`cs340_shonkap`@`%` PROCEDURE `updateUser` ()  NO SQL
UPDATE Users 
	SET num_posts = (SELECT COUNT(Post.user_id)
                     FROM Post 
                     WHERE Users.UserID = Post.user_id)$$

--
-- Functions
--
CREATE DEFINER=`cs340_shonkap`@`%` FUNCTION `BanUser` (`admin` VARCHAR(30), `user` VARCHAR(30)) RETURNS INT(11) NO SQL
BEGIN
	UPDATE Admins
	SET numUsersBanned = numUsersBanned + 1
	WHERE UserID = admin;

	DELETE FROM Favorites WHERE UserID = user;
    
    INSERT INTO BannedUsers (UserID, date) 
VALUES (user, CURDATE());

    RETURN 1;
END$$

CREATE DEFINER=`cs340_shonkap`@`%` FUNCTION `sailorSpending` (`sid` INT(11)) RETURNS VARCHAR(15) CHARSET utf8 NO SQL
BEGIN
	DECLARE maxspent int;
    DECLARE minspent int;
    
    SELECT MAX(s.amountDue) into maxspent FROM SailorStats s;
    SELECT MIN(s.amountDue) into minspent FROM SailorStats s;
    
	if maxspent = (SELECT s.amountDue FROM SailorStats s where (sid = s.sid)) THEN
    	RETURN 'Big Spender';
    elseif minspent = (SELECT s.amountDue FROM SailorStats s where (sid = s.sid)) THEN
    	RETURN 'Small Fry';
    else
    	RETURN 'Average Guy';
    end if;
    Return 'error';
END$$

CREATE DEFINER=`cs340_shonkap`@`%` FUNCTION `studentRank` (`GPA` FLOAT(3,2)) RETURNS VARCHAR(10) CHARSET utf8 NO SQL
BEGIN
	if GPA > 3.50 THEN
    	RETURN 'GOOD';
    elseif GPA < 3.0 THEN
    	RETURN 'POOR';
    else 
    	RETURN 'AVERAGE';
   	end if;
    RETURN 'ERROR';
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Admins`
--

CREATE TABLE `Admins` (
  `UserID` varchar(30) NOT NULL,
  `numUsersBanned` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Admins`
--

INSERT INTO `Admins` (`UserID`, `numUsersBanned`) VALUES
('admin1', 3),
('correct_time', 8),
('IamAnAdmin', 0),
('IamAnAdminAlso', 0),
('iamnumber1', 2),
('ILikeToHelp', 0),
('mathishard', 0),
('NotARobot', 0),
('smartie', 0),
('teacher', 0),
('user2', 2);

-- --------------------------------------------------------

--
-- Table structure for table `BannedUsers`
--

CREATE TABLE `BannedUsers` (
  `UserID` varchar(30) NOT NULL,
  `date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `BannedUsers`
--

INSERT INTO `BannedUsers` (`UserID`, `date`) VALUES
('[Banned]awful', '2019-06-08'),
('[Banned]ban_me', '2019-06-08'),
('[Banned]bobmath', '2019-05-28'),
('[Banned]CSMAJOR', '2019-05-31'),
('[Banned]fbiguy', '2019-05-31'),
('[Banned]hi', '2019-06-03'),
('[Banned]jimbean', '2019-06-09'),
('[Banned]johnny', '2019-05-28'),
('[Banned]junk', '2019-06-03'),
('[Banned]pleasedontban', '2019-06-04'),
('[Banned]plsdontbaneither', '2019-06-04'),
('[Banned]robot', '2019-06-09'),
('[Banned]sch00l_is_h4rd', '2019-05-31'),
('[Banned]selected', '2019-06-08'),
('[Banned]Xx_thousands', '2019-05-31');

--
-- Triggers `BannedUsers`
--
DELIMITER $$
CREATE TRIGGER `addBanned` AFTER INSERT ON `BannedUsers` FOR EACH ROW BEGIN
UPDATE Users
SET UserID = CONCAT('[Banned]', UserID)
WHERE UserID = new.UserID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Content`
--

CREATE TABLE `Content` (
  `postID` int(11) NOT NULL,
  `picURL` varchar(200) NOT NULL,
  `text` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Content`
--

INSERT INTO `Content` (`postID`, `picURL`, `text`) VALUES
(0, 'https://www.researchgate.net/profile/Peter_Fritzson/publication/228792639/figure/fig1/AS:393782852898820@1470896556105/Abstract-syntax-tree-of-the-while-loop.png', 'I am trying to make an abstract syntax tree. I don\'t know where to start. I know there should be nodes linked together but how do I do that? '),
(1, 'https://i0.wp.com/algorithms.tutorialhorizon.com/files/2015/11/Tree-Traversals.png', 'How do you do a preorder traversal in c++?'),
(2, 'https://cdncontribute.geeksforgeeks.org/wp-content/uploads/cycle.png', 'I\'m trying to implement a depth first search for a graph in C++. \r\n\r\nWe are given this code: \r\n    // Create a graph given in the above diagram \r\n    Graph g(4); \r\n    g.addEdge(0, 1); \r\n    g.addEdge(0, 2); \r\n    g.addEdge(1, 2); \r\n    g.addEdge(2, 0); \r\n    g.addEdge(2, 3); \r\n    g.addEdge(3, 3); '),
(3, 'https://upload.wikimedia.org/wikipedia/commons/1/1f/Simple_pendulum.svg', 'A pendulum consists of a ball at the end of a massless string of length 1.4 m. The ball is released from rest with the string making an angle of 20 degrees with the vertical. What is the maximum speed of the pendulum? \r\n\r\nI know you use probably use conservation of energy but please I am stuck. :('),
(4, 'http://hyperphysics.phy-astr.gsu.edu/hbase/imgmec/bulletblock.gif', 'A bullet with mass m hits a ballistic pendulum with length L and mass M and lodges in it. When the bullet hits the pendulum it swings up from the equilibrium position and reaches an angle α at its maximum. Determine the bullet’s velocity.\r\n\r\nNote: The ballistic pendulum was used for measuring the speed of a bullet. It consists of a wooden block suspended from two long cords so that it can swing only in the vertical direction.\r\n\r\nBecause the bullet lodges in the pendulum’s body, we can say that the collision was inelastic. What can one say about the momentum before and after the collision?\r\n\r\n'),
(5, '', 'Can someone link me to a good Haskell tutorial? I am confused. \r\n'),
(6, 'https://image.slidesharecdn.com/integration-150302025451-conversion-gate01/95/integration-1-638.jpg?cb=1425265037', 'How do you evaluate the integral of -4?'),
(7, '', 'Problem 1: A person 100 meters from the base of a tree, observes that the angle between the ground and the top of the tree is 18 degrees. Estimate the height h of the tree to the nearest tenth of a meter. \r\n\r\nI know it\'s easy but help! Math is hard!\r\n'),
(9, '', 'Is there an easier way to do responsive web design other than just using the weird media queries? I don\'t understand them. \r\n\r\nOr find me a understandable website for flex boxes?'),
(13, '', ' Recall that a power function is of the form f(x) = xn. Can an even power function defined on the reals have an inverse? Why or why not? Could one restrict the domain and obtain an inverse? If so, how?'),
(14, '', 'If you have 2 computers connected on their own network sending packets of 3000 bytes. The bandwidth is 1 Mbps and a of a network between node A and node B, what is the delay if the latency is 10 msec?'),
(15, '', 'idk what to write here i just don\'t know physics'),
(16, '', 'I don\'t understand linked lists and I need an easy implementation. '),
(17, '', 'test'),
(18, '', 'I\'m sorry this is probably spam'),
(19, '', 'How do you create an array of fibonacci numbers given the type  fibs :: Int -> Array Int Int'),
(20, '', 'Tested\r\nmulti\r\nline'),
(21, '', '2.A \"10-pound bag\" of potatoes has a mass of abt 4.54kg. If I take them to the moon, the bag of potatoes: \r\na) will still weight 10 pounds \r\nb)will still have a mass of 4.54kg \r\nc)will weight much less than 10 pounds \r\nd)will have a mass of much less than 4.54kg \r\n'),
(22, '', 'I know you gotta use induction, but discrete math is too much for me. \r\nI just know you must assume it\'s true. '),
(23, 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Arthur%2C_the_cat.jpg/1200px-Arthur%2C_the_cat.jpg', 'cats?'),
(24, '', 'how do data bases work i literally have no idea'),
(25, '', 'please help me with math'),
(26, '', 'i like cats.'),
(27, '', 'In a coordinate system, a vector is oriented at angle with respect to the x-axis. The y component of the vector equals the vector\'s magnitude multiplied by which trigonometric function?\r\n\r\n\r\n    A. Tan angle\r\n    B. Cos angle\r\n    C. Cot angle\r\n    D. Sin angle\r\n'),
(28, '', '2x^2+4x+8'),
(29, '', 'Content');

-- --------------------------------------------------------

--
-- Table structure for table `Favorites`
--

CREATE TABLE `Favorites` (
  `postID` int(11) NOT NULL,
  `userID` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Favorites`
--

INSERT INTO `Favorites` (`postID`, `userID`) VALUES
(0, 'correct_time'),
(0, 'hello'),
(0, 'smartboi'),
(2, 'iamnumber1'),
(3, 'hello'),
(3, 'iamafool'),
(5, 'brandi'),
(5, 'mimu'),
(6, 'geosuxks'),
(6, 'mathishard'),
(7, 'geosuxks'),
(7, 'mathishard'),
(9, 'Jonnyboi'),
(14, 'smartboi'),
(15, 'smartboi'),
(18, 'admin1'),
(18, 'smartboi'),
(22, 'smartboi'),
(24, 'hello'),
(28, 'Jonny'),
(29, 'user');

--
-- Triggers `Favorites`
--
DELIMITER $$
CREATE TRIGGER `AddFavorite` AFTER INSERT ON `Favorites` FOR EACH ROW BEGIN
UPDATE Users
SET num_favorites = num_favorites + 1 
where (UserID = NEW.userID);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `DeleteFavorite` AFTER DELETE ON `Favorites` FOR EACH ROW BEGIN
UPDATE Users
SET num_favorites = num_favorites - 1 
where (UserID = OLD.userID) and (num_favorites>0);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Post`
--

CREATE TABLE `Post` (
  `postID` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `category` varchar(25) NOT NULL,
  `user_id` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Post`
--

INSERT INTO `Post` (`postID`, `title`, `category`, `user_id`) VALUES
(0, 'How do you make a node?', 'Computer Science', 'iamnumber1'),
(1, 'Tree traversals', 'Computer Science', 'user2'),
(2, 'Depth-first-search', 'Computer Science', '[Banned]johnny'),
(3, 'Pendulum Velocities', 'Physics', 'user2'),
(4, 'Pendulum Energy', 'Physics', 'brandi'),
(5, 'UMMMMMMM??', 'Physics ', '[Banned]bobmath'),
(6, 'Integration - basic', 'Math', 'mathishard'),
(7, 'Trigonometry problems', 'Math', 'kookoo'),
(9, 'Responsive Web Design', 'Web Dev', 'iamnumber1'),
(10, 'Math is hard', 'Math', '[Banned]bobmath'),
(11, 'math really hard', 'Math', 'smartboi'),
(13, 'Explain this calculus question', 'Math', 'Jonnyboi'),
(14, 'Computer Networks - delay ', 'Computer science', 'hellopeople'),
(15, 'hello', 'Physics', '[Banned]plsdontbaneither'),
(16, 'How do I make a linked list ', 'Computer Science', 'iamafool'),
(17, 'test', 'test', '[Banned]hi'),
(18, 'What is 2+2', 'Math', 'NotARobot'),
(19, 'Making an array of fibonacci numbers in haskell? ', 'Computer science', 'geosuxks'),
(20, 'Multi line in html?', 'webdev', 'smartboi'),
(21, 'Mass vs Weight? ', 'Physics', 'kookoo'),
(22, 'Prove the sum of all the numbers from 1 to n is n(n+1)/2. ', 'discrete math', 'brandi'),
(23, 'cats', 'Physics', 'smartboi'),
(24, 'someone help', 'Computer Science', 'hello'),
(25, 'need math help please!!', 'math', 'mimu'),
(26, 'what?', 'Physics', 'one2'),
(27, 'Trignometry/Physics questions??', 'Math', '[Banned]robot'),
(28, 'Calculus question', 'math', 'Jonny'),
(29, 'Test ', 'Math', 'user');

--
-- Triggers `Post`
--
DELIMITER $$
CREATE TRIGGER `DeletePost` AFTER DELETE ON `Post` FOR EACH ROW BEGIN
UPDATE Users
SET num_posts = num_posts - 1 
where (UserID = OLD.user_id) and (num_posts>0);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `NewPost` AFTER INSERT ON `Post` FOR EACH ROW BEGIN
UPDATE Users
SET num_posts = num_posts + 1 
where UserID = NEW.user_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Replies`
--

CREATE TABLE `Replies` (
  `replyID` int(11) NOT NULL,
  `textContent` text NOT NULL,
  `postID` int(11) NOT NULL,
  `user_id` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Replies`
--

INSERT INTO `Replies` (`replyID`, `textContent`, `postID`, `user_id`) VALUES
(1, 'struct Node { int data; Node *left; Node *right;\r\n}', 0, 'smartboi'),
(2, 'In c++ i prefer this way assuming the tree is not binary. \r\nstruct Node {\r\n   var data;\r\n   vector<Node*> children;\r\n}', 0, 'smartboi'),
(3, 'Following is Depth First Traversal (starting from vertex 2)\r\n2 0 1 3', 2, 'smartboi'),
(4, '1  procedure DFS(G,v):\r\n2      label v as discovered\r\n3      for all directed edges from v to w that are in G.adjacentEdges(v) do\r\n4          if vertex w is not labeled as discovered then\r\n5              recursively call DFS(G,w)', 2, 'smartboi'),
(5, 'The law of conservation of momentum states that in an isolated system the total momentum is constant. This law works also during perfectly inelastic collision.\r\n\r\nThe pendulum is at rest before the collision.', 4, 'smartboi'),
(6, 'module Main (main) where          -- not needed in interpreter, is the default in a module file\r\n\r\nmain :: IO ()                       -- the compiler can infer this type definition\r\nmain = putStrLn \"Hello, World!\"', 5, 'smartboi'),
(8, 'it\'s just 4 ', 6, '[Banned]jimbean'),
(9, '@jimbean he is wrong, it is 4x. ', 6, 'iamnumber1'),
(10, 'It is -4x. NEGATIVE. \r\nAll you have to do if the result is a constant is put an \'x\' after it. it\'s a rule. ', 6, 'teacher'),
(11, 'Use the tangent \r\n\r\ntan(18 deg) = h / 100 \r\n\r\nSolve for h to obtain \r\n\r\nh = 100 tan(18 deg) = 32.5 meters.', 7, 'ILikeToHelp'),
(12, 'https://css-tricks.com/snippets/css/a-guide-to-flexbox/\r\n\r\nThis site saved my life.\r\nCSS is really annoying sometimes :) ', 9, 'Jonnyboi'),
(13, 'An even power function cannot have an inverse on its whole\r\ndomain. If f(x) = x^n is an even power function, then n is divisible by\r\n2, i.e. n = 2k for some real number k. But then f(x) = x^n = (x^2)^k and\r\n4\r\nthen we can see that for any a, f(a) = f(−a). Thus f isn’t one-to-one,\r\nand hence cannot have an inverse on its whole domain. Alternatively,\r\none notes that f an even power function ⇒ the graph is shaped like\r\na parabola, and fails the horizontal line test. One could restrict the\r\ndomain, by choosing {x : x > 0} or {x : x < −0}, or choosing any\r\nsubdomain on which the function passes the horizontal line test.\r\n\r\nhttps://math.rice.edu/~rl6/Calculus_101_files/exam1solutions.pdf', 13, 'NotARobot'),
(15, 'Delay = L + (P ÷ B) \r\n= 1x10⁻² + [(2.4x10⁴) ÷ (1.0x10⁷)]\r\n= 1x10⁻² + 2.4x10⁻³\r\nDelay = 12.4 msec ore 0.0124 seconds', 14, 'forevergrateful'),
(16, '@forevergrateful\r\n\r\nCould you explain what those variables mean? Turns out it is the correct answer. ', 14, 'hellopeople'),
(70, 'jk i learned physics', 15, 'smartboi'),
(71, 'Use pointers', 0, 'smartboi'),
(72, 'test reply1', 2, 'smartboi'),
(73, 'Use pointers', 16, '[Banned]CSMAJOR'),
(74, 'abc', 17, 'smartboi'),
(75, '123', 0, 'smartboi'),
(76, '@Johnnyboi thankz', 9, 'smartboi'),
(77, 'u suck', 9, '[Banned]sch00l_is_h4rd'),
(78, 'great!', 15, 'smartboi'),
(79, 'what', 10, '[Banned]hi'),
(80, '123', 9, 'smartboi'),
(81, '???', 9, 'smartboi'),
(82, 'dude u got banned', 5, 'smartboi'),
(83, 'wow', 5, 'smartboi'),
(84, 'math isn\'t hard.', 10, 'smartboi'),
(85, 'Think about it recursively. The values depend on the others.  Here is the formula to get you started Xn+2= Xn+1 + Xn', 19, 'katieee'),
(86, 'fibs n  =  a  where a = array (0,n) ([(0, 1), (1, 1)] ++                                       [(i, a!(i-2) + a!(i-1)) | i <- [2..n]])', 19, 'hellopeople'),
(87, '@hellopeople it works but can you please explain what you did?? ', 19, 'smartboi'),
(88, 'Use D0EL   (energy conservation).\r\n\r\nStep 1: Define/draw system and coordinates. (see transparency)\r\n\r\nInitial position i and final position f (at the bottom).\r\n\r\nStep 2: Define potential energy zero.\r\n\r\nDefine the zero of the potential energy to be the bottom of the path.\r\n\r\nStep 3: Energy conservation statement.\r\n\r\nUi + Ki = Uf + Kf\r\n\r\nInitial kinetic energy Ki = 0 because the ball is released from rest. \r\nFinal potential energy Uf = 0 by definition.\r\n\r\nConclusion: Ui = Kf   or   mgh = ½ mvf2, \r\nwhere h is the height from which the ball is released.\r\n\r\nCancel the m\'s to give:   vf = (2gh)½\r\n\r\nDetermine h from geometry: h = L - Lcos θ = L (1-cos θ)\r\n\r\nWith L = 1.40 m and θ = 20o, h = 0.0844 m,  vf = (2gh)½ = 1.29 m/s ', 3, 'zebra6'),
(89, '2+2 = 4 – 9/2 + 9/2 = √(4 – 9/2)2 + 9/2 = √(16 – 2*4*9/2 + (9/2)2) + 9/2 = √(16 – 36 + (9/2)2) + 9/2 = √(-20 + (9/2)2) + 9/2 = √(25 – 45 + (9/2)2) + 9/2 = √(52) – 2*5*9/2 + (9/2)2) + 9/2 = √(5 – 9/2)2 + 9/2 = 5 – 9/2 + 9/2 = 5 Therefore, 2+2 = 5 (proved)', 18, 'smartboi'),
(90, 'What kind of linked list?? ', 16, 'smartboi'),
(91, 'https://www.geeksforgeeks.org/linked-list-set-1-introduction/', 16, 'smartboi'),
(93, 'In C: \r\n\r\nstruct Node \r\n{ \r\n  int data; \r\n  struct Node *next; \r\n}; \r\n\r\n\r\nThis is as simple as it gets. ', 16, 'teacher'),
(94, '@smartboi nice', 18, 'NotARobot'),
(95, 'Please be specific? ', 11, 'smartboi'),
(103, 'Use textarea ', 20, 'smartboi'),
(104, '1. Prove the statement is true for 1.  2. Prove that if you assume it\'s true for any n, then it\'s true for n + 1. ', 22, 'smartboi'),
(105, 'wow man google it or something', 6, 'smartboi'),
(118, 'test', 16, 'smartboi'),
(119, 'dsasdas', 16, 'smartboi'),
(123, 'what?', 1, 'smartboi'),
(124, 'huh?', 1, 'smartboi'),
(127, 'b ! ', 21, 'smartboi'),
(128, 'I don\'t get it?', 1, 'smartboi'),
(129, 'Algorithm Preorder(tree)    1. Visit the root.    2. Traverse the left subtree, i.e., call Preorder(left-subtree)    3. Traverse the right subtree, i.e., call Preorder(right-subtree) ', 1, 'smartboi'),
(140, 'nice', 23, '[Banned]jimbean'),
(141, 'fish.', 18, 'hello'),
(142, 'What is thisss', 1, 'mimu'),
(143, 'Use the multi line tester from groupspot', 20, '[Banned]robot'),
(144, 'Cute Kitty', 23, 'phonetest'),
(145, 'oof ruff day mate', 5, '[Banned]robot'),
(146, 'is this a good question?', 27, 'hello'),
(147, 'Hmmm', 28, 'Jonny'),
(148, 'replying to myself', 29, 'user');

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

CREATE TABLE `Users` (
  `UserID` varchar(30) NOT NULL,
  `password` varchar(12) NOT NULL,
  `date` date NOT NULL DEFAULT current_timestamp(),
  `num_posts` int(11) NOT NULL DEFAULT 0,
  `num_favorites` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Users`
--

INSERT INTO `Users` (`UserID`, `password`, `date`, `num_posts`, `num_favorites`) VALUES
('admin1', 'pancakes9', '2019-06-02', 0, 1),
('brandi', 'bbe45', '2019-06-19', 1, 1),
('correct_time', 'sda34', '2019-05-28', 0, 1),
('forevergrateful', 'sasdkl111slk', '2019-05-01', 0, 0),
('geosuxks', 'fsd345', '0000-00-00', 0, 0),
('hello', 'hello', '2019-06-03', 1, 3),
('hellopeople', 'djf132112', '2019-05-01', 0, 0),
('iamafool', 'password1', '2019-05-01', 0, 1),
('IamAnAdmin', 'wow12345', '0000-00-00', 0, 0),
('IamAnAdminAlso', 'wow12345', '0000-00-00', 0, 0),
('iamnumber1', 'password1', '2019-05-24', 2, 1),
('ILikeToHelp', 'wow12345', '0000-00-00', 0, 0),
('Jonny', 'Meep', '2019-06-09', 1, 1),
('Jonnyboi', 'SERYWE', '2019-06-01', 0, 1),
('katieee', 'f34tgdsa', '0000-00-00', 0, 0),
('kookoo', 'asf34', '0000-00-00', 1, 1),
('mathishard', '2zebra342323', '2019-04-25', 1, 2),
('mimu', 'mimu', '2019-06-09', 1, 1),
('NotARobot', 'wow12345', '0000-00-00', 0, 0),
('one2', 'one2', '2019-06-09', 1, 0),
('Phonetest', 'Test', '2019-06-09', 0, 0),
('Pleasework', 'Pleasework', '2019-06-09', 0, 0),
('Robotman', 'robot', '2019-06-09', 0, 0),
('smartboi', 'asfj343', '2019-02-05', 13, 7),
('smartie', 'boiman', '0000-00-00', 0, 0),
('teacher', 'sadf33', '0000-00-00', 0, 0),
('user', 'pancakes', '2019-06-09', 1, 1),
('user2', 'pancakes9', '2019-05-02', 2, 0),
('zebra6', 'zebra9', '2019-05-01', 0, 0),
('[Banned]awful', 'hi', '0000-00-00', 0, 0),
('[Banned]ban_me', 'haha', '0000-00-00', 0, 0),
('[Banned]bobmath', 'dasf34', '0000-00-00', 2, 0),
('[Banned]CSMAJOR', 'mybirthday2', '2019-05-11', 0, 0),
('[Banned]fbiguy', '234ga', '0000-00-00', 0, 0),
('[Banned]hi', 'hi', '2019-06-03', 0, 0),
('[Banned]jimbean', 'Yeet', '2019-06-02', 0, 0),
('[Banned]johnny', '23kfd3', '0000-00-00', 1, 0),
('[Banned]junk', '', '2019-06-03', 0, 0),
('[Banned]pleasedontban', 'hahaaa', '0000-00-00', 0, 0),
('[Banned]plsdontbaneither', 'whatwhat', '0000-00-00', 0, 0),
('[Banned]robot', 'robot', '2019-06-09', 1, 0),
('[Banned]sch00l_is_h4rd', 'soccerscorre', '2019-05-01', 0, 0),
('[Banned]selected', 'sdf34', '2019-05-28', 0, 0),
('[Banned]Xx_thousands', 'whatwhat', '2019-05-05', 0, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Admins`
--
ALTER TABLE `Admins`
  ADD PRIMARY KEY (`UserID`);

--
-- Indexes for table `BannedUsers`
--
ALTER TABLE `BannedUsers`
  ADD PRIMARY KEY (`UserID`);

--
-- Indexes for table `Content`
--
ALTER TABLE `Content`
  ADD PRIMARY KEY (`postID`);

--
-- Indexes for table `Favorites`
--
ALTER TABLE `Favorites`
  ADD PRIMARY KEY (`postID`,`userID`),
  ADD KEY `userID` (`userID`);

--
-- Indexes for table `Post`
--
ALTER TABLE `Post`
  ADD PRIMARY KEY (`postID`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `Replies`
--
ALTER TABLE `Replies`
  ADD PRIMARY KEY (`replyID`,`postID`),
  ADD KEY `Replies_ibfk_1` (`postID`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`UserID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Replies`
--
ALTER TABLE `Replies`
  MODIFY `replyID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=149;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Admins`
--
ALTER TABLE `Admins`
  ADD CONSTRAINT `constraint_userid` FOREIGN KEY (`UserID`) REFERENCES `Users` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `BannedUsers`
--
ALTER TABLE `BannedUsers`
  ADD CONSTRAINT `BannedUsers_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `Users` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `Content`
--
ALTER TABLE `Content`
  ADD CONSTRAINT `postid` FOREIGN KEY (`postID`) REFERENCES `Post` (`postID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `Favorites`
--
ALTER TABLE `Favorites`
  ADD CONSTRAINT `Favorites_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `Users` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Favorites_ibfk_2` FOREIGN KEY (`postID`) REFERENCES `Post` (`postID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `Post`
--
ALTER TABLE `Post`
  ADD CONSTRAINT `Post_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `Replies`
--
ALTER TABLE `Replies`
  ADD CONSTRAINT `Replies_ibfk_1` FOREIGN KEY (`postID`) REFERENCES `Post` (`postID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Replies_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `Users` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

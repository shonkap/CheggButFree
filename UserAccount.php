<?php
        if(!session_id()){
            session_start();
        }
?>
<!DOCTYPE html>
<?php
		$currentpage="UserAccount";
		include "pages.php";
?>
<html>
	<head>
		<title>Your Account</title>
		<link rel="stylesheet" href="style.css">
		<link rel="stylesheet" href="acctStyle.css">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<!-- bootstrap stuff -->
		<!-- Latest compiled and minified CSS -->
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">

		<!-- jQuery library -->
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>

		<!-- Latest compiled JavaScript -->
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
	</head>
<body>


<?php
// change the value of $dbuser and $dbpass to your username and password
	include 'connectvars.php'; 
	include 'header.php';	

	$conn = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
	if (!$conn) {
		die('Could not connect: ' . mysql_error());
	}	

	global $currentId;
		if(isset($_SESSION['userID'])){
		    $currentId = $_SESSION['userID'];
		}
	$query = "SELECT UserID, date, num_posts, num_favorites FROM Users WHERE UserID='$currentId' ";
	
// Get results from query
	$result = mysqli_query($conn, $query);
	if (!$result) {
		die("Query to show fields from table failed");
	}
// get number of columns in table	
	$fields_num = mysqli_num_fields($result);
	echo "<div class='container'>";
	
	echo "<h1>Account Info:</h1>";

	$row = mysqli_fetch_array($result);

	echo "<div id='account'>";
	echo "<p> <b>Username:</b> " . $row['UserID']. "<p>";
	echo "<p> <b>Date Joined:</b> " . $row['date']. "<p>";
	echo "<p> <b>Number Posts:</b> " . $row['num_posts']. "<p>";
	echo "<p> <b>Number Favorites:</b> " . $row['num_favorites']. "<p>";


	$isAdminQuery = "SELECT * FROM Admins WHERE UserID = '$currentId'"; /// check if the currentID is an admin and show data based on if it is in the currentID 
	$result2 = mysqli_query($conn, $isAdminQuery);
	if (!$result2) {
		die("Can't tell if admin..");
	}
	$num = mysqli_num_rows($result2);
	$adminInfo = mysqli_fetch_array($result2);

	//If admin show the banned users and a link to ban users
	if($num != 0) {
		echo "<p> <b>Number Users Banned By You:</b> " . $adminInfo['numUsersBanned']. " users";

		//banned users
		$query = "SELECT * FROM BannedUsers ";

		$result2 = mysqli_query($conn, $query);
		if (!$result2) {
			die("Query to show fields from table failed");
		}

		// $row = mysqli_fetch_array($result2);

		// echo "<p>" . $row['']
		//get number of columns in table	
		$fields_num = mysqli_num_fields($result2);
		echo "<table id='t01' border='1'><tr>";
		
	// printing table headers
		echo "<td><b>Banned Username</b></td>";
		echo "<td><b>Date Banned</b></td>";


		echo "</tr>\n";
		while($row = mysqli_fetch_row($result2)) {	
			echo "<tr>";	
			// $row is array... foreach( .. ) puts every element
			// of $row to $cell variable	
			foreach($row as $cell)		
				echo "<td>$cell</td>";	
			echo "</tr>\n";
		}

		echo "<h2>Banned Users:</h2>";
		echo "<a href='BanUser.php' class='btn btn-primary btn-xs'> Ban a User Here </a>";
	}

	echo "</div>";
	echo "</div>"; //container


	mysqli_free_result($result);
	mysqli_close($conn);
?>
</body>

</html>

	

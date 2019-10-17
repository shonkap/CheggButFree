<?php
        if(!session_id()){
            session_start();
        }
?>
<!DOCTYPE html>
<?php?>
<html>
	<head>
		<title>Favorites</title>
		<link rel="stylesheet" href="style.css">

		<meta name="viewport" content="width=device-width, initial-scale=1">
		<!-- bootstrap stuff -->
		<!-- Latest compiled and minified CSS -->
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">

		<!-- jQuery library -->
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>

		<!-- Latest compiled JavaScript -->
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
	</head>
<?php
	include 'connectvars.php';
	include 'header.php';
	?>

	<div style="padding: 10px">
	<h1>Your Favorite Posts:</h1>
	<?php
	$conn = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
	if (!$conn) {
		die('Could not connect: ' . mysql_error());
	}

global $currentId;
		if(isset($_SESSION['userID'])){
		    $currentId = $_SESSION['userID'];
		}

$query = "SELECT Post.postID, Post.title, Post.user_id as posted_by FROM Favorites, Post
			WHERE Favorites.postID = Post.postID
			AND Favorites.UserID = '$currentId' ";

// Get results from query
$result = mysqli_query($conn, $query);
if (!$result) {
	die("Query to show fields from table failed");
}

// get number of columns in table
$fields_num = mysqli_num_fields($result);
echo "<table id='t01' border='1' class='table table-info table-striped table-bordered'><tr>";

// printing table headers
for($i=0; $i<$fields_num; $i++) {
	$field = mysqli_fetch_field($result);
	if($i > 0){
		echo "<td><b>$field->name</b></td>";
	}
}
echo "</tr>\n";
while($row = mysqli_fetch_row($result)) {
	echo "<tr>";
	$count = 1;
	// $row is array... foreach( .. ) puts every element
	// of $row to $cell variable
	foreach($row as $cell){
		global $id;
		if($count == 1){
			$id = $cell;
		}
		else if($count == 2){
			echo "<td><a href='viewPost.php?post=$id'>$cell</a></td>";
		}
		else{
			echo "<td>$cell</td>";
		}
		$count = $count + 1;
	}
	echo "</tr>\n";
}


?>
	</div>
</body>

</html>

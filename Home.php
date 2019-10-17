<?php
        if(!session_id()){
            session_start();
        }
?>
<!DOCTYPE html>
<html>
	<head>
		<title>CheggButFree.com | Home</title>
		<link rel="stylesheet" href="style.css">
		<script type = "text/javascript"  src = "verifyInput.js" > </script>
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
	include 'connectvars.php'; 

	$conn = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
	if (!$conn) {
		die('Could not connect: ' . mysql_error());
	}

	include 'header.php';

	/*$conn = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
	if (!$conn) {
		die('Could not connect: ' . mysql_error());
	} //dont need right now*/


echo "<div class=container>";

// // show buttons of all categories 
// $categories = "SELECT DISTINCT category FROM Post";
// $catResult = mysqli_query($conn, $categories);
// echo "<div>";	
// while($row = mysqli_fetch_row($catResult)) {	
// 	// $row is array... foreach( .. ) puts every element
// 	// of $row to $cell variable	
// 	foreach($row as $cell)		
// 		echo "<button name='$cell'>$cell</button>";	
// }
// echo "</div>\n";


// query to select all information from supplier table
$currentId = "zebra6"; // temporary nonadmin current user

$query = "SELECT postID, user_id, title, category FROM Post ";

if(isset($_POST['search'])) {
	$search_term = mysqli_real_escape_string($conn,$_POST['search_box']);
	$query .= "WHERE title LIKE '%{$search_term}%' OR category LIKE '%{$search_term}%'";
	// echo "search term: $search_term\n";
}

// Get results from query
$result = mysqli_query($conn, $query);
if (!$result) {
	die("Query to show fields from table failed");
}


// get number of columns in table
$fields_num = mysqli_num_fields($result);
// echo "<table id='t01' class='table' border='1'><tr>";
echo "<table class='table table-info table-striped table-bordered'><tr>";

// // printing table headers
// for($i=0; $i<$fields_num; $i++) {
// 	$field = mysqli_fetch_field($result);
// 	if($i > 0){
// 		echo "<td><b>$field->name</b></td>";
// 	}
// }
echo "<td><b>Username</b></td>";
echo "<td><b>Post Title</b></td>";
echo "<td><b>Category</b></td>";

echo "</tr>\n";
while($row = mysqli_fetch_row($result)) {
	echo "<tr>";
	// $row is array... foreach( .. ) puts every element
	// of $row to $cell variable
	$count = 1;
	foreach($row as $cell){
		global $id;
		if($count == 1){
			$id = $cell;
		}
		else if($count == 3){
		echo "<td><a href='viewPost.php?post=$id'>$cell</a></td>";
		}
		else{
			echo "<td>$cell</td>";
		}
		$count=$count+1;
	}
	echo "</tr>\n";
}



?>
<form name="search_form" method="POST" action="Home.php" class="form-inline">
	<i class="fas fa-search" aria-hidden="true"></i>
	<input class="form-group mx-sm-3 mb-2" type="text" name="search_box" value=""/>
	<input type="submit" class="btn btn-primary btn-xs" name="search" value="Search posts">
</form>
<div <?php
            if(isset($_SESSION['login'])){
                    if(($_SESSION['login']) == TRUE){
                    }
                    else{
                       echo "style='display: none;'";
                    }
            } else{
                echo "style='display:none;'";
            }
        ?>>
<div class="fixed-action-btn" style="position:fixed; bottom: 30px; right:24px">
	<a href='newPost.php' id="new_post" class="btn btn-primary btn-lg" role="button">Create a Post</a>
</div>
</div>


</div>
</body>

</html>

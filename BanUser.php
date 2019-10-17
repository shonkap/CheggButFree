<?php
        if(!session_id()){
            session_start();
        }
?>
<!DOCTYPE html>
<!-- Add Supplier Info to Table Supplier -->
<?php
		$currentpage="Ban User";
		include "pages.php";

		
?>
<html>
	<head>
		<title>Ban User</title>
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
<?php include "header.php"; ?>
<div style="padding: 20px;">
<?php
	echo "<h2>Ban a Problematic User</h2>";

// change the value of $dbuser and $dbpass to your username and password
	include 'connectvars.php'; 
	
	$conn = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
	if (!$conn) {
		die('Could not connect: ' . mysql_error());
	}
	if ($_SERVER["REQUEST_METHOD"] == "POST") {

// Escape user inputs for security
        $userToBan = mysqli_real_escape_string($conn, $_POST['banUser']);
    global $admin;
        if(isset($_SESSION['userID'])){
        $admin = $_SESSION['userID'];
    }
	
		
        // attempt insert query 
        $query = "SELECT BanUser('$admin', '$userToBan') AS BanUser";
        if(mysqli_query($conn, $query)){
            echo "<h3>Successfully banned $userToBan</h3>";
        } else{
            echo "ERROR: Could not able to execute $query. " . mysqli_error($conn);
        }

}
// close connection
mysqli_close($conn);

?>
	<section>
    <h2> <?php echo $msg; ?> </h2>

<form method="post" id="addForm">
<fieldset>
    <p>
        <label for="banUser">Username to Ban:</label>
        <input type="text" class="required" name="banUser" id="banUser" title="banUser">
    </p>
</fieldset>

      <p>
        <input class="btn btn-warning" type = "submit"  value = "Ban User" />
        <input class="btn btn-secondary" type = "reset"  value = "Clear" />
      </p>
</form>
</div>
</body>
</html>

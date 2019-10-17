<?php
        if(!session_id()){
            session_start();
        }
		$currentpage="New Post";
		include "pages.php";
?>
<!DOCTYPE html>
<html>
<head>
    <title>New Post</title>
    <script type = "text/javascript"  src = "verifyInput.js" > </script>
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
<body>
<?php
	include "header.php";
	$msg = "Add new Post";

    // change the value of $dbuser and $dbpass to your username and password
	include 'connectvars.php';

	$conn = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
	if (!$conn) {
		die('Could not connect: ' . mysql_error());
	}
	if ($_SERVER["REQUEST_METHOD"] == "POST") {
        // Escape user inputs for security
		$title = mysqli_real_escape_string($conn, $_POST['title']);
		$category = mysqli_real_escape_string($conn, $_POST['category']);
		$content = mysqli_real_escape_string($conn, $_POST['content']);
		$url = mysqli_real_escape_string($conn, $_POST['url']);

		global $currUser;
		if(isset($_SESSION['userID'])){
		    $currUser = $_SESSION['userID'];
		}

        // attempt insert query
        $queryTwo = "SELECT * FROM Post";
        $resultTwo = mysqli_query($conn, $queryTwo);
        $value = mysqli_num_rows($resultTwo) + 2;
        $query = "INSERT INTO Post (postID, title, category, user_id) VALUES ('$value', '$title', '$category', '$currUser')";
        $contentQ = "INSERT INTO Content (postID, picURL, text) VALUES ('$value', '$url', '$content')";
        if(mysqli_query($conn, $query) && mysqli_query($conn, $contentQ)){
            $_SESSION['currPost'] = $value;
            echo '<script>window.location.href = "viewPost.php";</script>';
        } else if (mysqli_query($conn, $query) == null && mysqli_query($conn, $contentQ)==null){
            echo "ERROR: Could not able to execute: " . mysqli_error($conn);
        }
        else {
            echo "ERROR: Could not able to execute $query. " . mysqli_error($conn);
        }
    }
    // close connection
    $contentQ = null;
    $query = null;
    mysqli_close($conn);

    ?>
<div class="container">
    <section>
    <h2> <?php echo $msg; ?> </h2>
    <form method="post" id="addForm">
        <fieldset>
            <legend>New Post:</legend>
    <p>
        <label for="title">Title:</label>
        <input type="text" class="required form-control" name="title" id="title" required="true">
    </p>
    <p>
        <label for="category">Category:</label>
        <input type="text" class="required form-control" name="category" id="category" required="true">
    </p>
    <p>
        <label for="url">Photo URL (optional):</label>
        <input type="text" class="form-control" name="url" id="url">
    </p>

    <p>
        <label for="content">Content:</label>
        <textarea cols="40" rows="5" class="form-control" name="content" id="content" required="true"></textarea>

        </fieldset>

    <p>
        <input type = "submit"  value = "Submit" />
        <input type = "reset"  value = "Clear Form" />
    </p>
    </form>
</div>
</body>
</html>




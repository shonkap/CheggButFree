<?php
        if(!session_id()){
            session_start();
        }
		$currentpage="View Post";
		include "pages.php";
?>
<!DOCTYPE html>
<html>
<head>
    <title>View Post</title>
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
    include 'connectvars.php';
	include 'header.php';
?>
<div style="padding: 20px;">
    <?php
        if(isset($_GET['post'])){
            $_SESSION['currPost'] = $_GET['post'];
        }
        $pid = $_SESSION['currPost'];

        global $currUser;
		if(isset($_SESSION['userID'])){
		    $currUser = $_SESSION['userID'];
		} else {
		    $currUser = "";
		}
        // change the value of $dbuser and $dbpass to your username and password


	    $conn = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
	    if (!$conn) {
		    die('Could not connect: ' . mysql_error());
	    }

        // query to select all information from supplier table
	    $query = "SELECT title, category, user_id FROM Post WHERE postID = '$pid'";

        // Get results from query
	    $result = mysqli_query($conn, $query);
	    if (!$result) {
		    die("Query to show fields from table failed: mysqli_error($conn)");
	    }
        // get number of columns in table
	    $fields_num = mysqli_num_fields($result);
        //echo "<table id='t02' border='1'><tr>";

        // printing table headers
        for($i=0; $i<$fields_num; $i++) {
            $field = mysqli_fetch_field($result);
            //echo "<td><b>$field->name</b></td>";
        }
        echo "</tr>\n";
        while($row = mysqli_fetch_row($result)) {
            //echo "<div>";
            // $row is array... foreach( .. ) puts every element
            // of $row to $cell variable
            $count1 = 0;
            echo "<div style='background-color: #f1f1f1; color: #050505; padding: 10px;'>";
            foreach($row as $cell){
                if($count1 == 0){
                    echo "<h2>$cell</h2>";
                }
                else if($count1 == 1){
                    echo "<h4>Category: $cell</h4>";
                }
                else{
                    echo "<h4>Posted By: $cell</h4>";
                }
                $count1 = $count1 + 1;
            }

        }

        // query to select all information from supplier table
        $queryContent = "SELECT picUrl, text FROM Content WHERE postID = '$pid'";

        // Get results from query
        $resultContent = mysqli_query($conn, $queryContent);
        if (!$resultContent) {
            die("Query to show fields from table failed: mysqli_error($conn)");
        }

        // $cont = mysqli_fetch_array($resultContent);
        // echo "<img src='" . $cont['picURL'] . "'/>";

        while($row = mysqli_fetch_row($resultContent)) {
            $count2 = 0;
            foreach($row as $cell){
                if($count2 == 0){
                    if($cell != null){
                        // echo "$cell";
                        echo "<img src='" . $cell . "'/>";
                    }
                }
                else{
                    echo "<h5>$cell</h5>";
                }
                $count2 = $count2 + 1;
            }
        }
        echo "</div>";

        $queryReply = "SELECT user_id as user, textContent as reply FROM Replies WHERE postID = '$pid'";

        // Get results from query
        $resultReply = mysqli_query($conn, $queryReply);
        if (!$resultReply) {
            die("Query to show fields from table failed: mysqli_error($conn)");
        }
        // get number of columns in table
        $fieldsReply = mysqli_num_fields($resultReply);
        echo "<table id='t02' class='table table-info table-striped table-bordered' border='1'><tr>";

        // printing table headers
        for($i=0; $i<$fieldsReply; $i++) {
            $fieldHeader = mysqli_fetch_field($resultReply);
            echo "<td><b>$fieldHeader->name</b></td>";
        }
        echo "</tr>\n";
        while($row = mysqli_fetch_row($resultReply)) {
            echo "<tr>";
            // $row is array... foreach( .. ) puts every element
            // of $row to $cell variable
            foreach($row as $cell)
            echo nl2br("<td>$cell</td>");
            echo "</tr>\n";
        }
        mysqli_free_result($resultContent);
        mysqli_free_result($resultReply);
        mysqli_free_result($result);

                if ($_SERVER["REQUEST_METHOD"] == "POST") {
                // Escape user inputs for security
                    $reply = mysqli_real_escape_string($conn, $_POST['reply']);
                    $idQ = "SELECT * FROM Replies WHERE postID = '$pid'";
                    $idQResponse = mysqli_query($conn, $idQResponse);
                    $id = mysqli_num_fields($idQResponse);

                    if($reply != "") {
                        $query = "INSERT INTO Replies (replyID, textContent, postId, user_id) VALUES ('$id', '$reply', '$pid', '$currUser')";
                        if(mysqli_query($conn, $query)){
                            echo '<script>window.location.href = "viewPost.php";</script>';
                        } else if (mysqli_query($conn, $query) == null){
                            echo "ERROR: Could not able to execute: " . mysqli_error($conn);
                        }
                    }
                }
                $idQ = null;
                $query = null;


        if(isset($_POST['favorite'])) {
            $favQuery = "INSERT INTO Favorites(postID, userID)
                        VALUES ('$pid', '$currUser')";
            if(mysqli_query($conn, $favQuery)){
                echo '<script>window.location.href = "viewPost.php";</script>';
                // echo "<p> favorited! </p>";
            }
        }
        mysqli_close($conn);
    ?>
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
        <section>
                <form method="post" id="addForm">
                    <fieldset>
                        <p>
                            <label for="reply">Reply:</label>
                            <input type="text" class="required form-control" name="reply" id="reply" required="true">
                        </p>
                    </fieldset>
                    <p>
                        <input class="btn btn-default" id="submitReply" type = "submit"  value = "Submit" />
                    </p>
                </form>

                <form method="post" id="fav-button">
                    <input type="submit" name="favorite" value="favorite"/>
                </form>
        </div>
</div>
</body>
</html>

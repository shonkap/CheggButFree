<header>

    <div class="header">
        <a class="left" onclick="backfunc()" style="margin-left='12'"> Back </a>
        <a href='Home.php' class="left" style="margin-left='12'">Home</a>

        <h1 style="text-align:center; display:inline-block;">CheggButFree.com</h1>

        <div class="header-right">
            <?php
                if(isset($_SESSION['login'])){
                    if(($_SESSION['login']) == TRUE){
                        echo '<a href="UserAccount.php" class="right" style="width: 90px;"> Account </a>';
                        echo '<a href="Favorites.php" class="right" style="width: 100px;"> Favorites</a>';
                        echo '<a id="logout" href="LogOut.php" class="right" style="width: 100px;"> Log out </a>';
                    }
                    else{
                        echo '<a id="login" href="LoginInfo.php" class="right" style="width: 100px;"> Log in </a>';
                    }
                }
                else{
                    echo '<a id="login" href="Login.php" class="right" style="width: 100px;"> Log in </a>';
                }
            ?>
        </div>
    </div>

    <?php
    include 'connectvars.php';
	$conn = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
	if (!$conn) {
		die('Could not connect: ' . mysql_error());
	}

        if ($_SERVER["REQUEST_METHOD"] == "LOGIN") {
		// Escape user inputs for security
		$UserID = mysqli_real_escape_string($conn, $_POST['UserID']);
		$password = mysqli_real_escape_string($conn, $_POST['password']);
				// See if sid is already in the table
		$queryIn = "SELECT * FROM Users where UserID='$UserID' and password='$password'";
		$resultIn = mysqli_query($conn, $queryIn);
		if (mysqli_num_rows($resultIn)> 0) {
    $_SESSION[Login] = TRUE;
    echo "$_SESSION[Login]";
    $_SESSION[UserID] = $UserID;
    $msg ="Found User Attempting login.<p>";

    } else {
        $_SESSION[Login] = False;
    }
    }
    ?>


    <script>
        function backfunc() {
            window.history.back();
        }

        function loginfunc() {
            var modal = document.getElementById("myModal");
            modal.style.display = "block";
        }
        function loginsuc() {
            var modal = document.getElementById("myModal");
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }
    </script>

</header>
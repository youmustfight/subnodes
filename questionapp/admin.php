<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Poll Test</title>
<link href="poll/template/styles.css" rel="stylesheet" type="text/css" />
<script src="/js/jquery.min.js"></script>
</head>
<body>

<?php

$question_file = "poll_data.txt";
$question = json_decode(file_get_contents($question_file), true);

$home_url = '/var/www';

if ($_GET['ssid'] && $_GET['question'] && $_GET['answers'])
{
    $question['ssid'] = $_GET['ssid'];
    $question['question'] = $_GET['question'];
    $question['answers'] = $_GET['answers'];

    file_put_contents($question_file, json_encode($question));

    shell_exec("sed -i \"s/\(ssid *= *\).*/\\1".$question['ssid']."/\" ".$home_url."/questionapp/test.conf");

}


?> 

<form method=GET>
<input name=ssid type=text size=32 value="Type here the SSID name (up to 32 characters)"></input>
<br/>
<br/>

<input name=question type=text size=50 value="Type here your preferred question"></input>
<br/>
<br/>

<input name=answers type=text size=100 value='Type the possible answers, delimited with ";", like "Answer 1;Answer2;...'</input>
<br/>
<br/>

<input type=submit value=Go!></input>
</form>

</body>
</html>

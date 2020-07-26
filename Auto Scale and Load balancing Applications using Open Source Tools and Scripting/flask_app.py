from flask import Flask
import socket
app = Flask(__name__)


@app.route('/')
def hello_world():
	return '<!DOCTYPE html><html lang="en"><head>  <title>Bootstrap Theme Simply Me</title>  <meta charset="utf-8">  <meta name="viewport" content="width=device-width, initial-scale=1">  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>  <style>  .bg-1 {    background-color: #555555; /* Green */    color: #ffffff;  }  </style></head><body><div class="container-fluid bg-1 text-center">    <h1>Cloud Computing Basics</h1>    <img src="https://miro.medium.com/max/469/1*24oTbi-r9SXkkJjtV2_B2A.png" alt="cc">    <h3>This is a simple Flask Application for demo of a autoscaled and load balanced applications docker running this app</h3>    <h3>Hostname of Docker image serving the page is '+socket.gethostname()+'</h3></div></body></html>'

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')
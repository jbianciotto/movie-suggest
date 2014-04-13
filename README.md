movie-suggest
=============

Movie suggestion engine that takes the user's location and weather into account.


Installation instructions
-----------

### Pre-requisites  
* Apache2  
	sudo apt-get install apache2 or [here](http://httpd.apache.org/)
* mod_perl2 
	sudo apt-get install libapache2-mod-perl2 or [here](http://perl.apache.org/docs/2.0/user/intro/start_fast.html)
* Mysql
	sudo apt-get install mysql-server or [here](http://dev.mysql.com/)
* DBI mysql driver
	sudo apt-get install libdbd-mysql-perl or [here](http://search.cpan.org/CPAN/authors/id/C/CA/CAPTTOFU/DBD-mysql-4.027.tar.gz)

### Installation  
1. Clone this repo into the folder of your choice
2. Use the db dump file located in utils/db_dump.sql to recreate the app db
3. Modify config file conf/movie-suggest.conf with your db credentials
4. Apache conf:
	
	1. Add the following to your sites apache configuration


		    Alias /movie-suggest/ /var/www/movie-suggest/  
	    	<Location /movie-suggest/>  
	      		SetHandler perl-script  
	      		PerlResponseHandler MovieSuggestHandler  
	      		PerlOptions +ParseHeaders  
	      		Options +ExecCGI  
	      		Order allow,deny  
	      		Allow from all   
	    	</Location>  

    2. Modify apache/movie-suggest file with the path to apache/startup.pl of this repo, and then copy it to your apache conf.d directory

    3. Restart your apache

API Specifications:
-----------

* User creation  
	/movie-suggest/create_user  
	Arguments: username, region, city, genre, [genre...]  
	Creates an user and registers its location and preferred genres  

* User location update  
	/movie-suggest/update_location  
	Arguments: username, region, city  
	Updates location for the provided user 

* User genres update  
	/movie-suggest/update_genres  
	Arguments: username, genre, [genre...]  
	Updates the preferred genres for the provided user  

* Get movies suggestions  
	/movie-suggest/suggest  
	Arguments: username  
	Obtains the movies suggestions for the provided user  

* Get suggestions history  
	/movie-suggest/history  
	Arguments: username   
	Obtains the history of movies suggestions given to the provided user  



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
* Perl Modules:   
	* DBD::mysql
	* DBIx::Class  
	* LWP::Agent  
	* HTTP::Request  
	* JSON::XS  
	* URL::Encode  
	* DateTime  

### Installation  
1. Clone this repo into the folder of your choice
2. Use the db dump file located in utils/db_dump.sql to recreate the app db
3. Modify config file conf/movie-suggest.conf with your db credentials
4. Apache conf:
	
	1. Add the following to your apache sites configuration

		    Alias /movie-suggest/ /var/www/movie-suggest/  
	    	<Location /movie-suggest/>  
	      		SetHandler perl-script  
	      		PerlResponseHandler MovieSuggestHandler  
	      		PerlOptions +ParseHeaders  
	      		Options +ExecCGI  
	      		Order allow,deny  
	      		Allow from all   
	    	</Location>  

	2. Create /var/www/movie-suggest/ directory

    3. Modify apache/movie-suggest file in this repo with the path to apache/startup.pl of this repo, and then copy it to your apache conf.d directory  

    4. Modify the lib path in apache/startup.pl of this repo so it points to the directory containing this project   

    5. Restart your apache

API Specifications:
-----------

* User creation  
	/movie-suggest/create_user  
	Arguments: username, region, city, genre, [genre...]   
	Returns: newly created user data

			{
	    		"location": {
	        		"city": <city>,
	        		"country/state": <region>
	    		},
	    		"date": <response_date>,
	    		"preferred_genres": [
	        		<genre>,
	        		....
	    		],
	    		"username": <username>
			}

	Creates an user and registers its location and preferred genres  

* User location update  
	/movie-suggest/update_location  
	Arguments: username, region, city    
	Return: updated user data, see create_user return structure   
	Updates location for the provided user 

* User genres update  
	/movie-suggest/update_genres  
	Arguments: username, genre, [genre...]   
	Return: updated user data, see create_user return structure   
	Updates the preferred genres for the provided user  

* Get movies suggestions  
	/movie-suggest/suggest  
	Arguments: username  
	Returns:  

	    {
    		"matched_genres": [
        		<genre>,
        		.... 
    		],
    		"date": <response_date>,
    		"conditions": {
        		"weather": <weather>,
        		"temperature": <temperature>
    		},
    		"results": {
        		"count": <movies_count>,
        		"movies": [
            		{
                		"movie_id": <movie id>,
                		"genres": [
                    		<movie_genre>,
                    		....
                		],
                		"title": <movie title>
            		},
            		...
        		]
    		}
		}
	Obtains the movies suggestions for the provided user  

* Get suggestions history  
	/movie-suggest/history  
	Arguments: username   
	Returns:
	   
		{
		    "count": <history count>,
		    "date": <response date>,
		    "results": [
		        {
		            "id": <history id>,
		            "movie_count": <history movies count>,
		            "date": <history date>,
	        		"movies": [
	            		{
	                		"movie_id": <movie id>,
	                		"genres": [
	                    		<movie_genre>,
	                    		....
	                		],
	                		"title": <movie title>
	            		},
	            		...
	        		], 
		            "conditions": {
		                "weather": <history weather>,
		                "temperature": <history temperature>
		            }
		        },
		        ...
		    ]
		}	

	Obtains the history of movies suggestions given to the provided user   



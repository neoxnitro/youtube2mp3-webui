# youtube2mp3-webui
Webui for youtube-dl in hmtl+cgi

It's not the best way to do that but it's an old script i have made a couple of years ago

+Set ID3tag author and title extracted based on youtube video title
+Set ID3tag thumbnail extracted from youtube video thumbnail

[Customize mp3 file destination]
> nano cgi-bin/simple-ajax-send.cgi

Replace "/home/cgi/mp3/" by a path where you want save permanelty the mp3
N.B if you change the path, don't forget to alose change the path of last step
N.B' be sure that this directory is editable by everybody (sudo chmod ugo+rw <directory>)
  
eyed3 (ID3TAG)
> sudo apt install eyed3

Apache2:
> sudo apt-get install apache2

Apache2, Enable cgi:
> cd /etc/apache2/mods-enabled
> sudo ln -s ../mods-available/cgi.load
> sudo service apache2 reload

Copy custom html:
> sudo cp -r youtube2mp3 /var/www/html/
> sudo chmod ugo+r /var/www/html/youtube2mp3

Copy custom cgi:
> sudo cp cgi-bin/* /usr/lib/cgi-bin/
> sudo chmod ugo+rx /usr/lib/cgi-bin/*

Copy the bash script invoked by cgi:
> sudo mkdir /home/cgi/
> sudo mkdir /home/cgi/mp3
> sudo chmod ugo+rw /home/cgi/mp3
> sudo cp youtube2mp3.sh /home/cgi/
> sudo chmod ugo+rx /home/cgi/youtube2mp3.sh

Install/Update youtube-dl: ... a good thing is to create a cron task to update dialy youtube-dl !
> sudo /home/cgi/youtube2mp3.sh update

Download from html page:
> sudo ln -s /home/cgi/mp3/ /var/www/html/mp3
> sudo ln -s /tmp/ /var/www/html/tmp

Replace "/home/cgi/mp3/" by a path where you want save permanelty the mp3

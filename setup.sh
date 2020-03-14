exit

sudo apt install eyed3
sudo apt-get install apache2
cd /etc/apache2/mods-enabled
sudo ln -s ../mods-available/cgi.load
sudo service apache2 reload

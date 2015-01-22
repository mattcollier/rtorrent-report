# rtorrent-report
You must have a redis server operating on localhost and a working installation of pyrocode/rtcontrol

modify settings.conf to your liking and copy to your $HOME folder

setup a cron job to run report.sh on an hourly basis.  This records a snapshot of your rtorrent status in redis.

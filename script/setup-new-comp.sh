#!/bin/bash

cat > /etc/apt/sources.list <<__EOS__
deb http://debs.hq.allmed.net:9999/ubuntu gutsy main universe restricted
deb http://debs.hq.allmed.net:9999/ubuntu-security gutsy-security main
__EOS__

apt-get update

apt-get --assume-yes install libpgsql-ruby1.8 ruby ruby1.8 emacs21 libgnome2-ruby libgconf2-ruby libstdc++5 rdoc1.8 postgresql-8.2 libpgsql-ruby1.8 libvte-ruby libopenssl-ruby rake subversion rubygemsi ssh
if [ $? != 0 ]; then
    echo failed to download needed *.debs, will now exit
    exit 1
fi


su postgres -c '/usr/lib/postgresql/8.2/bin/createuser -s -d nas'
su postgres -c '/usr/lib/postgresql/8.2/bin/createuser -s -d ezpos'

cat > /etc/postgresql/8.2/main/pg_hba.conf <<__EOS_
local   all     postgres                                ident sameuser
local   all     all                                     trust
host    all     all             127.0.0.1/32            trust
__EOS_
/etc/init.d/postgresql-8.2 restart
psql -Unas -c "CREATE DATABASE ezpos ENCODING 'latin1'" template1
psql -Unas -c "CREATE LANGUAGE 'plpgsql'" ezpos
cd /tmp

gem install rails --include-dependencies | tail -n 10

cd /usr/local

if [ ! -d ezpos ]; then
   mkdir ezpos
fi

chown nas ezpos

su -c 'svn co https://trac.allmed.net/svn/computers/trunk/ezpos' nas | tail

cd /tmp

su -c 'svn co https://trac.allmed.net/svn/computers/vendor/yourpay' nas | tail
cp yourpay/*.so /usr/local/lib/
echo /usr/local/lib > /etc/ld.so.conf
ln -s /usr/lib/libssl.so.0.9.8 /usr/lib/libssl.so.2
ln -s /usr/lib/libcrypto.so.0.9.8 /usr/lib/libcrypto.so.2
ldconfig
rm -rf /tmp/yourpay

cd /usr/local/ezpos

cat > ./config/database.yml <<__EOS_
production:
  adapter: postgresql
  database: ezpos
  host: localhost
  username: ezpos
  password:

development:
  adapter: postgresql
  database: ezpos
  host: localhost
  username: ezpos
  password:
__EOS_

cat > /etc/udev/rules.d/51-pos-updates.rules <<EOF
ACTION=="add", KERNEL=="sd[a-z]1", NAME="pos_update" RUN+="/usr/local/ezpos/script/update_pos"
EOF

cat > ./config/settings.yml <<EOF
LOCATION_NAME: `hostname` Computer
LOCATION_EMAIL: sysadmin@allmed.net
NONEXISTANT_SKU_ID: 1
RETURNED_SKU_ID:    2
SKU_FIRST_ID: 3

DB:
  DUMPS: /tmp
  NAME: ezpos
  USER: ezpos

SBT_SERVER: 192.168.1.4
DISPLAY_POLE_PORT: /dev/ttyS0
RECEIPT_PRINTER: receipt
RECEIPT_LOGO: allmed-receipt-logo.bin
CASH_DRAWER_PRINTER: receipt
POS_UPDATES_DEV: /dev/pos_update
POS_UPDATES_MOUNT_DIR: /mnt/pos_update
POS_PROCESS_CARDS: true
NNTP_REPORTING_SERVER: reports.hq.allmed.net
POS_SHOW_COST: true
POS_HEIGHT: 768
POS_WIDTH: 1024
ACCOUNTS:
  POS_CASH: CASH
  POS_CHECK: CASH
  POS_GIFT_CERT: CASH
  POS_CREDIT_CARD: CASH

YOUR_PAY_CERT_PATH:  /etc/your-pay-cert.pem
YOUR_PAY_HOST:       secure.linkpt.net
YOUR_PAY_PORT:       1129
YOUR_PAY_ID:         '1001116300'

EOF

echo "NOW COPYING YOUR PAY PEM FILE"
scp nas@nas.hq.allmed.net:/etc/your-pay-cert.pem /etc/your-pay-cert.pem


su -c 'rake db:migrate RAILS_ENV=production' nas
echo Updating Database, this will take quite awhile
su -c './script/update_db -v' nas

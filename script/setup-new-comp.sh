#!/bin/bash

cat > /etc/apt/sources <<__EOS__
deb http://us.archive.ubuntu.com/ubuntu/ dapper main restricted universe
deb http://us.archive.ubuntu.com/ubuntu/ dapper-updates main restricted universe
deb http://security.ubuntu.com/ubuntu dapper-security main restricted universe
__EOS__

apt-get update

apt-get --assume-yes install libpgsql-ruby1.8 ruby ruby1.8 emacs21 libgnome2-ruby libgconf2-ruby libstdc++5 rdoc1.8 postgresql-8.1 libpgsql-ruby1.8 libvte-ruby libopenssl-ruby
if [ $? != 0 ]; then
    echo failed to download needed *.debs, will now exit
    exit 1
fi


su postgres -c '/usr/lib/postgresql/8.1/bin/createuser -s -d nas'
su postgres -c '/usr/lib/postgresql/8.1/bin/createuser -S -R -D allmed'

cat > /etc/postgresql/8.1/main/pg_hba.conf <<__EOS_
local   all     postgres                                ident sameuser
local   all     all                                     trust
host    all     all             127.0.0.1/32            trust
__EOS_
/etc/init.d/postgresql-8.1 restart
psql -Unas -c "CREATE DATABASE allmed ENCODING 'latin1'" template1
psql -Unas -c "CREATE LANGUAGE 'plpgsql'" allmed
cd /tmp

svn co https://trac.allmed.net/svn/computers/vendor/rubygems-0.9.0 | tail
cd /tmp/rubygems-0.9.0
ruby setup.rb 2>&1 | tail
cd /tmp
rm -r /tmp/rubygems-0.9.0
gem install rails --include-dependencies | tail -n 10

cd /usr/local

if [ ! -d allmed ]; then
   mkdir allmed
fi

chown nas allmed

su -c 'svn co https://trac.allmed.net/svn/computers/trunk/allmed' nas | tail

cd /tmp

svn co https://trac.allmed.net/svn/computers/vendor/yourpay | tail
cp yourpay/*.so /usr/local/lib/
echo /usr/local/lib > /etc/ld.so.conf
ln -s /usr/lib/libssl.so.0.9.8 /usr/lib/libssl.so.2
ln -s /usr/lib/libcrypto.so.0.9.8 /usr/lib/libcrypto.so.2
ldconfig
rm -rf /tmp/yourpay

cd /usr/local/allmed

cat > ./config/database.yml <<__EOS_
production:
  adapter: postgresql
  database: allmed
  host: localhost
  username: allmed
  password:
__EOS_

cat > /etc/udev/rules.d/05-pos-updates <<EOF
ACTION=="add", KERNEL=="sd[a-z]1", NAME="pos_update" RUN+="/usr/local/allmed/script/update_pos"
EOF

cat > ./config/settings.yml <<EOF
LOCATION_NAME: `hostname` Computer
LOCATION_EMAIL: sysadmin@allmed.net
NONEXISTANT_SKU_ID: 1
RETURNED_SKU_ID:    2
SKU_FIRST_ID: 3

DB:
  DUMPS: /tmp
  NAME: allmed
  USER: allmed

SBT_SERVER: 192.168.1.4
DISPLAY_POLE_PORT: /dev/ttyS0
RECEIPT_PRINTER: receipt
CASH_DRAWER_PRINTER: receipt
POS_UPDATES_DEV: /dev/pos_update
POS_UPDATES_MOUNT_DIR: /mnt/pos_update
POS_PROCESS_CARDS: true
NNTP_REPORTING_SERVER: reports.hq.allmed.net
POS_SHOW_COST: true
POS_HEIGHT: 800
POS_WIDTH: 600
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

set :application, "ezpos"
set :repository,  "https://trac.allmed.net/svn/computers/trunk/ezpos"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, '/usr/local/ezpos'
set :user, 'nas'
set :spinner_user, 'nas'
set :runner, 'root'

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "register.kcstore.allmed.net", "register.jcstore.allmed.net"
role :web, "register.kcstore.allmed.net", "register.jcstore.allmed.net"
role :db,  "register.kcstore.allmed.net", :primary => true
role :db,  "register.jcstore.allmed.net", :primary => true


desc "Create database.yml in shared/config"
task :database_yml_change do
    database_configuration =<<-EOF
login: &login
  adapter: postgresql
  host: localhost
  username: allmed
  password:

development:
  database: allmed_dev
  <<: *login

test:
  database: allmed_test
  <<: *login

production:
  database: allmed
  <<: *login
EOF

    run "mkdir -p #{deploy_to}/shared/config"
    put database_configuration, "#{deploy_to}/shared/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
end

desc "Link in the config yml files"
task :load_basic_settings do
    run "ln -nfs #{deploy_to}/shared/config/settings.yml #{release_path}/config/settings.yml"
    run "ln -nfs #{deploy_to}/shared/config/dbsync.yml #{release_path}/config/dbsync.yml"
end

task :after_update_code do
    database_yml_change
    load_basic_settings
end

task :start do

end

desc 'Restart the POS'
task :restart_ezpos, :roles => :web do
    sudo "killall -9 ruby"
    run 'sleep 10'
    if File.exists?("#{deploy_to}/shared/log/production.log")
        run "tail -n100 #{deploy_to}/shared/log/production.log"
    else
        run "touch #{deploy_to}/shared/log/production.log"
        run "chmod a+rw #{deploy_to}/shared/log/production.log"
    end
end


after "deploy:restart", :restart_ezpos

desc "Spy on register screens to ensure it's ok to upgrade"
task :spy do | s |
    s.roles[:app].each do | server | #methods
        pid=Kernel.fork do
            Kernel.exec( "xvncviewer -viewonly -passwd ./config/vnc.passwd #{server}" )
        end
        Process.detach( pid )
    end
end

desc "Control register screens via vnc"
task :vnc do | s |
    s.roles[:app].each do | server | #methods
        pid=Kernel.fork do
            Kernel.exec( "xvncviewer -passwd ./config/vnc.passwd #{server}" )
        end
        Process.detach( pid )
    end
end

desc "Show last 50 lines from logs .xsession-errors"
task :logtail do | s |
    s.roles[:app].each do | server | #methods
        run "tail -n50 /home/auto/.xsession-errors"
    end
end

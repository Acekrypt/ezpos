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

desc "Link in the settings.yml file"
task :load_basic_settings do
    run "ln -nfs #{deploy_to}/shared/config/settings.yml #{release_path}/config/settings.yml"
end

task :after_update_code do
    database_yml_change
    load_basic_settings
end

task :start do

end

task :restart_ezpos, :roles => :web do
#    sudo "killall -9 ruby"
    run 'sleep 10'
    if File.exists?("#{deploy_to}shared/log/production.log")
        run "tail -n100 #{deploy_to}shared/log/production.log"
    end
end


#after "deploy:start", :restart_ezpos

task :restart, :roles => :app do
    restart_ezpos
end

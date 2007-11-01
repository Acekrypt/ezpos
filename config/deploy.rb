set :application, "ezpos"
set :repository,  "https://trac.allmed.net/svn/computers/trunk/ezpos"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
 set :deploy_to, "/usr/local/ezpos"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "register.kcstore.allmed.net", "register.jcstore.allmed.net"
role :web, "register.kcstore.allmed.net", "register.jcstore.allmed.net"
role :db,  "register.kcstore.allmed.net", :primary => true
role :db,  "register.jcstore.allmed.net", :primary => true



desc "Create database.yml in shared/config"
task :after_setup do
    database_configuration = render :template => <<-EOF
login: &login
  adapter: postgresql
  host: localhost
  port: <%= postgresql_port %>
  username: allmed
  password:

development:
  database: <%= "#{application}_development" %>
  <<: *login

test:
  database: <%= "#{application}_test" %>
  <<: *login

production:
  database: <%= "#{application}_production" %>
  <<: *login
EOF

    run "mkdir -p #{deploy_to}/#{shared_dir}/config"
    put database_configuration, "#{deploy_to}/#{shared_dir}/config/database.yml"
end

desc "Link in the production database.yml"
task :after_update_code do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
end



task :restart_web_server, :roles => :web do
    `killall -9 ezpos`
end

after "deploy:start", :restart_web_server

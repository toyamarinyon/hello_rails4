
set :application, "hello_rails4"

require 'capistrano_colors'
require "bundler/capistrano"

# rbenv
require 'capistrano-rbenv'
set :rbenv_ruby_version, '2.0.0-p0'

# リポジトリ
set :scm, :git

set :repository, "/home/vagrant/works/hello_rails4"
set :deploy_via,  :copy
set :branch, "master"
set :deploy_to, "/var/www/#{application}"
set :rails_env, "production"

# SSH
set :user, "vagrant"
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/insecure_private_key"]
default_run_options[:pty] = true

# デプロイ先
role :web, "192.168.50.11"
role :app, "192.168.50.11"
role :db, "192.168.50.11", :primary => true

# precompile
load 'deploy/assets'

# cap deploy:setup 後に実行
namespace :setup do
  task :fix_permissions do
    sudo "chown -R #{user}.#{user} #{deploy_to}"
  end
end
after "deploy:setup", "setup:fix_permissions"

# Unicorn用に起動/停止タスクを変更
namespace :deploy do
  task :start, :roles => :app do
    run "cd #{current_path}; bundle exec unicorn_rails -c config/unicorn.rb -E #{rails_env} -D"
  end
  task :restart, :roles => :app do
    if File.exist? "/tmp/unicorn_#{application}.pid"
      run "kill -s USR2 `cat /tmp/unicorn_#{application}.pid`"
    end
  end
  task :stop, :roles => :app do
    run "kill -s QUIT `cat /tmp/unicorn_#{application}.pid`"
  end
end

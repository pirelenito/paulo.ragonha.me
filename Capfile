load 'deploy'

set :application, "paulo"
set :deploy_to, "/www/paulo"
set :deploy_via, :copy
set :repository, "build"
set :scm, :none
set :copy_compression, :gzip
set :use_sudo, false
set :domain, 'paulo.ragonha.me'
set :user, 'deploy'

role :web, domain

before 'deploy:update_code' do
  run_locally 'rm -rf build/*'
  run_locally 'middleman build'
end
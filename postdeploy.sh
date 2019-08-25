#/bin/sh

rails db:migrate
rails tmp:clear
rails cache:clear
rails runner "Role.create_all_for_active_tenants"

APPSIGNAL_PUSH_API_KEY=${APPSIGNAL_DEPLOY_API_KEY} appsignal notify_of_deploy --environment=${RAILS_ENV} --revision=${GIT_REV} --user=anonymous

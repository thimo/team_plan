#/bin/sh

rails db:migrate
rails tmp:clear
rails cache:clear
rails runner "Role.create_all_for_active_tenants"

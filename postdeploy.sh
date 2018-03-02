#/bin/sh

rails db:migrate
rails tmp:clear
rails cache:clear

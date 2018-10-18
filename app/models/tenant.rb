class Tenant < ApplicationRecord
  multi_tenant :tenant
end

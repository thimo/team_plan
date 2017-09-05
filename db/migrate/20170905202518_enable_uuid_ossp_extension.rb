class EnableUuidOsspExtension < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'uuid-ossp'
  end
end

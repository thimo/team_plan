class ConvertOldUserSettings < ActiveRecord::Migration[5.2]
  def change
    Tenant.all.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        UserOldSetting.all.find_each do |old_setting|
          UserSetting.create(user: old_setting.user, name: :email_separator, value: old_setting.email_separator) if old_setting.email_separator.present? && old_setting.email_separator != ";"
          UserSetting.create(user: old_setting.user, name: :export_columns, value: old_setting.export_columns) if old_setting.export_columns.present?
          UserSetting.create(user: old_setting.user, name: :include_member_comments, value: old_setting.include_member_comments) if old_setting.include_member_comments
          UserSetting.create(user: old_setting.user, name: :active_comments_tab, value: old_setting.active_comments_tab) if old_setting.active_comments_tab.present?
          UserSetting.create(user: old_setting.user, name: :active_team_tab, value: old_setting.active_team_tab) if old_setting.active_team_tab.present?
        end
      end
    end
  end
end

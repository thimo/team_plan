class OrgPositionPolicy < OrgPolicy

  def permitted_attributes
    attributes = [:name, :parent_id, :position_type, :remark]
    # attributes << :status if set_status?
    return attributes
  end

end

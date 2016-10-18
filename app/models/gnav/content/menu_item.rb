class Gnav::Content::MenuItem < Cms::Content
  default_scope { where(model: 'Gnav::MenuItem') }

  has_one :public_node, -> { public_state.order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'Gnav::Content::Setting', dependent: :destroy

  has_many :menu_items, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'Gnav::MenuItem', dependent: :destroy

  def public_nodes
    nodes.public_state
  end

#TODO: DEPRECATED
  def menu_item_node
    return @menu_item_node if @menu_item_node
    @menu_item_node = Cms::Node.where(state: 'public', content_id: id, model: 'Gnav::MenuItem').order(:id).first
  end

  def gp_category_content_category_type
    return @gp_category_content_category_type if defined? @gp_category_content_category_type
    @gp_category_content_category_type = GpCategory::Content::CategoryType.find_by(id: setting_value(:gp_category_content_category_type_id))
  end

  def category_types
    gp_category_content_category_type.try(:category_types) || []
  end

  def list_style
    setting_value(:list_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end
end

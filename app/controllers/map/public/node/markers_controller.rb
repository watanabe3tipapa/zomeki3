require 'will_paginate/array'

class Map::Public::Node::MarkersController < Cms::Controller::Public::Base
  skip_after_action :render_public_layout, :only => [:file_content]

  def pre_dispatch
    @node = Page.current_node
    @content = Map::Content::Marker.find_by(id: @node.content.id)
    return http_error(404) unless @content

    category = params[:category] ? params[:category] : params[:escaped_category].to_s.gsub('@', '/')
    @specified_category = find_category_by_specified_path(category)
  end

  def index
    markers = if @specified_category
                categorizations = GpCategory::Categorization.arel_table
                @content.public_markers.joins(:categorizations)
                                       .where(categorizations[:category_id].in(@specified_category.public_descendants_ids))
              else
                @content.public_markers
              end

    @all_markers = @content.sort_markers(markers.to_a.concat(doc_markers))

    @markers = @all_markers.paginate(page: params[:page], per_page: 30)

    return http_error(404) if @markers.current_page > @markers.total_pages
  end

  def file_content
    @marker = @content.markers.find_by!(name: params[:name])
    file = @marker.files.first
    return http_error(404) unless file

    send_file file.upload_path, filename: file.name
  end

  private

  def doc_markers
    docs = @content.public_marker_docs(@specified_category)
                   .preload(:marker_categories, :files, :marker_icon_category)
    docs.each_with_object([]) do |doc, markers|
      markers << Map::Marker.from_doc(doc)
    end.flatten
  end

  def find_category_by_specified_path(path)
    return nil unless path.kind_of?(String)
    category_type_name, category_path = path.split('/', 2)
    category_type = @content.category_types.find_by(name: category_type_name)
    return nil unless category_type
    category_type.find_category_by_path_from_root_category(category_path)
  end
end

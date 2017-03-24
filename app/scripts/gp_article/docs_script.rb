class GpArticle::DocsScript < Cms::Script::Publication
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_page(@node, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
    publish_page(@node, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)

    content = @node.content
    common_params = { uri: uri, path: path, smart_phone_path: smart_phone_path }
    if content.doc_list_pagination == 'simple'
      publish_more(@node, common_params.merge(limit: content.doc_publish_more_pages))
    else
      if params[:target_date].present?
        publish_target_dates(@node, common_params.merge(
                                    page_style: content.doc_list_pagination,
                                    first_date: date_pagination_query(content).first_page_date,
                                    target_dates: load_neighbor_dates(content, params[:target_date])))
      else
        publish_more_dates(@node, common_params.merge(
                                  page_style: content.doc_list_pagination,
                                  page_dates: date_pagination_query(content).page_dates))
      end
    end
  end

  def date_pagination_query(content, current_date = nil)
    DatePaginationQuery.new(content.public_docs_for_list,
                            page_style: content.doc_list_pagination,
                            column: content.docs_order_column,
                            direction: content.docs_order_direction,
                            current_date: current_date)
  end

  def load_neighbor_dates(content, target_date)
    dates = []
    Array(target_date).each do |date|
      current_date = Time.parse(date)
      query = date_pagination_query(content, current_date)
      dates += [query.next_page_date, current_date, query.prev_page_date]
    end
    dates.compact.uniq
  end

  def publish_doc
    docs = @node.content.public_docs.where(id: params[:target_doc_id])
    docs.find_each do |doc|
      ::Script.progress(doc) do
        uri = doc.public_uri
        path = doc.public_path
        if doc.publish(render_public_as_string(uri, site: doc.content.site))
          uri_ruby = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
          path_ruby = "#{path}.r"
          doc.publish_page(render_public_as_string(uri_ruby, site: doc.content.site), path: path_ruby, dependent: :ruby)
          doc.publish_page(render_public_as_string(uri, site: doc.content.site, agent_type: :smart_phone),
                      path: doc.public_smart_phone_path, dependent: :smart_phone)
        end
      end
    end
  end

  def publish_by_task
    return unless item = params[:item]

    if item.state_approved? || item.state_prepared?
      ::Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      uri = item.public_uri.to_s
      path = item.public_path.to_s

      # Renew edition before render_public_as_string
      item.update_attribute(:state, 'public')

      if item.publish(render_public_as_string(uri, site: item.content.site))
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'publish')
      else
        raise item.errors.full_messages
      end

      if item.published? || !::File.exist?("#{path}.r")
        uri_ruby = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
        path_ruby = "#{path}.r"
        item.publish_page(render_public_as_string(uri_ruby, site: item.content.site),
                          path: path_ruby, dependent: :ruby)
      end

      info_log %Q!OK: Published to "#{path}"!
      ::Script.success
      return true
    elsif item.state_public?
      return true
    end
  end

  def close_by_task
    return unless item = params[:item]

    if item.state_public?
      ::Script.current
      info_log "-- Close: #{item.class}##{item.id}"

      item.close
      Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'close')

      info_log 'OK: Finished'
      ::Script.success
      return true
    elsif item.state_closed?
      return true
    end
  end
end

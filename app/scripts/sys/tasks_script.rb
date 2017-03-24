class Sys::TasksScript < Cms::Script::Base
  def exec
    tasks = []
    Sys::Task.transaction do
      tasks = Sys::Task.queued_items
                       .where(Sys::Task.arel_table[:process_at].lteq(Time.now))
                       .order(process_at: :desc)
      tasks = tasks.where(site_id: ::Script.site.id) if ::Script.site
      Sys::Task.where(id: tasks.map(&:id)).update_all(state: 'performing')
    end

    ::Script.total tasks.size

    tasks.each do |task|
      begin
        unless task.processable
          task.destroy
          raise 'Processable Not Found'
        end

        script_klass = "#{task.processable_type.pluralize}Script".constantize
        processed = script_klass.new(params.merge(task: task, item: task.processable)).public_send("#{task.name}_by_task")
        task.update_attributes(state: 'performed') if processed
      rescue => e
        ::Script.error e
        info_log "Error: #{e}"
        puts "Error: #{e}"
      end
    end

    Sys::Task.where(id: tasks.map(&:id), state: 'performing').update_all(state: 'queued')
  end
end

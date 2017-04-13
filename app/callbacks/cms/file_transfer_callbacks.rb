class Cms::FileTransferCallbacks < FileTransferCallbacks
  def initialize(path_methods, recursive: false)
    @path_methods = Array(path_methods)
    @recursive = recursive
  end

  def after_save_file(item)
    enqueue(item)
  end

  def after_remove_file(item)
    enqueue(item)
  end

  def after_publish_file(item)
    enqueue(item)
  end

  def after_close_file(item)
    enqueue(item)
  end

  private

  def enqueue(item)
    return unless enqueue?
    return unless item.respond_to?(:site_id)

    paths = @path_methods.map { |method| item.public_send(method) }.select(&:present?).uniq
    return if paths.blank?

    paths = paths.map { |path| "#{File.dirname(path)}/" }
    Cms::FileTransfer.register(item.site_id, paths, recursive: @recursive)
  end
end

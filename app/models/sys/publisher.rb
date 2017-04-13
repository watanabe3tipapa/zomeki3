class Sys::Publisher < ApplicationRecord
  include Sys::Model::Base

  belongs_to :publishable, polymorphic: true

  before_validation :modify_path
  before_save :remove_files_in_old_path
  before_destroy :remove_files

  define_callbacks :publish_file, :close_file, scope: [:kind, :name]
  set_callback :publish_file, :after, Cms::FileTransferCallbacks.new([:path, :path_was])
  set_callback :close_file, :after, Cms::FileTransferCallbacks.new([:path, :path_was])

  after_save :run_publish_file_callbacks

  def site_id
    path.scan(%r{^./sites/(\d+)}).dig(0, 0).try!(:to_i)
  end

  def site
    @site ||= Cms::Site.find_by(id: site_id)
  end

  private

  def modify_path
    self.path = path.gsub(/^#{Rails.root.to_s}/, '.')
  end

  def remove_files(options = {})
    up_path = options[:path] || path
    up_path = ::File.expand_path(path, Rails.root) if up_path.to_s.slice(0, 1) == '/'

    run_callbacks :close_file do
      FileUtils.rm(up_path) if FileTest.exist?(up_path)
      FileUtils.rm("#{up_path}.mp3") if FileTest.exist?("#{up_path}.mp3")
      FileUtils.rmdir(::File.dirname(path)) rescue nil
    end
    return true
  end

  def remove_files_in_old_path
    remove_files(path: path_was) if path_changed? && path_was.present?
    return true
  end

  def run_publish_file_callbacks
    run_callbacks :publish_file
  end
end

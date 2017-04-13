class Cms::TalkTask < ApplicationRecord
  include Sys::Model::Base

  define_callbacks :save_file, :remove_file, scope: [:kind, :name]
  set_callback :save_file, :after, Cms::FileTransferCallbacks.new(:path)
  set_callback :remove_file, :after, Cms::FileTransferCallbacks.new(:path)

  validates :path, presence: true

  def create_sound_file
    return false unless ::File.exist?(path)

    jtalk = Cms::Lib::Navi::Jtalk.new
    jtalk.make(::File.read(path), site_id: site_id)
    mp3 = jtalk.output
    return false unless mp3
    return false if ::File.stat(mp3[:path]).size == 0

    run_callbacks :save_file do
      FileUtils.mv(mp3[:path], "#{path}.mp3")
      ::File.chmod(0644, "#{path}.mp3")
    end
    return true
  end

  def delete_sound_file
    return false unless ::File.exist?("#{path}.mp3")

    run_callbacks :remove_file do
      ::File.delete("#{path}.mp3")
    end

    info_log "DELETED: #{path}.mp3"
    return true
  end
end

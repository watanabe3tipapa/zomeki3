class Cms::TalkTask < ApplicationRecord
  include Sys::Model::Base

  validates :path, presence: true

  def create_sound_file
    return false unless ::File.exist?(path)

    jtalk = Cms::Lib::Navi::Jtalk.new
    jtalk.make(::File.read(path), site_id: site_id)
    mp3 = jtalk.output
    return false unless mp3
    return false if ::File.stat(mp3[:path]).size == 0

    FileUtils.mv(mp3[:path], "#{path}.mp3")
    ::File.chmod(0644, "#{path}.mp3")
    return true
  end

  def delete_sound_file
    return false unless ::File.exist?("#{path}.mp3")

    ::File.delete("#{path}.mp3")
    info_log "DELETED: #{path}.mp3"
    return true
  end
end

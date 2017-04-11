class Cms::KanaDictionary < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Site

  belongs_to :site

  validates :name, presence: true

  before_save :convert_csv

  def convert_csv
    csv = []

    body.split(/(\r\n|\n)/u).each_with_index do |line, idx|
      line = line.to_s.gsub(/#.*/, "")
      line.strip!
      next if line.blank?

      data = line.split(/\s*,\s*/)
      word = data[0].strip
      kana = data[1].strip.tr("ぁ-ん", "ァ-ン")
      hira = kana.tr("ァ-ン", "ぁ-ん")

      errors.add :base, "フォーマットエラー: #{line} (#{idx+1}行目)" if !data[1] || data[2]
      errors.add :base, "フォーマットエラー: #{line} (#{idx+1}行目)" if kana !~ /^[ァ-ンー]+$/
      return false if errors.size > 0

      csv << "#{word},*,*,100,名詞,固有名詞,*,*,*,*,#{hira},#{kana},#{kana}"
    end

    self.mecab_csv = csv.join("\n")

    return true
  end

  class << self
    def mecab_rc(site_id = nil)
      user_dic(site_id) # confirm
      site_mecab_rc(site_id)
    end

    def user_dic(site_id = nil)
      dic = mecab_dir(site_id).join('zomeki.dic').to_s
      unless ::File.exists?(dic)
        dir = ::File.dirname(dic)
        ::FileUtils.mkdir_p(dir) unless ::Dir.exist?(dir)
        FileUtils.cp(Rails.root.join("config/mecab/zomeki.dic.original").to_s, dic)
      end
      dic
    end

    def site_mecab_rc(site_id = nil)
      rc = mecab_dir(site_id).join("mecabrc").to_s
      unless ::File.exists?(rc)
        dir = ::File.dirname(rc)
        ::FileUtils.mkdir_p(dir) unless ::Dir.exist?(dir)
        data = ::File.read(Rails.root.join("config/mecab/mecabrc").to_s).to_s
                     .gsub(/config\//, "sites/#{format('%04d', site_id)}/config/")
        ::File.write(rc, data)
      end
      rc
    end

    def dic_mtime(site_id = nil)
      file = user_dic(site_id)
      ::File.mtime(file)
    end

    private
    
    def mecab_dir(site_id = nil)
      if site_id.blank?
        Rails.root.join('config/mecab')
      else
        Rails.root.join('sites', format('%04d', site_id), 'config/mecab')
      end
    end
  end
end

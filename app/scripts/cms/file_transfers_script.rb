class Cms::FileTransfersScript < Cms::Script::Base
  def exec
    if params[:file_transfer_id].present?
      transfers = Cms::FileTransfer.where(id: params[:file_transfer_id])
                                   .order(priority: :asc, id: :asc)
      transfers = transfers.where(site_id: ::Script.site.id) if ::Script.site
    else
      transfers =
        if ::Script.site
          [Cms::FileTransfer.new(path: "sites/#{format('%04d', ::Script.site.id)}/", recursive: true)]
        else
          [Cms::FileTransfer.new(path: "sites/", recursive: true)]
        end
    end

    ::Script.total transfers.size

    transfers.each do |transfer|
      ::Script.progress(transfer) do
        path = ::File.exists?(transfer.path) ? transfer.path : "#{::File.dirname(transfer.path)}/" 
        if ::File.exists?(path)
          out, error = rsync(path, recursive: transfer.recursive)
          ::Script.log out if out.present?
          raise error if error.present?
        end
        transfer.destroy
      end
    end
  end

  private

  def rsync(path, options = {})
    require "open3"
    com = rsync_command(path, options)
    ::Script.log com
    Open3.capture3(com)
  end

  def rsync_command(path, options)
    conf = Util::Config.load(:rsync).with_indifferent_access

    src_path = path
    src_path += '/' if src_path[-1] != '/'
    dest_path = conf[:dest_path]
    dest_path += '/' if dest_path[-1] != '/'

    com = "#{conf[:bin]} #{conf[:opts]} --relative #{src_path} #{dest_path}"
    com << (options[:recursive] ? " --recursive" : " --dirs")
    com
  end
end

class FileTransferCallbacks < ApplicationCallbacks
  private
  def enqueue?
    Zomeki.config.application['sys.file_transfer']
  end
end

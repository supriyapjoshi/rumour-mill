require 'fileutils'

class RumourMill

  def new_files_to_process?
    @process_file_location = 'rumours/new'
    !Dir.glob(@process_file_location + '/*.json').empty?
  end

end

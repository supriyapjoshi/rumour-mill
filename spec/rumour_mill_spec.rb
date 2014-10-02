require 'spec_helper'
require 'fakefs/spec_helpers'

describe RumourMill do 
  

  describe '#new_files_to_process?' do
    include FakeFS::SpecHelpers::All

    def create_test_file path, data
      FakeFS::FileSystem.clear
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "wb") do |file|
          data.each { |row| file << row }
      end
    end
    
    context 'when there are new files to process' do
      
      before do
        create_test_file 'rumours/new/data.json', ['blah']
      end

      it '#new_files_to_process? returns true' do
        expect(subject.new_files_to_process?).to be_truthy
      end

    end

    context 'when there are no new files to process' do
      
      before do
        FakeFS::FileSystem.clear
        FileUtils.mkdir_p 'rumours/new'
      end

      it 'returns false' do
        expect(subject.new_files_to_process?).to be_falsey
      end

    end

  end

end

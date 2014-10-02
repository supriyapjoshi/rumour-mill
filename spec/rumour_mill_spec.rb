require 'spec_helper'

describe RumourMill do 
  context 'when there are new files to process' do

    it '#has_new_files? returns true' do
      expect(subject.has_new_files?).to be_truthy
    end
  end

end

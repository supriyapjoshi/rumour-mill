require 'spec_helper'
require 'fakefs/spec_helpers'
require 'neo4j'

describe RumourMill do 
  
  describe '#new_files_to_process?' do
    
    include FakeFS::SpecHelpers::All

    def create_test_file path, data
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "wb") do |file|
          data.each { |row| file << row }
      end
    end
    
    context 'when there are new files to process' do
      
      before do
        FakeFS::FileSystem.clear
        create_test_file 'rumours/new/data.json', ['blah']
      end

      it 'returns true' do
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

  before do
    @session = Neo4j::Session.open(:server_db, 'http://localhost:7474')
  end

  describe '#insert_nodes' do

    let(:node_file_data) { '[{
                                "name":"node_1",
                                "type":"service"
                              },
                              {
                                "name":"node_2",
                                "type":"entity",
                                "detail_1":"property1",
                                "property_2":"property2",
                                "something":"propertyn"
                              },
                              {
                                "name":"node_n",
                                "detail_1":"property1",
                                "something":"property2",
                                "foo":"propertyn"
                              }]'}

    it 'inserts all the nodes into the database' do

      subject.insert_nodes(node_file_data)
      node_1 = @session.query("MATCH (n:node) WHERE n.name='node_1' RETURN n")
      node_2 = @session.query("MATCH (n:node) WHERE n.name='node_2' RETURN n")
      node_n = @session.query("MATCH (n:node) WHERE n.name='node_n' RETURN n")
      expect(node_1.first[:n].props[:type]).to eq('service')
      expect(node_2.first[:n].props[:type]).to eq('entity')
      expect(node_n.first[:n].props[:type]).to eq('unknown')

    end

  end

  describe '#insert_relationships' do
    

  end

  after do
    @session.query('MATCH (n) DELETE n')
  end

end

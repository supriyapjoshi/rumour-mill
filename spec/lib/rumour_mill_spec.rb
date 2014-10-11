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

  before do
    @session = Neo4j::Session.open(:server_db, 'http://localhost:7474')
    subject.insert_nodes(node_file_data)
  end

  describe '#insert_nodes' do

    it 'inserts all the nodes into the database' do
      nodes = @session.query("MATCH (n:node) RETURN n")
      expect(nodes.to_a.size).to eq(3)
    end

    it 'adds an unknown type to the node if it is not specified' do
      node_n = @session.query("MATCH (n:node) WHERE n.name='node_n' RETURN n")
      expect(node_n.first[:n].props[:type]).to eq('unknown')
    end

    it 'inserts the type property when specified' do
      node_1 = @session.query("MATCH (n:node) WHERE n.name='node_1' RETURN n")
      node_2 = @session.query("MATCH (n:node) WHERE n.name='node_2' RETURN n")
      expect(node_1.first[:n].props[:type]).to eq('service')
      expect(node_2.first[:n].props[:type]).to eq('entity')
    end

    it 'inserts any additional properties specified as they are' do
      node_1 = @session.query("MATCH (n:node) WHERE n.name='node_1' RETURN n")
      node_2 = @session.query("MATCH (n:node) WHERE n.name='node_2' RETURN n")
      node_n = @session.query("MATCH (n:node) WHERE n.name='node_n' RETURN n")
      expect(node_1.first[:n].props.keys.size).to eq(2)
      expect(node_2.first[:n].props.keys.size).to eq(5)
      expect(node_n.first[:n].props.keys.size).to eq(5)
    end

  end

  describe '#insert_relationships' do
    let(:relationships_data){'[{
                                 "from":"node_1",
                                 "to":"node_2",
                                 "relationship":"loves"
                                },
                                {
                                 "from":"node_1",
                                 "to":"node_n",
                                 "relationship":"friends",
                                 "property-1": "property_1",
                                 "property-n": "property_n"
                                },
                                {
                                 "from":"node_2",
                                 "to":"node_n",
                                 "relationship":"consumes",
                                 "property-1": "property_1",
                                 "property-n": "property_n"
                                }]'}
    before do
      subject.insert_relationships relationships_data
    end

    def get_node name
      @session.query("MATCH (n:node) WHERE n.name='#{name}' RETURN n")
    end

    def get_relationship_start_node relationship_name
      @session.query("MATCH (n:node)-[r:#{relationship_name}]-() RETURN startNode(r)")
    end

    def get_relationship_end_node relationship_name
      @session.query("MATCH (n:node)-[r:#{relationship_name}]-() RETURN endNode(r)")
    end

    it 'inserts all the correct relationship connections' do
      node_1 = get_node 'node_1'
      expect(node_1.first.n.rels[0].rel_type).to eq('loves'.to_sym)
      expect(node_1.first.n.rels[1].rel_type).to eq('friends'.to_sym)

      node_2 = get_node 'node_2'
      expect(node_2.first.n.rels[0].rel_type).to eq('loves'.to_sym)
      expect(node_2.first.n.rels[1].rel_type).to eq('consumes'.to_sym)

      node_n = get_node 'node_n'
      expect(node_n.first.n.rels[0].rel_type).to eq('friends'.to_sym)
      expect(node_n.first.n.rels[1].rel_type).to eq('consumes'.to_sym)

    end

    it 'inserts the relationships with the correct direction' do
      relationship_start_node = get_relationship_start_node 'loves'
      relationship_end_node = get_relationship_end_node 'loves'

      expect(relationship_start_node.first.first.props[:name]).to eq('node_1')
      expect(relationship_end_node.first.first.props[:name]).to eq('node_2')

      relationship_start_node = get_relationship_start_node 'friends'
      relationship_end_node = get_relationship_end_node 'friends'

      expect(relationship_start_node.first.first.props[:name]).to eq('node_1')
      expect(relationship_end_node.first.first.props[:name]).to eq('node_n')

      relationship_start_node = get_relationship_start_node 'consumes'
      relationship_end_node = get_relationship_end_node 'consumes'

      expect(relationship_start_node.first.first.props[:name]).to eq('node_2')
      expect(relationship_end_node.first.first.props[:name]).to eq('node_n')

    end


    xit 'will not insert relationships without relationship property' do

    end

    xit 'will not insert relationships without to property' do

    end

    xit 'will not insert relationships without from property' do

    end

    xit 'will not insert relationships when the to node does not exist' do

    end

    xit 'will not insert relationships when the from node does not exist' do

    end

    xit 'attaches any other properties to that relationship that are given' do

    end

    after do

    end
  end

  after do
    @session.query('MATCH (n)-[r]-() DELETE n, r')
    @session.query('MATCH (n) DELETE n')
  end

end

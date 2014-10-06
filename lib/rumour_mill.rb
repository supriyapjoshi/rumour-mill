require 'fileutils'
require 'neo4j'
require 'json'

class RumourMill

  def initialize
    connect_to_db
    @process_file_location = 'rumours/new'
  end

  def new_files_to_process?
    !Dir.glob(@process_file_location + '/*.json').empty?
  end

  def insert_nodes nodes_json_data
    JSON.parse(nodes_json_data).each do |node|
      add_unknown_property_type node unless contains_type? node 
      Neo4j::Node.create(node, :node)
    end
  end

  private
  def connect_to_db
    @db_host = 'http://localhost:7474'
    @session = Neo4j::Session.open(:server_db, @db_host)
  end

  def contains_type? node
    node.has_key? 'type'
  end

  def add_unknown_property_type node
    node[:type] = 'unknown'
  end

end

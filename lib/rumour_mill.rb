require 'fileutils'
require 'neo4j'
require 'json'

class RumourMill

  def new_files_to_process?
    @process_file_location = 'rumours/new'
    !Dir.glob(@process_file_location + '/*.json').empty?
  end

  def insert_nodes nodes_json_data
    @db_host = 'http://localhost:7474'
    nodes_hash = JSON.parse nodes_json_data
    @session = Neo4j::Session.open(:server_db, @db_host)

    nodes_hash.each do |node|
      node[:type] = 'unknown' unless node.has_key? 'type' 
      Neo4j::Node.create(node, :node)
    end

  end

end

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

  def insert_relationships relationship_json_data
    relationship_hash = JSON.parse relationship_json_data

    relationship_hash.each do |relationship|
      insert_relationship relationship unless nodes_dont_exist_or_relationship_malformed_or_relationship_exists? relationship
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

  def relationship_connection_malformed? relationship
    ['relationship','to','from'].each do |key|
      return true unless relationship.has_key? key
    end
    false
  end

  def nodes_dont_exist_or_relationship_malformed_or_relationship_exists? relationship
    node_not_exist?(relationship['from']) || node_not_exist?(relationship['to']) || relationship_connection_malformed?(relationship) || relationship_exists?(relationship)
  end

  def node_exists? node_name
    @session.query("MATCH (n:node) WHERE n.name='#{node_name}' RETURN n").any?
  end

  def node_not_exist? node_name
    !node_exists? node_name
  end

  def relationship_exists? relationship
    get_node(relationship['from']).first.n.rels.each { |relation| return true if relation.rel_type == relationship['relationship'].to_sym }
    false
  end

  def get_node name
    @session.query("MATCH (n:node) WHERE n.name='#{name}' RETURN n")
  end

  def insert_relationship relationship
    n1 = Neo4j::Session.query('MATCH n WHERE n.name = "' + relationship['from'] + '" RETURN n').first.n
    n2 = Neo4j::Session.query('MATCH n WHERE n.name = "' + relationship['to'] + '" RETURN n').first.n
    Neo4j::Relationship.create(relationship['relationship'].to_sym, n1, n2)
  end

end

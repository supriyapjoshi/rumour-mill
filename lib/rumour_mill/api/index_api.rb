require 'grape/api'
require 'yaml'
require 'pry'

module RumourMill
  module Api

    class IndexApi < Grape::API
      content_type :html, 'text/html'
      content_type :json, 'application/json' # Grape seems to be upset if we specify HTML without JSON

      default_format :json
      desc 'rea-rels:links'

      get '/' do
        {
          :_links => {
            :self => {
              :href => request.url,
              :title => 'This index page'
            }
          }
        }
      end

    end
  end
end

module Api
  module Internal
    class PluginsController < ApplicationController
      def index
        plugins = YAML.load(File.read("lib/canhelp/plugins.yml"))
        render json: {
          plugins: plugins
        }
      end

      # A very insecure and stupid way of executing methods.
      # This should only be run locally
      def execute
        require "./lib/canhelp/plugins/#{params[:plugin_file]}.rb"
        CanhelpPlugin.send(params[:plugin_method], *params[:plugin_args])
        render json: {}
      end
    end
  end
end

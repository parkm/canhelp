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
      # To fix this in the future, just verify the user input via the plugins.yml file in lib/canhelp
      def execute
        require "./lib/canhelp/plugins/#{params[:plugin_file]}.rb"
        CanhelpPlugin.send(params[:plugin_method], *params[:plugin_args])
        render json: {}
      end
    end
  end
end

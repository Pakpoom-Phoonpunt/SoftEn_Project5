class ApplicationController < ActionController::Base
    before_action :set_current_user
    after_action :clearFlash
    protected # prevents method from being invoked by a route
    def set_current_user
      # we exploit the fact that the below query may return nil
      @current_user ||= Moviegoer.find_by(:id => session[:user_id])
      # redirect_to login_path and return unless @current_user
    end

    def clearFlash 
      flash.clear
    end
     # config TMDB
     require 'themoviedb'
     require_relative '../../config/.tmdb_key.rb'  # get api key
     Tmdb::Api.key($api_key)
 
     def set_config
         @configuration = Tmdb::Configuration.new
     end
 
  end
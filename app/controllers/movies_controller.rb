class MoviesController < ApplicationController
    skip_after_action :clearFlash , :only =>[:destroy]
    def index
        # @movies = Movie.all()
        @movies = Movie.order("title ASC")
        # @movies = Movie.all().sort_by{|mov| mov.title}
    end

    def show
        begin
            @movie = Movie.find(params[:id])
        rescue ActiveRecord::RecordNotFound
            flash[:notice] = " No movie with the given ID could be found."
            redirect_to action:"index"
        end
    end

    def new
        @movie = Movie.new()
    end

    def create
        
        new_movie  = params[:movie].permit(:title,:rating,:release_date,:description)
        @movie = Movie.new(new_movie)
        if @movie.save
            flash[:notice] = "#{@movie.title} was successfully created."
            redirect_to movies_path
        else 
            render 'new'
        end
    end
    
    def edit
        @movie = Movie.find(params[:id])
    end
      
    def update
        @movie = Movie.find_by_id(params[:id])
        if @movie.update!(params[:movie].permit(:title,:rating,:release_date,:description) )
            flash[:notice] = "#{@movie.title} was successfully updated."
            redirect_to movie_path(@movie)
        else 
            render 'edit'
        end
    end

    def destroy
        begin
            @movie = Movie.find(params[:id])
            @movie.destroy()
            flash[:notice] = "#{@movie.title} was Deleted."
            redirect_to movies_path
        rescue
            flash[:notice] = "#{@movie.title} was Deleted."
            redirect_to movies_path
        end
    end

    def movies_with_good_reviews
        @movies = Movie.joins(:reviews).group(:movie_id).
          having('AVG(reviews.potatoes) > 3')
    end

    def movies_for_kids
        @movies = Movie.where('rating in ?', %w(G PG))
    end

      def movies_with_filters_2
        @movies = Movie.with_good_reviews(params[:threshold])
        %w(for_kids with_many_fans recently_reviewed).each do |filter|
          @movies = @movies.send(filter) if params[filter]
        end
      end


    def search_tmdb
        begin            
            @search_terms = params[:search_terms]
            @movies = Movie.find_in_tmdb(@search_terms)
            if @movies.length() == 1
                @tmdbmovie = @movies[0]
                @rating = Movie.find_rating(@tmdbmovie.id)
                @movie = Movie.new( :title => @tmdbmovie.title, :release_date => @tmdbmovie.release_date, :rating => @rating, :description => @tmdbmovie.overview)
                render 'detail_tmdb'
            elsif !@movies.empty?
                flash[:notice] = "Found #{@movies.length()} Movies Match."
                @ratings = []
                @movies.each {|tmp| @ratings << Movie.find_rating(tmp.id)}
                render 'tmdb_result'
            else
                flash[:warning] = "'Movie That Does Not Exist' was not found in TMDb."
                redirect_to movies_path
            end
        rescue NoMethodError
            flash[:notice] = "'Movie That Does Not Exist' was not found in TMDb."
            redirect_to movies_path
        end     
    end

    def add
        tmp = Movie.find_by_id_tmdb(params[:id])
        rating = Movie.find_rating(tmp["id"])
        @movie = Movie.create!(:title => tmp["title"], :release_date => tmp["release_date"], :rating => rating, :description => tmp["overview"])
        redirect_to movies_path
    end
    def show_tmdb
        
        @movie = Movie.find_by_id_tmdb(params[:id])
        @rating = Movie.find_rating(params[:id])
        @id_tmdb = @movie["id"]
        @movie = Movie.new( :title => @movie["title"], :release_date => @movie["release_date"], :rating => @rating, :description => @movie["overview"])
        render 'detail_tmdb'
    end
end
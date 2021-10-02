class MoviesController < ApplicationController
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
        @movie = Movie.find(params[:id])
        @movie.destroy()
        flash[:notice] = "#{@movie.title} was Deleted."
        redirect_to movies_path
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
            @tmp = Movie.find_in_tmdb(@search_terms)
            @movies = [@tmp[0]]
            if @movies.length() == 1
                @movie = @movies[0]
                @rating = Movie.find_rating(@movie.id)
                render 'detail_tmdb'
            elsif !@movies.empty?
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

     
end
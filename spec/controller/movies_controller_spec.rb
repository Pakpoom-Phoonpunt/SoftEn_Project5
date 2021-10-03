require 'rails_helper'

  describe MoviesController, :type => :controller do
    describe 'searching TMDb' do
      before :each do
        @fake_results = [double('movie1'), double('movie2')]
      end
      it 'calls the model method that performs TMDb search' do
        expect(Movie).to receive(:find_in_tmdb).with('hardware').and_return(@fake_results)
          post :search_tmdb, params: {:search_terms => 'hardware'}
      end

      describe 'after valid search' do
        before :each do
          allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
          post :search_tmdb, params: {:search_terms => 'hardware'}
        end
      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end

      #Failure test
      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end
    end
  end
end

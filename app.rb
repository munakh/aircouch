require 'sinatra/base'
require 'sinatra/flash'
require './lib/listing.rb'
require './lib/booking.rb'
require './lib/user.rb'

class AirCouch < Sinatra::Base
  enable :sessions
  set :session_secret, "secret"
  register Sinatra::Flash

  get '/' do
    erb(:index)
  end

  get '/listings' do
    @listings = Listing.all
    erb :listings
  end

  get '/listings/new' do
    erb :new_listing
  end

  post '/listings/new' do
    @id = session[:user_id]
    Listing.create(params[:name], params[:description], params[:price], params[:start_date], params[:end_date], session[:user_id])
    redirect "/welcome/#{session[:user_id]}"
  end

  get '/listings/:id' do
    @id = params["id"]
    erb :new_booking
  end

  post '/listings/:id/book' do
    new_booking = Booking.create(params["start_date"], params["end_date"], session["user_id"], params["id"])
    "Your Booking has been requested"
    redirect "/welcome/#{session["user_id"]}"
  end

  get '/users/new' do
    erb :users_new
  end

  post '/users/new' do
    user = User.create(name: params[:name], email: params[:email], password: params[:password])
    session[:user_id] = user.id
    redirect "/welcome/#{user.id}"
  end

  get '/welcome/:id' do
    @user = User.find(session[:user_id])
    @listings = Listing.findhost(session[:user_id])
    @bookings = Booking.findGuest(session[:user_id])
    erb :welcome
  end

  post '/welcome/:id' do
    "You approved this booking"
    redirect "/welcome/#{session[:user_id]}"
  end

  post '/approve/:booking_id' do
    Booking.approve(params[:booking_id])
    redirect "/welcome/#{session[:user_id]}"
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    user = User.authenticate(email: params[:email], password: params[:password])

      if user
        session[:user_id] = user.id
        redirect "/welcome/#{user.id}"
      else
        flash[:notice] = 'Please check your email or password'
        redirect '/login'
      end
  end

  get '/login/destroy' do
    session.clear
    flash[:notice] = "You have signed out"
    redirect('/listings')
  end

  get '/images' do
    erb :images
  end

  run! if app_file == $0
end

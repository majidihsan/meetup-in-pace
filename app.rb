require 'sinatra'
require_relative 'config/application'
require 'pry'
enable :session

helpers do
  def current_user
    if @current_user.nil? && session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
      session[:user_id] = nil unless @current_user
    end
    @current_user
  end
end

get '/' do
  redirect '/meetups'
end

get '/auth/github/callback' do
  user = User.find_or_create_from_omniauth(env['omniauth.auth'])
  session[:user_id] = user.id
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/meetups/new' do
  user_id = session[:user_id]
  if user_id.nil?
    flash[:notice] = "You have to Log In "
    redirect '/meetups'
  else
    erb :'meetups/new'
  end
end

post '/meetups' do
  @errors = []
  @name = params[:name]
  @description = params[:description]
  @location = params[:location]

  if
    @name.empty? || @description.empty? || @location.empty?
    @errors << "Please fill all the fields in the form"
    erb :'meetups/new'
  elsif
    @creator = session[:user_id]
    @meetups = Meetup.new(name: params[:name], description: params[:description], location: params[:location], creator_id: "#{@creator}")
    @existing = @meetups.invalid?
    if
      @existing == true
      @errors << "Meet up Already exists"
      erb :'meetups/new'
    else
      @existing == false
      @meetups.save
      flash[:notice] = "You have successfuly created a Meetup #{current_user.username}!"
      redirect '/meetups'
    end
  end
end


get '/meetups' do
  @meetups = Meetup.all
  erb :'meetups/index'
end

get '/meetups/:id' do
  @meetup = Meetup.find(params[:id])
  @meetups = Meetup.all
  @users = User.all
  @meetups.each do |meetup|
    @users.each do |user|
      if user.id == meetup.creator_id
        @creator = user
      end
      end
    end
    @creator
    erb :'meetups/show'
  end

post '/meetups/:id' do
  user_id = session[:user_id]
  if user_id.nil?
    flash[:notice] = "You have to Log In "
    redirect '/meetups'
  elsif
    user_id = session[:user_id]
    @meetup = UsersMeetup.new(user_id: user_id, meetup_id: params[:meetup_to_join_id])
    if
      user_id == session[:user_id]
      flash[:notice] = "You are already a member of this Meetup #{current_user.username}!"
      redirect '/meetups'
    else
      user_id != session[:user_id]
      @meetup.save
      erb :'meetups/show'
    end
  end
end

# coding: utf-8

class AvatarApp < Sinatra::Base
  configure do
    use Rack::Session::Cookie, :secret => (ENV['RACK_SESSION_SECRET'] || 'change me')
    use Rack::Flash
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    redirect '/avatar'
  end

  get '/avatar' do
    @notice = flash[:notice]
    slim :index
  end

  post '/avatar' do
    unless params[:file]
      flash[:notice] = "Can't detect upload file."
      redirect '/avatar'
    end

    filetype = params[:file][:filename].to_s.split('.').last.downcase
    unless AvatarConfig::FILE_TYPE.include? filetype
      flash[:notice] = "Can't support file format : #{params[:file][:filename]}"
      redirect '/avatar'
    end

    avatar = Avatar.create params[:file]
    unless avatar
      flash[:notice] = "Can't processing your upload file"
      redirect '/avatar'
    end

    redirect "/avatar/info/#{avatar.email}"
  end

  get '/avatar/info/:email' do
    @avatar = Avatar.find_by_email params[:email]
    unless @avatar
      return "not found your avatar."
    end

    slim :upload
  end

  get '/avatar/:hash.?:format?' do
    avatar = Avatar.find params[:hash]

    unless avatar
      # not found
      if AvatarConfig::GRAVATOR_REDIRECT
        redirect "#{AvatarConfig::GRAVATOR_REDIRECT}#{request.path}?#{request.query_string}"
      elsif params[:d]
        redirect params[:d]
      else
        resonse.status = '404'
      end
    end

    type = nil
    if params[:format] && FILE_TYPE.include?(params[:format].to_s.downcase)
      type = params[:format]
    end
    size = nil
    if params[:s] && params[:s] =~ /^\d+$/
      size = params[:s].to_s.to_i
      size = nil  if size <= 0 or size > 2048
    end

    send_file avatar.filepath(size: size, type: type, autoresize: true)
  end

end

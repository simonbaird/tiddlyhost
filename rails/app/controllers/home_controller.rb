class HomeController < ApplicationController

  def index
    if user_signed_in?
      redirect_to sites_path
    end
  end

  def after_registration
    render template: 'devise/registrations/after_registration'
  end

  def donate
  end

  def build_info
    @build_info = {
      'version' => App::VERSION,
      'empties' => Empty.versions,
    }.merge(read_build_info)

    @sha = @build_info['sha']
    @short_sha = @sha[0...9]
  end

  def error_404
    render_error_page(404, 'Not Found')
  end

  def error_422
    render_error_page(422, 'Unprocessable Entity')
  end

  def error_500
    render_error_page(500, 'Internal Server Error')
  end

  private

  def render_error_page(status_code, status_message)
    @status_code = status_code
    @status_message = status_message
    render :error_page, status: status_code, layout: 'simple'
  end

  def read_build_info
    build_info_file = Rails.root.join('public', 'build-info.txt')
    YAML.load(File.read(build_info_file))
  end

end
